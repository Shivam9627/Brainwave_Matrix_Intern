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

-- INSERTING MORE VALUES
INSERT INTO Authors (name, birthdate, nationality) VALUES 
('Ravi Sharma', '1975-02-15', 'Indian'),
('Ananya Verma', '1982-09-23', 'Indian'),
('Amitabh Das', '1960-05-10', 'Indian'),
('Neha Trivedi', '1985-07-19', 'Indian'),
('Rajesh Iyer', '1970-03-05', 'Indian'),
('Priya Kapoor', '1992-08-12', 'Indian'),
('Suresh Menon', '1955-12-30', 'Indian'),
('Meera Nair', '1988-04-21', 'Indian'),
('Karthik Reddy', '1981-11-25', 'Indian'),
('Deepika Chaturvedi', '1976-06-14', 'Indian'),
('Manoj Joshi', '1969-01-07', 'Indian'),
('Kavita Bhatia', '1995-03-22', 'Indian'),
('Sanjay Gupta', '1983-05-31', 'Indian'),
('Preeti Malhotra', '1978-09-17', 'Indian'),
('Vikram Rao', '1966-07-03', 'Indian'),
('Anjali Mishra', '1990-10-05', 'Indian'),
('Arun Pandey', '1958-11-09', 'Indian'),
('Sonia Nambiar', '1987-06-18', 'Indian'),
('Harish Choudhary', '1971-04-28', 'Indian'),
('Tanvi Saxena', '1994-02-06', 'Indian'),
('Prakash Yadav', '1980-12-01', 'Indian'),
('Madhavi Srinivasan', '1986-07-15', 'Indian'),
('Vinod Kulkarni', '1977-09-11', 'Indian'),
('Pooja Jain', '1991-08-24', 'Indian'),
('Aditya Narayan', '1984-05-02', 'Indian'),
('Sarita Bhargava', '1963-11-30', 'Indian'),
('Mahesh Patil', '1972-03-16', 'Indian'),
('Jyoti Venkatesh', '1998-10-21', 'Indian'),
('Gaurav Mehta', '1993-01-09', 'Indian'),
('Asha Raman', '1974-06-27', 'Indian'),
('Siddharth Mukherjee', '1989-05-12', 'Indian'),
('Namita Basu', '1982-07-19', 'Indian'),
('Rohit Chatterjee', '1979-04-03', 'Indian'),
('Sunita Dey', '1996-09-08', 'Indian'),
('Bhaskar Pillai', '1968-12-17', 'Indian'),
('Swati Ghosh', '1977-08-13', 'Indian'),
('Anirudh Banerjee', '1985-03-29', 'Indian'),
('Rashmi Khandelwal', '1992-11-14', 'Indian'),
('Dinesh Nanda', '1961-06-25', 'Indian'),
('Sujata Roy', '1988-07-07', 'Indian'),
('Abhishek Bhatt', '1990-02-19', 'Indian'),
('Renu Reddy', '1983-12-03', 'Indian'),
('Tarun Goel', '1997-05-26', 'Indian'),
('Kiran Desai', '1975-10-09', 'Indian'),
('Vishal Tiwari', '1981-08-14', 'Indian'),
('Komal Singh', '1993-06-28', 'Indian'),
('Harsha Kapoor', '1987-04-07', 'Indian'),
('Rakesh Sinha', '1976-01-15', 'Indian'),
('Tanya Kaushik', '1995-11-22', 'Indian'),
('Yogesh Malviya', '1973-03-31', 'Indian');

-- Insert Categories (50 Different Genres)
INSERT INTO Categories (category_name) VALUES 
('LOVE'), ('Hate'), ('Multiverse'), ('Self-Help'), ('Business'), 
('Spirituality'), ('Philosophy'), ('Mythology'), ('Thriller'), ('Romance'),
('Psychology'), ('Autobiography'), ('Biography'), ('Finance'), ('Technology'),
('Poetry'), ('Drama'), ('Classic'), ('Adventure'), ('Horror'),
('Fantasy'), ('Graphic Novel'), ('Short Stories'), ('Anthology'), ('Children'),
('Young Adult'), ('Crime'), ('Health'), ('Cooking'), ('Motivational'),
('Music'), ('Religion'), ('Politics'), ('Science'), ('Engineering'),
('Medical'), ('Art'), ('Education'), ('Law'), ('Environment'),
('Sports'), ('Travel'), ('Humor'), ('Astronomy'), ('Economics'),
('Astrology'), ('Mystery'), ('War'), ('Cultural'), ('Language');


-- Insert Books Categorized by Genre
INSERT INTO Books (title, isbn, publication_year, copies_available, category_id) VALUES 
('Into the Wild', '9780385486804', 1996, 4, 172), -- Adventure
('The Vintage Book of Contemporary American Short Stories', '9780679745136', 1994, 5, 177), -- Anthology
('The Story of Art', '9780714832470', 1950, 3, 190), -- Art
('The Only Astrology Book You’ll Ever Need', '9781589796539', 1982, 2, 199), -- Astrology
('Cosmos', '9780345331359', 1980, 6, 197), -- Astronomy
('The Diary of a Young Girl', '9780553296983', 1947, 7, 165), -- Autobiography
('Steve Jobs', '9781451648539', 2011, 5, 166), -- Biography
('The Lean Startup', '9780307887894', 2011, 6, 158), -- Business
('Charlie and the Chocolate Factory', '9780142410318', 1964, 8, 178), -- Children
('Pride and Prejudice', '9780679783268', 1813, 4, 171), -- Classic
('Mastering the Art of French Cooking', '9780375413407', 1961, 3, 182), -- Cooking
('The Girl with the Dragon Tattoo', '9780307949436', 2005, 5, 180), -- Crime
('Sapiens: A Brief History of Humankind', '9780062316097', 2011, 6, 202), -- Cultural
('Hamlet', '9780141013077', 1803, 3, 170), -- Drama
('The Wealth of Nations', '9780679783367', 1800, 4, 198), -- Economics
('Pedagogy of the Oppressed', '9780826412768', 1968, 3, 191), -- Education
('The Design of Everyday Things', '9780465050659', 1988, 5, 188), -- Engineering
('Silent Spring', '9780618249060', 1962, 4, 193), -- Environment
('Harry Potter and the Sorcerer’s Stone', '9780590353427', 1997, 6, 174), -- Fantasy
('To Kill a Mockingbird', '9780061120084', 1960, 5, 1), -- Fiction
('Rich Dad Poor Dad', '9781612680194', 1997, 6, 167), -- Finance
('Maus', '9780679406419', 1986, 5, 175), -- Graphic Novel
('Mein Kampf', '9780395925033', 1925, 2, 155), -- Hate
('The China Study', '9781932100662', 2005, 3, 181), -- Health
('Guns, Germs, and Steel', '9780393354323', 1997, 5, 3), -- History
('Dracula', '9780141439846', 1897, 6, 173), -- Horror
('Born a Crime', '9780399588173', 2016, 5, 196), -- Humor
('Fluent Forever', '9780399578754', 2014, 3, 203), -- Language
('The Rule of Law', '9780141034539', 2010, 4, 192), -- Law
('P.S. I Love You', '9780786890934', 2003, 5, 154), -- LOVE
('Gray’s Anatomy', '9780550146538', 1858, 4, 189), -- Medical
('The Power of Now', '9781577314806', 1997, 5, 183), -- Motivational
('Dark Matter', '9781101904220', 2016, 6, 156), -- Multiverse
('Musicophilia', '9781400033539', 2007, 4, 184), -- Music
('The Girl with the Dragon Tattoo', '9780307949486', 2005, 5, 200), -- Mystery
('Mythos', '9781405934138', 2017, 5, 161), -- Mythology
('The Republic', '9780140455113', 1880, 3, 160), -- Philosophy
('Leaves of Grass', '9780486456768', 1855, 4, 169), -- Poetry
('The Prince', '9780140449150', 1832, 3, 186), -- Politics
('Thinking, Fast and Slow', '9780374533557', 2011, 5, 164), -- Psychology
('The Bhagavad Gita', '9780140449181', 2000 , 6, 185), -- Religion
('The Notebook', '9780446605236', 1996, 7, 163), -- Romance
('Brief Answers to the Big Questions', '9781984819192', 2018, 5, 187), -- Science
('Dune', '9780441013593', 1965, 6, 2), -- Science Fiction
('How to Win Friends and Influence People', '9780671027033', 1936, 4, 157), -- Self-Help
('The Lottery and Other Stories', '9781250239358', 1948, 5, 176), -- Short Stories
('The Seven Spiritual Laws of Success', '9781878424112', 1994, 3, 159), -- Spirituality
('Moneyball', '9780393338393', 2003, 4, 194), -- Sports
('The Innovators', '9781476708706', 2014, 5, 168), -- Technology
('Gone Girl', '9780307588371', 2012, 6, 162), -- Thriller
('In Patagonia', '9780679724971', 1977, 4, 195), -- Travel
('The Art of War', '9781590302255', 2005, 8, 201), -- War
('The Fault in Our Stars', '9780142424179', 2012, 6, 179); -- Young Adult

-- NEW MEMBERS 
INSERT INTO Members (name, email, phone, address, membership_date) VALUES 
('Amit Sharma', 'amit.sharma@example.com', '9876543211', '45 Green Street, Delhi', CURDATE()),
('Neha Verma', 'neha.verma@example.com', '8765432112', '78 Residency Road, Mumbai', CURDATE()),
('Rohan Kapoor', 'rohan.kapoor@example.com', '7654321123', '10 MG Road, Bangalore', CURDATE()),
('Priya Nair', 'priya.nair@example.com', '6543211234', '22 Park Avenue, Chennai', CURDATE()),
('Arjun Mehta', 'arjun.mehta@example.com', '5432112345', '99 Hill View, Kolkata', CURDATE()),
('Kavita Joshi', 'kavita.joshi@example.com', '4321123456', '15 Sea Road, Pune', CURDATE()),
('Vikas Malhotra', 'vikas.malhotra@example.com', '3211234567', '20 Palace Road, Hyderabad', CURDATE()),
('Ananya Desai', 'ananya.desai@example.com', '2112345678', '55 Lotus Avenue, Ahmedabad', CURDATE()),
('Sandeep Yadav', 'sandeep.yadav@example.com', '1012345679', '33 Garden Colony, Jaipur', CURDATE()),
('Meera Pillai', 'meera.pillai@example.com', '9012345670', '88 Sunshine Road, Chandigarh', CURDATE()),
('Rajeev Saxena', 'rajeev.saxena@example.com', '8112345671', '77 Blue Street, Indore', CURDATE()),
('Sonia Gupta', 'sonia.gupta@example.com', '7212345672', '66 Park Lane, Lucknow', CURDATE()),
('Karthik Iyer', 'karthik.iyer@example.com', '6312345673', '44 Skyline Tower, Coimbatore', CURDATE()),
('Swati Bansal', 'swati.bansal@example.com', '5412345674', '99 Royal Street, Nagpur', CURDATE()),
('Rahul Choudhary', 'rahul.choudhary@example.com', '4512345675', '11 Central Park, Bhopal', CURDATE()),
('Deepika Reddy', 'deepika.reddy@example.com', '3612345676', '14 Sunrise Avenue, Patna', CURDATE()),
('Nitin Aggarwal', 'nitin.aggarwal@example.com', '2712345677', '25 Emerald Road, Surat', CURDATE()),
('Pooja Thakur', 'pooja.thakur@example.com', '1812345678', '19 South Lane, Ludhiana', CURDATE()),
('Vivek Goel', 'vivek.goel@example.com', '0912345679', '12 Maple Street, Kanpur', CURDATE()),
('Rashmi Sen', 'rashmi.sen@example.com', '8912345670', '77 Horizon View, Visakhapatnam', CURDATE());

-- 4 other librarians of library
INSERT INTO Librarians (name, email, phone) VALUES 
('Rajesh Kumar', 'rajesh.kumar@example.com', '8765432109');

INSERT INTO Librarians (name, email, phone) VALUES 
('Sneha Patil', 'sneha.patil@example.com', '7654321098');

INSERT INTO Librarians (name, email, phone) VALUES 
('Vikram Singh', 'vikram.singh@example.com', '6543210987');

INSERT INTO Librarians (name, email, phone) VALUES 
('Pooja Iyer', 'pooja.iyer@example.com', '5432109876');









