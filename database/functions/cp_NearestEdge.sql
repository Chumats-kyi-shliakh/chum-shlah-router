CREATE OR REPLACE FUNCTION cp_NearestEdge(IN lng NUMERIC, IN lat NUMERIC) RETURNS BIGINT  
AS $BODY$
BEGIN 
  RETURN id
  FROM ways
  ORDER BY the_geom::geography <-> ST_SetSRID(
      ST_Point(lng, lat),
      4326
    )::geography
  LIMIT 1;
END $BODY$ LANGUAGE 'plpgsql';


-- select cp_NearestEdge(28.66468004491071, 50.26009144660287);