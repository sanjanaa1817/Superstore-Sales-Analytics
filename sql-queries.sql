SELECT *
FROM customers
LIMIT 5;

SELECT *
FROM products
LIMIT 5;

SELECT *
FROM orders
LIMIT 5;

--primary keys
ALTER TABLE customers
ADD PRIMARY KEY ("Customer ID");

ALTER TABLE products
ADD PRIMARY KEY ("Product ID");

ALTER TABLE orders
ADD PRIMARY KEY ("Row ID");

--duplicate values
SELECT "Product ID", COUNT(*)
FROM products
GROUP BY "Product ID"
HAVING COUNT(*) > 1;

--foreign keys
ALTER TABLE orders
ADD CONSTRAINT fk_customer
FOREIGN KEY ("Customer ID")
REFERENCES customers("Customer ID");

ALTER TABLE orders
ADD CONSTRAINT fk_product
FOREIGN KEY ("Product ID")
REFERENCES products("Product ID");

--rename customer column names
ALTER TABLE customers
RENAME COLUMN "Customer ID" TO customer_id;

ALTER TABLE customers
RENAME COLUMN "Segment" TO segment;

ALTER TABLE customers
RENAME COLUMN "Customer Name" TO customer_name;

--rename products column names
ALTER TABLE products
RENAME COLUMN "Product ID" TO product_id;

ALTER TABLE products
RENAME COLUMN "Sub/Category" TO sub_category;

ALTER TABLE products
RENAME COLUMN "Product Name" TO product_name;

--rename orders column names
ALTER TABLE orders
RENAME COLUMN "Row ID" TO row_id;

ALTER TABLE orders
RENAME COLUMN "Order ID" TO order_id;

ALTER TABLE orders
RENAME COLUMN "Region" TO region;

ALTER TABLE orders
RENAME COLUMN "Discount" TO discount;

ALTER TABLE orders
RENAME COLUMN "Order Date" TO order_date;

ALTER TABLE orders
RENAME COLUMN "Ship Date" TO ship_date;

--1. Total Sales
SELECT ROUND(SUM(sales)::numeric,2) AS total_sales
FROM orders;

--2. Total Profit
SELECT ROUND(SUM(profit)::numeric,2) AS total_profit
FROM orders;

--3. Sales by Category
SELECT
p.category,
ROUND(SUM(o.sales)::numeric,2) AS total_sales
FROM orders o
JOIN products p
ON o.product_id = p.product_id
GROUP BY p.category
ORDER BY total_sales DESC;

--4. Profit by Category
SELECT
p.category,
ROUND(SUM(o.profit)::numeric,2) AS total_profit
FROM orders o
JOIN products p
ON o.product_id = p.product_id
GROUP BY p.category
ORDER BY total_profit DESC;

--5. Top 10 Customers
SELECT
c.customer_name,
ROUND(SUM(o.sales)::numeric,2) AS total_sales
FROM orders o
JOIN customers c
ON o.customer_id = c.customer_id
GROUP BY c.customer_name
ORDER BY total_sales DESC
LIMIT 10;

--6. Top 10 Products
SELECT
p.product_name,
ROUND(SUM(o.sales)::numeric,2) AS total_sales
FROM orders o
JOIN products p
ON o.product_id = p.product_id
GROUP BY p.product_name
ORDER BY total_sales DESC
LIMIT 10;

--7. Sales by Region
SELECT
region,
ROUND(SUM(sales)::numeric,2) AS total_sales
FROM orders
GROUP BY region
ORDER BY total_sales DESC;

--8. Average Order Value
SELECT
ROUND(
SUM(sales)::numeric /
COUNT(DISTINCT order_id),2
) AS avg_order_value
FROM orders;

--9. Monthly Sales Trend
SELECT
DATE_TRUNC('month', order_date) AS month,
ROUND(SUM(sales)::numeric,2) AS total_sales
FROM orders
GROUP BY month
ORDER BY month;

--10. Shipping Performance
SELECT
ROUND(
AVG(EXTRACT(DAY FROM (ship_date - order_date)))::numeric,
2
) AS avg_shipping_days
FROM orders;

--11. Customer Ranking (Window Function)
WITH customer_sales AS (
SELECT
c.customer_name,
SUM(o.sales) total_sales,
RANK() OVER(
ORDER BY SUM(o.sales) DESC
) AS sales_rank
FROM orders o
JOIN customers c
ON o.customer_id = c.customer_id
GROUP BY c.customer_name
)
SELECT *
FROM customer_sales
WHERE sales_rank <= 10;

--12. Product Ranking by Category
WITH ranked_products AS (
SELECT
p.category,
p.product_name,
SUM(o.sales) total_sales,
RANK() OVER(
PARTITION BY p.category
ORDER BY SUM(o.sales) DESC
) rank_num
FROM orders o
JOIN products p
ON o.product_id = p.product_id
GROUP BY p.category,p.product_name
)

SELECT *
FROM ranked_products
WHERE rank_num = 1;

--13. Running Sales Total
SELECT
    DATE_TRUNC('month', order_date) AS month,
    ROUND(SUM(sales)::numeric, 2) AS total_sales
FROM orders
GROUP BY DATE_TRUNC('month', order_date)
ORDER BY month;


--14. Discount Impact
SELECT
discount,
ROUND(AVG(profit)::numeric,2) avg_profit
FROM orders
GROUP BY discount
ORDER BY discount;

--15. Loss Making Products
SELECT
p.product_name,
ROUND(SUM(o.profit)::numeric,2) total_profit
FROM orders o
JOIN products p
ON o.product_id = p.product_id
GROUP BY p.product_name
ORDER BY total_profit
LIMIT 10;

--16. Who is the highest spending customer in each segment?
WITH customer_sales AS (
SELECT
c.segment,
c.customer_name,
SUM(o.sales) total_sales,
RANK() OVER(
PARTITION BY c.segment
ORDER BY SUM(o.sales) DESC
) rank_num
FROM customers c
JOIN orders o
ON c.customer_id = o.customer_id
GROUP BY c.segment,c.customer_name
)

SELECT *
FROM customer_sales
WHERE rank_num = 1;

--SELECT column_name, data_type
--FROM information_schema.columns
--WHERE table_name='orders';