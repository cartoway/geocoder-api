Download admin_levl 6 and 8 from as GeoJson from https://osm-boundaries.com

Eg. for France
```
curl --location --max-redirs -1 "https://osm-boundaries.com/Download/Submit?apiKey=a08a557eb440351e00d4b4aa015cfbef&db=osm20230605&osmIds=-2202162&recursive&minAdminLevel=6&maxAdminLevel=8&format=GeoJSON&srid=4326" > admin_level_x.geojson
```

## Convert to SQLite

Convert to Spatialite

```bash
ogr2ogr -sql "SELECT name, '' AS label, admin_level FROM admin_level_x" -f "SQLite" -dsco "SPATIALITE=YES" -nln admin_level_x admin_level_x.sqlite admin_level_x.geojson
```

Extend the admin level 8 names with the admin level 6 names

    echo "
    UPDATE
      admin_level_x
    SET
      label = name || ', ' || (
        SELECT
          name
        FROM
          admin_level_x AS s
        WHERE
          s.admin_level = '6' AND
          ST_Within(ST_Centroid(admin_level_x.Geometry), s.Geometry) AND
          ROWID IN (
            SELECT
              ROWID FROM SpatialIndex
            WHERE
              f_table_name = 'admin_level_x' AND
              search_frame = ST_Centroid(admin_level_x.Geometry))
        LIMIT 1
    )
    WHERE
      admin_level = '8'
    ;" | spatialite admin_level_x.sqlite

Extract the admin level 8 only

    ogr2ogr -select name,label -sql "SELECT * FROM admin_level_x WHERE admin_level='8'" -f "SQLite" -dsco "SPATIALITE=YES" -lco SPATIAL_INDEX=YES -nln poly admin_level_8.sqlite admin_level_x.sqlite


## Request a point

    SELECT
        name,
        label
    FROM
        poly
    WHERE
        st_within(GeomFromText('POINT(6.1390 49.6139)'), Geometry) AND
        ROWID IN (SELECT ROWID FROM SpatialIndex WHERE f_table_name = 'poly' AND search_frame = GeomFromText('POINT(6.1390 49.6139)'))
    ;
