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
SELECT AVG(price) 
	AS average_price 
FROM order_items;

#4. Are expensive tech products popular? 
#4 step ️1: Retrieve all distinct prices, sorted from highest to lowest.
SELECT DISTINCT price 
FROM order_items ORDER BY price DESC;
#4 step 2: View the minimum and maximum prices
SELECT
    MIN(price) AS min_price,
    MAX(price) AS max_price
FROM order_items
WHERE price IS NOT NULL;
#4 step 3: Calculate the positions (row numbers) of the 33% and 66% percentiles
SELECT FLOOR(COUNT(*) * 0.33) AS offset_33, 
       FLOOR(COUNT(*) * 0.66) AS offset_66
FROM order_items
WHERE price IS NOT NULL;
#4 step 4: Precisely extract the price values at those percentile positions
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
#4 step 5: Categorize products based on price ranges and count the number of products in each category
SELECT
    CASE 
        WHEN price <= 49.9 THEN 'Cheap (<= 49.9)'
        WHEN price <= 109 THEN 'Medium (49.9 - 109)'
        ELSE 'Expensive (> 109)'
    END AS price_category,
     COUNT(*) AS product_count
FROM order_items
GROUP BY price_category;

#4 Alternative! From AVG Order Price of Eniac
SELECT 
    CASE 
        WHEN price > 540 THEN 'Expensive'
        ELSE 'Cheap'
    END AS price_category,
    COUNT(*) AS product_count
FROM order_items
GROUP BY price_category;

#5. How many months of data are included in the magist database?
SELECT MIN(order_purchase_timestamp), MAX(order_purchase_timestamp) 
FROM orders;
SELECT TIMESTAMPDIFF(MONTH, MIN(order_purchase_timestamp), MAX(order_purchase_timestamp)) 
	AS months_of_data 
FROM orders;

#6.1 How many sellers are there? 
SELECT COUNT(*) AS total_sellers 
FROM sellers
WHERE seller_id IS NOT NULL;

#6.2 How many Tech sellers are there?
SELECT COUNT(DISTINCT oi.seller_id) 
AS tech_sellers,
#What percentage of overall sellers are Tech sellers?
(100 * count(DISTINCT oi.seller_id) / (SELECT COUNT(*) AS total_sellers FROM sellers)) 
AS tech_sellers_percentage
FROM order_items oi
JOIN products p ON oi.product_id = p.product_id
JOIN product_category_name_translation t USING (product_category_name)
WHERE t.product_category_name_english 
	IN ('audio', 'electronics', 'computers_accessories', 'pc_gamer', 'computers', 'tablets_printing_image', 'telephony')
	AND oi.seller_id IS NOT NULL;

#7.1 What is the total amount earned by all sellers? 
SELECT SUM(price) 
	AS total_revenue 
FROM order_items
WHERE price IS NOT NULL;

#7.2 What is the total amount earned by all Tech sellers?
SELECT SUM(oi.price) 
	AS tech_revenue 
FROM order_items oi
JOIN products p ON oi.product_id = p.product_id
JOIN product_category_name_translation t ON p.product_category_name = t.product_category_name
WHERE t.product_category_name_english 
	IN ('audio', 'electronics', 'computers_accessories', 'pc_gamer', 'computers', 'tablets_printing_image', 'telephony')
	AND oi.price IS NOT NULL;

#8.1 Can you work out the average monthly income of all sellers? 
SELECT SUM(price) 
/ (SELECT TIMESTAMPDIFF(MONTH, MIN(order_purchase_timestamp), MAX(order_purchase_timestamp)) FROM orders) 
AS avg_monthly_income FROM order_items
WHERE price IS NOT NULL;

#8.2 Can you work out the average monthly income of Tech sellers?
SELECT SUM(oi.price) 
/ (SELECT TIMESTAMPDIFF(MONTH, MIN(order_purchase_timestamp), MAX(order_purchase_timestamp)) 
	FROM orders) 
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

#11 How many orders are there in each status category?
SELECT o.order_status, COUNT(*) 
	AS order_count
FROM orders o
GROUP BY o.order_status
ORDER BY order_count DESC;

#12.1 How many orders are delivered? How many orders are not?
SELECT
    COUNT(*) AS total_orders,
    COUNT(CASE
        WHEN order_delivered_customer_date IS NOT NULL 
        THEN 1
        END) 
        AS delivered_orders,
    COUNT(CASE
        WHEN order_delivered_customer_date IS NULL 
        THEN 1
        END) AS undelivered_orders
FROM orders;

#12.2 How many orders are delivered? How many orders are not?
SELECT AVG(TIMESTAMPDIFF(DAY, order_purchase_timestamp, order_delivered_customer_date)) 
	AS avg_delivery_time_days
FROM orders;

#13 How many orders are delivered on time? How many orders are late?
SELECT 
    SUM(CASE WHEN order_delivered_customer_date <= order_estimated_delivery_date 
	THEN 1 
	ELSE 0 
	END) AS on_time_deliveries,
    SUM(CASE WHEN order_delivered_customer_date > order_estimated_delivery_date 
	THEN 1 
	ELSE 0 
	END) AS delayed_deliveries
FROM orders;

#14 Does larger product size lead to delivery delay?
SELECT 
    (CASE WHEN p.product_weight_g > (SELECT AVG(p.product_weight_g) FROM products p) THEN 'Heavy'
    ELSE 'Light'
    END) AS weight_category,
    SUM(CASE WHEN o.order_delivered_customer_date > o.order_estimated_delivery_date 
	THEN 1 
	ELSE 0 
	END) AS delayed_orders
FROM order_items oi
JOIN orders o ON oi.order_id = o.order_id
JOIN products p ON oi.product_id = p.product_id
GROUP BY weight_category;
