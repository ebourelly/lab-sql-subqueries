-- LAB 3.03 - SQL SUBQUERIES

USE sakila;

-- 1. How many copies of the film Hunchback Impossible exist in the inventory system?

SELECT COUNT(DISTINCT(inventory_id)) AS number_of_copies
	FROM sakila.inventory
	WHERE film_id = (
		SELECT film_id
		FROM sakila.film
        WHERE title = 'Hunchback Impossible'
        );

-- output : there are 6 physical copies


-- 2. List all films whose length is longer than the average of all the films.

SELECT film_id, title, length
FROM sakila.film
WHERE length > (
	SELECT AVG(length)
    FROM sakila.film
    );

-- output shows a list of 489 films out of the 1 000 the table contains


-- 3. Use subqueries to display all actors who appear in the film Alone Trip.

SELECT actor_id, first_name, last_name
FROM sakila.actor
WHERE actor_id IN (
		SELECT actor_id
        FROM film_actor
        WHERE film_id = (
			SELECT film_id
            FROM sakila.film
            WHERE title = 'Alone Trip'
            )
		);
        
-- output is a list of 8 actors


-- 4. Sales have been lagging among young families, and you wish to target all family movies for a promotion.
-- Identify all movies categorized as family films.

SELECT title
FROM sakila.film
WHERE film_id IN (
		SELECT film_id
        FROM sakila.film_category
        WHERE category_id = (
			SELECT category_id
            FROM sakila.category
            WHERE name = 'Family'
            )
		);
        
-- output is 69 movies


-- 5. Get name and email from customers from Canada using subqueries. Do the same with joins. Note that to create
-- a join, you will have to identify the correct tables with their primary keys and foreign keys, that will help
-- you get the relevant information.


-- Version with subqueries
SELECT first_name, last_name, email
FROM sakila.customer
WHERE address_id IN (
	SELECT address_id
    FROM sakila.address
    WHERE city_id IN (
		SELECT city_id
        FROM sakila.city
        WHERE country_id = (
			SELECT country_id
            FROM sakila.country
            WHERE country = 'Canada'
            )
		)
	);
-- output contais a list of 5 customers and their coordinates

-- verion with JOIN

SELECT first_name, last_name, email
FROM sakila.customer
JOIN sakila.address
USING (address_id)
	JOIN sakila.city
	USING (city_id)
		JOIN sakila.country
		USING (country_id)
		WHERE country = 'Canada';

-- same output, with the 5 formerly identified customers


-- 6. Which are films starred by the most prolific actor? Most prolific actor is defined as the actor that has acted
-- in the most number of films. First you will have to find the most prolific actor and then use that actor_id to
-- find the different films that he/she starred.

SELECT title
FROM sakila.film
WHERE film_id IN (
	SELECT film_id
    FROM sakila.film_actor
    WHERE actor_id = (
		SELECT actor_id
        FROM sakila.film_actor
        GROUP BY actor_id
        ORDER BY COUNT(DISTINCT(film_id)) DESC
        LIMIT 1
		)
	);

-- output returns a list of 42 movies


-- 7. Films rented by most profitable customer. You can use the customer table and payment table to find the most
-- profitable customer ie the customer that has made the largest sum of payments

SELECT title
FROM sakila.film
WHERE film_id IN (
	SELECT DISTINCT(film_id)
    FROM sakila.inventory
    WHERE inventory_id IN (
		SELECT inventory_id
        FROM sakila.rental
        WHERE customer_id = (
			SELECT DISTINCT(customer_id)
            FROM sakila.payment
            GROUP BY customer_id
            ORDER BY SUM(amount) DESC
            LIMIT 1
            )
        )
    );

-- output = 44 list of the 44 film titles rented by the most profitable customer

-- 8. Customers who spent more than the average payments.

-- I assume that we want to see the list of customers whose average payment is above the average of all customers
-- I leave the customer_id in the output, as there might be different customers with the same name

SELECT customer_id, first_name, last_name
FROM sakila.customer
WHERE customer_id IN (
	SELECT customer_id
    FROM (
		SELECT customer_id, AVG(amount) AS average_spent
        FROM sakila.payment
        GROUP BY customer_id
        HAVING average_spent > (
			SELECT AVG(amount)
            FROM sakila.payment
            )
        ) sub_1
    );

-- output is a list of 298 cusomers