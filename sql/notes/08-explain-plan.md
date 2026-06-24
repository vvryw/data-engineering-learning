# SQL Performance Tuning by Analyzing Explain Plan

Performance tuning is the process of improving SQL query performance by analyzing how the database executes a query and then applying the right optimization technique.

The common workflow is:

1. Generate an Explain Plan for the SQL query.
2. Interpret the Explain Plan to identify bottlenecks.
3. Apply the correct tuning technique, such as adding indexes or rewriting the query.
4. Run the Explain Plan again to compare the result.

---

## Example Query

```sql
SELECT count(*)
FROM orders AS o
    JOIN order_items AS oi
        ON o.order_id = oi.order_item_order_id
WHERE o.order_customer_id = 5;
```

This query counts the number of order items that belong to orders from customer `5`.


### Before Performance Tuning

The first Explain Plan showed:

```txt
Seq Scan on order_items AS oi
Seq Scan on orders AS o
```

`Seq Scan` means **Sequential Scan**, or full table scan.

- Full table scan = database **reads all rows** from the table to find matching records.

- For small tables -> acceptable
- For large tables -> SLOW


### Bottleneck

From the Explain Plan, the main bottlenecks are:

* `orders` table is scanned to find `order_customer_id = 5`
* `order_items` table is scanned to join with `orders`
* The database does not have useful indexes for the filter and join condition

Important columns in this query:

| Column                            | Purpose                    |
| --------------------------------- | -------------------------- |
| `orders.order_customer_id`        | Used in the `WHERE` filter |
| `orders.order_id`                 | Used in the join           |
| `order_items.order_item_order_id` | Used in the join           |

---

### **Step 1: Create Foreign Key**

```sql
ALTER TABLE orders
    ADD FOREIGN KEY (order_customer_id)
    REFERENCES customers (customer_id);
```

- A foreign key defines a relationship between tables and protects data integrity.

- However, in PostgreSQL, creating a foreign key does **not always automatically create an index** on the foreign key column.

- If the column is frequently used for filtering or joining, we should create an index manually.



### **Step 2: Create Index on Filter Column**

```sql
CREATE INDEX orders_order_customer_id_idx
ON orders (order_customer_id);
```

- This index helps the database quickly find rows where:

```sql
WHERE order_customer_id = 5
```

- After creating this index, the Explain Plan changed from:

```txt
Seq Scan on orders
```

to:

```txt
Bitmap Index Scan using orders_order_customer_id_idx
Bitmap Heap Scan on orders
```

- Database can now **use index** instead of scanning the whole `orders` table.



### **Step 3: Create Index on Join Column**

```sql
CREATE INDEX order_items_order_item_order_id_idx
ON order_items (order_item_order_id);
```

- Index helps the database join `orders` with `order_items` faster.

The join condition is:

```sql
ON o.order_id = oi.order_item_order_id
```

After creating this index, the Explain Plan changed to:

```txt
Index Only Scan using order_items_order_item_order_id_idx
```

- PostgreSQL can use only the index to find matching rows in `order_items`, instead of scanning the full table.



### **Improved Explain Plan**

- After adding indexes, the plan became:
- This is better because the database no longer needs to scan the full `orders` and `order_items` tables.

```txt
Aggregate
  -> Nested Loop Inner Join
      -> Bitmap Heap Scan on orders
          -> Bitmap Index Scan using orders_order_customer_id_idx
      -> Index Only Scan using order_items_order_item_order_id_idx
```

---

## How to Read the Execution Plan

Execution starts from the bottom, also called the leaf nodes, and moves upward to the root node.

```txt
#4 Bitmap Index Scan
   - Find orders where order_customer_id = 5

#3 Bitmap Heap Scan
   - Fetch matching rows from orders

#5 Index Only Scan
   - Find matching order_items using order_item_order_id

#2 Nested Loop Inner Join
   - Join orders with order_items

#1 Aggregate
   - Count the final result using count(*)
```

So the execution flow is:

```txt
Leaves → Nodes → Root
```


## Before vs After

### Before

```txt
Seq Scan on order_items
Seq Scan on orders
```

Problem:

```txt
Full table scan = slower for large tables
```

### After

```txt
Bitmap Index Scan on orders
Index Only Scan on order_items
Nested Loop Inner Join
Aggregate
```

Improvement:

```txt
Index scan = faster lookup
No more full table scan on the important filter/join columns
```

---

# Summary

Performance tuning steps used in this example:

1. Run `EXPLAIN` or `EXPLAIN ANALYZE`.
2. Find slow operations such as `Seq Scan`.
3. Identify columns used in `WHERE` and `JOIN`.
4. Create indexes on important filter and join columns.
5. Run the Explain Plan again.
6. Compare the new plan with the old plan.

In this case, adding indexes helped the database avoid full table scans and use faster index-based access instead.
