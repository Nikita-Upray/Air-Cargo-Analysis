CREATE DATABASE air;
USE air;

SELECT * FROM customer;
SELECT * FROM passengers_on_flights;
SELECT * FROM routes;
SELECT * FROM ticket_details;

/* (Q - 1) Write a query to create a route_details table using suitable data types 
for the fields, such as route_id, flight_num, origin_airport, 
destination_airport, aircraft_id, and distance_miles; implement the 
check constraint for the flight number and unique constraint for the 
route_id fields; also, make sure that the distance miles field is greater 
than 0 */

CREATE TABLE route_details(
	route_id INT PRIMARY KEY,
    flight_num INT,
    origin_airport VARCHAR(10),
    destination_airport VARCHAR(10),
    aircraft_id VARCHAR(15),
    distance_miles INT
);

SELECT * FROM route_details;
    
/* (Q - 2) Write a query to display all the passengers (customers) who have 
traveled on routes 01 to 25; refer to the data from the 
passengers_on_flights table. */

SELECT * 
FROM passengers_on_flights
WHERE route_id BETWEEN 1 AND 25
ORDER BY route_id;

/* (Q - 3) Write a query to identify the number of passengers and total revenue in 
business class from the ticket_details table. */

SELECT COUNT(*) AS 'No. of Passsengers',
		SUM(Price_per_ticket) AS 'Total Revenue'
FROM ticket_details
WHERE class_id = 'Bussiness';
    
/* (Q - 4) Write a query to display the full name of the customer by extracting the 
first name and last name from the customer table. */

SELECT 
	CONCAT(first_name, ' ', last_name) AS 'Customer Name'
FROM customer;

/* (Q - 5) Write a query to extract the customers who have registered and 
booked a ticket. Use data from the customer and ticket_details tables. */

SELECT c.customer_id, first_name, last_name
FROM customer AS c
JOIN ticket_details AS td
	ON c.customer_id = td.customer_id
WHERE no_of_tickets > 0; 

/* (Q - 6) Write a query to identify the customer’s first name and last name based 
on their customer ID and brand (Emirates) from the ticket_details table. */

SELECT c.customer_id, first_name, last_name, brand
FROM customer AS c
JOIN ticket_details AS td
	ON c.customer_id = td.customer_id
WHERE brand = 'Emirates';

/* (Q - 7) Write a query to identify the customers who have traveled by Economy 
Plus class using Group By and Having clause on the 
passengers_on_flights table. */

SELECT customer_id, class_id, 
		COUNT(*) AS num_flights
FROM passengers_on_flights
WHERE class_id = 'Economy Plus'
GROUP BY customer_id
HAVING  num_flights > 0;

/* (Q - 8) Write a query to identify whether the revenue has crossed 10000 using 
the IF clause on the ticket_details table. */

SELECT SUM(Price_per_ticket) AS 'Total Revenue',
	IF(SUM(Price_per_ticket) > 10000, 'The revenue crossed 10000',
										'The revenue not crossed 10000') AS 'Revenue Status'
FROM ticket_details;

/* (Q - 9) Write a query to create and grant access to a new user to perform 
operations on a database. */

CREATE USER 'new_user'@'localhost' IDENTIFIED BY 'password11';
GRANT ALL PRIVILEGES ON air TO 'new_user'@'localhost';

SHOW GRANTS FOR 'new_user'@'localhost';

/* (Q - 10) Write a query to find the maximum ticket price for each class using 
window functions on the ticket_details table. */

SELECT DISTINCT(class_id), 
		 MAX(Price_per_ticket) OVER (PARTITION BY class_id) AS max_ticket_price
FROM ticket_details;

/* (Q - 11) Write a query to extract the passengers whose route ID is 4 by 
improving the speed and performance of the passengers_on_flights 
table. */

CREATE INDEX idx_route_id ON passengers_on_flights (route_id);

SELECT * 
FROM passengers_on_flights
WHERE route_id = 4;

/* (Q - 12) For route ID 4, write a query to view the execution plan of the 
passengers_on_flights table. */

EXPLAIN SELECT * 
FROM passengers_on_flights
WHERE route_id = 4;

/* (Q - 13) Write a query to calculate the total price of all tickets booked by a 
customer across different aircraft IDs using the rollup function. */

SELECT customer_id, aircraft_id,
		SUM(Price_per_ticket) AS 'Total Price'
FROM ticket_details
GROUP BY customer_id, aircraft_id WITH ROLLUP
ORDER BY customer_id;

/* (Q - 14) Write a query to create a view with only business class customers along 
with the brand of airlines. */

CREATE VIEW business_class_customers AS
SELECT c.customer_id, first_name, last_name, brand
FROM customer AS c
JOIN ticket_details AS td
ON c.customer_id = td.customer_id
WHERE class_id = 'Bussiness';

SELECT * FROM business_class_customers;

/* (Q - 15) Write a query to create a stored procedure to get the details of all 
passengers flying between a range of routes defined in run time. Also, 
return an error message if the table doesn't exist. */

DELIMITER //

CREATE PROCEDURE GetPassengersByRouteRange(
    IN route_start INT,
    IN route_end INT
)
BEGIN
    DECLARE table_exists INT;

    SELECT COUNT(*) INTO table_exists
    FROM information_schema.tables
    WHERE table_name = 'passengers_on_flights';

    IF table_exists = 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Error: The passengers_on_flights table does not exist.';
    ELSE
        SELECT *
        FROM passengers_on_flights
        WHERE route_id BETWEEN route_start AND route_end;
    END IF;
END//

DELIMITER ;

CALL GetPassengersByRouteRange(1, 10);

/* (Q - 16) Write a query to create a stored procedure that extracts all the details 
from the routes table where the traveled distance is more than 2000 
miles. */

DELIMITER //

CREATE PROCEDURE RoutesByDistance()
BEGIN
    SELECT *
    FROM routes
    WHERE distance_miles > 2000;
END//

DELIMITER ;

CALL RoutesByDistance;

/* (Q - 17) 8. Write a query to create a stored procedure that groups the distance 
traveled by each flight into three categories. The categories are, short 
distance travel (SDT) for >=0 AND <= 2000 miles, intermediate distance 
travel (IDT) for >2000 AND <=6500, and long-distance travel (LDT) for 
>6500. */

DELIMITER //

CREATE PROCEDURE CategorizeFlightDistance()
BEGIN
    SELECT
        flight_num,
        distance_miles,
        CASE
            WHEN distance_miles BETWEEN 0 AND 2000 THEN 'SDT'
            WHEN distance_miles BETWEEN 2000 AND 6500 THEN 'IDT'
            ELSE 'LDT'
        END AS distance_category
    FROM
        routes;
END//

DELIMITER ;

CALL CategorizeFlightDistance;

/* (Q - 18) Write a query to extract ticket purchase date, customer ID, and class ID 
and specify if the complimentary services are provided for the specific 
class using a stored function in the stored procedure on the 
ticket_details table. */

DELIMITER //

CREATE FUNCTION Comp_Services(class_id INT) RETURNS VARCHAR(3) DETERMINISTIC
BEGIN
    DECLARE complimentary_services VARCHAR(3);

    IF class_id IN (1, 2) THEN
        SET complimentary_services = 'Yes';
    ELSE
        SET complimentary_services = 'No';
    END IF;

    RETURN complimentary_services;
END//

DELIMITER ;


DELIMITER //

CREATE PROCEDURE TicketDetailsWithComplimentaryServices()
BEGIN
    SELECT
        td.p_date,
        td.customer_id,
        td.class_id,
        Comp_Services(td.class_id) AS complimentary_services
    FROM
        ticket_details td;
END//

DELIMITER ;

/* (Q - 19) Write a query to extract the first record of the customer whose last 
name ends with Scott using a cursor from the customer table. */

DELIMITER //

CREATE PROCEDURE Customer_LastName()
BEGIN
    DECLARE done INT DEFAULT FALSE;
	DECLARE customer_id INT;
	DECLARE first_name VARCHAR(255);
	DECLARE last_name VARCHAR(255);

    -- Declare a cursor for selecting customers
    DECLARE customer_cursor CURSOR FOR
        SELECT customer_id, first_name, last_name
        FROM customer
        WHERE last_name LIKE 'Scott'
        LIMIT 1;

    -- Declare continue handler
    DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = TRUE;

    OPEN customer_cursor;

    -- Fetch the first record
    FETCH customer_cursor INTO customer_id, first_name, last_name;

    IF NOT done THEN
        -- Output the result
        SELECT customer_id, first_name, last_name;
    ELSE
        SELECT 'No customer found with last name ending in Scott';
    END IF;

    CLOSE customer_cursor;
END//

DELIMITER ;

CALL Customer_LastName();


