-- ==============================================================================
-- ASSIGNMENT: Homework 4 - Introduction to MySQL (INS3064)
-- STUDENT NAME: [Điền Họ và Tên của bạn]
-- STUDENT ID: [Điền Mã Sinh Viên của bạn]
-- DATE: 2026-10-05
-- FILE: university_db.sql
-- DESCRIPTION: Full relational database schema and seed data for University Course Registration System.
-- ==============================================================================

-- ------------------------------------------------------------------------------
-- 1. DATABASE CREATION & SETUP (Idempotent)
-- ------------------------------------------------------------------------------
DROP DATABASE IF EXISTS university_db;
CREATE DATABASE university_db CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE university_db;

-- ------------------------------------------------------------------------------
-- 2. TABLE CREATION IN DEPENDENCY ORDER
-- ------------------------------------------------------------------------------

-- Table 1: departments (Stores academic departments)
DROP TABLE IF EXISTS departments;
CREATE TABLE departments (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100) NOT NULL UNIQUE,
    code VARCHAR(10) NOT NULL UNIQUE,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB;

-- Table 2: instructors (Stores faculty members, linked to a department)
DROP TABLE IF EXISTS instructors;
CREATE TABLE instructors (
    id INT AUTO_INCREMENT PRIMARY KEY,
    department_id INT NOT NULL,
    name VARCHAR(100) NOT NULL,
    email VARCHAR(100) NOT NULL UNIQUE,
    phone VARCHAR(20),
    hire_date DATE,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_instructors_department FOREIGN KEY (department_id) 
        REFERENCES departments(id) ON DELETE RESTRICT ON UPDATE CASCADE
) ENGINE=InnoDB;

-- Table 3: students (Stores student information, linked to major department)
DROP TABLE IF EXISTS students;
CREATE TABLE students (
    id INT AUTO_INCREMENT PRIMARY KEY,
    department_id INT NOT NULL,
    student_code VARCHAR(20) NOT NULL UNIQUE,
    name VARCHAR(100) NOT NULL,
    email VARCHAR(100) NOT NULL UNIQUE,
    gender ENUM('Male', 'Female', 'Other') DEFAULT 'Male',
    gpa DECIMAL(3,2) DEFAULT 0.00 CHECK (gpa BETWEEN 0.00 AND 4.00),
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_students_department FOREIGN KEY (department_id) 
        REFERENCES departments(id) ON DELETE RESTRICT ON UPDATE CASCADE
) ENGINE=InnoDB;

-- Table 4: courses (Stores course catalog, linked to department and instructor)
DROP TABLE IF EXISTS courses;
CREATE TABLE courses (
    id INT AUTO_INCREMENT PRIMARY KEY,
    department_id INT NOT NULL,
    instructor_id INT NOT NULL,
    course_code VARCHAR(20) NOT NULL UNIQUE,
    title VARCHAR(150) NOT NULL,
    credits INT NOT NULL DEFAULT 3,
    description TEXT,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_courses_department FOREIGN KEY (department_id) 
        REFERENCES departments(id) ON DELETE RESTRICT ON UPDATE CASCADE,
    CONSTRAINT fk_courses_instructor FOREIGN KEY (instructor_id) 
        REFERENCES instructors(id) ON DELETE RESTRICT ON UPDATE CASCADE
) ENGINE=InnoDB;

-- Table 5: semesters (Stores academic semester terms)
DROP TABLE IF EXISTS semesters;
CREATE TABLE semesters (
    id INT AUTO_INCREMENT PRIMARY KEY,
    semester_name VARCHAR(50) NOT NULL UNIQUE,
    start_date DATE NOT NULL,
    end_date DATE NOT NULL,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB;

-- Table 6: enrollments (Junction table linking students, courses, and semesters)
DROP TABLE IF EXISTS enrollments;
CREATE TABLE enrollments (
    id INT AUTO_INCREMENT PRIMARY KEY,
    student_id INT NOT NULL,
    course_id INT NOT NULL,
    semester_id INT NOT NULL,
    enrollment_date DATE DEFAULT (CURRENT_DATE),
    grade DECIMAL(3,2) DEFAULT NULL CHECK (grade IS NULL OR (grade BETWEEN 0.00 AND 4.00)),
    letter_grade ENUM('A', 'B', 'C', 'D', 'F') DEFAULT NULL,
    CONSTRAINT unique_enrollment UNIQUE (student_id, course_id, semester_id),
    CONSTRAINT fk_enrollments_student FOREIGN KEY (student_id) 
        REFERENCES students(id) ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT fk_enrollments_course FOREIGN KEY (course_id) 
        REFERENCES courses(id) ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT fk_enrollments_semester FOREIGN KEY (semester_id) 
        REFERENCES semesters(id) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB;

-- ------------------------------------------------------------------------------
-- 3. SAMPLE DATA SEEDING
-- ------------------------------------------------------------------------------

-- Seed 1: departments (5 records)
INSERT INTO departments (id, name, code) VALUES
(1, 'Khoa Công nghệ Thông tin', 'CNTT'),
(2, 'Khoa Multimedia & Thiết kế Web', 'MMD'),
(3, 'Khoa Quản trị Kinh doanh', 'QTKD'),
(4, 'Khoa Ngôn ngữ Anh', 'NNA'),
(5, 'Khoa Điện tử Viễn thông', 'DTVT');

-- Seed 2: instructors (5 records)
INSERT INTO instructors (id, department_id, name, email, phone, hire_date) VALUES
(1, 1, 'Nguyễn Văn An', 'an.nguyen@university.edu.vn', '0901234567', '2015-09-01'),
(2, 2, 'Trần Thị Bình', 'binh.tran@university.edu.vn', '0912345678', '2018-02-15'),
(3, 3, 'Lê Hoàng Cường', 'cuong.le@university.edu.vn', '0923456789', '2012-11-20'),
(4, 4, 'Phạm Hải Yến', 'yen.pham@university.edu.vn', '0934567890', '2020-08-01'),
(5, 5, 'Đỗ Minh Đức', 'duc.do@university.edu.vn', '0945678901', '2016-04-10');

-- Seed 3: students (5 records)
INSERT INTO students (id, department_id, student_code, name, email, gender, gpa) VALUES
(1, 2, 'SV2024001', 'Nguyễn Minh Khoa', 'khoa.sv2024001@st.university.edu.vn', 'Male', 3.65),
(2, 2, 'SV2024002', 'Lê Thu Hà', 'ha.sv2024002@st.university.edu.vn', 'Female', 3.80),
(3, 1, 'SV2024003', 'Trần Tuấn Kiệt', 'kiet.sv2024003@st.university.edu.vn', 'Male', 3.20),
(4, 3, 'SV2024004', 'Vũ Ngọc Ánh', 'anh.sv2024004@st.university.edu.vn', 'Female', 2.95),
(5, 5, 'SV2024005', 'Hoàng Quốc Bảo', 'bao.sv2024005@st.university.edu.vn', 'Male', 3.40);

-- Seed 4: courses (5 records)
INSERT INTO courses (id, department_id, instructor_id, course_code, title, credits, description) VALUES
(1, 1, 1, 'INS3064', 'Web Development & MySQL', 3, 'Nhập môn phát triển Web và cơ sở dữ liệu MySQL'),
(2, 2, 2, 'MMD2010', 'Thiết kế Đồ họa Đa phương tiện', 3, 'Kỹ thuật thiết kế giao diện UI/UX và đồ họa số'),
(3, 3, 3, 'BUS1001', 'Quản trị Học Cơ bản', 2, 'Các nguyên lý cơ bản trong quản trị doanh nghiệp'),
(4, 4, 4, 'ENG2002', 'Tiếng Anh Chuyên ngành CNTT', 2, 'Cung cấp từ vựng và kỹ năng giao tiếp tiếng Anh chuyên ngành'),
(5, 5, 5, 'ECE3005', 'Mạng Máy tính Cơ bản', 3, 'Kiến trúc mạng, giao thức TCP/IP và cấu hình thiết bị');

-- Seed 5: semesters (5 records)
INSERT INTO semesters (id, semester_name, start_date, end_date) VALUES
(1, 'Fall 2024', '2024-09-01', '2024-12-31'),
(2, 'Spring 2025', '2025-01-15', '2025-05-30'),
(3, 'Summer 2025', '2025-06-10', '2025-08-15'),
(4, 'Fall 2025', '2025-09-01', '2025-12-31'),
(5, 'Spring 2026', '2026-01-15', '2026-05-30');

-- Seed 6: enrollments (10 records)
INSERT INTO enrollments (student_id, course_id, semester_id, enrollment_date, grade, letter_grade) VALUES
(1, 1, 1, '2024-09-05', 3.80, 'A'),
(1, 2, 1, '2024-09-05', 3.50, 'B'),
(2, 1, 1, '2024-09-06', 4.00, 'A'),
(2, 2, 1, '2024-09-06', 3.70, 'A'),
(3, 1, 1, '2024-09-07', 3.20, 'B'),
(3, 5, 1, '2024-09-07', 3.00, 'B'),
(4, 3, 1, '2024-09-08', 2.80, 'C'),
(4, 4, 1, '2024-09-08', 3.10, 'B'),
(5, 5, 1, '2024-09-09', 3.60, 'A'),
(5, 1, 2, '2025-01-16', NULL, NULL);
