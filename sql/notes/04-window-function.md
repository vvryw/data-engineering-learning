# Window functions

## OVER (PARTITION BY)
To calculate across group of rows while keeping original rows

## Window functions vs GROUP BY
- Window functions: Keep original rows
- GROUP BY: Aggregate rows that we selected

Example:
```txt
SELECT to_char(dr.order_date::timestamp, 'yyyy-MM') AS order_month,
    dr.order_date,
    dr.order_revenue,
    SUM(dr.order_revenue) OVER(
        PARTITION BY to_char(dr.order_date::timestamp, 'yyyy-MM')
    ) AS monthly_order_revenue
FROM daily_revenue AS dr
ORDER BY 1;
```

Output:

| order_month | order_date | order_revenue | monthly_order_revenue |
|---|---|---|---|
| 2013-07 | 2013-07-12 | 120.00 | 523.00 |
| 2013-07 | 2013-07-15 | 224.00 | 523.00 |
| 2013-07 | 2013-07-30 | 179.00 | 523.00 |
| 2013-08 | 2013-08-01 | 8322.00 | 12384.00 |
| 2013-08 | 2013-08-23 | 4062.00 | 12384.00 |
| 2013-09 | ... | ... | ... |
