
--Question 1. Creating the tables and inserting the various constraint and
-- data types in parch and porsey database

CREATE TABLE region(
	id serial PRIMARY KEY,
	name varchar(255) NOT NULL
);


CREATE TABLE sales_reps(
	id serial PRIMARY KEY,
	name varchar(255) NOT NULL,
	region_id Int REFERENCES region(id)
);


CREATE TABLE accounts (
    id SERIAL PRIMARY KEY,
    name VARCHAR(255) NOT NULL UNIQUE,
    website VARCHAR(255),
    lat DOUBLE PRECISION,
    long DOUBLE PRECISION,
    primary_poc VARCHAR(255),
    sales_rep_id INT REFERENCES sales_reps(id)
);


CREATE TABLE web_events(
    id SERIAL PRIMARY KEY,
    account_id INT REFERENCES accounts(id),
    occurred_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    channel VARCHAR(255) NOT NULL
);


CREATE TABLE orders(
    id SERIAL PRIMARY KEY,
    account_id INT REFERENCES accounts(id),
    standard_qty INT CHECK (standard_qty >= 0),
    poster_qty INT CHECK (poster_qty >= 0),
    total INT CHECK (total >= 0),
    standard_amt_usd DECIMAL(10, 2) CHECK (standard_amt_usd >= 0),
    gloss_amt_usd DECIMAL(10, 2) CHECK (gloss_amt_usd >= 0),
    poster_amt_usd DECIMAL(10, 2) CHECK (poster_amt_usd >= 0),
    total_amt_usd DECIMAL(10, 2) CHECK (total_amt_usd >= 0)
);

--Adding Primary Key constraint (region)
ALTER TABLE region
ADD CONSTRAINT pk_region_id PRIMARY KEY (id);


-- Adding Primary Key constraint (sales_reps)
ALTER TABLE sales_reps
ADD CONSTRAINT pk_sales_rep_id PRIMARY KEY (id);


-- Adding Foreign Key constraint (sales_reps)
ALTER TABLE sales_reps
ADD CONSTRAINT fk_sales_rep_region
FOREIGN KEY (region_id)
REFERENCES region(id);


-- Adding Primary Key constraint (accounts)
ALTER TABLE accounts
ADD CONSTRAINT pk_accounts_id PRIMARY KEY (id);


-- Adding Foreign Key constraint (accounts)
ALTER TABLE accounts
ADD CONSTRAINT fk_accounts_sales_rep
FOREIGN KEY (sales_rep_id)
REFERENCES sales_reps(id);


-- Adding Not Null constraints(accounts)
ALTER TABLE accounts
ALTER COLUMN name SET NOT NULL;
ALTER TABLE accounts
ALTER COLUMN website SET NOT NULL;


-- Adding Unique constraint
ALTER TABLE accounts
ADD CONSTRAINT uq_accounts_name UNIQUE (name);

-- Adding Primary Key constraint(web_events)
ALTER TABLE web_events
ADD CONSTRAINT pk_web_events_id PRIMARY KEY (id);


-- Adding Foreign Key constraint(web_events)
ALTER TABLE web_events
ADD CONSTRAINT fk_web_events_accounts
FOREIGN KEY (account_id)
REFERENCES accounts(id);


-- Adding Default constraint on occurred_at
ALTER TABLE web_events
ALTER COLUMN occurred_at SET DEFAULT CURRENT_DATE;


-- Adding Not Null constraint on channel
ALTER TABLE web_events
ALTER COLUMN channel SET NOT NULL;


-- Adding Primary Key constraint(orders)
ALTER TABLE orders
ADD CONSTRAINT pk_orders_id PRIMARY KEY (id);


-- Adding Foreign Key constraint
ALTER TABLE orders
ADD CONSTRAINT fk_orders_account
FOREIGN KEY (account_id)
REFERENCES accounts(id);


-- Adding Check constraints
ALTER TABLE orders
ADD CONSTRAINT chk_orders_standard_qty CHECK (standard_qty >= 0);

ALTER TABLE orders
ADD CONSTRAINT chk_orders_poster_qty CHECK (poster_qty >= 0);

ALTER TABLE orders
ADD CONSTRAINT chk_orders_total CHECK (total >= 0);

ALTER TABLE orders
ADD CONSTRAINT chk_orders_standard_amt_usd CHECK (standard_amt_usd >= 0);

ALTER TABLE orders
ADD CONSTRAINT chk_orders_gloss_amt_usd CHECK (gloss_amt_usd >= 0);

ALTER TABLE orders
ADD CONSTRAINT chk_orders_poster_amt_usd CHECK (poster_amt_usd >= 0);

ALTER TABLE orders
ADD CONSTRAINT chk_orders_total_amt_usd CHECK (total_amt_usd >= 0);


-- Assignment 4 querry the parch and porsey database
-- 1. Use the accounts table to find
--All the companies whose names start with 'C'

SELECT * FROM accounts
WHERE name LIKE 'C%'


-- 1. Use the accounts table to find
-- All the companies whose names start with 'C'

SELECT * FROM accounts;
SELECT * FROM accounts
WHERE name LIKE 'C%';

--All companies whose names contain the string 'one' somewhere in the name.
SELECT *
FROM accounts
WHERE name LIKE '%one%';

-- All companies whose names end with 's'.
SELECT *
FROM accounts
WHERE name LIKE '%s';

-- 2. Use the accounts table to find the account name, primary_poc,
-- and sales_rep_id for Walmart, Target, and Nordstrom.

SELECT name AS accountName, primary_poc, sales_rep_id
FROM accounts
WHERE name IN ('Walmart', 'Target', 'Nordstrom');

--3. Use the web_events table to find all information regarding individuals
-- who were contacted via the channel of organic or adwords.

SELECT *
FROM web_events
WHERE channel IN ('organic', 'adwords');

--4. Write a query that returns all the orders where the standard_qty is over
-- 1000, the poster_qty is 0, and the gloss_qty is 0.

SELECT standard_qty, gloss_qty, poster_qty
FROM orders
WHERE standard_qty > 1000
  AND poster_qty = 0
  AND gloss_qty = 0;

--5. Using the accounts table, find all the companies whose names do not
-- start with 'C' and end with 's'.
SELECT name
FROM accounts
WHERE name NOT LIKE 'C%' AND name LIKE '%s';

--6. When you use the BETWEEN operator in SQL, do the results include the
-- values of your endpoints, or not? Figure out the answer to this important
-- question by writing a query that displays the order date and gloss_qty data
--for all orders where gloss_qty is between 24 and 29. Then look at your output
-- to see if the BETWEEN operator included the begin and end values or not.

SELECT occurred_at AS orderdate, gloss_qty
FROM orders
WHERE gloss_qty BETWEEN 24 AND 29;

-- Output shows that the BETWEEN operator included the begin and end values.
--7. Use the web_events table to find all information regarding individuals who
-- were contacted via the organic or adwords channels, and started their account
-- at any point in 2016, sorted from newest to oldest.

SELECT *
FROM web_events
WHERE channel IN ('organic', 'adwords')
AND EXTRACT(YEAR FROM occurred_at) = 2016
ORDER BY occurred_at DESC;

--8. Find list of orders ids where either gloss_qty or poster_qty is greater
-- than 4000. Only include the id field in the resulting table.

SELECT id AS list_of_ordersids
FROM orders
WHERE gloss_qty > 4000 OR poster_qty > 4000;

--9. Write a query that returns a list of orders where the standard_qty
-- is zero and either the gloss_qty or poster_qty is over 1000.

SELECT *
FROM orders
WHERE standard_qty = 0
AND (gloss_qty > 1000 OR poster_qty > 1000);

--10. Find all the company names that start with a 'C' or 'W', and the
-- primary contact contains 'ana' or 'Ana', but it doesn't contain 'eana'.

SELECT name, primary_poc
FROM accounts
WHERE (name LIKE 'C%' OR name LIKE 'W%')
AND (primary_poc ILIKE '%ana%' AND primary_poc NOT ILIKE '%eana%');

--11. Create a column that divides the standard_amt_usd by the standard_qty
-- to find the unit price for standard paper for each order.
-- Limit the results to the first 10 orders, and include the id and account_id fields.

SELECT id, account_id, standard_amt_usd, standard_qty,
      ROUND(standard_amt_usd / standard_qty, 2) AS unit_price
FROM orders
LIMIT 10;

--12. Write a query that finds the percentage of revenue that comes from poster paper
-- for each order. You will need to use only the columns that end with _usd.
-- (Try to do this without using the total column.) Display the id and account_id fields ????

SELECT id, account_id,
       poster_amt_usd / (standard_amt_usd + gloss_amt_usd + poster_amt_usd)
	   * 100 AS poster_percentage
FROM orders; --Returns error cant divide by zero

--13. Pulls the first 5 rows and all columns from the orders table that have a
-- dollar amount of gloss_amt_usd greater than or equal to 1000.

SELECT *
FROM orders
WHERE gloss_amt_usd >= 1000
LIMIT 5;

--14. Pull the first 10 rows and all columns from the orders table that have
-- a total_amt_usd less than 500.

SELECT *
FROM orders
WHERE total_amt_usd < 500
LIMIT 10;
































