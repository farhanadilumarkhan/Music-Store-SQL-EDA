-- Q1. Who is the senior most employee based on job title?

SELECT EmployeeId, FirstName, LastName, Title, Phone
FROM employee
WHERE ReportsTo IS NULL;

-- Q2. Which countries have the most invoices?

SELECT  COUNT(*) AS Count, BillingCountry AS Country
FROM invoice
GROUP BY BillingCountry
ORDER BY Count DESC;

-- Q3. What are top 3 values of total invoice?

SELECT Total FROM invoice
ORDER BY Total DESC
LIMIT 3;

-- Q4. Which city has the best customers? We would like to throw a promotional Music Festival in the city we made
-- the most money. Write a query that returns one city that has the highest sum of invoice totals. Return both
-- the city name & sum of all invoice totals?

SELECT SUM(Total) AS Invoice_Total, BillingCity AS City_Name
FROM invoice
GROUP BY City_Name
ORDER BY Invoice_Total DESC
LIMIT 1;

-- Q5. Who is the best customer? The customer who has spent the most money will be declared the best customer. 
-- Write a query that returns the person who has spent the most money?

SELECT customer.CustomerId, customer.FirstName, customer.LastName, customer.Email, SUM(invoice.Total) AS Total
FROM customer
JOIN invoice ON customer.CustomerId = invoice.CustomerId
GROUP BY customer.CustomerId
ORDER BY Total DESC;

-- Q6. Write query to return the email, first name, last name, & Genre of all Rock Music listeners. Return your 
-- list ordered alphabetically by email starting with A?

SELECT DISTINCT Email, FirstName, LastName
FROM customer
JOIN invoice ON customer.CustomerID = invoice.CustomerID
JOIN invoiceline ON invoice.InvoiceId = invoiceline.InvoiceId
WHERE TrackId IN(
	SELECT TrackId FROM track
    JOIN genre ON track.GenreId = genre.GenreId
    WHERE genre.Name LIKE 'Rock'
)
ORDER BY Email;

-- Q7. Let's invite the artists who have written the most rock music in our dataset. Write a query that returns 
-- the Artist name and total track count of the top 10 rock bands?

SELECT artist.ArtistId, artist.Name, COUNT(artist.ArtistId) AS Number_of_Songs
FROM track
JOIN album ON album.AlbumId = track.AlbumID
JOIN artist ON artist.ArtistId = album.ArtistId
JOIN genre ON genre.GenreId = track.GenreId
WHERE genre.Name LIKE 'Rock'
GROUP BY artist.ArtistId
ORDER BY Number_of_Songs DESC
LIMIT 10;

-- Q8. Return all the track names that have a song length longer than the average song length. Return the Name 
-- and Milliseconds for each track. Order by the song length with the longest songs listed first?

SELECT Name, Milliseconds 
FROM track
WHERE Milliseconds > (
	SELECT AVG(Milliseconds) AS AVG_Track_Length
    FROM track
)
ORDER BY Milliseconds DESC;

-- Q9. Find how much amount spent by each customer on artists? Write a query to return customer name, artist name 
-- and total spent?

WITH best_selling_artist AS (
	SELECT artist.ArtistId, artist.Name AS Artist_Name, SUM(invoiceline.UnitPrice * invoiceline.Quantity) AS Total 
    FROM invoiceline
    JOIN track ON track.TrackId = invoiceline.TrackId
    JOIN album ON album.AlbumId = track.AlbumId
    JOIN artist ON artist.ArtistId = album.ArtistId
    GROUP BY 1
    ORDER BY 3 DESC
    LIMIT 3
)
SELECT c.CustomerId, c.FirstName, c.LastName, bsa.Artist_Name,
SUM(il.UnitPrice * il.Quantity) AS Amount_Spent
FROM invoice i
JOIN customer c ON c.CustomerId = i.CustomerId
JOIN invoiceline il ON il.InvoiceId = i.InvoiceId
JOIN track t ON t.TrackId = il.TrackId
JOIN album alb ON alb.AlbumId = t.AlbumId
JOIN best_selling_artist bsa ON bsa.ArtistId = alb.ArtistId
GROUP BY 1, 2, 3, 4
ORDER BY 5 DESC;

-- Q10. We want to find out the most popular music Genre for each country. We determine the most popular genre as 
-- the genre with the highest amount of purchases. Write a query that returns each country along with the top Genre. 
-- For countries where the maximum number of purchases is shared return all Genres?

WITH popular_genre AS (
	SELECT COUNT(invoiceline.Quantity) AS Purchases, 
    customer.Country, 
    genre.Name AS Genre_Name, 
    genre.GenreId,
    ROW_NUMBER() OVER(PARTITION BY customer.Country ORDER BY COUNT(invoiceline.Quantity) DESC) AS Row_No
    FROM invoiceline
    JOIN invoice ON invoice.InvoiceId = invoiceline.InvoiceId
    JOIN customer ON customer.CustomerId = invoice.CustomerId
    JOIN track ON track.TrackId = invoiceline.TrackId
    JOIN genre ON genre.GenreId = track.GenreId
    GROUP BY 2, 3, 4
)
SELECT * FROM popular_genre 
WHERE Row_No <= 1
ORDER BY Purchases DESC; 

-- Q11. Write a query that determines the customer that has spent the most on music for each country. Write a 
-- query that returns the country along with the top customer and how much they spent. For countries where the top 
-- amount spent is shared, provide all customers who spent this amount?

WITH customer_with_country AS(
	SELECT customer.CustomerId, FirstName, LastName, BillingCountry, SUM(Total) AS Total_Spending,
    ROW_NUMBER() OVER(PARTITION BY BillingCountry ORDER BY SUM(Total) DESC) AS Row_No
    FROM invoice
    JOIN customer ON customer.CustomerId = invoice.CustomerId
    GROUP BY 1, 2, 3, 4
    ORDER BY 4 ASC, 5 DESC
)
SELECT * FROM customer_with_country WHERE Row_No <= 1;

-- Q12. Categorize customers into loyalty tiers based on their overall purchasing history. Write a query that 
-- returns the customer ID, full name, country, total orders, total lifetime spend, and average order value. Assign 
-- each customer a tier: 'VIP Customer' if total spend is 100$ or more, 'Regular Customer' if total spend is between
-- 50$ and 99.99$, and 'Occasional Customer' for anything below $50$. Order the results by total spend in descending order?

SELECT 
	c.CustomerId,
    CONCAT(FirstName , ' ' , c.LastName) AS Customer_Name,
    c.Country,
    COUNT(i.InvoiceId) AS Total_Orders,
    ROUND(SUM(i.Total), 2) AS Lifetime_Spend,
    ROUND(AVG(i.Total), 2) AS Avg_Order_Value,
    CASE
		WHEN SUM(i.Total) >= 100 THEN 'VIP Customer'
        WHEN SUM(i.Total) BETWEEN 50 AND 99.99 THEN 'Regular Customer'
        ELSE 'Ocasional Customer'
	END AS Customer_Tier
FROM customer c
JOIN invoice i ON c.CustomerId = i.CustomerId
GROUP BY c.CustomerId, c.FirstName, c.LastName, c.Country
ORDER BY Lifetime_Spend DESC;

-- Q13. The finance team wants to assess the store's annual growth rate over time. Write a query using window 
-- functions that calculates the total revenue and order count for each year, alongside the previous year's revenue 
-- and the Year-over-Year (YoY) Growth Percentage. Order the results chronologically by year?

WITH Yearly_Sales AS(
	SELECT
		YEAR(InvoiceDate) AS Sales_Year,
		ROUND(SUM(Total), 2) AS Revenue
	FROM invoice
    GROUP BY YEAR(InvoiceDate)
)
SELECT 
	Sales_Year,
    Revenue AS Current_Year_Revenue,
    LAG(Revenue, 1) OVER(ORDER BY Sales_Year) AS Previous_Year_Revenue,
    ROUND(
		((Revenue - LAG(Revenue, 1) OVER (ORDER BY Sales_Year))
		/ LAG(Revenue, 1) OVER (ORDER BY Sales_Year)) * 100, 2 
    ) AS YOY_Growth_Percentage
FROM Yearly_Sales;

-- Q14. Identify tracks in the catalog that have generated zero sales to help optimize licensing costs and cloud 
-- media storage. Write a query that returns the Track ID, Track Name, Album Title, Artist Name, Genre Name, and 
-- Unit Price for all unpurchased tracks. Order the list by Artist Name and Track Name?

SELECT 
	t.TrackId AS Track_Id,
    t.Name AS Track_Name,
    alb.Title AS Album_Title,
    ar.Name AS Artist_Name,
    g.Name AS Genre_Name,
    t.UnitPrice AS Unit_Price
FROM track t
JOIN album alb ON t.AlbumId = alb.AlbumId
JOIN artist ar ON  alb.ArtistId = ar.ArtistId
JOIN genre g ON t.GenreId = g.GenreId
LEFT JOIN invoiceline il ON t.TrackId = il.TrackId
WHERE il.InvoiceLineId IS NULL
ORDER BY ar.Name ASC, t.Name ASC;
    


    
    
    
    
    
    
    
    
    

