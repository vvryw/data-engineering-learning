-- Total Agg
SELECT sum(order_item_subtotal)
FROM order_item_subtotal
WHERE order_item_id = 1
-- sum version multiple/mathematics
SELECT sum(x * y) FROM z;
-- round numeric
SELECT round(sum(order_item_subtotal)::numeric, 2) AS order_revenue


-- GROUP BY
SELECT order_status, count(*) AS order_status_count
FROM orders
GROUP BY order_status;

-- another version
SELECT order_status, count(*) AS order_status_count
FROM orders
GROUP BY 1          -- 1 = order_status
ORDER BY 2 DESC;    -- 2 = order_status_count


--  Change Format
SELECT to_char(order_date, 'yyyy-MM') AS order_month
FROM daily_revenue;

SELECT to_char(order_date::timestamp, 'yyyy-MM') AS order_month
FROM daily_revenue;



-- HAVING
SELECT order_date, count(*) AS order_count 
FROM orders
WHERE order_status IN ('COMPLETE', 'CLOSED')    -- filter only date and order that have status of complete/closed
GROUP BY 1                  -- 1 = order_date
HAVING count(*) >= 250;     -- selecting the order_count that greater than 250

