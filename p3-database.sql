-- CREATING DATABASE company and it's tables

CREATE TABLE department
(unit_id integer,
 unit_name CHARACTER VARYING(128) NOT NULL,
 unit_address CHARACTER VARYING(128) NOT NULL,
 PRIMARY KEY(unit_id)
);

CREATE TABLE employee
(employee_id integer,
 employee_firstName CHARACTER VARYING(128) NOT NULL,
 employee_lastName CHARACTER VARYING(128) NOT NULL,
 employee_birth DATE NOT NULL,
 PRIMARY KEY(employee_id)
);

CREATE TABLE job
(job_name CHARACTER VARYING(128) NOT NULL,
 min_salary integer NOT NULL,
 PRIMARY KEY(job_name)
);

CREATE TABLE career
(id_post integer,
 unit_id integer,
 employee_id integer,
 career_start DATE NOT NULL,
 career_end DATE,
 PRIMARY KEY(id_post),
 FOREIGN KEY(unit_id) REFERENCES department(unit_id),
 FOREIGN KEY(employee_id) REFERENCES employee(employee_id)
);

CREATE TABLE salary
(employee_id integer,
 salary_month integer,
 salary_year integer,
 salary_cash integer,
 FOREIGN KEY(employee_id) REFERENCES employee(employee_id)
);

-- INSERTING INTO TABLE VALUES

INSERT INTO department VALUES
(1, 'fisrt', 'Kolasa'),
(2, 'second', 'Tanka'),
(3, 'third', 'Kazlova'),
(4, 'fourth', 'Bogdanovicha');

INSERT INTO employee VALUES
(11, 'Yhar', 'Zlobin', '1992-11-12'),
(31, 'Vasiliy', 'Karpov', '1982-03-02'),
(32, 'Vladislav', 'Rybko', '1995-07-11'),
(13, 'Karina', 'Stolipina', '1998-04-07'),
(92, 'Ivan', 'Kazeka', '1996-12-09');

INSERT INTO job VALUES
('HR', 400),
('FrontEnd', 600),
('BackEnd', 700),
('BigData', 1000),
('AI', 1200),
('PR-manager', 350),
('Barista', 300);

INSERT INTO career VALUES
(1, 2, 11, '2005-11-11', '2009-11-03'),
(2, 3, 31, '2009-12-07', NULL),
(3, 1, 32, '2012-07-12', '2015-06-02'),
(4, 2, 13, '2011-04-08', NULL),
(5, 1, 92, '2010-09-03', NULL);

INSERT INTO salary VALUES
(11, 01, 2006, 400),
(11, 02, 2007, 610),
(11, 03, 2007, 600),
(11, 04, 2007, 630),
(11, 07, 2008, 750),
(11, 08, 2008, 780),
(11, 02, 2009, 800),
(31, 11, 2013, 500),
(31, 12, 2013, 500),
(31, 01, 2015, 700),
(31, 02, 2015, 680),
(31, 08, 2016, 800),
(32, 06, 2013, 1000),
(32, 08, 2014, 1300),
(32, 09, 2014, 1300),
(13, 07, 2012, 400),
(13, 09, 2013, 480),
(13, 10, 2013, 500),
(13, 01, 2015, 550),
(13, 08, 2015, 550),
(92, 01, 2011, 400),
(92, 08, 2012, 400),
(92, 01, 2015, 450),
(92, 10, 2016, 480),
(31, 5, 2015, 650);

-- FIXING SOME DATA

UPDATE public.salary
SET salary_cash = 1200
WHERE employee_id = 92
  AND salary_month = 1
  AND salary_year = 2015
  AND salary_cash = 450
  AND ctid = '(0,23)';

DELETE
FROM job
WHERE job_name = 'Barista';
DELETE
FROM job
WHERE job_name = 'BigData';

--ADDING FOREIGN KEY TO job TABLE

ALTER TABLE job ADD COLUMN fk_id_post integer ;

ALTER TABLE job ADD CONSTRAINT fk_id_post  FOREIGN KEY(fk_id_post) REFERENCES career(id_post);

UPDATE job set fk_id_post = 1 WHERE job_name = 'AI';
UPDATE job set fk_id_post = 2 WHERE job_name = 'BackEnd';
UPDATE job set fk_id_post = 3 WHERE job_name = 'FrontEnd';
UPDATE job set fk_id_post = 5 WHERE job_name = 'HR';
UPDATE job set fk_id_post = 4 WHERE job_name = 'PR-manager';

--TASKS


--1.1 SELECT ALL DATA FROM EMPLOYEE

SELECT * FROM employee;

--1.2 SELECT JOB ID AND JOB NAME FROM TABLE job WHERE MINIMAL SALARY LESS THAN 500

SELECT job_name, fk_id_post
FROM job
WHERE min_salary <= 500;

--1.3 SELECT AVERAGE SALARY ON JAN.2015

SELECT AVG(salary_cash)
FROM salary
WHERE salary_month = 1
  AND salary_year = 2015;

--2.1 SELECT NAME AND DATE OF BIRTH OF THE OLDEST EMPLOYEE

SELECT employee_firstname, employee_lastname, employee_birth
FROM employee
WHERE employee_birth = (SELECT MIN(employee_birth) from employee);

--2.2 SELECT NAME OF  EMPLOYEES WHICH HAVE SALARY IN JAN.2015

SELECT employee_lastname
FROM employee
WHERE employee_id IN (
    SELECT employee_id
    FROM salary
    WHERE salary_month = 1
      AND salary_year = 2015);

--2.3 SELECT IDs OF EMPLOYEES WHOSE WAGES DECREASES IN MAY 2015 COMPARED TO ANY PREVIOUS MONTH OF THE SAME YEAR
--(NOT WORKING)
SELECT *
FROM (
         SELECT employee_id,
                salary_cash - (SELECT MAX(salary_cash)
                               FROM salary
                               WHERE salary_month <= 5
                                 and salary_year = 2015
                               GROUP BY employee_id)
         FROM salary
         WHERE salary_month = 5
           AND salary_year = 2015
     ) as ssc;


SELECT *
FROM salary
WHERE (SELECT MAX(salary_cash)
       FROM salary
       WHERE salary_month = 5
         and salary_year = 2015
       group by employee_id) - (SELECT MAX(salary_cash)
                                FROM salary
                                WHERE salary_month = 1
                                  and salary_year = 2015
                                group by employee_id) < 0;



SELECT *
FROM employee
WHERE (SELECT salary_cash FROM salary WHERE salary_month = 5 and salary_year = 2015) -
      (SELECT MAX(salary_cash) FROM salary WHERE salary_month <= 5 and salary_year = 2015) < 0;

--2.4 SELECT  IDs, UNIT NAMES AND NUMBER OF EMPLOYEES CURRENTLY WORKING ON THEM

SELECT unit_id, unit_name, (SELECT count(career.employee_id) from career WHERE career.unit_id = department.unit_id)
from department;

--3.1 SELECT AVERAGE SALARY FOR 2015 FOR EACH EMPLOYEE WHOSE HAVE WAGES

SELECT employee_id, salary_year, AVG(salary_cash)
from salary
WHERE salary_year = 2015
group by employee_id, salary_year
ORDER BY employee_id;

--3.2 SAME SELECT TO PREVIOUS, BUT NOW CHOOSING ONLY EMPLOYEES WHOSE HAVE MORE THAN 2 WAGES FOR YEAR

SELECT employee_id, avg
FROM (
         SELECT employee_id, AVG(salary_cash) as avg, COUNT(salary_cash) as count
         from salary
         where salary_year = 2015
         group by employee_id
     ) as podzapros
WHERE count > 2;

--4.1 SELECT EMPLOYEE NAMES, WHOSE SALARY IN JAN.2015 GREATER THAN 1000

SELECT employee_firstname, employee_lastname
from employee
         LEFT JOIN salary ON employee.employee_id = salary.employee_id
WHERE salary_year = 2015
  and salary_month = 1
  and salary_cash > 1000;

--4.2 SELECT WORK EXPERIENCE FOR EACH WORKER

SELECT employee_lastname,
       employee_firstname,
       career_end,
       career_start,
       (COALESCE(career_end, current_date) - career.career_start) as work_time
from employee
         INNER JOIN career on employee.employee_id = career.employee_id;

--5.1 INCREASE MIN SALARY BY 1,5 TIMES

UPDATE job
set min_salary = min_salary * 1.5;

--5.2 DELETE FROM TABLE ALL DATA WHICH IS LESSER THAN 2015 YEAR

DELETE
FROM salary
WHERE salary_year > 2015;