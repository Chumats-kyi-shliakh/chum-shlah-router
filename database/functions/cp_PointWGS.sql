CREATE OR REPLACE FUNCTION cp_PointWGS(
          IN lng NUMERIC
        , IN lat NUMERIC
        , OUT point geometry
    )
    AS $BODY$
      SELECT ST_SetSRID(
        ST_Point(
            lng
          , lat
          )
          , 4326
        )::geometry

    $BODY$
    LANGUAGE 'sql';