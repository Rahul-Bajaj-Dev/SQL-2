-- 1. Retrieve the names of all products that have been shipped from a warehouse located in 'New York'.
SELECT DISTINCT p.product_name
FROM products p
JOIN shipments s ON p.product_id = s.product_id
JOIN warehouses w ON s.warehouse_id = w.warehouse_id
WHERE w.location = 'New York';

-- 2. Calculate the total quantity of each product present across all warehouses.
SELECT p.product_id, p.product_name, SUM(i.quantity) AS total_quantity
FROM inventory i
JOIN products p ON i.product_id = p.product_id
GROUP BY p.product_id, p.product_name;

-- 3. Identify the warehouse that has dispatched the highest number of shipments.
SELECT w.warehouse_id, w.warehouse_name, COUNT(s.shipment_id) AS total_shipments
FROM shipments s
JOIN warehouses w ON s.warehouse_id = w.warehouse_id
GROUP BY w.warehouse_id, w.warehouse_name
ORDER BY total_shipments DESC
LIMIT 1;

-- 4. List all products that have never been part of any shipment.
SELECT p.product_id, p.product_name
FROM products p
LEFT JOIN shipments s ON p.product_id = s.product_id
WHERE s.product_id IS NULL;

-- 5. Update the quantity of a specific product in a particular warehouse after a new shipment arrives.
UPDATE inventory
SET quantity = quantity - 10  -- Adjust the quantity as per the shipment
WHERE product_id = 101  -- Example product ID
AND warehouse_id = 5;  -- Example warehouse ID

-- 6. Create a report that displays the average shipment processing time (time from arrival to dispatch) for each warehouse.
SELECT w.warehouse_id, w.warehouse_name, AVG(s.dispatch_date - s.arrival_date) AS avg_processing_time
FROM shipments s
JOIN warehouses w ON s.warehouse_id = w.warehouse_id
GROUP BY w.warehouse_id, w.warehouse_name;

-- 7. Add a new warehouse to the database with its respective details.
INSERT INTO warehouses (warehouse_id, warehouse_name, location, capacity)
VALUES (10, 'West Coast Hub', 'Los Angeles', 50000);

-- 8. Remove shipments that are older than five years from the database to optimize storage.
DELETE FROM shipments
WHERE dispatch_date < NOW() - INTERVAL '5 years';

-- 9. Retrieve the top 5 most expensive products from each warehouse.
SELECT warehouse_id, product_id, product_name, price
FROM (
    SELECT i.warehouse_id, p.product_id, p.product_name, p.price,
           RANK() OVER (PARTITION BY i.warehouse_id ORDER BY p.price DESC) AS rank
    FROM inventory i
    JOIN products p ON i.product_id = p.product_id
) ranked_products
WHERE rank <= 5;

-- 10. Create a view that combines product details with their corresponding shipment information.
CREATE VIEW product_shipments AS
SELECT p.product_id, p.product_name, s.shipment_id, s.warehouse_id, s.arrival_date, s.dispatch_date
FROM products p
JOIN shipments s ON p.product_id = s.product_id;
