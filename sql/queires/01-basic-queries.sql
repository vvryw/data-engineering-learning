-- Create DATABASE
CREATE DATABASE <db_name>;
CREATE USER <user_name> WITH ENCRIPTED PASSWORD <password>;
GRANT ALL ON <db_name> DATABASE TO <user_name>;      -- Grant permission to user; can change [ALL] to other permission  

-- Basic
SELECT * FROM orders;


-- Select distinct
SELECT DISTINCT order_status FROM orders
ORDER BY 1;     -- ASC
                -- 1 = order_status


-- Filter
SELECT *
FROM orders
WHERE order_status = 'COMPLETE';
-- OR
WHERE order_status = 'COMPLETE' OR order_status = 'CLOSED';
-- IN
WHERE order_status IN ('COMPLETE' , 'CLOSED');


-- Count
SELECT count(*) FROM orders;    -- count รวมทั้งหมด
SELECT count(DISTINCT order_status) FROM orders;    -- count order_status unique