
CREATE OR REPLACE FUNCTION cp_GetNerestOrders(
  IN lng NUMERIC, IN lat NUMERIC
)
    RETURNS SETOF jsonb
    LANGUAGE 'plpgsql'
    STABLE PARALLEL SAFE
AS $BODY$ 
BEGIN
RETURN QUERY 
WITH stock_in_stores AS (
--     get nn stores for driver
        SELECT
              s.id AS storage_id
            , s.fund_id
            , s.geom
            , name
            , adress
            , pa.product_id
            , pa.quantity
            , dist_m
        FROM 
    (
        SELECT 
              id 
            , fund_id
            , name
            , city || ', ' || street || ', ' || house_number AS adress
            , geom
            , geom::geography
              <-> cp_PointWGS(28.66468, 50.26009)::geography AS dist_m
        FROM public.storages
        ORDER BY dist_m
        OFFSET 0
        LIMIT 10) s
        LEFT JOIN public.product_availabilities pa
        ON s.id = pa.storage_id
        WHERE quantity > 0
    ),
    item_in_oreder AS (
        SELECT 
              customers.id AS order_id
            , co.geom
            , product_id
            , quantity
            , city || ', ' || street || ', ' || house_number AS adress
        FROM public.customers 
        LEFT JOIN public.customer_orders co ON customers.id = co.customer_id
        LEFT JOIN public.carts c ON co.cart_id = c.id
        LEFT JOIN public.cart_items ci ON c.id = ci.cart_id
    ),
    nn_join AS (
--     get nn pois for stores
    SELECT 
             io.order_id
           , io.geom
            ,io.adress
           , sum(io.quantity)
           , array_agg(io.dist_m) AS dist_m
           , array_agg(storage_id) as store_id
       FROM stock_in_stores s 
       CROSS JOIN LATERAL(
       SELECT   
             order_id
           , geom
           , product_id
           , quantity
           , adress
           , s.geom::geography <-> i.geom::geography AS dist_m
       FROM item_in_oreder i
       WHERE i.product_id = s.product_id AND s.quantity > 0
       ORDER BY dist_m
       LIMIT 3
       ) io
        GROUP BY
             io.order_id
           , io.geom
           , io.product_id
        , io.quantity , io.adress

    ),
    add_temp as (SELECT DISTINCT              
              storage_id
            , fund_id
            , geom
            , name
            , adress
            , dist_m
             FROM stock_in_stores

                )
    SELECT
         jsonb_build_object(
         'customer_orders', (SELECT jsonb_build_object(
                            'type', 'FeatureCollection',
                            'features', json_agg(ST_AsGeoJSON(t.*)::jsonb))
                            FROM nn_join t),
         'storages',        (SELECT jsonb_build_object(
                            'type', 'FeatureCollection',
                            'features', json_agg(ST_AsGeoJSON(t2.*)::jsonb))
                            FROM add_temp t2)
                            )
    ;

END;
$BODY$;


SELECT cp_GetNerestOrders(28.66468, 50.26009)
