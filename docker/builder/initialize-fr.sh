#!/bin/bash
DEP=${1}

set -e

echo "Your variables are : DEPARTMENT: $DEP"

if [ -z ${DEP} ]; then
  BANO="https://bano.openstreetmap.fr/data/full.sjson.gz"
else
  BANO="https://bano.openstreetmap.fr/data/bano-${DEP}.json.gz"
fi
mkdir -p docker/addresses-fr
curl "$BANO" > "./docker/addresses-fr/bano.sjson.gz"

cd ..

docker-compose exec redis-addok-fr redis-cli FLUSHALL

docker-compose run --rm addok-fr bash -c "\\
  # Compute all possible postcodes for city
  # https://github.com/osm-fr/bano/issues/369
  zcat /addresses/bano.sjson.gz | tr -d \"\\t\" | jq -c 'select(.type==\"city\" or .type==\"town\" or .type==\"village\")' | jq --slurp 'map({(.id): .}) | add' > /addresses/city-orig.json
  zcat /addresses/bano.sjson.gz | tr -d \"\\t\" | jq -c '. | {id: (.citycode // .id), postcode: .postcode}' | uniq | jq --slurp 'group_by(.id)| map({(.[0].id): {postcode: [.[].postcode] | flatten | unique}}) | add' > /addresses/city-postcode.json
  jq --slurp -c '.[0] * .[1] | .[]' /addresses/city-orig.json /addresses/city-postcode.json | gzip > /addresses/city-multi.sjson.gz
  rm /addresses/city-orig.json /addresses/city-postcode.json

  # Duplicate entry, one for each postcode
  # https://github.com/addok/addok/issues/811
  zcat /addresses/city-multi.sjson.gz | jq  '. + {postcode: .postcode[]}' | gzip > /addresses/city.sjson.gz

  zcat /addresses/city.sjson.gz | \\
  tr -d \"\\t\" | \\
  jq -c '. | select(.type==\"city\" or .type==\"town\" or .type==\"village\") | . + {citycode: (.citycode // .id) }' | \\
  jq -c 'def mapping: {\"city\":\"municipality\",\"town\":\"municipality\",\"village\":\"municipality\",\"place\":\"locality\",\"street\":\"street\"}; . + {type: mapping[.type]}' | \\
  addok batch"

# Bano contents invalid JSON, it is why we need tr -d \"\\t\"
# https://github.com/osm-fr/bano/issues/367
docker-compose run --rm addok-fr bash -c "\\
  zcat /addresses/bano.sjson.gz | \\
  tr -d \"\\t\" | \\
  jq -c '. | select(.type==\"place\" or .type==\"street\") | . + {citycode: (.citycode // .id) }' | \\
  jq -c 'def mapping: {\"city\":\"municipality\",\"town\":\"municipality\",\"village\":\"municipality\",\"place\":\"locality\",\"street\":\"street\"}; . + {type: mapping[.type]}' | \\
  jq -c 'del(.housenumbers[]?.id)' | \\
  addok batch"

# # Patch BANO
docker-compose run --rm --entrypoint /bin/bash addok-fr -c "ls ./addresses/*.*json | xargs cat | addok batch"

docker-compose run --rm addok-fr addok ngrams
docker-compose exec redis-addok-fr redis-cli BGSAVE
