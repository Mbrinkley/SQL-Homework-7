use sakila;
-- 1a. display the first and last names of all actors 
select first_name, last_name from actor;

-- 1b. display first & last name in a single column in uppercase letters
select concat(first_name, ' ', last_name) as 'Actor Name'
from actor;

-- 2a. find the ID number, first name, and last name of an actor, 
-- of whom you know only the first name, "Joe."
select * from actor
where first_name = 'JOE';

-- 2b. Find all actors whose last name contain the letters GEN
select last_name 
from actor 
where last_name like '%GEN%';

-- 2c. Find all actors whose last names contain the letters LI.
-- order the rows by last name and first name
select last_name, first_name 
from actor 
where last_name like '%LI%';

-- 2d. Using IN, display the country_id and country columns 
-- of the following countries: Afghanistan, Bangladesh, and China
select * from country;
select country_id, country
from country
where country in ('Afghanistan', 'Bangladesh', 'China');

-- 3a. create a column in the table actor named description
alter table actor 
add  description BLOB;
-- 3b. delect column description 
alter table actor
drop description;
select * from actor;

-- 4a. List the last names of actors,how many actors have that last name
select last_name, count(*) as 'Last name count'
from actor
group by last_name;

-- 4b. list last names, & how many have the same (shared by at least 2)
select last_name, count(*) as 'Last name count'
from actor
group by last_name
having count(*) > 2;

-- 4c. rename GROUCHO WILLIAMS to HARPO WILLIAMS
update actor
set first_name = 'HARPO'
where first_name = 'GROUCHO' and last_name = 'Williams';
-- 4d. switch it back 
update actor 
set first_name = 'GROUCHO' 
where first_name = 'HARPO' and last_name = 'WILLIAMS';

-- 5a. cannot locatoe the schema address table, query to recreate it:
describe sakila.address;

-- 6a. use JOIN (tables: Staff & Address) - display first & last names, address
select s.first_name, s.last_name, a.address
from staff s
left join address a on s.address_id = a.address_id;
select * from staff;
-- 6b. use JOIN: display total amount rung up by each staff member
-- in August 2005 (Staff, payment table)
select * from payment;
select * from staff;
select s.first_name, s.last_name, sum(p.amount) as 'Total Amount'
from staff s
left join payment p on s.staff_id = p.staff_id
group by s.first_name, s.last_name;

-- 6c. (inner join) list each film & number of acotrs in the film
-- tables: film_actor, film
select * from film_actor;
select * from film;
select f.title, count(fa.actor_id) as 'Total Actors'
from film f
inner join film_actor fa on f.film_id = fa.film_id
group by f.title;

-- 6d. how many copies of "hunchback Impossible"??????????? 
select * from inventory;
select * from film;
select title, count(inventory_id) as 'Total Copies'
from film f
inner join inventory i 
on f.film_id = i.film_id
where title = 'Hunchback Impossible';

-- 6e. (tables: payment & customer) JOIN - list the total paid 
-- by each customber alphabetically by last name
select * from payment;
select * from customer;
select first_name, last_name, sum(amount) as 'Total Amount Paid'
from payment p
inner join customer c 
on p.customer_id = c.customer_id
group by last_name asc;

-- 7a. subqueries to display titles of movies starting with K & Q
-- language = english 
select * from film;
select * from language;
select title 
from film
where (title like 'K%' or title like 'Q%')
and language_id =(select language_id from language where name = 'English');

-- 7b. subqueries to display all actors in film = Alone Trip
select * from actor;
select * from film_actor;
select * from film;
select first_name, last_name
from actor
where actor_id in 
(
select actor_id 
from film_actor
where film_id in
(
select film_id 
from film
where title = 'Alone Trip'
));

-- 7c.  joins - retreieve emails of all canadian customers
select * from country;
select * from customer;
select * from address;
select * from city;
select cust.first_name, cust.last_name, cust.email
from customer cust
join address a on (cust.address_id = a.address_id)
join city cit
on (cit.city_id = a.city_id)
join country c
on (c.country_id = cit.country_id)
where c.country = 'Canada';

-- 7d. identify all movies categorized as family films
select * from film;
select * from category;
select * from film_category;
select title as 'Family Films'
from film
where film_id in 
(
select film_id from film_category 
where category_id in
(
select category_id from category 
where name = 'Family'
));

-- 7e. most frequently rented movies - descending order
select * from film;
select * from rental;
select * from inventory;
select f.title, count(rental_id) as 'Most Frequently Rented Movies'
from rental r
join inventory i 
on ( r.inventory_id = i.inventory_id)
join film f
on ( i.film_id = f.film_id)
group by f.title
order by count(rental_id) desc;

-- 7f. query - display how much business, in $ each store brought in
select * from inventory;
select * from payment;
select * from staff;
select * from store; 
select st.store_id, sum(amount) as 'Revenue'
from store st
join staff s
on (s.store_id = st.store_id)
join payment p 
on (s.staff_id = p.staff_id)
group by st.store_id;

-- 7g. query - display for each store = store ID, city, country
select * from store;
select * from city;
select * from address;
select * from country;
select st.store_id, cit.city, c.country
from store st 
join address a
on( st.address_id = a.address_id)
join city cit
on (a.city_id = cit.city_id)
join country c 
on ( cit.country_id = c.country_id);

-- 7h. list top 5 genres in gross revenue in desc order
select * from category;
select * from film_category;
select * from inventory;
select * from payment;
select * from rental;
select c.name as 'Top 5 Genres', sum(amount) as 'Gross Revenue'
from category c
join film_category fc 
on (fc.category_id = c.category_id)
join inventory i 
on (i.film_id = fc.film_id)
join rental r 
on (r.inventory_id = i.inventory_id)
join payment p
on (p.rental_id = r.rental_id)
group by c.name
order by sum(amount) desc limit 5;

-- 8a. create a view
drop view if exists top_five_genres;
create view top_five_genres as 
select c.name as 'Top 5 Genres', sum(amount) as 'Gross Revenue'
from category c
join film_category fc 
on (fc.category_id = c.category_id)
join inventory i 
on (i.film_id = fc.film_id)
join rental r 
on (r.inventory_id = i.inventory_id)
join payment p
on (p.rental_id = r.rental_id)
group by c.name
order by sum(amount) desc limit 5;

-- 8b. display view 
select * from top_five_genres;

-- 8c. delete view
drop view top_five_genres;
 