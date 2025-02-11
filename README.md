# Library Management System using SQL Project --P2

## Project Overview

**Project Title**: Library Management System  
**Level**: Intermediate  
**Database**: `library_db`

This project demonstrates the implementation of a Library Management System using SQL. It includes creating and managing tables, performing CRUD operations, and executing advanced SQL queries. The goal is to showcase skills in database design, manipulation, and querying.

![Library_project](https://github.com/najirh/Library-System-Management---P2/blob/main/library.jpg)

## Objectives

1. **Set up the Library Management System Database**: Create and populate the database with tables for branches, employees, members, books, issued status, and return status.
2. **CRUD Operations**: Perform Create, Read, Update, and Delete operations on the data.
3. **CTAS (Create Table As Select)**: Utilize CTAS to create new tables based on query results.
4. **Advanced SQL Queries**: Develop complex queries to analyze and retrieve specific data.

## Project Structure

### 1. Database Setup
![ERD](https://github.com/najirh/Library-System-Management---P2/blob/main/library_erd.png)

- **Database Creation**: Created a database named `LMS_Project`.
- **Table Creation**: Created tables for branches, employees, members, books, issued status, and return status. Each table includes relevant columns and relationships.

```sql
CREATE DATABASE LMS_Project;

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

```

### 2. CRUD Operations

- **Create**: Inserted sample records into the `books` table.
- **Read**: Retrieved and displayed data from various tables.
- **Update**: Updated records in the `employees` table.
- **Delete**: Removed records from the `members` table as needed.

**Task 1. Create a New Book Record**
-- "978-1-60129-456-2', 'To Kill a Mockingbird', 'Classic', 6.00, 'yes', 'Harper Lee', 'J.B. Lippincott & Co.')"

```sql
insert into books
(isbn, book_title, category, rental_price, status, author, publisher)
values 
('978-1-60129-456-2', 'To Kill a Mockingbird', 'Classic', 6.00, 'yes', 'Harper Lee', 'J.B. Lippincott & Co.');
select * from Books;
```
**Task 2: Update an Existing Member's Address**

```sql
update Members
set member_address = '125 Main St'
where member_id = 'C101';
select * from Members;
```

**Task 3: Delete a Record from the Issued Status Table**
-- Objective: Delete the record with issued_id = 'IS121' from the issued_status table.

```sql
delete from issued_status
where issued_id = 'IS121';
select * from issued_status;
```

**Task 4: Retrieve All Books Issued by a Specific Employee**
-- Objective: Select all books issued by the employee with emp_id = 'E101'.
```sql
select * from issued_status
where issued_emp_id = 'E101';
```


**Task 5: List Members Who Have Issued More Than One Book**
-- Objective: Use GROUP BY to find members who have issued more than one book.

```sql
select 
	issued_emp_id,
	count(issued_book_isbn) as Total_books
	from issued_status
group by 1
having count(issued_book_isbn) > 1
order by 2 desc;
```

### 3. CTAS (Create Table As Select)

- **Task 6: Create Summary Tables**: Used CTAS to generate new tables based on query results - each book and total book_issued_cnt**

```sql
create table book_counts
as
select
	b.isbn,
	b.book_title,
	count(ist.issued_id) as No_Issued
	from Books as b
join
	issued_status as ist
	on ist.issued_book_isbn = b.isbn
	group by 1,2
	order by 3 desc;

select * from book_counts;
```


### 4. Data Analysis & Findings

The following SQL queries were used to address specific questions:

Task 7. **Retrieve All Books in a Specific Category**:

```sql
SELECT * FROM books
WHERE category = 'Classic';
```

8. **Task 8: Find Total Rental Income by Category**:

```sql
select b.category, sum(b.rental_price), count(*)
from books as b
join
	issued_status as ist
	on ist.issued_book_isbn = b.isbn
group by 1
order by 2 desc;
```

9. **List Members Who Registered in the Last 180 Days**:
```sql
select * from Members
where reg_date >= current_date - interval '180 days';	
```

10. **List Employees with Their Branch Manager's Name and their branch details**:

```sql
select e1.*,b.manager_id,e2.emp_name as Manager_name from Employees as e1
join
	Branch as b
	on e1.branch_id = b.branch_id
join
	Employees as e2
	on b.manager_id = e2.emp_id
```

Task 11. **Create a Table of Books with Rental Price Above a Certain Threshold**:
```sql
create table books_price_gthan7 
as
select * from Books
where rental_price >= 7;

select * from books_price_gthan7
```

Task 12: **Retrieve the List of Books Not Yet Returned**
```sql
create table not_returned_books
as
select 
	distinct ist.issued_book_name	
from issued_status as ist
left join return_status as rst
	on ist.issued_id = rst.issued_id
where rst.return_id is null

select * from not_returned_books
```

## Advanced SQL Operations

**Task 13: Identify Members with Overdue Books**  
Write a query to identify members who have overdue books (assume a 30-day return period). Display the member's_id, member's name, book title, issue date, and days overdue.

```sql
select 
	ist.issued_member_id,
	m.member_name,
	bk.book_title,
	ist.issued_date,
	current_date - ist.issued_date as overdue_days
from issued_status as ist
join Members as m
	on m.member_id = ist.issued_member_id
join Books as bk
	on bk.isbn = ist.issued_book_isbn
left join return_status as rs
	on rs.issued_id = ist.issued_id
where
	rs.return_date is null
	and
	(current_date - ist.issued_date) > 30
order by 5 desc;
```


**Task 14: Update Book Status on Return**  
Write a query to update the status of books in the books table to "Yes" when they are returned (based on entries in the return_status table).


```sql
CREATE OR REPLACE PROCEDURE add_return_records(p_return_id VARCHAR(10), p_issued_id VARCHAR(10), p_book_quality VARCHAR(15))
LANGUAGE plpgsql
AS $$

DECLARE
    v_isbn VARCHAR(50);
    v_book_name VARCHAR(80);
    
BEGIN
    -- all your logic and code
    -- inserting into returns based on users input
    INSERT INTO return_status(return_id, issued_id, return_date, book_quality)
    VALUES
    (p_return_id, p_issued_id, CURRENT_DATE, p_book_quality);

    SELECT 
        issued_book_isbn,
        issued_book_name
        INTO
        v_isbn,
        v_book_name
    FROM issued_status
    WHERE issued_id = p_issued_id;

    UPDATE books
    SET status = 'yes'
    WHERE isbn = v_isbn;

    RAISE NOTICE 'Thank you for returning the book: %', v_book_name;
    
END;
$$

-- Testing FUNCTION add_return_records

issued_id = IS135
ISBN = WHERE isbn = '978-0-307-58837-1'

SELECT * FROM books
WHERE isbn = '978-0-307-58837-1';

SELECT * FROM issued_status
WHERE issued_book_isbn = '978-0-307-58837-1';

SELECT * FROM return_status
WHERE issued_id = 'IS135';

-- calling function 
CALL add_return_records('RS138', 'IS135', 'Good');

-- calling function 
CALL add_return_records('RS148', 'IS140', 'Good');
```




**Task 15: Branch Performance Report**  
Create a query that generates a performance report for each branch, showing the number of books issued, the number of books returned, and the total revenue generated from book rentals.

```sql
drop table if exists Branch_Report;
create table Branch_Report
as
select
	b.branch_id,
	b.manager_id,
	count(ist.issued_id) as total_books_issued,
	count(rs.return_id) as total_books_returned,
	sum(bk.rental_price) as total_revenue
from issued_status as ist
join Employees as e
	on e.emp_id = ist.issued_emp_id
join Branch as b
	on e.branch_id = b.branch_id
left join return_status as rs
	on rs.issued_id = ist.issued_id
join Books as bk
	on ist.issued_book_isbn = bk.isbn
group by 1,2
order by 5 desc;

select * from Branch_Report;
```

**Task 16: CTAS: Create a Table of Active Members**  
Use the CREATE TABLE AS (CTAS) statement to create a new table active_members containing members who have issued at least one book in the last 2 months.

```sql
drop table if exists active_members;
create table active_members
as
select * from Members
where member_id in
(
	select distinct issued_member_id
	from issued_status
	where issued_date >= current_date - interval '2 month'
);

select * from active_members;
```


**Task 17: Find Employees with the Most Book Issues Processed**  
Write a query to find the top 3 employees who have processed the most book issues. Display the employee name, number of books processed, and their branch.

```sql
select 
	e.emp_name,
	count(ist.issued_id) as total_books_processed,
	br.branch_id
from Employees as e
join issued_status as ist
	on e.emp_id = ist.issued_emp_id
left join Branch as br
	on e.branch_id = br.branch_id
group by 1,3
order by 2 desc;
```

**Task 18: Identify Members Issuing High-Risk Books**  
Write a query to identify members who have issued books more than twice with the status "damaged" in the books table. Display the member name, book title, and the number of times they've issued damaged books.    

```sql
select 
	e.emp_name,
	ist.issued_book_name,
	count(ist.issued_id) as issued_times
	
from Employees as e
join  issued_status as ist
	on ist.issued_emp_id = e.emp_id
left join return_status as rt
	on rt.issued_id = ist. issued_id
group by 1,2
having count(ist.issued_id) >= 2;
```

**Task 19: Stored Procedure**
Objective:
Create a stored procedure to manage the status of books in a library system.
Description:
Write a stored procedure that updates the status of a book in the library based on its issuance. The procedure should function as follows:
The stored procedure should take the book_id as an input parameter.
The procedure should first check if the book is available (status = 'yes').
If the book is available, it should be issued, and the status in the books table should be updated to 'no'.
If the book is not available (status = 'no'), the procedure should return an error message indicating that the book is currently not available.

```sql
create or replace procedure issue_book(p_issued_id varchar(10), p_issued_member_id varchar(30), 
	p_issued_book_isbn varchar(50), p_issued_emp_id varchar(10))
language plpgsql
as $$

declare
	v_status varchar(10);
begin
	-- check book availability
	select status
	into
	v_status
	from books
	where isbn = p_issued_book_isbn;

	if v_status = 'yes' then
		insert into issued_status(issued_id, issued_member_id, issued_date, issued_book_isbn, issued_emp_id)
		values (p_issued_id, p_issued_member_id, current_date, p_issued_book_isbn, p_issued_emp_id);

		update Books
		set status = 'no'
		where isbn = p_issued_book_isbn;
		
		raise notice 'Book record(s) added successfully for isbn: %', p_issued_book_isbn;
	else
		raise notice 'Sorry! The book is unavailable with isbn: %', p_issued_book_isbn;
		
	end if;
end
$$

select * from Books;
select * from issued_status;

-- "978-0-553-29698-2" yes
-- "978-0-375-41398-8" no

call issue_book('IS155', 'C108', '978-0-553-29698-2', 'E104')
call issue_book('IS156', 'C108', '978-0-375-41398-8', 'E104')

-- check the update
select * from Books
where isbn = '978-0-553-29698-2';
```



**Task 20: Create Table As Select (CTAS)**
Objective: Create a CTAS (Create Table As Select) query to identify overdue books and calculate fines.

Description: Write a CTAS query to create a new table that lists each member and the books they have issued but not returned within 30 days. The table should include:
    The number of overdue books.
    The total fines, with each day's fine calculated at $0.50.
    The number of books issued by each member.
    The resulting table should show:
    Member ID
    Number of overdue books
    Total fines

```sql
drop table if exists risky_books;
create table risky_books
as
select 
	ist.issued_member_id,
	count(current_date - rt.return_date) as No_of_overdue_books,
	(count(current_date - rt.return_date)) * 0.50 as Total_fine
from issued_status as ist
join return_status as rt
	on rt.issued_id = ist.issued_id
where current_date - rt.return_date > 30
group by 1
order by 2,3 desc;

select * from risky_books;
```

## Reports

- **Database Schema**: Detailed table structures and relationships.
- **Data Analysis**: Insights into book categories, employee salaries, member registration trends, and issued books.
- **Summary Reports**: Aggregated data on high-demand books and employee performance.

## Conclusion

This project demonstrates the application of SQL skills in creating and managing a library management system. It includes database setup, data manipulation, and advanced querying, providing a solid foundation for data management and analysis.
