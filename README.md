# Geocoder API
Offers an unified API for multiple geocoders like [Addok](https://github.com/etalab/addok), OpenCageData, Here, Google based on countries distribution. The main idea of this API is to define some specific geocoder for some countries and a fallback geocoder for all other countries.
Build in Ruby with a [Grape](https://github.com/intridea/grape) REST [swagger](http://swagger.io/) API compatible with [geocodejson-spec](https://github.com/yohanboniface/geocodejson-spec). Internaly also use [Geocoder Gem](https://github.com/alexreisner/geocoder).

## API

The API is defined in Swagger format at
http://localhost:8081/0.1/swagger_doc
and can be tested with Swagger-UI
https://petstore.swagger.io/?url=http://localhost:8081/0.1/swagger_doc

### Geocoding and Address completion
The search can be done by full text free form or by fields. Prefer fields form when you have an already split address. For any form, the country is a required field, use a simple country name or code in two or three chars.

Search can be guided by proximity. Set latitude and longitude of an close location.

### Reverse geocoding
Retrieve the closest address from latitude and longitude position by GET request.

### Unitary request
Unitary requesting convert only one address or coordinates at once using GET request.

Geocoding:

```
http://localhost:8081/0.1/geocode.json?&api_key=demo&country=fr&query=2+Avenue+Pierre+Angot+64000+Pau
```

Returns GeocodeJSON (and GeoJSON) valid result:
```json
{
  "type":"FeatureCollection",
  "geocoding":{
    "version":"draft",
    "licence":"ODbL",
    "attribution":"BANO",
    "query":"2 Avenue Pierre Angot 64000 Pau"
  },
  "features":[
    {
      "properties":{
        "geocoding":{
          "score":0.7223744186046511,
          "type":"house",
          "label":"2 Avenue du Président Pierre Angot 64000 Pau",
          "name":"2 Avenue du Président Pierre Angot",
          "housenumber":"2",
          "postcode":"64000",
          "city":"Pau"
        }
      },
      "type":"Feature",
      "geometry":{
        "coordinates":[
          -0.367199,
          43.319972
        ],
        "type":"Point"
      }
    }
  ]
}
```

Reverse:
```
http://localhost:8081/0.1/reverse.json?api_key=demo&lat=44&lng=0
```

```json
{
  "type": "FeatureCollection",
  "geocoding": {
    "version": "draft",
    "licence": "ODbL",
    "attribution": "BANO"
  },
  "features": [
    {
      "properties": {
        "geocoding": {
          "score": 0.9999613672785329,
          "type": "house",
          "label": "1905 Chemin de la Lanne 40310 Gabarret",
          "name": "1905 Chemin de la Lanne",
          "housenumber": "1905",
          "postcode": "40310",
          "city": "Gabarret"
        }
      },
      "type": "Feature",
      "geometry": {
        "coordinates": [
          0.001275,
          44.002642
        ],
        "type": "Point"
      }
    }
  ]
}
```

### Batch request
Batch convert a list in JSON or CSV format using POST request.

```
curl -v -X POST -H "Content-Type: text/csv" --data-binary @in.csv http://localhost:8081/0.1/geocode.csv?api_key=demo > out.csv
```

## Examples

### Geocode
[Geocode full text address](http://localhost:8081/geocode.html)

### Reverse geocode
[Get address from lat/lng](http://localhost:8081/reverse.html)

## Docker

Copy and adjust environments files.
```bash
cp ./config/environments/production.rb ./docker/
cp ./config/access.rb ./docker/
```

Create a `.env` from `.env.template`, and adapt if required.
Enable components in `COMPOSE_FILE` var. Only required for non external engines.

Build docker images
```
docker compose build
```

Launch containers
```
docker compose up -d
```

The countries data `sanitizer/countryInfo.txt` for supported languages can be update from https://download.geonames.org/export/dump/countryInfo.txt . The data is under creative commons attributions from GeoNames.

### Addok Initialization
After the first start, you need to initialize Addok database.

Run the initialization script:
```
./docker/builder/initialize-es.sh [PROV NAME]
./docker/builder/initialize-fr.sh [DEP NUMBER]
./docker/builder/initialize-lu.sh
```

```
# Download and build French KML boundaries
(cd contrib && sh ./osm2france+dom-geojson.sh)
```

## Without Docker
You need to install prerequisite packages:
```
apt-get install -y git build-essential zlib1g-dev gdal-bin zlib1g libsqlite3-mod-spatialite libsqlite3-dev libspatialite-dev
```

If you need to create a KML, Install package containing `ogr2ogr` bin as system package (GDAL).

In geocoder-api as root directory:
```
bundle install
```

## Dev / Tests
```
bundler exec puma -v -p 8081 --pidfile 'tmp/server.pid'
```
Access it at http://localhost:8081
