-- Library Management System --

-- Creating Branch table --
drop table if exists Branch;
create table Branch
	(
	branch_id varchar(10) primary key,	
	manager_id varchar(10),	
	branch_address varchar(55),	
	contact_no varchar(15)
	)

-- Alter the table --
ALTER TABLE Branch
ALTER COLUMN contact_no type varchar(20);

-- Creating Employee table --
drop table if exists Employees;
create table Employees
	(
	emp_id varchar(10) primary key,  
	emp_name varchar(25),	
	position varchar(15),	
	salary int,	
	branch_id varchar(10)
	)
	
-- Alter the table --
ALTER TABLE Employees
ALTER COLUMN salary type float;

-- Creating Books table --
drop table if exists Books;
create table Books
	(
	isbn varchar(20) primary key, 	
	book_title varchar(75),	
	category varchar(20),	
	rental_price float,	
	status varchar(15),	
	author varchar(35),	
	publisher varchar(55)
	)

-- Alter the table --
ALTER TABLE Books
ALTER COLUMN category type varchar(20);

-- Creating Members table --
drop table if exists Members;
create table Members
	(
	member_id varchar(10) primary key, 	
	member_name varchar(25),	
	member_address varchar(75),	
	reg_date date
	)

-- Creating issued_status table --
drop table if exists issued_status;
create table issued_status
	(
	issued_id varchar(10) primary key,	
	issued_member_id varchar(10),	
	issued_book_name varchar(75),
	issued_date	date,
	issued_book_isbn varchar(25),	
	issued_emp_id varchar(15)
	)

-- Creating return_status table --
drop table if exists return_status;
create table return_status
	(
	return_id varchar(10) primary key,	
	issued_id varchar(10),	
	return_book_name varchar(75),	
	return_date	date,
	return_book_isbn varchar(20)
	)

-- Foreign Key
alter table issued_status
add constraint fk_members
foreign key (issued_member_id)
references Members(member_id);

alter table issued_status
add constraint fk_books
foreign key (issued_book_isbn)
references Books(isbn);

alter table issued_status
add constraint fk_employees
foreign key (issued_emp_id)
references Employees(emp_id);

alter table Employees
add constraint fk_branch
foreign key (branch_id)
references Branch(branch_id);

alter table return_status
add constraint fk_issued_status
foreign key (issued_id)
references issued_status(issued_id);

select * from Books

