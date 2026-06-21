# Syntax Error and Semantic Error

## Syntax Error
- code is written in a way the language/database cannot understand
- aka grammar mistake

### Example 1: Error because the string quote is not closed
```sql
SELECT order_id, order_date
FROM orders
WHERE order_status = 'COMPLETE
```

### Example 2: FORM is wrong. It should be FROM
```sql
SELECT *
FORM orders;
```


## Semantic Error
- SQL is valid, but the result is not what you want

### Example 1: Goal is to keep all products

**Sample data**:

`products`
| product_id | product_name |
| ---------- | ------------ |
| 1          | Apple        |
| 2          | Banana       |
| 3          | Orange       |

`order_details`
| order_id | product_id | order_date |
| -------- | ---------- | ---------- |
| 101      | 1          | 2014-01-10 |
| 102      | 2          | 2014-02-05 |

```sql
SELECT *
FROM products AS p
    LEFT JOIN order_details AS od
    ON p.product_id = od.product_id
WHERE od.order_date = '2014-01-01';
```
- putting od.order_date in WHERE removes rows where od is NULL
- LEFT JOIN behaves like an INNER JOIN

**Case 1: Put condition in `WHERE`**
- Step 1: LEFT JOIN happens first.

| product_id | product_name | order_id | order_date |
| ---------- | ------------ | -------- | ---------- |
| 1          | Apple        | 101      | 2014-01-10 |
| 2          | Banana       | 102      | 2014-02-05 |
| 3          | Orange       | NULL     | NULL       |

- Step 2: WHERE order_date = '2014-01' filters rows.

| product_id | product_name | order_id | order_date | Keep? |
| ---------- | ------------ | -------- | ---------- | ----- |
| 1          | Apple        | 101      | 2014-01-10 | Yes   |
| 2          | Banana       | 102      | 2014-02-05 | No    |
| 3          | Orange       | NULL     | NULL       | No    |

- Final result:

| product_id | product_name | order_id | order_date |
| ---------- | ------------ | -------- | ---------- |
| 1          | Apple        | 101      | 2014-01-10 |


**Better approach: Put condition in `ON`**
```sql
SELECT *
FROM products AS p
    LEFT JOIN order_details AS od
    ON p.product_id = od.product_id
    AND od.order_date = '2014-01-01';
```

- the date condition is part of the matching rule

| product_id | product_name | order_id | order_date | Meaning               |
| ---------- | ------------ | -------- | ---------- | --------------------- |
| 1          | Apple        | 101      | 2014-01-10 | Matched January order |
| 2          | Banana       | NULL     | NULL       | No January order      |
| 3          | Orange       | NULL     | NULL       | No order              |

- Final result: keeps all products

| product_id | product_name | order_id | order_date |
| ---------- | ------------ | -------- | ---------- |
| 1          | Apple        | 101      | 2014-01-10 |
| 2          | Banana       | NULL     | NULL       |
| 3          | Orange       | NULL     | NULL       |


#### if want to find products that do not have orders in January:
```sql
SELECT *
FROM products AS p
LEFT JOIN order_details_v AS odv
    ON p.product_id = odv.order_item_product_id
    AND to_char(odv.order_date::timestamp, 'yyyy-MM') = '2014-01'
WHERE odv.order_item_product_id IS NULL;
```

### Example 2: order_date with SUM() but not grouping by order_date
```sql
SELECT 
    order_date,
    SUM(order_revenue) AS total_revenue
FROM daily_revenue;
```

Better approach:
```sql
SELECT 
    order_date,
    SUM(order_revenue) AS total_revenue
FROM daily_revenue
GROUP BY order_date;
```


## How to Debug Semantic Error
1. Check keyword spelling
2. Check commas
3. Check quotes
4. Check parentheses
5. Check table/column names
6. Run smaller parts of the query