-- 1. Create table for storing book information
CREATE TABLE books (
    book_id SERIAL PRIMARY KEY,
    title VARCHAR(255) NOT NULL,
    author VARCHAR(255) NOT NULL,
    publication_year INT,
    genre VARCHAR(100)
);

-- 2. Create table for storing borrower details
CREATE TABLE borrowers (
    borrower_id SERIAL PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    address TEXT,
    contact_number VARCHAR(20)
);

-- 3. Create table for recording book borrowings
CREATE TABLE borrowings (
    borrowing_id SERIAL PRIMARY KEY,
    book_id INT REFERENCES books(book_id),
    borrower_id INT REFERENCES borrowers(borrower_id),
    borrowing_date DATE NOT NULL,
    return_date DATE
);

-- 4. Insert new books into the library database
INSERT INTO books (title, author, publication_year, genre)
VALUES 
('The Great Gatsby', 'F. Scott Fitzgerald', 1925, 'Fiction'),
('To Kill a Mockingbird', 'Harper Lee', 1960, 'Classic');

-- 5. Add new borrowers to the library database
INSERT INTO borrowers (name, address, contact_number)
VALUES 
('John Doe', '123 Library St, City', '123-456-7890'),
('Jane Smith', '456 Book Ave, Town', '987-654-3210');

-- 6. Register book borrowing by a borrower
INSERT INTO borrowings (book_id, borrower_id, borrowing_date)
VALUES 
(1, 1, '2024-02-01'),
(2, 2, '2024-02-05');

-- 7. Update book information when returned
UPDATE borrowings
SET return_date = '2024-02-15'
WHERE borrowing_id = 1;

-- 8. Retrieve all books borrowed by a specific borrower
SELECT b.title 
FROM books b
JOIN borrowings br ON b.book_id = br.book_id
WHERE br.borrower_id = 1;

-- 9. List all overdue books (14 days past borrowing date)
SELECT b.title, br.borrowing_date 
FROM books b
JOIN borrowings br ON b.book_id = br.book_id
WHERE br.return_date IS NULL 
AND br.borrowing_date < CURRENT_DATE - INTERVAL '14 days';

-- 10. Count the total books by a specific author
SELECT author, COUNT(*) AS total_books
FROM books
WHERE author = 'J.K. Rowling'
GROUP BY author;

-- 11. Find the most popular genre (most borrowed)
SELECT b.genre, COUNT(*) AS borrow_count
FROM books b
JOIN borrowings br ON b.book_id = br.book_id
GROUP BY b.genre
ORDER BY borrow_count DESC
LIMIT 1;
