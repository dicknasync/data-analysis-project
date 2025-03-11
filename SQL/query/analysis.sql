-- PERFORM ANALYSIS
-- PROBLEM STATEMENT 1
-- Q: Selama transaksi yang terjadi selama 2021, pada bulan apa total nilai transaksi (after_discount) paling besar? 
SELECT 
    DATE_PART('month', order_date) AS transaction_month,
    SUM(after_discount) AS total_transaction_value
FROM order_detail
WHERE 
    is_valid = 1
    AND order_date BETWEEN '2021-01-01' AND '2021-12-31'
GROUP BY  DATE_PART('month', order_date)
ORDER BY total_transaction_value DESC
LIMIT 6;

SELECT 
    TO_CHAR(order_date, 'Month') AS transaction_month,
    SUM(after_discount) AS total_transaction_value
FROM order_detail
WHERE 
    is_valid = 1
    AND order_date BETWEEN '2021-01-01' AND '2021-12-31'
GROUP BY TO_CHAR(order_date, 'Month')
ORDER BY total_transaction_value DESC
LIMIT 12;

SELECT 
    SUM(after_discount) AS total_transaction_value
FROM order_detail
WHERE 
    is_valid = 1
    AND order_date BETWEEN '2021-01-01' AND '2021-12-31';



-- PROBLEM STATEMENT 2
-- Q: Selama transaksi pada tahun 2022, kategori apa yang menghasilkan nilai transaksi paling besar? 
SELECT 
    sd.category, 
    SUM(od.after_discount) AS total_transaction_value
FROM order_detail AS od
LEFT JOIN sku_detail AS sd ON od.sku_id = sd.id
WHERE 
    od.is_valid = 1
    AND od.order_date BETWEEN '2022-01-01' AND '2022-12-31'
GROUP BY sd.category
ORDER BY total_transaction_value DESC;
--LIMIT 1;



-- PROBLEM STATEMENT 3
-- Q: Bandingkan nilai transaksi dari masing-masing kategori pada tahun 2021 dengan 2022. 
-- Sebutkan kategori apa saja yang mengalami peningkatan dan kategori apa yang mengalami penurunan nilai transaksi dari tahun 2021 ke 2022. 
WITH category_transaction AS (
	SELECT 
		sd.category,
		EXTRACT(YEAR FROM od.order_date) AS transaction_year,
		SUM(od.after_discount) AS total_transaction_value
	FROM order_detail AS od
	LEFT JOIN sku_detail AS sd ON od.sku_id = sd.id
	WHERE od.is_valid = 1
	GROUP BY
		sd.category,
		transaction_year
),
category_comparison AS (
	SELECT ct_2021.category,
	COALESCE(ct_2021.total_transaction_value, 0) AS total_transaction_2021,
	COALESCE(ct_2022.total_transaction_value, 0) AS total_transaction_2022,
	COALESCE(ct_2022.total_transaction_value, 0) - COALESCE(ct_2021.total_transaction_value, 0) AS difference
FROM 
	(SELECT category, total_transaction_value
	 FROM category_transaction
	 WHERE transaction_year = 2021) AS ct_2021
FULL OUTER JOIN
	(SELECT category, total_transaction_value
	 FROM category_transaction
	 WHERE transaction_year = 2022) AS ct_2022
ON ct_2021.category = ct_2022.category
)

SELECT
	category,
	total_transaction_2021,
	total_transaction_2022,
	difference,
	CASE
		WHEN difference > 0 THEN 'Increase'
		WHEN difference < 0 THEN 'Decrease'
		ELSE 'No Change'
	END AS trend
FROM category_comparison
ORDER BY difference DESC;



-- PROBLEM STATEMENT 4
-- Q: Tampilkan top 5 metode pembayaran yang paling populer digunakan selama 2022 (berdasarkan total unique orde). 
SELECT 
	pd.payment_method, 
	COUNT(DISTINCT od.id) AS total_transaction
FROM order_detail AS od
LEFT JOIN payment_detail AS pd ON od.payment_id = pd.id
WHERE 
	od.is_valid = 1
	AND EXTRACT(YEAR FROM od.order_date) = 2022
GROUP BY pd.payment_method
ORDER BY total_transaction DESC
LIMIT 5;



-- NUMBER 5
-- Q: Urutkan dari ke-5 produk ini berdasarkan nilai transaksinya.
-- 1.	Samsung
-- 2.	Apple
-- 3.	Sony
-- 4.	Huawei
-- 5.	Lenovo
-- Identifying category
SELECT 
	category,
	SUM(CASE WHEN sku_name ILIKE '%Samsung%' THEN 1 ELSE 0 END) AS samsung_count,
	SUM(CASE WHEN sku_name ILIKE '%Apple%' THEN 1 ELSE 0 END) AS apple_count,
	SUM(CASE WHEN sku_name ILIKE '%Sony%' THEN 1 ELSE 0 END) AS sony_count,
	SUM(CASE WHEN sku_name ILIKE '%Huawei%' THEN 1 ELSE 0 END) AS huawei_count,
	SUM(CASE WHEN sku_name ILIKE '%Lenovo%' THEN 1 ELSE 0 END) AS lenovo_count
FROM sku_detail
GROUP BY 1
ORDER BY 1;
	
WITH brand_name AS (
	SELECT
		CASE 
			WHEN sd.sku_name ILIKE ANY (ARRAY['%Samsung%', '%Galaxy%']) THEN 'Samsung'
			WHEN sd.sku_name ILIKE ANY (ARRAY['%Apple%','%iPhone%','%iMac%','%MacBook%','%Ipad%','%Homepod%','%Mac Mini%']) THEN 'Apple'			
			WHEN sd.sku_name ILIKE ANY (ARRAY['%Sony%', '%Playstation%', '%PS4%']) THEN 'Sony'
			WHEN sd.sku_name ILIKE ANY (ARRAY['%Huawei%', '%Matepad%', '%Nova%']) THEN 'Huawei'
			WHEN sd.sku_name ILIKE ANY (ARRAY['%Lenovo%', '%Zuk%']) THEN 'Lenovo'
		END AS brand,
		SUM(od.after_discount) AS transaction_value
	FROM order_detail od
	JOIN sku_detail sd ON od.sku_id = sd.id
	WHERE od.is_valid = 1
	GROUP BY 1
	ORDER BY 2 DESC
)

SELECT *
FROM brand_name
WHERE brand_name IS NOT NULL;
