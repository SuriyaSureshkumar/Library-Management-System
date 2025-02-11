-- check table data
select * from Books;
select * from Branch;
select * from Employees;
select * from Members;
select * from issued_status;
select * from return_status;

-- Project tasks

-- Task 1. Create a New Book Record -- "978-1-60129-456-2', 'To Kill a Mockingbird', 'Classic', 6.00, 
-- 'yes', 'Harper Lee', 'J.B. Lippincott & Co.')"

insert into books
(isbn, book_title, category, rental_price, status, author, publisher)
values 
('978-1-60129-456-2', 'To Kill a Mockingbird', 'Classic', 6.00, 'yes', 'Harper Lee', 'J.B. Lippincott & Co.');
select * from Books;

-- Task 2: Update an Existing Member's Address

update Members
set member_address = '125 Main St'
where member_id = 'C101';
select * from Members;

-- Task 3: Delete a Record from the Issued Status Table 
-- Objective: Delete the record with issued_id = 'IS121' from the issued_status table.

delete from issued_status
where issued_id = 'IS121';
select * from issued_status;

-- Task 4: Retrieve All Books Issued by a Specific Employee 
-- Objective: Select all books issued by the employee with emp_id = 'E101'.

select * from issued_status
where issued_emp_id = 'E101';

-- Task 5: List Members Who Have Issued More Than One Book 
-- Objective: Use GROUP BY to find members who have issued more than one book.

select 
	issued_emp_id,
	count(issued_book_isbn) as Total_books
	from issued_status
group by 1
having count(issued_book_isbn) > 1
order by 2 desc;

-- Task 6: Create Summary Tables: 
-- Used CTAS to generate new tables based on query results - each book and total book_issued_cnt**

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

-- Task 7. Retrieve All Books in a Specific Category:

select * from books
where category = 'Classic';

-- Task 8: Find Total Rental Income by Category:

select b.category, sum(b.rental_price), count(*)
from books as b
join
	issued_status as ist
	on ist.issued_book_isbn = b.isbn
group by 1
order by 2 desc;

-- Task 9: List Members Who Registered in the Last 180 Days:
select * from Members
where reg_date >= current_date - interval '180 days';

insert into Members (member_id, member_name, member_address, reg_date)
values
	('C210','Sam','145 Main St','2025-01-25'),
	('C220','Ram','150 Main St','2025-01-26');	

-- Task 10: List Employees with Their Branch Manager's Name and their branch details:

select e1.*,b.manager_id,e2.emp_name as Manager_name from Employees as e1
join
	Branch as b
	on e1.branch_id = b.branch_id
join
	Employees as e2
	on b.manager_id = e2.emp_id

-- Task 11. Create a Table of Books with Rental Price Above a Certain Threshold (7 Dollars):

create table books_price_gthan7 
as
select * from Books
where rental_price >= 7;

select * from books_price_gthan7

-- Task 12: Retrieve the List of Books Not Yet Returned

create table not_returned_books
as
select 
	distinct ist.issued_book_name	
from issued_status as ist
left join return_status as rst
	on ist.issued_id = rst.issued_id
where rst.return_id is null

select * from not_returned_books

-- Task 13: Identify Members with Overdue Books
-- Write a query to identify members who have overdue books (assume a 30-day return period). 
-- Display the member's_id, member's name, book title, issue date, and days overdue.

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

-- Task 14: Branch Performance Report
-- Create a query that generates a performance report for each branch, showing the number of books issued, 
-- the number of books returned, and the total revenue generated from book rentals.

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