CREATE OR REPLACE FUNCTION cp_ExtendedBbox(
     IN p1 geometry
   , IN p2 geometry
   , IN units_to_expand INT
   , OUT bbox geometry)   
AS $BODY$
  SELECT ST_Expand(
             ST_Transform(
                 ST_Envelope(
                     ST_Collect(
                        p1
                      , p2              
                      )
                    )  
                 ,5558)
            , units_to_expand);
$BODY$ LANGUAGE 'sql';


