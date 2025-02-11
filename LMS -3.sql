-- SQL LMS Projects (cont.,) --

-- check table data
select * from Books;
select * from Branch;
select * from Employees;
select * from Members;
select * from issued_status;
select * from return_status;


/*
Task 13: Identify Members with Overdue Books
Write a query to identify members who have overdue books (assume a 30-day return period). 
Display the member's_id, member's name, book title, issue date, and days overdue.
*/

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

/*
Task 14: Branch Performance Report
Create a query that generates a performance report for each branch, showing the number of books issued, 
the number of books returned, and the total revenue generated from book rentals.
*/

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

/*
Task 15: Update Book Status on Return
Write a query to update the status of books in the books table to "Yes" when they are returned 
(based on entries in the return_status table).
*/


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

/*
Task 16: CTAS: Create a Table of Active Members
Use the CREATE TABLE AS (CTAS) statement to create a new table active_members containing members 
who have issued at least one book in the last 2 months.
*/

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

-- check table data
select * from Books;
select * from Branch;
select * from Employees;
select * from Members;
select * from issued_status;
select * from return_status;


/*
Task 17: Find Employees with the Most Book Issues Processed
Write a query to find the top 3 employees who have processed the most book issues. 
Display the employee name, number of books processed, and their branch.
*/

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

/*
Task 18: Identify Members Issuing High-Risk Books
Write a query to identify members who have issued books more than twice 
with the status "damaged" in the books table. 
Display the member name, book title, and the number of times they've issued books.
*/

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

/*
Task 19: Stored Procedure Objective: Create a stored procedure to manage the status of books 
in a library system. 
Description: Write a stored procedure that updates the status of a book in the library 
based on its issuance. 
The procedure should function as follows: 
The stored procedure should take the book_id as an input parameter. The procedure should first check 
if the book is available (status = 'yes'). 
If the book is available, it should be issued, and the status in the books table 
should be updated to 'no'. If the book is not available (status = 'no'), the procedure should return 
an error message indicating that the book is currently not available.
*/


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

/*
Create Table As Select (CTAS) Objective: Create a CTAS (Create Table As Select) query to 
identify overdue books and calculate fines.

Description: Write a CTAS query to create a new table that lists each member and 
the books they have issued but not returned within 30 days. 
The table should include: 
The number of overdue books. The total fines, with each day's fine calculated at $0.50. 
The number of books issued by each member. 
The resulting table should show: Member ID Number of overdue books Total fines
*/

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