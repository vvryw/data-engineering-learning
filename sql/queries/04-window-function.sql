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


-- OVER PARTITION BY
SELECT dr.*,
    SUM(dr.order_revenue) OVER(PARTITION BY 1) AS total_order_revenue
FROM daily_revenue AS dr
-- output = all columns + total order ทั้งหมด

-- Agg by order_date > month
SELECT to_char(dr.order_date::timestamp, 'yyyy-MM') AS order_month,
    dr.order_date,
    dr.order_revenue,
    SUM(dr.order_revenue) OVER(
        PARTITION BY to_char(dr.order_date::timestamp, 'yyyy-MM')
    ) AS monthly_order_revenue
FROM daily_revenue AS dr
ORDER BY 1;

-- CANNOT do PARTITION BY 1