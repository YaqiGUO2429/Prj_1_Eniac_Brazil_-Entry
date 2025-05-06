USE magist; 

#1 What categories of tech products does Magist have?
SELECT DISTINCT t.product_category_name_english 
FROM products p
JOIN product_category_name_translation t 
ON p.product_category_name = t.product_category_name
WHERE t.product_category_name_english 
IN ('audio', 'electronics', 'computers_accessories', 'pc_gamer', 'computers', 'tablets_printing_image', 'telephony');

#2.1 How many products of these tech categories have been sold (within the time window of the database snapshot)? 
#2.2 What percentage does that represent from the overall number of products sold?
SELECT 
	DISTINCT COUNT(oi.product_id) AS tech_products_sold,
    (100 * COUNT(oi.product_id) / (SELECT COUNT(*) FROM order_items)) AS tech_percentage
FROM order_items oi
JOIN products p USING (product_id)
JOIN orders o USING (order_id)
JOIN product_category_name_translation t USING (product_category_name)
WHERE t.product_category_name_english 
IN ('audio', 'electronics', 'computers_accessories', 'pc_gamer', 'computers', 'tablets_printing_image', 'telephony');

#3. What’s the average price of the products being sold?
SELECT AVG(price) AS average_price FROM order_items;

#4. Are expensive tech products popular? ※
SELECT DISTINCT price FROM order_items ORDER BY price DESC;
SELECT
    MIN(price) AS min_price,
    MAX(price) AS max_price
FROM order_items
WHERE 
    price IS NOT NULL;
SELECT FLOOR(COUNT(*) * 0.33) AS offset_33, 
       FLOOR(COUNT(*) * 0.66) AS offset_66
FROM order_items
WHERE price IS NOT NULL;
SELECT price
FROM order_items
WHERE price IS NOT NULL 
ORDER BY price ASC 
LIMIT 1 OFFSET 37174;
SELECT price
FROM order_items
WHERE price IS NOT NULL 
ORDER BY price ASC 
LIMIT 1 OFFSET 74349;
    SELECT
    CASE 
        WHEN price <= 49.9 THEN 'Cheap (<= 49.9)'
        WHEN price <= 109 THEN 'Medium (49.9 - 109)'
        ELSE 'Expensive (> 109)'
    END AS price_category,
     COUNT(*) AS product_count
FROM order_items
GROUP BY price_category;
#Alternative! From AVG Order Price of Eniac
SELECT 
    CASE 
        WHEN price > 540 THEN 'Expensive'
        ELSE 'Cheap'
    END AS price_category,
    COUNT(*) AS product_count
FROM order_items
GROUP BY price_category;

#5. How many months of data are included in the magist database?
SELECT MIN(order_purchase_timestamp), MAX(order_purchase_timestamp) FROM orders;
SELECT TIMESTAMPDIFF(MONTH, MIN(order_purchase_timestamp), MAX(order_purchase_timestamp)) 
AS months_of_data FROM orders;

#6.1 How many sellers are there? 
#6.2 How many Tech sellers are there? 
#6.3 What percentage of overall sellers are Tech sellers?
SELECT COUNT(*) AS total_sellers 
FROM sellers
WHERE seller_id IS NOT NULL;
SELECT COUNT(DISTINCT oi.seller_id) 
AS tech_sellers,
(100 * count(DISTINCT oi.seller_id) / (SELECT COUNT(*) AS total_sellers FROM sellers)) 
AS tech_sellers_percentage
FROM order_items oi
JOIN products p ON oi.product_id = p.product_id
JOIN product_category_name_translation t USING (product_category_name)
WHERE t.product_category_name_english 
IN ('audio', 'electronics', 'computers_accessories', 'pc_gamer', 'computers', 'tablets_printing_image', 'telephony')
AND oi.seller_id IS NOT NULL;

#7.1 What is the total amount earned by all sellers? 
#7.2 What is the total amount earned by all Tech sellers?
SELECT SUM(price) AS total_revenue 
FROM order_items
WHERE price IS NOT NULL;
SELECT SUM(oi.price) AS tech_revenue 
FROM order_items oi
JOIN products p ON oi.product_id = p.product_id
JOIN product_category_name_translation t ON p.product_category_name = t.product_category_name
WHERE t.product_category_name_english 
IN ('audio', 'electronics', 'computers_accessories', 'pc_gamer', 'computers', 'tablets_printing_image', 'telephony')
AND oi.price IS NOT NULL;

#8.1 Can you work out the average monthly income of all sellers? 
#8.2 Can you work out the average monthly income of Tech sellers?
SELECT SUM(price) 
/ (SELECT TIMESTAMPDIFF(MONTH, MIN(order_purchase_timestamp), MAX(order_purchase_timestamp)) FROM orders) 
AS avg_monthly_income FROM order_items
WHERE price IS NOT NULL;
SELECT SUM(oi.price) 
/ (SELECT TIMESTAMPDIFF(MONTH, MIN(order_purchase_timestamp), MAX(order_purchase_timestamp)) FROM orders) 
AS avg_monthly_income_tech
FROM order_items oi
JOIN products p USING (product_id)
JOIN product_category_name_translation t USING (product_category_name)
WHERE t.product_category_name_english 
IN ('audio', 'electronics', 'computers_accessories', 'pc_gamer', 'computers', 'tablets_printing_image', 'telephony')
AND oi.price IS NOT NULL;

#9. What’s the average time between the order being placed and the product being delivered?
SELECT 
    AVG(DATEDIFF(order_delivered_customer_date, order_purchase_timestamp)) AS avg_delivery_days
FROM 
    orders
WHERE 
    order_delivered_customer_date IS NOT NULL
    AND order_purchase_timestamp IS NOT NULL
	AND order_status = "delivered";
    
#10. How many orders are delivered on time vs orders delivered with a delay?
SELECT 
    COUNT(CASE WHEN order_delivered_customer_date <= order_estimated_delivery_date THEN 1 END) AS on_time_deliveries,
    COUNT(CASE WHEN order_delivered_customer_date > order_estimated_delivery_date THEN 1 END) AS late_deliveries
FROM 
    orders
WHERE 
    order_delivered_customer_date IS NOT NULL
    AND order_estimated_delivery_date IS NOT NULL
    AND order_status = "delivered";

