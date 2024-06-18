#!/bin/bash

set -e

mkdir -p ./docker/addresses-lu/
wget https://download.data.public.lu/resources/adresses-georeferencees-bd-adresses/20230925-043222/addresses.geojson -O ./docker/addresses-lu/addresses.geojson

jq -c '.features |
map(.properties + {lon: .geometry.coordinates[0], lat: .geometry.coordinates[1]}) |
group_by(.code_postal, .localite, .id_caclr_rue, .rue) |
map({name: .[0].rue, city: .[0].localite, postcode: .[0].code_postal, housenumbers: map({(.numero): {lat: .lat, lon: .lon}}) | add }) |
.[] |
{type: "street", city: .city, name: .name, postcode: .postcode, lat: ((.housenumbers | map(.lat) | add) / (.housenumbers | length)), lon: ((.housenumbers | map(.lon) | add) / (.housenumbers | length)), importance: 0.2, housenumbers: .housenumbers} |
del(.housenumbers."")' ./docker/addresses-lu/addresses.geojson > ./docker/addresses-lu/streets.json

jq -s -c 'group_by(.city) |
map({name: .[0].city, postcode: map(.postcode) |
unique, lat: map(.lat) |
add, lon: map(.lon) |
add, size: length}) |
map({type: "municipality", name: .name, city: .name, postcode: .postcode, lat: (.lat / .size), lon: (.lon / .size), importance: [1, .size / 20 + 0.2] | min}) |
.[]' ./docker/addresses-lu/streets.json > ./docker/addresses-lu/cities.json

cat ./docker/addresses-lu/cities.json ./docker/addresses-lu/streets.json > ./docker/addresses-lu/addresses.json

docker compose exec redis-addok-lu redis-cli FLUSHALL

docker compose run --rm addok-lu \
  addok batch /addresses/addresses.json

docker compose run --rm addok-lu addok ngrams
docker compose exec redis-addok-lu redis-cli BGSAVE
