SELECT * FROM sakila.actor;
# 1a. actor 1st & last names:
	SELECT first_name, last_name FROM actor;
    
# 1b. 1st & last names in new single column:
	SELECT CONCAT(first_name, " ", last_name) AS "Actor Name"
	FROM actor;
    
# 2a. ID#, 1st & last name of "Joe":
	SELECT actor_id, first_name, last_name FROM actor
    where first_name = "joe";
    
# 2b. actors last name w gen:
	SELECT last_name FROM actor
    where last_name LIKE '%gen%';
    
# 2c. last name, then first containing "LI":
	SELECT last_name, first_name FROM actor
    where last_name LIKE '%li%';
    
# 2d. use IN to dislay country cols for Af/Bang/China:
	SELECT * FROM sakila.country;
    SELECT * FROM country
    WHERE country IN ('Afghanistan','Bangladesh','China');
    
# 3a. add actor desc BLOB column:  w3schools: For BLOBs (Binary Large OBjects). Holds up to 65,535 bytes of data:
	ALTER TABLE `sakila`.`actor` 
	ADD COLUMN `description` BLOB NULL AFTER `last_name`;
    SELECT first_name, last_name, description FROM actor;
    
# 3b. drop/delete description table:
    ALTER TABLE actor
	DROP COLUMN description;
    SELECT * FROM sakila.actor;

# 4a. list actor names and how many actors have that name:
	SELECT last_name FROM actor;
    SELECT last_name, COUNT(last_name)
    FROM actor
    GROUP BY last_name;
    
# 4b. same as above but only for 2 or more matches:
	SELECT last_name, COUNT(last_name)
    FROM actor
    GROUP BY last_name
    HAVING COUNT(last_name) >1;
    
# 4c. update to harpo from groucho:
	SELECT actor_id, last_name, first_name
    FROM actor
    WHERE last_name = "williams";
    UPDATE actor
    SET first_name = "Harpo"
    WHERE actor_id = "172";
    SELECT actor_id, last_name, first_name
    FROM actor
    WHERE actor_id = "172";
    
# 4d. in single query change back to groucho:
	UPDATE actor SET first_name = "Groucho" WHERE actor_id = "172";
    
# 5a.  cannot locate schema for address table - how would you re-create it?:
	SHOW CREATE DATABASE sakila;

# 6a. use tables staff & address to JOIN first & last names with their address:
	SELECT staff.first_name, staff.last_name, address.address, address.address2, address.district, address.postal_code
    FROM staff
    LEFT JOIN address
    ON staff.address_id = address.address_id;
    SELECT staff.first_name, staff.last_name, address.address, address.address2, address.district, address.postal_code;
    
	# 6b. FIRST TEST - use JOIN to display the total rung up by each staff member in 8/2005
	# display grand totals
    #SELECT staff.first_name, staff.last_name, payment.payment_date, SUM(amount) AS RegisterTotal
    #FROM staff
    #LEFT JOIN payment 
    #ON staff.staff_id = payment.staff_id 
    #GROUP BY staff.staff_id;
        
    # 6b. SECOND TEST - displays totals for 2005-08 only but only out of the payment table
    #SELECT payment.staff_id, SUM(payment.amount) 
    #FROM payment
    #WHERE payment_date LIKE '2005-08%'
    #GROUP BY payment.staff_id;
    
# 6b. SOLUTION - use JOIN to display the total rung up by each staff member in 8/2005:
    SELECT staff.first_name, staff.last_name, SUM(payment.amount) AS RegisterTotal    
    FROM payment 
    LEFT JOIN staff 
    ON payment.staff_id = staff.staff_id 
    AND payment_date LIKE '2005-08%' 
    WHERE staff.last_name IS NOT NULL
    GROUP BY staff.last_name;

# 6c. films and actors for each film:
    SELECT film.title, COUNT(film_actor.actor_id)
    FROM film
    LEFT JOIN film_actor
    ON film.film_id = film_actor.film_id
    GROUP BY film.title;
    
# 6d. # copies of hunchback impossible:
	SELECT film.title, COUNT(inventory.store_id) AS "Film Copies Total"
    FROM inventory
    LEFT JOIN film
    ON inventory.film_id = film.film_id
    GROUP BY title
    HAVING film.title="Hunchback Impossible";

# 6e. total paid by customer:
	SELECT customer.first_name, customer.last_name, SUM(payment.amount) AS "Total Amount Paid" 
    FROM payment
    LEFT JOIN customer
    ON payment.customer_id = customer.customer_id
    GROUP BY last_name
    ORDER by last_name;
    
# 7a. films starting with K & Q with langusgae of English:
	SELECT language.name, sub.title
	FROM language
	JOIN (
	SELECT film_id, title, language_id
	FROM film
	WHERE title LIKE 'K%' OR title LIKE 'Q%'
	AND film.language_id = '1'
	) 
	sub ON language.language_id = sub.language_id;
    
# 7b. all actors who appear in the film "Alone Trip":
	SELECT title, first_name, last_name
	FROM film
	JOIN 
	(
	SELECT first_name, last_name, film_actor.film_id
	FROM actor
	LEFT JOIN film_actor
	ON actor.actor_id = film_actor.actor_id
	)
	sub ON film.film_id = sub.film_id 
	WHERE film.film_id = '17';
    
# 7c.  Canadian cusstomer e-mails - solution 'A' with subquery JOIN:
    SELECT customer.first_name, customer.last_name, customer.email
    FROM customer
    JOIN
    (
    SELECT city.city_id, city.country_id, address_id
    FROM address
    LEFT JOIN city
    ON address.city_id = city.city_id
    WHERE city.country_id = '20'
    )
    sub ON customer.address_id = sub.address_id;
    
#7c. solution 'B' Canadian email addresses with JOINS ONLY:
    SELECT customer.first_name, customer.last_name, customer.email
	FROM customer
	LEFT JOIN address ON customer.address_id = address.address_id
	LEFT JOIN city ON address.city_id = city.city_id
	LEFT JOIN country ON city.country_id = country.country_id
	WHERE country.country = 'canada';
    
# 7d. family film category solution 'A' with subquery JOIN:
    SELECT sub.name, film.title
	FROM film
	JOIN
	(
	SELECT film_category.film_id, category.category_id, category.name
	FROM category
	LEFT JOIN film_category
	ON category.category_id = film_category.category_id
	WHERE film_category.category_id = '8'
	)
	sub ON film.film_id = sub.film_id;
    
#7d. solution 'B' with JOINS ONLY:
    SELECT category.name, film.title
	FROM film 
	LEFT JOIN film_category ON film.film_id = film_category.film_id
	LEFT JOIN category ON film_category.category_id = category.category_id
	WHERE category.name = 'family';

# 7e. list most frequenty rented movies in descending order:
	SELECT film.title, COUNT(inventory.film_id) AS Totals
	FROM rental
	LEFT JOIN inventory ON rental.inventory_id = inventory.inventory_id
	LEFT JOIN film ON inventory.film_id = film.film_id
	GROUP BY inventory.film_id
	ORDER BY Totals DESC;

# 7f. How much revenue each sotre brought in:
	SELECT store.store_id, SUM(payment.amount)
	FROM payment
	LEFT JOIN store
	ON payment.staff_id = store.manager_staff_id
	GROUP BY staff_id;
    
# 7g. display store_id, city & country:
	SELECT store.store_id, city.city, country.country 
    FROM store
	LEFT JOIN address on store.address_id = address.address_id
	LEFT JOIN city on address.city_id = city.city_id
	LEFT JOIN country on city.country_id = country.country_id;

# 7h. total revenue by genre:
	SELECT category.name AS Genre, SUM(payment.amount) AS 'Total Revenue'
	FROM payment
	LEFT JOIN rental ON payment.customer_id = rental.customer_id
	LEFT JOIN inventory ON rental.inventory_id = inventory.inventory_id
	LEFT JOIN film_category ON inventory.film_id = film_category.film_id
	LEFT JOIN category ON film_category.category_id = category.category_id
	GROUP BY category.name
	ORDER BY 'Total Revenue' DESC;
    
# 8a. create view of 7h:
	CREATE OR REPLACE VIEW top_5 AS
    SELECT category.name AS Genre, SUM(payment.amount) AS 'Total Revenue'
	FROM payment
	LEFT JOIN rental ON payment.customer_id = rental.customer_id
	LEFT JOIN inventory ON rental.inventory_id = inventory.inventory_id
	LEFT JOIN film_category ON inventory.film_id = film_category.film_id
	LEFT JOIN category ON film_category.category_id = category.category_id
	GROUP BY category.name
    #HAVING 'Total Revenue' > '100000'
	ORDER BY 'Total Revenue' DESC;
    
    
# 8b. display view created above:
	SELECT * FROM top_5
    LIMIT 5;
    
# 8c. drop view:
	DROP VIEW top_5;
    
    
    
    
    
    

    





    
    
    
    
      
    
    
    
    
    
    
    
    
    
    

    
    
    
    
    
    
    
    
    
    
    
    
    




    

    