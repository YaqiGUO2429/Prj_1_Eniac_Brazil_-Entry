USE magist;

#1. How many orders are there in the dataset?
SELECT count( DISTINCT order_id) AS order_amount FROM orders;

#2. Are orders actually delivered?
SELECT DISTINCT order_status, count(DISTINCT order_id) AS orders_amount
FROM orders
GROUP BY order_status
ORDER BY orders_amount DESC;

#3. Is Magist having user growth?
#month level
SELECT 
    YEAR(order_purchase_timestamp) AS order_year,
    MONTH(order_purchase_timestamp) AS order_month,
    count(customer_id) AS cunstomer_amount
FROM
    orders
GROUP BY order_year, order_month
ORDER BY order_year, order_month ASC;
#year level
SELECT 
    YEAR(order_purchase_timestamp) AS order_year,
    count(customer_id) AS cunstomer_amount
FROM
    orders
GROUP BY order_year
ORDER BY order_year ASC;

#4. How many products are there in the products table?
SELECT count(DISTINCT product_id) AS products_count FROM products;

#5. Which are the categories with most products?
SELECT DISTINCT p.product_category_name, pcnt.product_category_name_english,
count(DISTINCT p.product_id) AS products_amount
FROM products p
LEFT JOIN product_category_name_translation pcnt
USING (product_category_name)
GROUP BY product_category_name
ORDER BY count(DISTINCT p.product_id) DESC;

#6. How many of those products were present in actual transactions?
SELECT COUNT(DISTINCT product_id) AS used_product_count
FROM order_items
WHERE product_id IS NOT NULL;

#7. What’s the price for the most expensive and cheapest products?
# most expensive product
SELECT DISTINCT(product_id), price
FROM order_items
WHERE price = (SELECT MAX(price) FROM order_items);
# most cheap product
SELECT DISTINCT(product_id), price
FROM order_items
WHERE price = (SELECT MIN(price) FROM order_items);

# 8. What are the highest and lowest payment values?
# highest payment value
SELECT DISTINCT MAX(payment_value) 
FROM order_payments 
AS highest_payment
WHERE payment_value IS NOT NULL;
# lowest payment value
SELECT DISTINCT MIN(payment_value) 
FROM order_payments 
AS lowest_payment
WHERE payment_value IS NOT NULL;
