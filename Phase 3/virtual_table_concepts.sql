-- CS4400: Introduction to Database Systems
-- Views as Virtual Tables & Advanced Query Techniques
-- Wednesday, December 23, 2020

-- [1] Creating views from the textbook
create view works_on1 as
select fname, lname, pname, hours
from employee, project, works_on
where ssn = essn and pno = pnumber;

-- [2] It might appear as if the view is accepting parameters like
-- a function or a stored procedure, but it's not - these are the names
-- for the out put columns (e.g. renaming columns via "as")
create view dept_info(dept_name, no_of_emps, total_sal) as
select dname, count(*), sum(salary)
from department, employee
where dnumber = dno group by dname;

-- [3] Example transactions from the textbook
update works_on1 set hours = 33
where fname = 'Franklin' and lname = 'Wong' and pname = 'Computerization';

-- [4] Determine if this transaction succeeds or fails
update dept_info set total_sal = 100000
where dname = 'Research';

-- [5] Views for Query Simplification
-- Views can be used almost like tables to simplify the assembly
-- of complex queries
create view dept5emp as
select * from employee
where dno = 5;

-- [6] Display all of the information about the Department 5 members
select * from dept5emp;

-- [7] Display the first name, last name and salary for all
-- Department 5 members who have a salary > $25,000
select fname, lname, salary from dept5emp
where salary > 25000;

-- [8] Display the project numbers for any project that is being
-- supported by at least one Department 5 member
select distinct pno from works_on
where essn in (select ssn from dept5emp);

-- [9] Display the ssn, first and last names, along with the
-- total number of hours worked on Project 2 or 3 for all of
-- the Department 5 members
select ssn, fname, lname, sum(hours)
from dept5emp join works_on on ssn = essn
where pno in (2, 3) group by ssn;

-- alternate approach
select ssn, fname, lname, total_hours
from dept5emp, (select essn, sum(hours) as total_hours
	from works_on where pno in (2, 3) group by essn) temp
where ssn = essn;

-- [10] Views for Access Control
-- Views can be used to allow and decline access to perform different types
-- of modifications to the database
-- The following transactions are running on a query in "unchecked" mode
insert into dept5emp
values ('Hanna', 'Muller', 999999999, '1966-11-24', '2001 Hal Avenue, Dallas TX', 'F', 33000, 333445555, 5);

-- [11] Determine if these transactions succeeds or fails
insert into dept5emp
values ('Samuel', 'Levi', 987654321, '1970-07-27', '31 Fingerling Way, Houston TX', 'M', 21000, 333445555, 5);

-- [12]
insert into dept5emp
values ('Samuel', 'Levi', 444444444, '1970-07-27', '31 Fingerling Way, Houston TX', 'M', 21000, 987654321, 4);

-- [13]
update dept5emp set salary = 25000
where ssn = 444444444;

-- [14] The following query is running with the "check option" to
-- provide greater controls
create view dept5emp_check as
select * from employee
where dno = 5 with check option;

-- [15] Compare the effects of these queries with the earlier queries
insert into dept5emp_check
values ('Harriet', 'Barrison', 111111111, '1971-03-19', '11 Downing Street, Lubbock TX', 'F', 26000, 987654321, 4);

-- [16]
update dept5emp_check set salary = 25000
where ssn = 444444444;

-- [17] Advanced Queries (ALL and similar comparison operators)
select lname, fname, salary from employee
where salary > all (select salary from employee
	where dno = 5);

-- [18]
select lname, fname, salary from employee
where salary > all (select salary from employee
	where dno = 4);

-- [19] Advanced Queries (Correlated Subqueries)
select lname, fname, salary, dno
from employee as main
where salary >= all (select salary from employee as my_dept
	where my_dept.dno = main.dno);

-- [20] alternate ways to frame these types of queries
-- without the all keyword
select lname, fname, salary, dno
from employee as main
where salary >= (select max(salary) from employee as my_dept
	where my_dept.dno = main.dno);

select lname, fname, salary, dno
from employee as main
where salary <= (select min(salary) from employee as my_dept
	where my_dept.dno = main.dno);

-- [21] Advanced Queries (EXISTS and UNIQUE Checks)
-- EXISTS can be used to return True (1) if and only if a result
-- set has one or more rows
select *
from employee e, employee m, department d
where e.salary > m.salary
and e.dno = d.dnumber
and d.mgrssn = m.ssn;

select exists (select *
from employee e, employee m, department d
where e.salary > m.salary
and e.dno = d.dnumber
and d.mgrssn = m.ssn);

-- [22] Other examples of using EXISTS
select * from employee;

select exists (select * from employee);

-- [23]
select ssn, count(*) from employee
group by ssn having count(*) > 1;

select exists (select ssn, count(*) from employee
	group by ssn having count(*) > 1);

-- [24]
select salary, count(*) from employee
group by salary having count(*) > 1;

select exists (select salary, count(*) from employee
	group by salary having count(*) > 1);

-- UNIQUE is not implemented in MySQL
