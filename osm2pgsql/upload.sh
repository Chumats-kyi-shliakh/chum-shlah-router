osm2pgsql --slim --drop --output=flex --style=./osm2pgsql/_routes.lua \
  -H 0.0.0.0 -P 5433 -d postgres -U postgres \
  -W ./osm2pgsql/ukraine-latest.osm.pbf