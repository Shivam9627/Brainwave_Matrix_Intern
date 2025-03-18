CREATE DATABASE LibraryDB;
USE LibraryDB;

-- Authors Table
CREATE TABLE Authors (
    author_id INT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(255) NOT NULL,
    birthdate DATE,
    nationality VARCHAR(100)
);

-- Categories Table
CREATE TABLE Categories (
    category_id INT PRIMARY KEY AUTO_INCREMENT,
    category_name VARCHAR(100) UNIQUE NOT NULL
);

CREATE TABLE Books (
    book_id INT PRIMARY KEY AUTO_INCREMENT,
    title VARCHAR(255) NOT NULL,
    isbn VARCHAR(20) UNIQUE NOT NULL,
    publication_year INT,
    copies_available INT DEFAULT 1,
    category_id INT,
    FOREIGN KEY (category_id) REFERENCES Categories(category_id) ON DELETE SET NULL
);
-- Book_Authors (Many-to-Many relationship between Books and Authors)
CREATE TABLE Book_Authors (
    book_id INT,
    author_id INT,
    PRIMARY KEY (book_id, author_id),
    FOREIGN KEY (book_id) REFERENCES Books(book_id) ON DELETE CASCADE,
    FOREIGN KEY (author_id) REFERENCES Authors(author_id) ON DELETE CASCADE
);
-- Members Table
CREATE TABLE Members (
    member_id INT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(255) NOT NULL,
    email VARCHAR(255) UNIQUE NOT NULL,
    phone VARCHAR(15),
    address TEXT,
    membership_date DATE DEFAULT  (NOW())
);

-- Librarians Table
CREATE TABLE Librarians (
    librarian_id INT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(255) NOT NULL,
    email VARCHAR(255) UNIQUE NOT NULL,
    phone VARCHAR(15),
    hire_date DATE DEFAULT (NOW())
);
-- Loans Table (Tracks book borrowing)
CREATE TABLE Loans (
    loan_id INT PRIMARY KEY AUTO_INCREMENT,
    book_id INT,
    member_id INT,
    loan_date DATE DEFAULT (NOW()),
    due_date DATE NOT NULL,
    return_date DATE DEFAULT NULL,
    librarian_id INT,
    FOREIGN KEY (book_id) REFERENCES Books(book_id) ON DELETE CASCADE,
    FOREIGN KEY (member_id) REFERENCES Members(member_id) ON DELETE CASCADE,
    FOREIGN KEY (librarian_id) REFERENCES Librarians(librarian_id) ON DELETE SET NULL
);

-- Reservations Table (Tracks book reservations)
CREATE TABLE Reservations (
    reservation_id INT PRIMARY KEY AUTO_INCREMENT,
    book_id INT,
    member_id INT,
    reservation_date DATE DEFAULT (NOW()),
    status ENUM('Pending', 'Completed', 'Cancelled') DEFAULT 'Pending',
    FOREIGN KEY (book_id) REFERENCES Books(book_id) ON DELETE CASCADE,
    FOREIGN KEY (member_id) REFERENCES Members(member_id) ON DELETE CASCADE
);

-- Fines Table (Tracks penalties for late book returns)
CREATE TABLE Fines (
    fine_id INT PRIMARY KEY AUTO_INCREMENT,
    loan_id INT,
    amount DECIMAL(5,2) NOT NULL,
    paid BOOLEAN DEFAULT FALSE,
    FOREIGN KEY (loan_id) REFERENCES Loans(loan_id) ON DELETE CASCADE
);

DELIMITER //
CREATE TRIGGER check_publication_year
BEFORE INSERT ON Books
FOR EACH ROW
BEGIN
    IF NEW.publication_year < 1800 OR NEW.publication_year > YEAR(NOW()) THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Publication year must be between 1800 and the current year';
    END IF;
END;
//
DELIMITER ;

Trigger to Prevent Negative Copies Available
DELIMITER //
CREATE TRIGGER prevent_negative_copies
BEFORE UPDATE ON Books
FOR EACH ROW
BEGIN
    IF NEW.copies_available < 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Copies available cannot be negative';
    END IF;
END;
//
DELIMITER ;

-- Insert Authors
INSERT INTO Authors (name, birthdate, nationality) VALUES 
('J.K. Rowling', '1965-07-31', 'British'),
('George Orwell', '1903-06-25', 'British');

-- Insert Categories
INSERT INTO Categories (category_name) VALUES 
('Fiction'), ('Science Fiction'), ('History');

-- Insert Books
INSERT INTO Books (title, isbn, publication_year, copies_available, category_id) VALUES 
('Harry Potter', '9780747532743', 1997, 5, 1),
('1984', '9780451524935', 1949, 3, 2);

-- Link Books to Authors
INSERT INTO Book_Authors (book_id, author_id) VALUES 
(1, 1), (2, 2);

-- Insert Members
INSERT INTO Members (name, email, phone, address,membership_date) VALUES 
('John Doe', 'john.doe@example.com', '1234567890', '123 Elm Street', CURDATE());

-- Insert Librarians
INSERT INTO Librarians (name, email, phone) VALUES 
('Alice Johnson', 'alice.johnson@example.com', '9876543210');

INSERT INTO Loans (book_id, member_id, loan_date, due_date, librarian_id) 
VALUES (1, 1, CURRENT_DATE(), DATE_ADD(CURRENT_DATE(), INTERVAL 14 DAY), 1);

-- Reduce copies available
UPDATE Books 
SET copies_available = copies_available - 1 
WHERE book_id = 1;

UPDATE Loans 
SET return_date = CURRENT_DATE() 
WHERE loan_id = 1;

-- Increase copies available
UPDATE Books 
SET copies_available = copies_available + 1 
WHERE book_id = 1;

-- Calculates fine
INSERT INTO Fines (loan_id, amount) 
SELECT loan_id, DATEDIFF(CURRENT_DATE(), due_date) * 0.5 
FROM Loans 
WHERE return_date > due_date;

-- List all borrowed books
SELECT Books.title, Members.name, Loans.loan_date, Loans.due_date, Loans.return_date 
FROM Loans
JOIN Books ON Loans.book_id = Books.book_id
JOIN Members ON Loans.member_id = Members.member_id;

-- find overdue books

SELECT Books.title, Members.name, Loans.due_date 
FROM Loans 
JOIN Books ON Loans.book_id = Books.book_id
JOIN Members ON Loans.member_id = Members.member_id
WHERE Loans.return_date IS NULL AND Loans.due_date < CURRENT_DATE();

-- list books reserved but not yet available
SELECT Books.title, Members.name, Reservations.reservation_date, Reservations.status 
FROM Reservations
JOIN Books ON Reservations.book_id = Books.book_id
JOIN Members ON Reservations.member_id = Members.member_id
WHERE Reservations.status = 'Pending';

-- find members with outstanding fines
SELECT Members.name, SUM(Fines.amount) AS total_fines 
FROM Fines
JOIN Loans ON Fines.loan_id = Loans.loan_id
JOIN Members ON Loans.member_id = Members.member_id
WHERE Fines.paid = FALSE
GROUP BY Members.name;









