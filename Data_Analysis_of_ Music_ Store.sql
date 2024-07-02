CREATE DATABASE music_store;
USE music_store;
SELECT DATABASE();
                                                          
                                                          
                                                          -- EASY LEVEL --


-- Q1: WHO IS THE SENIOR MOST EMPLOYEE BASED ON JOB TITLE?--

SELECT * FROM employee;
select first_name,last_name,title,levels from employee
order by levels desc
limit 1;

-- Q2: Which countries have the most Invoices?
select * from invoice;
select billing_country, count(invoice_id) from invoice
group by billing_country
order by count(invoice_id) desc
limit 1;

-- Q3:  What are top 3 values of total invoice?

select * from invoice;
select total from invoice
order by total desc
limit 3; 

-- Q4: Which city has the best customers? We would like to throw a promotional Music Festival in the city we made the most money. 
-- Return both the city name & sum of all invoice totals.


select * from invoice;
select billing_city, sum(total) from invoice
group by billing_city
order by sum(total) desc
limit 1;

-- Q5: Who is the best customer? The customer who has spent the most money will be declared the best customer. 
-- Write a query that returns the person who has spent the most money.

select * from invoice;
select * from customer;

select customer.customer_id,customer.first_name, customer.last_name, sum(invoice.total) as total_money_spent from customer
left join invoice on invoice.customer_id = customer.customer_id
group by  customer.first_name, customer.last_name,customer.customer_id
order by sum(invoice.total) desc
limit 1; 
                                                      -- INTERMEDIATE LEVEL --


-- Q1: Write query to return the email, first name, last name, & Genre of all Rock Music listeners. 
-- Return your list ordered alphabetically by email starting with A.

-- solving_method: used joins to connect the table 
--                 used wildcards to get the match which is like rock
--                 used having clause to filter the data using group by clause

select * from genre;
select * from customer;
select * from invoice_line;
select * from invoice;

select customer.first_name, customer.last_name, customer.email, genre.name from customer
join invoice on invoice.customer_id = customer.customer_id
join invoice_line on invoice.invoice_id = invoice_line.invoice_id
join track on invoice_line.track_id = track.track_id
join genre on  track.genre_id = genre.genre_id
group by genre.name,customer.first_name, customer.last_name, customer.email
having genre.name like  '%Rock%'
order by customer.email asc;


-- Q2: Let's invite the artists who have written the most rock music in our dataset. 
-- Write a query that returns the Artist name and total track count of the top 10 rock bands.

-- solving_method: used join to connect the table
--                 used count function to get the track_count
--                 used limit to get the top ten tracks on the basis of maximum counts. 


select * from artist;
select * from track;
select * from genre;
select * from album2;


select artist.name,count(track.track_id) as track_counts, genre.name from artist
join album2 on artist.artist_id = album2.album_id
join track on track.album_id = album2.album_id
join genre on genre.genre_id = track.genre_id 
where genre.name like '%Rock%'
group by artist.name,genre.name
order by count(track.track_id) desc
limit 10;


-- Q3: Return all the track names that have a song length longer than the average song length. 
-- Return the Name and Milliseconds for each track. Order by the song length with the longest songs listed first.


-- solving_method: calculated the average of the all songs
--                 used subquery to get the avg so that we can compare the avg of all songs and the actual length of the track in the same table
                

select * from track;
select avg(track.milliseconds) from track;

SELECT
    track.name,
    track.milliseconds,
    (SELECT AVG(track.milliseconds) FROM track) AS avg_song_length
FROM
    track
WHERE
    track.milliseconds > (SELECT AVG(track.milliseconds) FROM track)
    order by milliseconds desc;
    
 
                                                     -- ADVANCE LEVEL --


-- Q1:Find how much amount spent by each customer on the best artist artists? Write a query to return customer name, artist name and total spent.

-- SOLVING_METHOD: -frist found the best artist using group by and order by clauses and also by joining the tables
--                 -used common table expression to get a temporary table of the best artist
--                 -finaly calculated the amt spent by each customer on the best artist
                     
    
    SELECT * FROM CUSTOMER;
    SELECT * FROM ARTIST;
    SELECT * FROM INVOICE;
    
  WITH best_selling_artist AS (
	SELECT artist.artist_id AS artist_id, artist.name AS artist_name, SUM(invoice_line.unit_price*invoice_line.quantity) AS total_sales
	FROM invoice_line
	JOIN track ON track.track_id = invoice_line.track_id
	JOIN album2 ON album2.album_id = track.album_id
	JOIN artist ON artist.artist_id = album2.artist_id
	GROUP BY artist.artist_id,artist.name
	ORDER BY total_sales DESC
	LIMIT 1
)
SELECT customer.customer_id, customer.first_name, customer.last_name, best_selling_artist.artist_name, SUM(invoice_line.unit_price*invoice_line.quantity) AS amount_spent
FROM invoice 
JOIN customer  ON customer.customer_id = invoice.customer_id
JOIN invoice_line  ON invoice_line.invoice_id = invoice.invoice_id
JOIN track  ON track.track_id = invoice_line.track_id
JOIN album2  ON album2.album_id = track.album_id
JOIN best_selling_artist  ON best_selling_artist.artist_id = album2.artist_id
GROUP BY  customer.customer_id, customer.first_name, customer.last_name, best_selling_artist.artist_name
ORDER BY amount_spent DESC;
    

-- Q2:find out the most popular music Genre for each country.
-- Write a query that returns each country along with the top Genre. For countries where the maximum number of purchases is shared return all Genres.

-- solving_method: -first calculated the count of each song and then ranked it according to the count using partition over country to get the result on the country basis
--                 -then selected those results where rank was 1 to get the most popular genre for each country.


select * from genre;
select * from customer;
select * from invoice;

with popular_genre as(
select genre.name, customer.country, count(invoice_line.quantity) AS amount_spent,
ROW_NUMBER() OVER(PARTITION BY customer.country ORDER BY COUNT(invoice_line.quantity) DESC) AS Row_No
 from customer
JOIN invoice  ON customer.customer_id = invoice.customer_id
JOIN invoice_line  ON invoice_line.invoice_id = invoice.invoice_id
JOIN track  ON track.track_id = invoice_line.track_id
join genre on genre.genre_id = track.genre_id
group by customer.country,genre.name
order by amount_spent desc)

select * from popular_genre 
where Row_No = 1;



-- Q3: Write a query that determines the customer that has spent the most on music for each country. 
-- Write a query that returns the country along with the top customer and how much they spent. 
-- For countries where the top amount spent is shared, provide all customers who spent this amount.


-- solving_method: used common table expression to get the temporary table
--                 used row_number to get the rank using partition by over country
--                 finaly selected those results where rank is 1 to get the music on which spent was the most


select * from customer;
select * from invoice;

with spent as (
select customer.first_name,customer.last_name,sum(invoice.total) as total_spent,customer.country,
row_number() over(partition by customer.country order by sum(invoice.total)) as row_no
from customer
join invoice on customer.customer_id = invoice.customer_id
group by customer.country,customer.first_name,customer.last_name
order by total_spent)

select * from spent where row_no = 1;

    



