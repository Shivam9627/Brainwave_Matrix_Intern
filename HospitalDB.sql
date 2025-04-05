-- Creating the Database Named HospitalDB
CREATE DATABASE HospitalDB;
USE HospitalDB;

-- Creating table for patients
CREATE TABLE Patients (
    patient_id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    dob DATE,
    gender VARCHAR(10),
    phone VARCHAR(15),
    address TEXT
);


-- Creating table for doctors
CREATE TABLE Doctors (
    doctor_id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    specialty VARCHAR(50),
    phone VARCHAR(15),
    email VARCHAR(100)
);

-- Creating table for appointments
CREATE TABLE Appointments (
    appointment_id INT AUTO_INCREMENT PRIMARY KEY,
    patient_id INT,
    doctor_id INT,
    appointment_date DATE,
    appointment_time TIME,
    reason TEXT,
    FOREIGN KEY (patient_id) REFERENCES Patients(patient_id),
    FOREIGN KEY (doctor_id) REFERENCES Doctors(doctor_id)
);

-- Creating table for treatments
CREATE TABLE Treatments (
    treatment_id INT AUTO_INCREMENT PRIMARY KEY,
    appointment_id INT,
    diagnosis TEXT,
    prescription TEXT,
    notes TEXT,
    FOREIGN KEY (appointment_id) REFERENCES Appointments(appointment_id)
);

-- Creating table for bills
CREATE TABLE Bills (
    bill_id INT AUTO_INCREMENT PRIMARY KEY,
    patient_id INT,
    amount DECIMAL(10,2),
    payment_status VARCHAR(20),
    payment_date DATE,
    FOREIGN KEY (patient_id) REFERENCES Patients(patient_id)
);

-- Inserting  sample data into  patients table
INSERT INTO Patients (name, dob, gender, phone, address) VALUES
('Rahul Sharma', '1992-08-15', 'Male', '9876543210', '45, MG Road, Delhi'),
('Priya Verma', '1988-03-22', 'Female', '9123456789', '22, Park Street, Kolkata'),
('Amit Joshi', '1975-12-30', 'Male', '9988776655', '11, FC Road, Pune'),
('Neha Patel', '1995-05-05', 'Female', '9765432101', '88, CG Road, Ahmedabad');

-- Inserting sample data into doctors table
INSERT INTO Doctors (name, specialty, phone, email) VALUES
('Dr. Arvind Kumar', 'Cardiology', '9999988888', 'arvind.kumar@hospital.in'),
('Dr. Meena Rao', 'Gynecology', '8888877777', 'meena.rao@hospital.in'),
('Dr. Karan Singh', 'Orthopedics', '9876501234', 'karan.singh@hospital.in');

-- Inserting sample data into appointments table
INSERT INTO Appointments (patient_id, doctor_id, appointment_date, appointment_time, reason) VALUES
(1, 1, '2025-04-06', '10:00:00', 'Chest pain and breathlessness'),
(2, 2, '2025-04-07', '11:30:00', 'Routine pregnancy checkup'),
(3, 3, '2025-04-08', '14:00:00', 'Knee pain while walking'),
(4, 1, '2025-04-09', '09:30:00', 'High blood pressure');

-- Inserting sample data in treatments table
INSERT INTO Treatments (appointment_id, diagnosis, prescription, notes) VALUES
(1, 'Angina', 'Sorbitrate, Aspirin 75mg', 'Advised ECG and regular follow-up'),
(2, 'Healthy pregnancy', 'Iron, Calcium, Folic Acid', 'Ultrasound after 2 weeks'),
(3, 'Osteoarthritis', 'Calcium supplements, Knee brace', 'Avoid stairs, advised physiotherapy'),
(4, 'Hypertension', 'Telmisartan 40mg', 'Low salt diet, daily BP monitoring');

-- Inserting sample data in bills table
INSERT INTO Bills (patient_id, amount, payment_status, payment_date) VALUES
(1, 1500.00, 'Paid', '2025-04-06'),
(2, 1000.00, 'Paid', '2025-04-07'),
(3, 1200.00, 'Unpaid', NULL),
(4, 800.00, 'Paid', '2025-04-09');

        -- NOW SOME SAMPLE QUEIRES TO CHECK DATABASE THAT IT IS RUNNING PERFECTLY IN ALL MANNER OR NOT --

--  Querie for list all appointments with doctor & patient names
SELECT A.appointment_id, P.name AS patient, D.name AS doctor, A.appointment_date, A.reason
FROM Appointments A
JOIN Patients P ON A.patient_id = P.patient_id
JOIN Doctors D ON A.doctor_id = D.doctor_id;

-- Querie for all patients who haven’t paid bills
SELECT P.name, B.amount
FROM Bills B
JOIN Patients P ON B.patient_id = P.patient_id
WHERE B.payment_status = 'Unpaid';

-- Querie that Show total revenue collected (in ₹)
SELECT CONCAT('₹', FORMAT(SUM(amount), 2)) AS total_revenue
FROM Bills
WHERE payment_status = 'Paid';

-- Querie to Find all female patients who visited Gynecology
SELECT P.name, A.appointment_date, D.specialty
FROM Patients P
JOIN Appointments A ON P.patient_id = A.patient_id
JOIN Doctors D ON A.doctor_id = D.doctor_id
WHERE P.gender = 'Female' AND D.specialty = 'Gynecology';

-- Querie to Show treatment history of a patient (e.g., ‘Rahul Sharma’)
SELECT A.appointment_date, T.diagnosis, T.prescription
FROM Treatments T
JOIN Appointments A ON T.appointment_id = A.appointment_id
JOIN Patients P ON A.patient_id = P.patient_id
WHERE P.name = 'Rahul Sharma';

-- Querie for uniqueness in doctors table
ALTER TABLE Doctors ADD CONSTRAINT unique_email UNIQUE (email);

-- Querie for uniqueness in patients table
ALTER TABLE Patients ADD CONSTRAINT unique_phone UNIQUE (phone);


    -- NOW INSERTING MORE DATA IN ALL TABLES TO MAKE OUR DATABASE MORE BIG TO CHECK IT PROPERLY IN ALL MANNER --    

-- Inserting details of more patients
INSERT INTO Patients (name, dob, gender, phone, address) VALUES
('Anjali Mehta', '1993-11-10', 'Female', '9823001100', 'DLF Phase 1, Gurgaon'),
('Rajesh Khanna', '1980-05-22', 'Male', '9911002233', 'Anna Nagar, Chennai'),
('Sneha Reddy', '1991-02-15', 'Female', '9876541234', 'Banjara Hills, Hyderabad'),
('Arjun Desai', '1978-07-19', 'Male', '9822004433', 'Law Garden, Ahmedabad'),
('Kavita Nair', '1985-12-01', 'Female', '9867554411', 'Andheri West, Mumbai'),
('Ravi Menon', '1990-06-10', 'Male', '9777700001', 'Marine Drive, Kochi'),
('Pooja Iyer', '1996-03-25', 'Female', '9845100123', 'Jayanagar, Bengaluru'),
('Nitin Shah', '1970-09-09', 'Male', '9818005544', 'Sector 62, Noida'),
('Divya Kapoor', '1998-04-04', 'Female', '9832012345', 'Salt Lake, Kolkata'),
('Mohit Yadav', '1994-07-07', 'Male', '9819090909', 'Sector 14, Gurugram'),
('Deepika Chauhan', '1992-10-10', 'Female', '9786512345', 'Vijay Nagar, Indore'),
('Saurabh Mishra', '1982-01-11', 'Male', '9798901234', 'Hazratganj, Lucknow'),
('Ritika Jain', '1987-08-17', 'Female', '9867511223', 'Wakad, Pune'),
('Akash Gupta', '1993-03-30', 'Male', '9870001212', 'Vasant Kunj, Delhi'),
('Tanvi Saxena', '1986-06-06', 'Female', '9900111222', 'Gomti Nagar, Lucknow'),
('Rohit Verma', '1983-12-29', 'Male', '9811122233', 'Mira Road, Mumbai'),
('Isha Kaur', '1997-01-01', 'Female', '9876123456', 'Rajouri Garden, Delhi'),
('Siddharth Rao', '1989-04-22', 'Male', '9765432165', 'Alwarpet, Chennai'),
('Meera Das', '1995-09-14', 'Female', '9819988776', 'Kalighat, Kolkata'),
('Vivek Dubey', '1984-02-28', 'Male', '9876543200', 'C-Scheme, Jaipur');

-- Inserting details of more doctors
INSERT INTO Doctors (name, specialty, phone, email) VALUES
('Dr. Swati Pandey', 'Neurology', '9888882222', 'swati.pandey@hospital.in'),
('Dr. Tarun Malhotra', 'Pediatrics', '9811223344', 'tarun.malhotra@hospital.in'),
('Dr. Sangeeta Singh', 'ENT', '9876542222', 'sangeeta.singh@hospital.in'),
('Dr. Hitesh Rawal', 'Dermatology', '9911334455', 'hitesh.rawal@hospital.in'),
('Dr. Reema Arora', 'Psychiatry', '9922558899', 'reema.arora@hospital.in');


-- Inserting more appointments detail in database
INSERT INTO Appointments (patient_id, doctor_id, appointment_date, appointment_time, reason) VALUES
(5, 4, '2025-04-10', '11:00:00', 'Follow-up for hypertension'),
(6, 5, '2025-04-10', '12:00:00', 'Mental health consultation'),
(7, 6, '2025-04-11', '09:45:00', 'Migraine and dizziness'),
(8, 3, '2025-04-11', '10:15:00', 'Knee joint pain'),
(9, 2, '2025-04-11', '11:30:00', 'Prenatal checkup'),
(10, 1, '2025-04-12', '13:00:00', 'Cardiac evaluation'),
(11, 5, '2025-04-12', '14:30:00', 'Stress management'),
(12, 6, '2025-04-12', '15:45:00', 'Frequent headaches'),
(13, 7, '2025-04-13', '09:00:00', 'Child fever and cough'),
(14, 2, '2025-04-13', '10:30:00', 'Gynec routine'),
(15, 8, '2025-04-13', '11:45:00', 'Allergy and skin rash'),
(16, 3, '2025-04-14', '10:00:00', 'Shoulder dislocation'),
(17, 7, '2025-04-14', '11:00:00', 'Infant vaccination'),
(18, 1, '2025-04-15', '12:30:00', 'Irregular heartbeat'),
(19, 7, '2025-04-15', '14:00:00', 'ENT issue - ear pain'),
(20, 5, '2025-04-15', '15:00:00', 'Anxiety and sleep issues'),
(21, 8, '2025-04-16', '09:30:00', 'Regular checkup'),
(22, 2, '2025-04-16', '11:15:00', 'Post-pregnancy care'),
(23, 6, '2025-04-17', '13:45:00', 'Back pain'),
(24, 3, '2025-04-17', '15:00:00', 'Sprained ankle');

-- Inserting more values in treatment
INSERT INTO Treatments (appointment_id, diagnosis, prescription, notes) VALUES
(5, 'Hypertension', 'Amlodipine 5mg', 'Monitor BP every 6 hrs'),
(6, 'Anxiety disorder', 'Clonazepam 0.25mg', 'Daily yoga advised'),
(7, 'Migraine', 'Sumatriptan 50mg', 'Trigger avoidance'),
(8, 'Arthritis', 'Calcium + painkiller', 'Physiotherapy suggested'),
(9, 'Pregnancy - healthy', 'Iron & folic acid', 'Ultrasound in 4 weeks'),
(10, 'Tachycardia', 'Beta blockers', 'ECG advised weekly'),
(11, 'Depression', 'SSRI – Sertraline 50mg', 'Counseling recommended'),
(12, 'Tension headaches', 'Paracetamol + rest', 'Check posture'),
(13, 'Common cold', 'Cough syrup + Paracetamol', 'Fluids and rest'),
(14, 'Routine Check', 'No issues', 'Next visit in 3 months');

-- Inserting more values in bills
INSERT INTO Bills (patient_id, amount, payment_status, payment_date) VALUES
(5, 900.00, 'Paid', '2025-04-10'),
(6, 1200.00, 'Unpaid', NULL),
(7, 800.00, 'Paid', '2025-04-11'),
(8, 1100.00, 'Paid', '2025-04-11'),
(9, 1000.00, 'Paid', '2025-04-11'),
(10, 1300.00, 'Unpaid', NULL),
(11, 1400.00, 'Paid', '2025-04-12'),
(12, 950.00, 'Paid', '2025-04-12'),
(13, 600.00, 'Paid', '2025-04-13'),
(14, 1050.00, 'Paid', '2025-04-13');

















