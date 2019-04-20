USE sakila;

#1a. Display the first and last names of all actors from the table `actor`.
SELECT first_name, last_name FROM actor;

# 1b. Display the first and last name of each actor in a single column in upper case letters. Name the column `Actor Name`.
SELECT CONCAT(first_name , '  ', last_name ) AS Actor_Name FROM actor;

# 2a. You need to find the ID number, first name, and last name of an actor, of whom you know only the first name, "Joe."
SELECT actor_id, first_name, last_name FROM actor WHERE first_name = 'Joe';

#2b. Find all actors whose last name contain the letters `GEN`:
SELECT actor_id,first_name, last_name 
FROM actor
WHERE last_name LIKE '%gen%';

# 2c. Find all actors whose last names contain the letters `LI`. This time, order the rows by last name and first name, in that order:
SELECT last_name, first_name
FROM actor 
WHERE last_name LIKE '%li%';

#2d. Using IN, display the country_id and country columns of the following countries:
# Afghanistan, Bangladesh, and China:
SELECT  
country_id, country
FROM
country
WHERE
country IN ('Afghanistan', 'Bangladesh', 'China');


#3a.You want to keep a description of each actor. You don't think you will be performing queries on a description
SELECT * FROM actor;
-- SE ME HACE FALTA ESTE CODIGO 
ALTER TABLE actor
ADD COLUMN description BLOB AFTER last_update;


#3b.Very quickly you realize that entering descriptions for each actor is too much effort. Delete the `description` column.
ALTER TABLE actor  DROP COLUMN description;
SELECT * FROM actor;

#4a. List the last names of actors, as well as how many actors have that last name.
SELECT last_name, COUNT(*)
AS total_last 
FROM actor
GROUP BY last_name;

-- 4b. List last names of actors and the number of actors who have that last name, but only for names that are shared by at least two actors
SELECT  last_name, COUNT(*)
AS total_last 
FROM actor
GROUP BY last_name
HAVING total_last >=2;


-- 4c. The actor `HARPO WILLIAMS` was accidentally entered in the `actor` table as `GROUCHO WILLIAMS`. Write a query to fix the record.

SET SQL_SAFE_UPDATES = 0;
UPDATE actor 
SET first_name = "HARPO" 
WHERE actor_id = 172;

-- 4d. Perhaps we were too hasty in changing GROUCHO to HARPO. It turns out that GROUCHO was the correct name after all! 
-- In a single query, if the first name of the actor is currently HARPO, change it to GROUCHO. 
UPDATE actor 
SET first_name = "GROUCHO" 
WHERE actor_id = 172;

SET SQL_SAFE_UPDATES = 1;
-- 5a. You cannot locate the schema of the `address` table. Which query would you use to re-create it?
SHOW TABLES;
DESCRIBE address;

DESCRIBE sakila.address;


-- 6a.Use `JOIN` to display the first and last names, as well as the address, of each staff member. Use the tables `staff` and `address`
SELECT * FROM staff;
SELECT * FROM address;

SELECT staff.first_name, staff.last_name, address.address
FROM  address 
INNER JOIN staff 
ON staff.address_id = address.address_id;



-- 6b. Use `JOIN` to display the total amount rung up by each staff member in August of 2005. Use tables `staff` and `payment`.
SELECT * FROM staff;
SELECT * FROM payment;

SELECT staff.first_name, staff.last_name,  SUM(payment.amount) AS 'Total Amount'
FROM payment 
JOIN staff 
ON payment.staff_id = staff.staff_id
WHERE payment_date like '2005-08%'
GROUP BY  payment.staff_id;


-- 6c. List each film and the number of actors who are listed for that film. Use tables `film_actor` and `film`. Use inner join.

SELECT * FROM film_actor;
SELECT * FROM film;

SELECT film.title AS 'Film', COUNT(film_actor.actor_id) AS 'Number of Actors'
FROM film
INNER JOIN film_actor 
ON film_actor.film_id = film.film_id
GROUP BY film.title;


-- 6d. How manyes copies of the film `Hunchback Impossible` exist in the inventory system?
SELECT * FROM film;
SELECT * FROM inventory;

SELECT title, (SELECT COUNT(*) FROM inventory 
WHERE film.film_id = inventory.film_id ) AS 'Number of Copies'
FROM film
WHERE title = 'Hunchback Impossible';


-- 6e. Using the tables `payment` and `customer` and the `JOIN` command, list the total paid by each customer. 
-- List the customers alphabetically by last name:
 
SELECT * FROM payment;
SELECT * FROM customer;

SELECT c.first_name, c.last_name , sum(p.amount) AS 'Total Amount Paid'
FROM payment AS p
INNER JOIN customer AS c
ON p.customer_id = c.customer_id
GROUP BY  p.customer_id 
ORDER BY c.last_name;
	


-- 7a. The music of Queen and Kris Kristofferson have seen an unlikely resurgence. As an unintended consequence, 
-- Films starting with the letters `K` and `Q` have also soared in popularity. Use subqueries to display the titles of movies starting with the letters `K` and `Q` whose language is English.
SELECT * FROM language; 
SELECT * FROM film; 

SELECT title
FROM film WHERE title 
LIKE 'K%' OR title LIKE 'Q%'
AND title IN 
(
SELECT title 
FROM film 
WHERE language_id = 1
);


-- 7b. Use subqueries to display all actors who appear in the film `Alone Trip`.
SELECT * FROM actor;
SELECT * FROM film;	

SELECT first_name, last_name
FROM actor
WHERE actor_id in
( 
  SELECT actor_id
  FROM film_actor
  WHERE film_id in
  (
    SELECT film_id 
    FROM film
    WHERE title = 'Alone Trip'
  )
);

-- 7c. You want to run an email marketing campaign in Canada, for which you will need the names and email addresses of all Canadian customers. 
-- Use joins to retrieve this information.
SELECT customer.first_name, customer.last_name, customer.email
FROM customer
INNER JOIN address ON
customer.address_id=address.address_id
INNER JOIN city ON
address.city_id=city.city_id
WHERE country_id = 20;





-- 7d. Sales have been lagging among young families, and you wish to target all family movies for a promotion. 
-- Identify all movies categorized as family films.

SELECT film.film_id, film.title, category.name
FROM film
INNER JOIN film_category 
ON film.film_id=film_category.film_id
INNER JOIN category 
ON film_category.category_id=category.category_id
WHERE name = 'Family';



-- 7e Display the most frequently rented movies in descending order

SELECT f.title AS 'Movie', count(r.rental_date) AS 'Times Rented'
FROM film AS f
JOIN inventory AS i 
ON i.film_id = f.film_id
JOIN rental AS r 
ON r.inventory_id = i.inventory_id
GROUP BY  f.title
ORDER BY  COUNT(r.rental_date) DESC;


-- 7f. Write a query to display how much business, in dollars, each store brought in
SELECT * FROM payment;
SELECT * FROM STORE;

SELECT s.store_id, SUM(amount) AS 'Revenue'
FROM payment p
JOIN rental r
ON (p.rental_id = r.rental_id)
JOIN inventory i
ON (i.inventory_id = r.inventory_id)
JOIN store s
ON (s.store_id = i.store_id)
GROUP BY s.store_id; 
-- 7g. Write a query to display for each store its store ID, city, and country.
SELECT * FROM store;
SELECT * FROM city;
SELECT * FROM country;

SELECT s.store_id, cty.city, country.country 
FROM store s
JOIN address a 
ON (s.address_id = a.address_id)
JOIN city cty
ON (cty.city_id = a.city_id)
JOIN country
ON (country.country_id = cty.country_id);

-- 7h. List the top five genres in gross revenue in descending order. 
-- (Hint: you may need to use the following tables: category, film_category, inventory, payment, and rental.)
SELECT c.name AS 'Genre', SUM(p.amount) AS 'Gross' 
FROM category c
JOIN film_category fc 
ON (c.category_id=fc.category_id)
JOIN inventory i 
ON (fc.film_id=i.film_id)
JOIN rental r 
ON (i.inventory_id=r.inventory_id)
JOIN payment p 
ON (r.rental_id=p.rental_id)
GROUP BY c.name ORDER BY Gross  LIMIT 5;

-- 8a. In your new role as an executive, you would like to have an easy way of viewing the Top five genres by gross revenue. 
-- Use the solution from the problem above to create a view. If you haven't solved 7h, you can substitute another query to create a view.
CREATE VIEW genre_revenue AS
SELECT c.name AS 'Genre', SUM(p.amount) AS 'Gross' 
FROM category c
JOIN film_category fc 
ON (c.category_id=fc.category_id)
JOIN inventory i 
ON (fc.film_id=i.film_id)
JOIN rental r 
ON (i.inventory_id=r.inventory_id)
JOIN payment p 
ON (r.rental_id=p.rental_id)
GROUP BY c.name ORDER BY Gross  LIMIT 5;

-- 8b. How would you display the view that you created in 8a?
SELECT * FROM genre_revenue;
-- 8c. You find that you no longer need the view top_five_genres. Write a query to delete it.
DROP VIEW genre_revenue;








