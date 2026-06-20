# Rank , Dense Rank , Nested Query

## Rank VS Dense Rank
- Rank: skip subsequent ranking
- Dense rank: maintain consecutive ranking
- Rules: **cannot** use WHERE as filter for rank and dense rank (use nested query)

Example:
```txt
SELECT order_date,
    order_item_product_id,
    order_revenue,
    rank() OVER(ORDER BY order_revenue DESC) AS rnk,
    dense_ranK() OVER(ORDER BY order_revenue DESC) AS drnk
FROM daily_product_revenue
WHERE order_date = '2014-01-01 00:00:00.0'
ORDER BY 1;
```

Output:

| student_id | student_score | student_rank | student_drank |
|---|---|---|---|
| 4 | 990 | 1 | 1 |
| 7 | 980 | 2 | 2 |
| 1 | 980 | 2 | 2 |
| 6 | 960 | 4 | 3 |
| 2 | 960 | 4 | 3 |
| 3 | 960 | 4 | 3 |
| 8 | 960 | 4 | 3 |
| 10 | 940 | 8 | 4 |

## Nested Query / CTE
- you want to filter rank/drank but cannot use WHERE ตรงๆ
- use nested query instead
```txt
SELECT * FROM (
    SELECT ...
        rank() OVER(ORDER BY ... DESC) AS rnk,
        dense_ranK() OVER(ORDER BY ... DESC) AS rnk
    FROM ... WHERE ...
) AS q 
WHERE drnk <= 5;
```