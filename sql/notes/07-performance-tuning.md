# Performance Tuning

- Improve SQL query performance by analyzing how the database executes a query.
- Generate an **Explain Plan** for the SQL query.
- Interpret the Explain Plan to identify performance bottlenecks, such as:

  - Full table scans
  - Inefficient joins
  - Missing indexes
  - High-cost operations
- Apply the appropriate optimization technique, such as:

  - Adding indexes
  - Rewriting queries
  - Filtering data earlier
  - Improving join conditions


## Index Example

- An index helps the database find rows faster without scanning the whole table.

**Example: filter by `order_id = 2`, database use primary key index to directly locate the matching row**

**Without Index:**
- If there is no index, the database may need to check every row one by one.
- This can cause a **full table scan** => slower for large tables.
```sql
SELECT *
FROM orders
WHERE order_id = 2;
```

**With Index:**
- If `order_id` is a primary key, PostgreSQL automatically creates an index for it
- The database can use the index to find the row faster.
```sql
CREATE TABLE orders (
    order_id INT PRIMARY KEY,
    order_date DATE,
    order_customer_id INT,
    order_status VARCHAR(50)
);
```

Now, when we run:

```sql
SELECT *
FROM orders
WHERE order_id = 2;
```

---

### Table: `orders`
- Table rows are **not sorted by `order_id`**

| row location | order_id | order_date | order_customer_id | order_status |
| ------------ | -------: | ---------- | ----------------: | ------------ |
| r1           |        1 | 2013-07-25 |               123 | COMPLETE     |
| r2           |        3 | 2013-07-25 |               234 | CLOSED       |
| r3           |        4 | 2013-07-25 |               123 | PENDING      |
| r4           |        2 | 2013-07-25 |               134 | COMPLETE     |
| r5           |        5 | 2013-07-25 |               134 | COMPLETE     |

---

### Index: `orders_pkey`
- The index stores the indexed column in sorted order and points to the row location.

| order_id | row location |
| -------: | ------------ |
|        1 | r1           |
|        2 | r4           |
|        3 | r2           |
|        4 | r3           |
|        5 | r5           |

When searching for: **`WHERE order_id = 2`**

The database looks in the index:

| order_id | row location |
| -------: | ------------ |
|        2 | r4           |

Then it directly goes to row `r4` in the table.


### Summary

Without index:

```txt
Check r1 → Check r2 → Check r3 → Check r4 → Found
```

With index:

```txt
Find order_id = 2 in index → Go directly to r4
```

So, indexes make filtering faster, especially when the table has many rows.
