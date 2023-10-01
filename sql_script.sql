-- Creating Table: dimDate
CREATE TABLE dimDate
(
	date_key integer 	NOT NULL PRIMARY KEY, -- Unique date key
	date date 			NOT NULL,             -- Date
	year smallint 		NOT NULL,             -- Year
	quarter smallint 	NOT NULL,             -- Quarter
	month smallint 		NOT NULL,             -- Month
	day smallint 		NOT NULL,             -- Day
	weak smallint 		NOT NULL,             -- Week
	is_weekend boolean  -- Weekend indicator
);

-- Creating Table: dimCustomer
CREATE TABLE dimCustomer
(
	customer_key serial PRIMARY KEY, -- Unique customer key
	customer_id smallint NOT NULL,   -- Customer ID
	first_name varchar(45) NOT NULL,  -- First name
	last_name varchar(45) NOT NULL,   -- Last name
	email varchar(50),                -- Email
	address varchar(50) NOT NULL,     -- Address
	address2 varchar(50),             -- Address line 2
	district varchar(30) NOT NULL,    -- District
	city varchar(30) NOT NULL,        -- City
	country varchar(50) NOT NULL,     -- Country
	postal_code varchar(10),          -- Postal code
	phone varchar(20) NOT NULL,       -- Phone
	active smallint NOT NULL,         -- Active status
	create_date timestamp NOT NULL,   -- Creation date
	start_date date NOT NULL,         -- Start date
	end_date date NOT NULL            -- End date
);

-- Creating Table: dimFilm
CREATE TABLE dimFilm
(
	film_key Serial PRIMARY KEY,      -- Unique film key
	film_id smallint NOT NULL,        -- Film ID
	title varchar(225) NOT NULL,      -- Title
	description text,                 -- Description
	release_year year,                -- Release year
	language varchar(20) NOT NULL,    -- Language
	original_language varchar(20),    -- Original language
	rental_duration smallint NOT NULL, -- Rental duration
	length smallint NOT NULL,         -- Length
	rating varchar(5) NOT NULL,       -- Rating
	special_features varchar(60) NOT NULL -- Special features
);

-- Creating Table: dimStore
CREATE TABLE dimStore
(
	store_key Serial PRIMARY KEY,      -- Unique store key
	store_id smallint NOT NULL,        -- Store ID
	address varchar(50) NOT NULL,      -- Address
	address2 varchar(50),              -- Address line 2
	district varchar(20) NOT NULL,     -- District
	city varchar(40) NOT NULL,         -- City
	country varchar(30) NOT NULL,      -- Country
	postal_code varchar(10),           -- Postal code
	manager_first_name varchar(45) NOT NULL, -- Manager's first name
	manager_last_name varchar(45) NOT NULL,  -- Manager's last name
	start_date date NOT NULL,          -- Start date
	end_date date NOT NULL             -- End date
);

-- Inserting Values into dimDate
INSERT INTO dimDate
(date_key, date, year, quarter, month, day, weak, is_weekend)
SELECT
	DISTINCT(TO_CHAR(payment_date :: date, 'yyyymmdd')::integer) as date_key,
	DATE(payment_date) as date,
	EXTRACT(year FROM payment_date) as year,
	EXTRACT(quarter FROM payment_date) as quarter,
	EXTRACT(month FROM payment_date) as month,
	EXTRACT(day FROM payment_date) as day,
	EXTRACT(week FROM payment_date) as week,
	CASE
		WHEN EXTRACT(ISODOW FROM payment_date) IN (6, 7) THEN true
		ELSE false
	END as is_weekend
FROM payment;

-- Inserting Values into dimCustomer
INSERT INTO dimCustomer
(customer_key, customer_id, first_name, last_name, email, address, address2, district, city, country, postal_code, phone, active, create_date, start_date, end_date)
SELECT
	c.customer_id as customer_key, -- Assigning a unique customer key
	c.customer_id,
	c.first_name,
	c.last_name,
	c.email,
	a.address,
	a.address2,
	a.district,
	ct.city,
	cu.country,
	postal_code,
	a.phone,
	c.active,
	c.create_date,
	now() as start_date, -- Setting start_date to the current timestamp
	now() as end_date -- Setting end_date to the current timestamp
FROM customer c
JOIN address a ON (c.address_id = a.address_id)
JOIN city ct ON (a.city_id = ct.city_id)
JOIN country cu ON (ct.country_id = cu.country_id);

-- Inserting Values into dimFilm
INSERT INTO dimFilm
(film_key, film_id, title, description, release_year, language, original_language, rental_duration, length, rating, special_features)
SELECT
	f.film_id as film_key, -- Assigning a unique film key
	f.film_id,
	f.title,
	f.description,
	f.release_year,
	l.name as language,
	ol.name as original_language,
	f.rental_duration,
	f.length,
	f.rating,
	f.special_features
FROM film as f
JOIN language as l ON (f.language_id = l.language_id)
LEFT JOIN language as ol ON (f.language_id = ol.language_id);

-- Inserting Values into dimStore
INSERT INTO dimStore
(store_key, store_id , address, address2, district, city, country, postal_code, manager_first_name, manager_last_name, start_date, end_date)
SELECT
	s.store_id as store_key, -- Assigning a unique store key
	s.store_id,
	a.address,
	a.address2,
	a.district,
	ct.city,
	cu.country,
	a.postal_code,
	st.first_name as manager_first_name,
	st.last_name as manager_last_name,
	now() as start_date, -- Setting start_date to the current timestamp
	now() as end_date -- Setting end_date to the current timestamp
FROM store s
JOIN staff st ON (s.manager_staff_id = st.staff_id)
JOIN address a ON (s.address_id = a.address_id)
JOIN city ct ON (a.city_id = ct.city_id)
JOIN country cu ON (ct.country_id = cu.country_id);

-- Creating Referencing Table: factSales
CREATE TABLE factSales
(
	sales_key serial PRIMARY KEY,           -- Unique sales key
	date_key integer REFERENCES dimDate(date_key), -- Reference to dimDate
	customer_key integer REFERENCES dimCustomer(customer_key), -- Reference to dimCustomer
	film_key integer REFERENCES dimFilm(film_key),          -- Reference to dimFilm
	store_key integer REFERENCES dimStore(store_key),       -- Reference to dimStore
	sales_amount numeric                      -- Sales amount
);

-- Inserting Values into factSales
INSERT INTO factSales
(date_key, customer_key, film_key, store_key, sales_amount)
SELECT
	TO_CHAR(payment_date :: date, 'yyyymmdd')::integer as date_key,
	p.customer_id as customer_key,
	i.film_id as film_key,
	i.store_id as store_key,
	p.amount as sales_amount
FROM payment p
JOIN rental as r on (p.rental_id = r.rental_id)
JOIN inventory as i on (r.inventory_id = i.inventory_id);

-- Show All The Tables
SELECT * FROM dimcustomer;
SELECT * FROM dimdate;
SELECT * FROM dimfilm;
SELECT * FROM dimstore;
SELECT * FROM factSales;

-- Test Star Schema Query
SELECT dimFilm.title, dimDate.month, dimCustomer.city, SUM(sales_amount) as revenue
FROM factSales
JOIN dimFilm on (dimFilm.film_key = factSales.film_key)
JOIN dimDate on (dimDate.date_key = factSales.date_key)
JOIN dimCustomer on (dimCustomer.customer_key = factSales.customer_key)
GROUP BY (dimFilm.title, dimDate.month, dimCustomer.city)
ORDER BY dimFilm.title, dimDate.month, dimCustomer.city, revenue DESC;

-- Test 3NF Schema Query
SELECT f.title, EXTRACT(month FROM p.payment_date) as month, ci.city, SUM(p.amount) as revenue
FROM payment p
JOIN rental r on (p.rental_id = r.rental_id)
JOIN inventory i on (r.inventory_id = i.inventory_id)
JOIN film f on (i.film_id = f.film_id)
JOIN customer c on (p.customer_id = c.customer_id)
JOIN address a on (c.address_id = a.address_id)
JOIN city ci on (a.city_id = ci.city_id)
GROUP BY (f.title, month, ci.city)
ORDER BY f.title, month, ci.city, revenue DESC;