#!/bin/bash
set -e
PROV=${1}

cd docker
mkdir -p ./addresses-es/
cd addresses-es

declare -A provs
provs["GUADALAJARA"]="9082"
provs["TOLEDO"]="9083"
provs["ALMERIA"]="9084"
provs["CANTABRIA"]="9085"
provs["LUGO"]="9086"
provs["GRANADA"]="9087"
provs["CASTELLON"]="9088"
provs["BURGOS"]="9089"
provs["CACERES"]="9090"
provs["CORDOBA"]="9091"
provs["TARRAGONA"]="9092"
provs["MURCIA"]="9093"
provs["MELILLA"]="9094"
provs["BARCELONA"]="9095"
provs["OURENSE"]="9096"
provs["SEVILLA"]="9097"
provs["SALAMANCA"]="9098"
provs["CEUTA"]="9099"
provs["CADIZ"]="9100"
provs["HUESCA"]="9101"
provs["CUENCA"]="9102"
provs["PALENCIA"]="9103"
provs["LA_RIOJA"]="9104"
provs["TERUEL"]="9105"
provs["ALICANTE"]="9106"
provs["ALBACETE"]="9107"
provs["MADRID"]="9108"
provs["A_CORUNA"]="9109"
provs["AVILA"]="9110"
provs["BADAJOZ"]="9111"
provs["HUELVA"]="9112"
provs["LAS_PALMAS"]="9113"
provs["ZARAGOZA"]="9114"
provs["GIRONA"]="9115"
provs["TENERIFE"]="9116"
provs["CIUDAD_REAL"]="9117"
provs["VALLADOLID"]="9118"
provs["SEGOVIA"]="9119"
provs["LLEIDA"]="9120"
provs["BALEARES"]="9121"
provs["MALAGA"]="9122"
provs["ZAMORA"]="9123"
provs["SORIA"]="9124"
provs["ASTURIAS"]="9125"
provs["LEON"]="9126"
provs["PONTEVEDRA"]="9127"
provs["JAEN"]="9128"
provs["VALENCIA"]="9129"
provs["ALAVA"]="42602"
provs["GUIPUZCOA"]="42603"
provs["VIZCAYA"]="42604"
provs["NAVARRA"]="42605"

if [ -z ${PROV} ]; then
    provs_load="${!provs[@]}"
else
    provs_load=$PROV
fi


rm addresses.json && touch addresses.json
for prov in $provs_load; do
    echo $prov
    magic=${provs[$prov]}

    # CartoCiudad
    curl 'https://centrodedescargas.cnig.es/CentroDescargas/descargaDir' -X POST -H 'Content-Type: application/x-www-form-urlencoded' --data-raw "secuencialDescDir=${magic}&aceptCodsLicsDD_0=15" > CARTOCIUDAD_CALLEJERO_${prov}.zip

    ogr2ogr \
        -t_srs 'EPSG:4326' \
        -lco GEOMETRY=AS_XY \
        CARTOCIUDAD_CALLEJERO_${prov}.0.csv \
        -dialect sqlite -sql "select ID_TRAMO AS id, TIPO_VIAL AS street_type, NOMBRE_VIA AS street_name, NUMERO AS number, EXTENSION AS ext, POBLACION AS city, COD_POSTAL AS postcode, geometry FROM PORTAL_PK WHERE TIPOPORPKD = 'Portal'" \
        /vsizip/CARTOCIUDAD_CALLEJERO_${prov}.zip/CARTOCIUDAD_CALLEJERO_${prov}/PORTAL_PK.shp

    # Fix invalid chars
    iconv -f UTF-8 -t UTF-8//IGNORE CARTOCIUDAD_CALLEJERO_${prov}.0.csv > CARTOCIUDAD_CALLEJERO_${prov}.1.csv
    ruby ../builder/initializer-es.rb < CARTOCIUDAD_CALLEJERO_${prov}.1.csv > CARTOCIUDAD_CALLEJERO_${prov}.2.csv
    ruby ../builder/initializer-es-json.rb < CARTOCIUDAD_CALLEJERO_${prov}.2.csv > CARTOCIUDAD_CALLEJERO_${prov}.json

    # importance - log interpolation of streets number by city
    jq -s -c 'group_by(.city) |
        map({
            citycode: .[0].citycode,
            name: .[0].city,
            postcode: map(.postcode) | unique,
            lat: map(.lat) | add,
            lon: map(.lon) | add,
            size: length
        }) |
        map({
            citycode: .citycode,
            type: "municipality",
            name: .name,
            city: (.name | split("/")),
            postcode: .postcode,
            lat: (.lat / .size),
            lon: (.lon / .size),
            importance: [1, ( ( (((.size+100)/100)*(2.71)) | log) / (100 | log) )] | min
        }) | .[]' \
    CARTOCIUDAD_CALLEJERO_${prov}.json > CARTOCIUDAD_CALLEJERO_${prov}-cities.json

    cat CARTOCIUDAD_CALLEJERO_${prov}-cities.json CARTOCIUDAD_CALLEJERO_${prov}.json >> addresses.json
done

cd ../..

docker-compose exec redis-addok-es redis-cli FLUSHALL

docker-compose run --rm addok-es \
  addok batch /addresses/addresses.json

docker-compose run --rm addok-es addok ngrams
docker-compose exec redis-addok-es redis-cli BGSAVE
