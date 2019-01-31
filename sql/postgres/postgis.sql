-- PostGIS notes

--- Enabling PostGIS within a database
CREATE EXTENSION postgis;

--- Veryfing version of PostGIS and GEO, GDAL, PROJ, LIBXML and LIBJSON libraries
SELECT postgis_full_version();

/*
wget --progress=dot:mega -O "highway_isla.osm" "http://www.overpass-api.de/api/xapi?way["highway"=*][bbox=37.08,-7.48,37.33,-7.13][@meta]"

osm2pgsql -d isla -H localhost -U postgres -S default.style --hstore highway_isla.osm

--- OSM default style file
https://github.com/openstreetmap/osm2pgsql/blob/master/default.style
*/