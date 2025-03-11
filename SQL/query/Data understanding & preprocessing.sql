-- 1. REVIEW DATABASE SCHEMA
-- 2. DATA STRUCTURE EVALUATION & CLEANING
-- #DATA UNDERSTANDING
-- Initial data inspection
SELECT * FROM customer_detail LIMIT 10;
SELECT * FROM sku_detail LIMIT 10;
SELECT * FROM payment_detail LIMIT 10;
SELECT * FROM order_detail LIMIT 10;

-- check foreign keys consistency
-- ika tabel dalam keadaan konsisten (tidak ada NULL di foreign key), query akan menghasilkan tidak ada baris (kosong).
SELECT od.customer_id, cd.id
FROM order_detail AS od
LEFT JOIN customer_detail AS cd ON od.customer_id = cd.id
WHERE cd.id IS NULL;

SELECT od.sku_id
FROM order_detail AS od
LEFT JOIN sku_detail AS sd ON od.sku_id = sd.id
WHERE sd.id IS NULL;

SELECT od.payment_id
FROM order_detail AS od
LEFT JOIN payment_detail AS pd ON od.payment_id = pd.id
WHERE pd.id IS NULL;

-- check for duplicates
SELECT id, registered_date, COUNT(*) 
FROM customer_detail 
GROUP BY id , registered_date
HAVING COUNT(*) > 1;

SELECT id, sku_name, base_price, cogs, category, COUNT(*) 
FROM sku_detail 
GROUP BY id , sku_name, base_price, cogs, category
HAVING COUNT(*) > 1;

SELECT id, payment_method, COUNT(*) 
FROM payment_detail
GROUP BY id , payment_method
HAVING COUNT(*) > 1;

SELECT 
	id, customer_id, order_date, sku_id, 
	price, qty_ordered, before_discount, 
	discount_amount, after_discount, is_gross, 
	is_valid, is_net, payment_id, COUNT(*) 
FROM order_detail
GROUP BY 
	id, customer_id, order_date, sku_id, 
	price, qty_ordered, before_discount, 
	discount_amount, after_discount, is_gross, 
	is_valid, is_net, payment_id
HAVING COUNT(*) > 1;

-- check for missing value
-- #Cara 1
SELECT
	COUNT(*) AS total_rows,
	SUM(CASE WHEN id IS NULL THEN 1 ELSE 0 END) AS id_nulls,
	SUM(CASE WHEN registered_date IS NULL THEN 1 ELSE 0 END) AS registered_date_nulls
FROM customer_detail;

SELECT
	COUNT(*) AS total_rows,
	SUM(CASE WHEN id IS NULL THEN 1 ELSE 0 END) AS id_nulls,
	SUM(CASE WHEN sku_name IS NULL THEN 1 ELSE 0 END) AS sku_name_nulls,
	SUM(CASE WHEN base_price IS NULL THEN 1 ELSE 0 END) AS base_price_nulls,
	SUM(CASE WHEN cogs IS NULL THEN 1 ELSE 0 END) AS cogs_nulls,
	SUM(CASE WHEN category IS NULL THEN 1 ELSE 0 END) AS category_nulls
FROM sku_detail;

SELECT
	COUNT(*) AS total_rows,
	SUM(CASE WHEN id IS NULL THEN 1 ELSE 0 END) AS id_nulls,
	SUM(CASE WHEN payment_method IS NULL THEN 1 ELSE 0 END) AS payment_method_nulls
FROM payment_detail;

SELECT
	COUNT(*) AS total_rows,
	SUM(CASE WHEN id IS NULL THEN 1 ELSE 0 END) AS id_nulls,
	SUM(CASE WHEN customer_id IS NULL THEN 1 ELSE 0 END) AS customer_id_nulls,
	SUM(CASE WHEN order_date IS NULL THEN 1 ELSE 0 END) AS order_date_nulls,
	SUM(CASE WHEN sku_id IS NULL THEN 1 ELSE 0 END) AS sku_id_nulls,
	SUM(CASE WHEN price IS NULL THEN 1 ELSE 0 END) AS price_nulls,
	SUM(CASE WHEN qty_ordered IS NULL THEN 1 ELSE 0 END) AS qty_ordered_nulls,
	SUM(CASE WHEN before_discount IS NULL THEN 1 ELSE 0 END) AS before_discount_nulls,
	SUM(CASE WHEN discount_amount IS NULL THEN 1 ELSE 0 END) AS discount_amount_nulls,
	SUM(CASE WHEN after_discount IS NULL THEN 1 ELSE 0 END) AS after_discount_nulls,
	SUM(CASE WHEN is_gross IS NULL THEN 1 ELSE 0 END) AS is_gross_nulls,
	SUM(CASE WHEN is_valid IS NULL THEN 1 ELSE 0 END) AS is_valid_nulls,
	SUM(CASE WHEN is_net IS NULL THEN 1 ELSE 0 END) AS is_net_nulls,
	SUM(CASE WHEN payment_id IS NULL THEN 1 ELSE 0 END) AS payment_id_nulls
FROM order_detail;

-- #Cara 2
SELECT
    COUNT(*) AS total_rows,
    COUNT(*) FILTER (WHERE id IS NULL) AS id_nulls,
    COUNT(*) FILTER (WHERE registered_date IS NULL) AS registered_date_nulls
FROM customer_detail;

SELECT
    COUNT(*) AS total_rows,
    COUNT(*) FILTER (WHERE id IS NULL) AS id_nulls,
    COUNT(*) FILTER (WHERE sku_name IS NULL) AS sku_name_nulls,
    COUNT(*) FILTER (WHERE base_price IS NULL) AS base_price_nulls,
    COUNT(*) FILTER (WHERE cogs IS NULL) AS cogs_nulls,
    COUNT(*) FILTER (WHERE category IS NULL) AS category_nulls
FROM sku_detail;

SELECT
    COUNT(*) AS total_rows,
    COUNT(*) FILTER (WHERE id IS NULL) AS id_nulls,
    COUNT(*) FILTER (WHERE payment_method IS NULL) AS payment_method_nulls
FROM payment_detail;

SELECT
    COUNT(*) AS total_rows,
    COUNT(*) FILTER (WHERE id IS NULL) AS id_nulls,
    COUNT(*) FILTER (WHERE customer_id IS NULL) AS customer_id_nulls,
    COUNT(*) FILTER (WHERE order_date IS NULL) AS order_date_nulls,
    COUNT(*) FILTER (WHERE sku_id IS NULL) AS sku_id_nulls,
    COUNT(*) FILTER (WHERE price IS NULL) AS price_nulls,
    COUNT(*) FILTER (WHERE qty_ordered IS NULL) AS qty_ordered_nulls,
    COUNT(*) FILTER (WHERE before_discount IS NULL) AS before_discount_nulls,
    COUNT(*) FILTER (WHERE discount_amount IS NULL) AS discount_amount_nulls,
    COUNT(*) FILTER (WHERE after_discount IS NULL) AS after_discount_nulls,
    COUNT(*) FILTER (WHERE is_gross IS NULL) AS is_gross_nulls,
    COUNT(*) FILTER (WHERE is_valid IS NULL) AS is_valid_nulls,
    COUNT(*) FILTER (WHERE is_net IS NULL) AS is_net_nulls,
    COUNT(*) FILTER (WHERE payment_id IS NULL) AS payment_id_nulls
FROM order_detail;


-- validate data types
SELECT column_name, data_type 
FROM information_schema.columns
WHERE table_name = 'customer_detail';

SELECT column_name, data_type 
FROM information_schema.columns
WHERE table_name = 'sku_detail';

SELECT column_name, data_type 
FROM information_schema.columns
WHERE table_name = 'payment_detail';

SELECT column_name, data_type 
FROM information_schema.columns
WHERE table_name = 'order_detail';

-- 3. DATA CLEANING (if data dirty)
-- remove duplicates
-- handle missing values
-- fix incorrect data types
