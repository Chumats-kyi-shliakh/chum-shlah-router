INSERT INTO funds (name, tg_bot_key, created_at, updated_at)
SELECT DISTINCT ON (name)
      tags ->> 'name' AS name
    , random() * 10000 AS tg_bot_key
    , now() as created_at
    , now() as updated_at
FROM public.polygons
WHERE 
        tags ->> 'name' IS NOT NULL 
    AND tags ->> 'shop' = 'mall'
    ;


INSERT INTO storages (
      fund_id
    , name
    , geom
    , city
    , street
    , postal_code
    , country
    , house_number
    , created_at
    , updated_at)
SELECT  DISTINCT ON (name)
      funds.id as fund_id
    , tags ->> 'name' AS name
    , ST_Centroid(geom) AS geom
    , tags ->> 'addr:city' AS city
    , tags ->> 'addr:street' AS street
    , tags ->> 'addr:postcod' AS postal_code
    , tags ->> 'addr:country' AS country
    , tags ->> 'addr:housenumber' AS house_number
    , now() as created_at
    , now() as updated_at
FROM public.polygons
LEFT JOIN public.funds ON funds.name = tags ->> 'name' 
WHERE 
        tags ->> 'name' IS NOT NULL 
    AND tags ->> 'shop' = 'mall'
    order by name
    ;
    
INSERT INTO categories (name, created_at, updated_at) 
    VALUES 
      ('Медикаменти', now(), now())
    , ('Спорядження', now(), now())
    , ('Прдукти харчування', now(), now())
    ;
    
SELECT * FROM public.categories
 
INSERT INTO products (
      category_id
    , name
    , weight
    , height
    , width
    , length
    , created_at
    , updated_at
    ) 
VALUES ('942386a0-8fad-4dd7-91a6-0c568daaa5ec'::UUID
        ,'Бинт ееластичний'
        , floor(random() * 10)
        , floor(random() * 10)
        , floor(random() * 10)
        , floor(random() * 10)
        , now()
        , now()
       ),
       ('942386a0-8fad-4dd7-91a6-0c568daaa5ec'::UUID
        ,'Фізрозччин'
        , floor(random() * 10)
        , floor(random() * 10)
        , floor(random() * 10)
        , floor(random() * 10)
        , now()
        , now()
       ),
       ('0303df44-25d9-45af-a31d-2babe4571a7e'::UUID
        ,'Мотопомпа'
        , floor(random() * 10)
        , floor(random() * 10)
        , floor(random() * 10)
        , floor(random() * 10)
        , now()
        , now()
       ),
       ('0303df44-25d9-45af-a31d-2babe4571a7e'::UUID
        ,'Ігрова приставка PS5 PlayStation 5'
        , floor(random() * 10)
        , floor(random() * 10)
        , floor(random() * 10)
        , floor(random() * 10)
        , now()
        , now()
       ),
       ('517d0d1c-8f00-4477-afd2-818f797308d5'::UUID
        ,'Галети'
        , floor(random() * 10)
        , floor(random() * 10)
        , floor(random() * 10)
        , floor(random() * 10)
        , now()
        , now()
       );

DO $$
BEGIN
    FOR i IN 1..(SELECT COUNT(id) * 2 FROM storages)
    LOOP
        INSERT INTO public.product_availabilities 
        (storage_id
         , product_id
         , quantity
         , created_at
         , updated_at)
        SELECT 
              storages.id AS storage_id
            , prod.id AS product_id
            , floor( random() * 50) AS quantity
            , now() AS created_at
            , now() AS updated_at
        FROM storages
        CROSS JOIN (
            SELECT products.id 
            FROM products 
            OFFSET floor(
                random() * (
                    SELECT COUNT(id)
                    FROM products
                    )
                ) 
            LIMIT 1) prod
        OFFSET floor(
            random() * (
                SELECT COUNT(id) 
                FROM storages
                )
            ) 
        LIMIT 1
            ON CONFLICT DO NOTHING;
    END LOOP;
END$$;


INSERT INTO drivers ( login
                     , encrypted_password 
                     , last_online
                     , created_at
                     , updated_at
                    ) VALUES
      ('test_driver_1', crypt('test_driver_1_password'
    , gen_salt('bf')), now(), now(), now())
    , ('test_driver_2', crypt('test_driver_2_password'
    , gen_salt('bf')), now(), now(), now())
    ;
    
INSERT INTO customers (name, created_at, updated_at)
SELECT distinct on (name)
     tags ->> 'name' AS name
     , now() AS created_at
     , now() AS updated_at
FROM public.polygons
WHERE 
        tags ->> 'name' IS NOT NULL 
   AND (tags ->> 'amenity' in ('townhall', 'government')
    OR tags ->> 'office' = 'government'
    OR tags ->> 'building' = 'government')
    ;


DO $$
BEGIN
    FOR i IN 1..(SELECT COUNT(id) * 2 FROM storages)
    LOOP
        INSERT INTO public.carts 
        (storage_id
         , product_id
         , quantity
         , created_at
         , updated_at)
        SELECT 
              storages.id AS storage_id
            , prod.id AS product_id
            , floor( random() * 50) AS quantity
            , now() AS created_at
            , now() AS updated_at
        FROM storages
        CROSS JOIN (
            SELECT products.id 
            FROM products 
            OFFSET floor(
                random() * (
                    SELECT COUNT(id)
                    FROM products
                    )
                ) 
            LIMIT 1) prod
        OFFSET floor(
            random() * (
                SELECT COUNT(id) 
                FROM storages
                )
            ) 
        LIMIT 1
            ON CONFLICT DO NOTHING;
    END LOOP;
END$$;



DO $$
BEGIN
    FOR i IN 1..(SELECT COUNT(id) * 2 FROM customers)
    LOOP
        INSERT INTO public.carts 
        (
           customer_id
         , created_at
         , updated_at)
        SELECT 
             customers.id AS customer_id
            , now() AS created_at
            , now() AS updated_at
        FROM customers
        OFFSET floor(
            random() * (
                SELECT COUNT(id) 
                FROM customers
                )
            ) 
        LIMIT 1
            ON CONFLICT DO NOTHING;
    END LOOP;
END$$;


DO $$
BEGIN
    FOR i IN 1..(SELECT COUNT(id) * 2 FROM carts)
    LOOP
        INSERT INTO public.cart_items 
        (
           cart_id
         , product_id
         , quantity
         , created_at
         , updated_at)
        SELECT 
             carts.id AS cart_id
            , prod.id AS product_id
            , floor( random() * 10) AS quantit
            , now() AS created_at
            , now() AS updated_at
        FROM public.carts
        CROSS JOIN (
            SELECT products.id 
            FROM products 
            OFFSET floor(
                random() * (
                    SELECT COUNT(id)
                    FROM products
                    )
                ) 
            LIMIT 1) prod
        OFFSET floor(
            random() * (
                SELECT COUNT(id) 
                FROM customers
                )
            ) 
        LIMIT 1
            ON CONFLICT DO NOTHING;
    END LOOP;
END$$;

INSERT INTO public.customer_orders
        (
           customer_id
         , cart_id
         , geom
         , created_at
         , updated_at)
        SELECT distinct on (tags ->> 'name')
         customer_id
        , carts.id as cart_id
        , ST_Centroid(geom)
        , now() as created_at
        , now()  as updated_at
        FROM public.carts
        left join public.customers on customer_id = customers.id
        left join public.polygons on customers.name = tags ->> 'name'
