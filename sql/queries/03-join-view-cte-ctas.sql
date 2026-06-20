-- INNER JOIN
SELECT *
FROM orders AS o 
    JOIN order_items AS oi 
    ON o.order_id = oi.order_item_order_id 


-- OUTER JOIN
SELECT *
FROM orders AS o 
    LEFT JOIN order_items AS oi 
    ON o.order_id = oi.order_item_order_id 


-- Filter and Agg on Join
SELECT o.order_date, oi.order_item_product_id,
    SUM(oi.order_item_subtotal)
FROM orders AS o 
    JOIN order_items AS oi 
    ON o.order_id = oi.order_item_order_id 
GROUP BY 1, 2 
WHERE o.order_status IN ('COMPLETE' , 'CLOSED')

-- you can do monthly order by using changing format of o.order_date:
to_char(o.order_date::timestamp, 'yyyy-MM') AS order_month 



-- VIEW 
CREATE VIEW order_detail_v AS 
SELECT o.*, oi.order_item_product_id, oi.order_item_subtotal 
FROM orders AS o 
    JOIN order_items AS oi 
    ON o.order_id = oi.order_item_order_id  

SELECT * FROM order_detail_v

-- if you want to replace exsited VIEW:
CREATE OR REPLACE VIEW



-- CTE
WITH order_detail_cte AS 
(
SELECT o.*, oi.order_item_product_id, oi.order_item_subtotal 
FROM orders AS o 
    JOIN order_items AS oi 
    ON o.order_id = oi.order_item_order_id  
)
SELECT * FROM order_detail_cte;



-- Example of incorrect query thing if NULL
-- output will be nothing
-- because  JOIN  if no match = NULL หมด
SELECT * 
FROM products AS p 
    LEFT OUTER JOIN order_detail_v AS odv 
    ON p.product_id = odv.product_id 
WHERE odv.product_id IS NULL 
    AND to_char(odv.order_date::timestamp, 'yyyy-MM') = '2014-01'

-- Correct version
SELECT * 
FROM products AS p 
WHERE NOT EXISTS (
    SELECT 1 FROM order_detail_v
    WHERE p.product_id  = odv.product_id
    AND to_char(odv.order_date::timestamp, 'yyyy-MM') = '2014-01'
)
-- anoter correct version
SELECT * 
FROM products AS p 
    LEFT OUTER JOIN order_detail_v AS odv 
    ON p.product_id = odv.product_id 
    AND to_char(odv.order_date::timestamp, 'yyyy-MM') = '2014-01'
WHERE  odv.product_id IS NULL



-- CTAS
CREATE TABLE daily_revenue
AS 
SELECT  o.order_date,
    round(sum(oi.order_item_subtotal)::numeric, 2) AS order_revenue 
FROM orders AS o 
    JOIN order_items AS oi 
    ON o.order_id = oi.order_item_order_id
WHERE o.order_status IN ('COMPLETE', 'CLOSED')
GROUP BY 1; 

-- select from ctas
SELECT * FROM daily_revenue
ORDER BY order_date;