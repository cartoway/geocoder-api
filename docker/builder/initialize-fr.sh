#!/bin/bash
DEP=${1}

set -e

echo "Your variables are : DEPARTMENT: $DEP"

if [ -z ${DEP} ]; then
  BANO="https://bano.openstreetmap.fr/data/full.sjson.gz"
else
  BANO="https://bano.openstreetmap.fr/data/bano-${DEP}.json.gz"
fi
cd docker
mkdir -p addresses-fr
curl "$BANO" > "./addresses-fr/bano.sjson.gz"

docker-compose exec redis-addok-fr redis-cli FLUSHALL

docker-compose run --rm addok-fr bash -c "\\
  zcat /addresses/bano.sjson.gz | \\
  jq -c 'def mapping: {\"city\":\"municipality\",\"town\":\"municipality\",\"village\":\"municipality\",\"place\":\"locality\",\"street\":\"street\"}; . + {type: mapping[.type]}' | \\
  jq -c 'del(.housenumbers[]?.id)' | \\
  addok batch"

# # Patch BANO
# docker-compose run --rm --entrypoint /bin/bash addok-fr -c "ls ./addresses/*.json | xargs cat | addok batch"

docker-compose run --rm addok-fr addok ngrams
docker-compose exec redis-addok-fr redis-cli BGSAVE
