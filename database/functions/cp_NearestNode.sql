CREATE OR REPLACE FUNCTION cp_NearestNode(IN point geometry) RETURNS BIGINT  
AS $BODY$
BEGIN 
  RETURN id
  FROM ways_vertices_pgr
  ORDER BY the_geom::geography <-> point::geography
  LIMIT 1;
END $BODY$ LANGUAGE 'plpgsql';
