-- Create the database
CREATE DATABASE Online_Bookstore;
USE Online_Bookstore;

-- ==========================
-- Table: User
-- Stores information about users
-- ==========================
CREATE TABLE User (
    User_ID INT PRIMARY KEY,
    Name VARCHAR(100) NOT NULL,
    Email VARCHAR(100) UNIQUE,
    Password VARCHAR(100) NOT NULL,
    Address VARCHAR(255)
);

-- ==========================
-- Table: Author
-- Stores book author information
-- ==========================
CREATE TABLE Author (
    Author_ID INT PRIMARY KEY,
    Author_Name VARCHAR(100) NOT NULL,
    Bio TEXT
);

-- ==========================
-- Table: Genre
-- Stores types/categories of books
-- ==========================
CREATE TABLE Genre (
    Genre_ID INT PRIMARY KEY,
    Type VARCHAR(100) NOT NULL
);

-- ==========================
-- Table: Book
-- Stores book details
-- ==========================
CREATE TABLE Book (
    Book_ID INT PRIMARY KEY,
    Title VARCHAR(255) NOT NULL,
    Description TEXT NOT NULL,
    Published_Date DATE NOT NULL,
    Stock INT CHECK (Stock >= 0),
    Price DECIMAL(10,2) CHECK (Price >= 0),
    Author_ID INT,
    Genre_ID INT,
    FOREIGN KEY (Author_ID) REFERENCES Author(Author_ID),
    FOREIGN KEY (Genre_ID) REFERENCES Genre(Genre_ID)
);

-- ==========================
-- Table: Review
-- Stores user reviews for books
-- ==========================
CREATE TABLE Review (
    Review_ID INT PRIMARY KEY,
    Book_ID INT,
    User_ID INT,
    Review_Date DATE,
    Rate INT CHECK (Rate BETWEEN 1 AND 5),
    Comments TEXT,
    FOREIGN KEY (Book_ID) REFERENCES Book(Book_ID),
    FOREIGN KEY (User_ID) REFERENCES User(User_ID)
);

-- ==========================
-- Table: Cart
-- Stores books added to cart by users
-- ==========================
CREATE TABLE Cart (
    User_ID INT,
    Book_ID INT,
    Quantity INT CHECK (Quantity > 0),
    PRIMARY KEY (User_ID, Book_ID),
    FOREIGN KEY (User_ID) REFERENCES User(User_ID),
    FOREIGN KEY (Book_ID) REFERENCES Book(Book_ID)
);

-- ==========================
-- Table: Order
-- Stores user orders
-- ==========================
CREATE TABLE `Order` (
    Order_ID INT PRIMARY KEY,
    Order_Date DATE NOT NULL,
    State VARCHAR(20),
    User_ID INT,
    Book_ID INT,
    Price DECIMAL(10,2) CHECK (Price >= 0),
    Quantity INT CHECK (Quantity > 0),
    FOREIGN KEY (User_ID) REFERENCES User(User_ID),
    FOREIGN KEY (Book_ID) REFERENCES Book(Book_ID)
);



-- Insert Users
INSERT INTO User VALUES
(1, 'Alice Johnson', 'alice@example.com', 'alice123', '123 Elm Street'),
(2, 'Bob Smith', 'bob@example.com', 'bobpass', '456 Oak Avenue');

-- Insert Authors
INSERT INTO Author VALUES
(1, 'George Orwell', 'British writer and journalist.'),
(2, 'J.K. Rowling', 'Author of the Harry Potter series.');

-- Insert Genres
INSERT INTO Genre VALUES
(1, 'Science Fiction'),
(2, 'Fantasy');

-- Insert Books
INSERT INTO Book VALUES
(1, '1984', 'A dystopian social science fiction novel.', '1949-06-08', 10, 15.99, 1, 1),
(2, 'Harry Potter and the Sorcerer''s Stone', 'A young wizard''s journey begins.', '1997-06-26', 20, 29.99, 2, 2);

-- Insert Reviews
INSERT INTO Review VALUES
(1, 1, 1, '2024-01-10', 5, 'A timeless classic!'),
(2, 2, 2, '2024-02-15', 4, 'Magical and captivating.');

-- Insert Cart Items
INSERT INTO Cart VALUES
(1, 2, 1),
(2, 1, 2);

-- Insert Orders
INSERT INTO `Order` VALUES
(1, '2024-03-05', 'Shipped', 1, 2, 29.99, 1),
(2, '2024-03-06', 'Processing', 2, 1, 15.99, 2);


INSERT INTO User VALUES
(3, 'Charlie Davis', 'charlie@example.com', 'charliepass', '789 Pine Lane'),
(4, 'Dana Lee', 'dana@example.com', 'danapass', '101 Maple Street'),
(5, 'Eli Brown', 'eli@example.com', 'elipass', '202 Birch Blvd');

INSERT INTO `Order` VALUES
(3, '2024-03-07', 'Shipped', 3, 1, 15.99, 1),
(4, '2024-03-08', 'Delivered', 4, 1, 15.99, 1),
(5, '2024-03-09', 'Delivered', 5, 1, 15.99, 1);

SELECT Book_ID, COUNT(User_ID) AS Buyers_Count
FROM `Order`
WHERE YEAR(Order_Date) = 2024
GROUP BY Book_ID
HAVING COUNT(User_ID) > 3;
-----------------------------------------------------------------

-- Number of orders completed for each book with the book name
SELECT b.Title, COUNT(o.Order_ID) AS Total_Orders
FROM `Order` o
JOIN Book b ON o.Book_ID = b.Book_ID
GROUP BY b.Title;

-- Total Revenue for each book 
SELECT b.Title, SUM(o.Price * o.Quantity) AS Total_Revenue
FROM `Order` o
JOIN Book b ON o.Book_ID = b.Book_ID
GROUP BY b.Title;

-- Names of users who wrote reviews and the number of their reviews
SELECT u.Name, COUNT(r.Review_ID) AS Total_Reviews
FROM Review r
JOIN User u ON r.User_ID = u.User_ID
GROUP BY u.Name
HAVING COUNT(r.Review_ID) > 0;

-- List of books with an average rating above 3
SELECT b.Title, AVG(r.Rate) AS Avg_Rating
FROM Review r
JOIN Book b ON r.Book_ID = b.Book_ID
GROUP BY b.Title
HAVING AVG(r.Rate) > 3;

-- List of authors and the number of books they have written
SELECT a.Author_Name, COUNT(b.Book_ID) AS Book_Count
FROM Author a
JOIN Book b ON a.Author_ID = b.Author_ID
GROUP BY a.Author_Name;

------------------------------------------

-- Number of request ORDER per user with their name
SELECT u.Name, COUNT(o.Order_ID) AS Orders_Count
FROM `Order` o
JOIN User u ON o.User_ID = u.User_ID
GROUP BY u.Name;

-- Total number of books in each genre
SELECT g.Type AS Genre, SUM(b.Stock) AS Total_Stock
FROM Genre g
JOIN Book b ON g.Genre_ID = b.Genre_ID
GROUP BY g.Type;

-- Most purchased book by number of orders
SELECT b.Title, COUNT(o.Order_ID) AS Total_Orders
FROM `Order` o
JOIN Book b ON o.Book_ID = b.Book_ID
GROUP BY b.Title
ORDER BY Total_Orders
LIMIT 1;

-- List of books purchased by more than 2 different users
SELECT b.Title, COUNT(o.User_ID) AS Buyers_Count
FROM `Order` o
JOIN Book b ON o.Book_ID = b.Book_ID
GROUP BY b.Title
HAVING COUNT(o.User_ID) > 2;


SELECT a.Author_Name , count(o.Quantity)
from  `Order` o 
join book b on (o.Book_ID = b.Book_ID)
join Author a on (a.Author_ID = b.Author_ID)
group by a.author_name
having count(o.Quantity) >5; 


-- All users who have books in their cart with the number of books
SELECT u.Name, COUNT(c.Book_ID) AS Books_In_Cart
FROM Cart c
JOIN User u ON c.User_ID = u.User_ID
GROUP BY u.Name;

--  get all books ordered in the year 2024
SELECT b.Title, o.Order_Date
FROM `Order` o
JOIN Book b ON o.Book_ID = b.Book_ID
WHERE YEAR(o.Order_Date) = 2024;










