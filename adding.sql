select * from project;
update project set pname = 'Innovation'
where pname = 'Newbenefits';

-- question 1: Change the name of project "Newbenefits" to "Innovation".
select * from project
where pname = 'Newbenefits';

select * from emp_proj; -- Newbenefits was not updated :(

select * from department;

-- Question 2: Add Dallas as one of the new locations for the Research Department.
update department set dlocations = concat(dlocations, ', Dallas')
where dname = 'Research';

select * from employee;
select * from emp_dept;

-- Question 3: Remove the information about John Smith's spouse from the database.
-- remove blank from employee
-- where fname = 'John' and lname = 'Smith';

-- Question 4: Retrieve a list of employees information who live in the city of Dallas.
select * from employee
where address like '%Dallas TX%';

-- Question 5: Retrieve a distinct list of all dependent names and birth dates along with their employee sponsor's SSN.
select ssn, depname1 as dnames, depbdate1 as bdates from employee
where depname1 is not null
union 
select ssn, depname2, depbdate2 from employee
where depname2 is not null
union 
select ssn, depname3, depbdate3 from employee
where depname3 is not null
union 
select ssn, depname4, depbdate4 from employee
where depname4 is not null;
