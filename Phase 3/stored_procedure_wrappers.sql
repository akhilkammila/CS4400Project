-- CS4400: Introduction to Database Systems
-- Functions and Stored Procedures (Course Project "Wrappers")
-- Wednesday, December 23, 2020

-- [1] FUNCTIONS: Use functions to calculate atomic values
-- Calculate the age given a date of birth
drop function if exists calc_age;
delimiter //
create function calc_age(birthdate date)
	returns integer deterministic
begin
	return timestampdiff(year, birthdate, current_date());
end //
delimiter ;

-- [2] Test the function to ensure that it works
select calc_age('1970-05-20');
select calc_age('2000-06-20');
select calc_age('2000-06-22');

-- [3] STORED PROCEDURES: Use stored procedures apply queries in
-- a more flexible manner (i.e., "multi-purpose")
-- Consider these individual queries with a common pattern
select * from employee where superssn = 888665555;
select * from employee where superssn = 444444444;
select * from employee where superssn = 987654321;

-- [4] Begin with a "fixed query" - no variables
drop procedure if exists direct_workers_fixed;
delimiter //
create procedure direct_workers_fixed()
begin
	select * from employee where superssn = 888665555;
end //
delimiter ;

-- [5] Test the procedure to ensure that it works
call direct_workers_fixed();

-- [6] Now, add an input (only) parameter to support flexibility
drop procedure if exists direct_workers_flexible;
delimiter //
create procedure direct_workers_flexible(in the_ssn decimal(9,0))
begin
	select * from employee where superssn = the_ssn;
end //
delimiter ;

-- [7] Test the procedure to ensure that it works
call direct_workers_flexible(888665555);
call direct_workers_flexible(444444444);
call direct_workers_flexible(987654321);

-- [8] Let's try a different query with more parameters
select * from employee
where salary between 20000 and 40000
and dno = 4;

select * from employee
where salary between 30000 and 50000
and dno = 5;

-- [9] Begin again with a "fixed query" - no variables
drop procedure if exists dept_salary_filter_fixed;
delimiter //
create procedure dept_salary_filter_fixed()
begin
	select * from employee
	where salary between 20000 and 40000
	and dno = 4;
end //
delimiter ;

-- [10] Test the procedure to ensure that it works
call dept_salary_filter_fixed();

-- [11] Now, let's add parameters to match the parts of the
-- query that vary between runs
drop procedure if exists dept_salary_filter_flexible;
delimiter //
create procedure dept_salary_filter_flexible(in low_bound integer,
	in high_bound integer, in the_dept integer)
begin
	select * from employee
	where salary between low_bound and high_bound
	and dno = the_dept;
end //
delimiter ;

-- [12] Test the procedure to ensure that it works
call dept_salary_filter_flexible(20000, 40000, 4);
call dept_salary_filter_flexible(30000, 50000, 5);

-- [13] Suppose that Department #4 is now "off limits" to being accessed
-- via this query.  How would you change the structure of the procedure
-- to support these controls?
drop procedure if exists dept_salary_filter_secure;
delimiter //
create procedure dept_salary_filter_secure(in low_bound integer,
	in high_bound integer, in the_dept integer)
sp_main: begin
	if the_dept = 4 then leave sp_main; end if;
    
	select * from employee
	where salary between low_bound and high_bound
	and dno = the_dept;
end //
delimiter ;

-- [14] Test the procedure to ensure that it works
call dept_salary_filter_secure(20000, 40000, 4);
call dept_salary_filter_secure(10000, 100000, 1);
call dept_salary_filter_secure(30000, 50000, 5);

-- [15] Can you make a variable represent a list- or an array-like
-- structure?
drop procedure if exists dept_salary_filter_list;
delimiter //
create procedure dept_salary_filter_list(in low_bound integer,
	in high_bound integer, in list_of_depts varchar(100))
sp_main: begin
	if find_in_set(4, list_of_depts) then leave sp_main; end if;
    
	select * from employee
	where salary between low_bound and high_bound
	and find_in_set(dno, list_of_depts);
end //
delimiter ;

-- [16] Test the procedure to ensure that it works
call dept_salary_filter_list(20000, 40000, '4');
call dept_salary_filter_list(10000, 100000, '1');
call dept_salary_filter_list(30000, 50000, '5');

call dept_salary_filter_list(20000, 40000, '4,1');
call dept_salary_filter_list(10000, 100000, '1,5');
call dept_salary_filter_list(30000, 50000, '5,4');

call dept_salary_filter_list(10000, 100000, '4,1,5');
call dept_salary_filter_list(30000, 50000, '');

-- [17] Now, let's create a procedure that adds new departments
drop procedure if exists add_new_dept;
delimiter //
create procedure add_new_dept(in the_name char(20),
	in the_number decimal(1,0), in the_mgr decimal(9,0), in the_start date)
begin    
	insert into department values (the_name, the_number, the_mgr, the_start);
end //
delimiter ;

-- [18] The stored procedure works, but doesn't allow you to override
-- other constraints such primary and foreign keys
call add_new_dept('Innovation', 2, 453453453, '2020-07-08');

call add_new_dept('Corruption', 5, 888665555, '2018-01-01');
call add_new_dept('Scandal', null, 888665555, '2017-01-01');
call add_new_dept('Controversy', 6, 777777777, '2016-01-01');
call add_new_dept('Disruption', 7, 888665555, null);
call add_new_dept('Headquarters', 8, 987987987, '2015-01-01');

-- [19] However, there is no limitation on the number of departments that
-- can be managed by a single employee
call add_new_dept('Creativity', 7, 453453453, '2020-07-09');
call add_new_dept('Excellence', 8, 453453453, '2020-07-10');

-- [20] Let's create a version of the procedure that prevent a new
-- department from being assigned to an employee who already manages
-- two or more other departments
drop procedure if exists add_new_dept_limited;
delimiter //
create procedure add_new_dept_limited(in the_name char(20),
	in the_number decimal(1,0), in the_mgr decimal(9,0), in the_start date)
sp_main: begin
	if (select count(*) from department where mgrssn = the_mgr) >= 2
		then leave sp_main; end if;
    
	insert into department values (the_name, the_number, the_mgr, the_start);
end //
delimiter ;

-- [21] Let's ensure that the new procedure operates as intended
call add_new_dept_limited('Finance', 3, 453453453, '2020-07-11');
call add_new_dept_limited('Finance', 3, 987654321, '2020-07-11');

call add_new_dept_limited('Logistics', 6, 987654321, '2020-07-12');
call add_new_dept_limited('Logistics', 6, 987987987, '2020-07-12');

-- [22] Finally, let's also add the capability for the procedure to
-- automatically assign a starting date for the department manager's
-- duties five days into the future.
drop procedure if exists add_new_dept_future_start;
delimiter //
create procedure add_new_dept_future_start(in the_name char(20),
	in the_number decimal(1,0), in the_mgr decimal(9,0))
sp_main: begin
	if (select count(*) from department where mgrssn = the_mgr) >= 2
		then leave sp_main; end if;
        
	set @starting_date = adddate(current_date(), 5);
    
	insert into department values (the_name, the_number, the_mgr, @starting_date);
end //
delimiter ;

-- [23] Let's ensure that the new procedure operates as intended
call add_new_dept_future_start('Time Travel', 9, 999887777);

-- [24] Finally, let's create a table to store the results from 
-- executing the select query.  Displaying the results on screen does
-- not allow us to evaluate the query later.
drop procedure if exists dept_salary_filter_persistent;
delimiter //
create procedure dept_salary_filter_persistent(in low_bound integer,
	in high_bound integer, in the_dept integer)
begin
	drop table if exists dept_salary_filter_persistent_result;
    create table dept_salary_filter_persistent_result(
		fname char(10),
		lname char(20),
		ssn decimal(9,0),
		bdate date,
		address char(30),
		sex char(1),
		salary decimal(5,0),
		superssn decimal(9,0),
		dno decimal(1,0)
    );
    
    insert into dept_salary_filter_persistent_result
	select * from employee
	where salary between low_bound and high_bound
	and dno = the_dept;
end //
delimiter ;

-- [25] Check the procedure to ensure that the results have been stored
call dept_salary_filter_persistent(20000, 40000, 4);
select * from dept_salary_filter_persistent_result;

-- [26] Later calls to the procedure will modify the output table
call dept_salary_filter_persistent(30000, 50000, 5);
select * from dept_salary_filter_persistent_result;
