USE sakila;

-- 1
CREATE TEMPORARY TABLE customer_rental_summary AS
SELECT
    c.customer_id,
    CONCAT(c.first_name, ' ', c.last_name) AS customer_name,
    c.email,
    COUNT(r.rental_id) AS rental_count
FROM customer AS c
LEFT JOIN rental AS r
    ON r.customer_id = c.customer_id
GROUP BY
    c.customer_id,
    c.first_name,
    c.last_name,
    c.email;

-- 2
CREATE TEMPORARY TABLE temp_customer_payments AS
SELECT
    crs.customer_id,
    SUM(p.amount) AS total_paid
FROM customer_rental_summary AS crs
LEFT JOIN payment AS p
    ON p.customer_id = crs.customer_id
GROUP BY
    crs.customer_id;
    
-- 3
WITH customer_summary AS (
    SELECT
        crs.customer_id,
        crs.customer_name,
        crs.email,
        crs.rental_count,
        tcp.total_paid
    FROM customer_rental_summary AS crs
    LEFT JOIN temp_customer_payments AS tcp
        ON crs.customer_id = tcp.customer_id
)
SELECT
    customer_name,
    email,
    rental_count,
    total_paid,
    CASE
        WHEN rental_count > 0 AND total_paid IS NOT NULL THEN
            total_paid / rental_count
        ELSE NULL
    END AS average_payment_per_rental
FROM customer_summary
ORDER BY customer_name;