CREATE OR REPLACE FUNCTION cp_TCProute(
  IN lng NUMERIC, IN lat NUMERIC,
  IN storage_id INT[],
  IN order_id UUID[]
  )
    RETURNS JSONB
    LANGUAGE 'plpgsql'
    VOLATILE PARALLEL SAFE
AS $BODY$ 
DECLARE
nearest_storage_node int; 
nearest_order_node int;
customers_orders_id UUID[];
storage_sort int[];
order_sort int[];
bbox geometry;
res jsonb;
BEGIN
customers_orders_id := (
SELECT array_agg(id)
FROM public.customer_orders
WHERE customer_id = ANY(order_id)
);

    IF customers_orders_id IS NULL THEN
        RAISE EXCEPTION 'No public.customer_orders match' ;
    END IF;
bbox := (
    WITH bbox_geom AS(
    SELECT
        geom
    FROM storages
    WHERE id  = ANY(storage_id)
        UNION
    SELECT
        geom
    FROM customer_orders
    WHERE id = ANY(customers_orders_id)    
    )
  SELECT ST_Expand(
             ST_Transform(
                 ST_Envelope(
                     ST_Collect(
                      geom              
                      )
                    )
                 ,5558)
            , 50000)
    FROM bbox_geom
);
RAISE NOTICE 'bbox - %', ST_AsEwkt(bbox);

nearest_storage_node := (SELECT cp_NearestNode(geom)
                       FROM storages
                       WHERE id  = ANY(storage_id)
                       ORDER BY geom::geography <->
                                (SELECT cp_PointWGS(lng, lat))::geography
                       LIMIT 1
                      );
RAISE NOTICE 'Nearest_storage_id - %', nearest_storage_node;

CREATE TEMPORARY TABLE matrix_storages ON COMMIT DROP AS 
   SELECT * FROM pgr_dijkstraCostMatrix(
        'SELECT
              id
            , source
            , target
            , cost_s * priority AS cost
            , reverse_cost_s * priority AS reverse_cost
        FROM ways
        LEFT JOIN ways_configuration
        USING (tag_id)
        WHERE 
        '''|| bbox::text ||'''::geometry
         && ST_Transform(the_geom, 5558)',
        (
        SELECT array_agg(cp_NearestNode(geom)) 
        FROM storages
        WHERE id = ANY(storage_id)
        ),
        directed => false);

storage_sort := (
       SELECT array_agg(DISTINCT node) FROM pgr_TSP(
      'SELECT * FROM matrix_storages',
      start_id => nearest_storage_node));
RAISE NOTICE 'storage_sort - %', storage_sort;

nearest_order_node := (SELECT cp_NearestNode(geom)
                       FROM customer_orders
                       WHERE id = ANY(customers_orders_id)  
                       ORDER BY geom::geography <->
                                (SELECT the_geom 
                                 FROM ways_vertices_pgr
                                 WHERE id = order_sort[-1]
                                )::geography
                       LIMIT 1
                      );
RAISE NOTICE 'nearest_order_node - %', nearest_order_node;


CREATE TEMPORARY TABLE matrix_orders ON COMMIT DROP AS 
   SELECT * FROM pgr_dijkstraCostMatrix(
        'SELECT
              id
            , source
            , target
            , cost_s * priority AS cost
            , reverse_cost_s * priority AS reverse_cost
        FROM ways
        LEFT JOIN ways_configuration
        USING (tag_id)
        WHERE 
        '''|| bbox::text ||'''::geometry
         && ST_Transform(the_geom, 5558)',
        (
        SELECT array_agg(cp_NearestNode(geom)) 
        FROM customer_orders
        WHERE id = ANY(customers_orders_id)
        ),
        directed => false);

order_sort := (
       SELECT  array_agg(DISTINCT node) FROM pgr_TSP(
      'SELECT * FROM matrix_orders'
        , start_id => nearest_order_node
       ));
RAISE NOTICE 'order_sort - %', order_sort;     


res := (
WITH route AS (
    SELECT             
         path_id
        , start_vid
        , end_vid
        , cost_s
        , length_m
        , CASE
              WHEN node = source THEN ST_AsText(the_geom)
              ELSE ST_AsText(ST_Reverse(the_geom))
          END AS route_readable,

          CASE
              WHEN node = source THEN the_geom
              ELSE ST_Reverse(the_geom)
          END AS route_geom
    FROM pgr_dijkstraVia(
          'SELECT
              id
            , source
            , target
            , cost_s * priority AS cost
            , reverse_cost_s * priority AS reverse_cost
        FROM ways
        LEFT JOIN ways_configuration
        USING (tag_id)
        WHERE 
        '''|| bbox::text ||'''::geometry
         && ST_Transform(the_geom, 5558)',
         storage_sort || order_sort)
         left join ways on edge = id
        ),
        agg_route AS (
        SELECT 
            path_id
            , start_vid 
            , end_vid
            , floor(sum(cost_s)) AS duration_s
            , floor(sum(length_m)) AS distance_m
            , ST_LineMerge(ST_Union(route_geom)) AS geom
        FROM route

        group by path_id, start_vid, end_vid
        )
        SELECT jsonb_build_object(
        'type', 'FeatureCollection',
        'features', jsonb_agg(ST_AsGeoJSON(t.*)::jsonb)
        )
        FROM agg_route t);
        
RETURN res;
END;
$BODY$;


SELECT cp_TCProute (  28.66468
                , 50.26009
                , ARRAY[4378, 3914, 4008]
                , ARRAY['f1bb12f0-8e39-4846-a532-e7c2aaf1731a', 'c920831a-ef35-4d54-8587-765cca60832f',
                             '543870d0-3609-4e0d-a346-797cc1c814ae', 'c3834b6f-8330-4327-8de8-f98b8f3ac04f']::uuid[])


