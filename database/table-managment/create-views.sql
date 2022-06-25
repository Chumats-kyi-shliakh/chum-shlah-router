CREATE VIEW cur_stock AS 
WITH agg_items AS (
SELECT 
      store_id
    , product_id
    , sum(quantity) AS sum_quantity
FROM public.delivery_items
WHERE is_outdated !=true OR is_complete !=true
GROUP BY store_id, product_id
)
SELECT
      s.store_id
    , s.product_id
    , s.quantity - COALESCE(sum_quantity, 0) AS cur_quantity
FROM public.stocks s
LEFT JOIN agg_items USING (store_id, product_id)
WHERE s.quantity - COALESCE(sum_quantity, 0) > 0