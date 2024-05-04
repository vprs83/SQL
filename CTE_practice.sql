-- CTE, Common Table Expression, WITH clause 
-- https://oracle-base.com/articles/misc/with-clause#subquery-factoring
-- subquery factoring process
-- exercise

create table dept (
  deptno    number(2) constraint pk_dept primary key,
  dname     varchar2(14),
  loc       varchar2(13)
);

create table emp (
  empno     number(4) constraint pk_emp primary key,
  ename     varchar2(10),
  job       varchar2(9),
  mgr       number(4),      -- employees manager
  hiredate  date,
  sal       number(7,2),
  comm      number(7,2),
  deptno    number(2) constraint fk_deptno references dept
);

insert into dept values (10,'ACCOUNTING','NEW YORK');
insert into dept values (20,'RESEARCH','DALLAS');
insert into dept values (30,'SALES','CHICAGO');
insert into dept values (40,'OPERATIONS','BOSTON');

insert into emp values (7369,'SMITH','CLERK',7902,to_date('17-12-1980','dd-mm-yyyy'),800,null,20);
insert into emp values (7499,'ALLEN','SALESMAN',7698,to_date('20-2-1981','dd-mm-yyyy'),1600,300,30);
insert into emp values (7521,'WARD','SALESMAN',7698,to_date('22-2-1981','dd-mm-yyyy'),1250,500,30);
insert into emp values (7566,'JONES','MANAGER',7839,to_date('2-4-1981','dd-mm-yyyy'),2975,null,20);
insert into emp values (7654,'MARTIN','SALESMAN',7698,to_date('28-9-1981','dd-mm-yyyy'),1250,1400,30);
insert into emp values (7698,'BLAKE','MANAGER',7839,to_date('1-5-1981','dd-mm-yyyy'),2850,null,30);
insert into emp values (7782,'CLARK','MANAGER',7839,to_date('9-6-1981','dd-mm-yyyy'),2450,null,10);
insert into emp values (7788,'SCOTT','ANALYST',7566,to_date('13-JUL-87','dd-mm-rr')-85,3000,null,20);
insert into emp values (7839,'KING','PRESIDENT',null,to_date('17-11-1981','dd-mm-yyyy'),5000,null,10);
insert into emp values (7844,'TURNER','SALESMAN',7698,to_date('8-9-1981','dd-mm-yyyy'),1500,0,30);
insert into emp values (7876,'ADAMS','CLERK',7788,to_date('13-JUL-87', 'dd-mm-rr')-51,1100,null,20);
insert into emp values (7900,'JAMES','CLERK',7698,to_date('3-12-1981','dd-mm-yyyy'),950,null,30);
insert into emp values (7902,'FORD','ANALYST',7566,to_date('3-12-1981','dd-mm-yyyy'),3000,null,20);
insert into emp values (7934,'MILLER','CLERK',7782,to_date('23-1-1982','dd-mm-yyyy'),1300,null,10);
commit;

SELECT * FROM dept;
SELECT * FROM emp;

-- for each employee how many other people are in their department
select e.ename as employee_name,
       dc.dept_count as emp_dept_count
from   emp e
       join (
                select deptno, count(*) as dept_count
                from   emp
                group by deptno
             ) dc
         on e.deptno = dc.deptno;

--  subquery dc factoring        
WITH dept_count AS
(
    select  deptno, 
            count(*) as dept_count
    from   emp
    group by deptno
)
select e.ename as employee_name,
       dc.dept_count as emp_dept_count
from   emp e
       join dept_count dc on e.deptno = dc.deptno;

-- for each employee how many other people are in their department
-- each employees manager name and the number of people in the managers department
with dept_count as 
(
    select  deptno, 
            count(*) as dept_count
    from   emp
    group by deptno
)
select e.ename as employee_name,
       dc1.dept_count as emp_dept_count,
       m.ename as manager_name,
       dc2.dept_count as mgr_dept_count
from   emp e
       join dept_count dc1 on e.deptno = dc1.deptno
       join emp m on e.mgr = m.empno
       join dept_count dc2 on m.deptno = dc2.deptno;

--  lists departments with above average wages
WITH 
    dept_costs as 
    (
        select  dname, 
                sum(sal) dept_total
        from    emp e, dept d
        where   e.deptno = d.deptno
        group by dname
    ),
    avg_cost as 
    (
        select  sum(dept_total)/count(*) avg
        from    dept_costs
    )
select *
from   dept_costs
where  dept_total > (
                        select avg 
                        from avg_cost
                    )
order by dname;

/*
    WITH 
    ... 
    SELECT
*/
--WITH cl_count(year, month, active_clients_amount) AS
WITH cl_count AS
(
    SELECT  EXTRACT(YEAR FROM report_month) year,
            EXTRACT(MONTH FROM report_month) month,
            COUNT(client_id) AS active_clients_amount
    FROM active_clients
    GROUP BY    EXTRACT(YEAR FROM report_month),
                EXTRACT(MONTH FROM report_month)
)
SELECT year, month, active_clients_amount
FROM cl_count;

WITH active_client(x, y, z) AS
(
    SELECT  EXTRACT(YEAR FROM report_month) year,
            EXTRACT(MONTH FROM report_month) month,
            COUNT(client_id) AS active_clients_amount
    FROM active_clients
    GROUP BY    EXTRACT(YEAR FROM report_month),
                EXTRACT(MONTH FROM report_month)
)
SELECT x, y, z
FROM active_client;

/* Subquery factoring process */
SELECT  dname,
        SUM(e.sal)
FROM dept d
JOIN emp e ON d.deptno = e.deptno
GROUP BY d.dname
HAVING SUM(e.sal) > (
                        SELECT AVG(sq.salary_sum)
                        FROM (
                                SELECT  dname,
                                        SUM(e.sal) salary_sum
                                FROM dept d
                                JOIN emp e ON d.deptno = e.deptno
                                GROUP BY d.dname
                        )sq
                    );
                    
-- Step 1. 
-- Defining sq subquery in WITH clause - avg_salary
WITH avg_salary AS
(
    SELECT AVG(salary_sum) avg
    FROM (
            SELECT  dname,
                    SUM(e.sal) salary_sum
            FROM dept d
            JOIN emp e ON d.deptno = e.deptno
            GROUP BY d.dname
         )
)
SELECT  dname,
        SUM(sal)
FROM dept d
JOIN emp e ON d.deptno = e.deptno
GROUP BY d.dname
HAVING SUM(e.sal) > (SELECT avg FROM avg_salary);

-- Step 2. 
-- Split avg_salary subquery into dept_emp and avg_salary subqueries
-- Determine the order of subqueries in WITH clause: 
-- dept_emp is called from avg_salary so must be defined first
WITH 
    dept_emp AS
    (
        SELECT  dname,
                SUM(e.sal) salary_sum
        FROM    dept d
        JOIN    emp e ON d.deptno = e.deptno
        GROUP BY d.dname
    ),
    avg_salary AS
    (
        SELECT  AVG(salary_sum) avg
        FROM    dept_emp
    )
SELECT  dname,
        salary_sum
FROM    dept_emp
WHERE   salary_sum > (
                        SELECT avg 
                        FROM avg_salary
                    );
        
/*
    ACTIVE_CLIENTS contains a slice of bank clients who made any transactions in a given month. 
    Lets consider that a client has left the bank in month N if he is active in month N 
    (present in the ACTIVE_CLIENTS table) and is not active in months N+1, N+2, N+3
    
    Exercise:
        display the number of active clients each month;
        share of clients who left the bank each month       
    
    Expected answer:
    
    01-JAN-18	0.33
    01-FEB-18	0
    01-MAR-18	0
    01-APR-18	0.33
    01-MAY-18	0
*/

CREATE TABLE active_clients(
    report_month    DATE,
    client_id       NUMBER
);
DROP TABLE ACTIVE_CLIENTS;

INSERT INTO active_clients VALUES(TO_DATE('2018-01-01', 'YYYY-MM-DD'), 1);
INSERT INTO active_clients VALUES(TO_DATE('2018-01-01', 'YYYY-MM-DD'), 2);
INSERT INTO active_clients VALUES(TO_DATE('2018-01-01', 'YYYY-MM-DD'), 3);
INSERT INTO active_clients VALUES(TO_DATE('2018-02-01', 'YYYY-MM-DD'), 2);
INSERT INTO active_clients VALUES(TO_DATE('2018-02-01', 'YYYY-MM-DD'), 4);
INSERT INTO active_clients VALUES(TO_DATE('2018-03-01', 'YYYY-MM-DD'), 1);
INSERT INTO active_clients VALUES(TO_DATE('2018-03-01', 'YYYY-MM-DD'), 2);
INSERT INTO active_clients VALUES(TO_DATE('2018-04-01', 'YYYY-MM-DD'), 1);
INSERT INTO active_clients VALUES(TO_DATE('2018-04-01', 'YYYY-MM-DD'), 2);
INSERT INTO active_clients VALUES(TO_DATE('2018-04-01', 'YYYY-MM-DD'), 4);
INSERT INTO active_clients VALUES(TO_DATE('2018-05-01', 'YYYY-MM-DD'), 1);
INSERT INTO active_clients VALUES(TO_DATE('2018-05-01', 'YYYY-MM-DD'), 5);
INSERT INTO active_clients VALUES(TO_DATE('2018-05-01', 'YYYY-MM-DD'), 2);

SELECT * from active_clients;

WITH 
    active_client_count AS
    (
        SELECT  report_month AS rm,
                COUNT(client_id) AS active_clients_amount
        FROM active_clients
        GROUP BY report_month
    ),
    active_client_ids AS
    (
        SELECT client_id AS active_client_id
        FROM active_clients
        WHERE report_month = (SELECT MAX(report_month) AS last_month FROM active_clients)
    ),
    inactive_clients_count AS
    (
        SELECT  DISTINCT COUNT(DISTINCT client_id) AS not_active_client_amount,
                MAX(report_month) OVER(PARTITION BY client_id) AS month_of_no_activity_begin 
        FROM    active_clients
        WHERE   client_id NOT IN (SELECT active_client_id FROM active_client_ids)
        GROUP BY    client_id,
                    report_month
    ),
    active_vs_inactive_clients_statistics AS
    (
        SELECT  DISTINCT report_month AS report_date,
                (
                    SELECT not_active_client_amount 
                    FROM inactive_clients_count
                    WHERE month_of_no_activity_begin = report_month
                ) AS x,
                (
                    SELECT active_clients_amount
                    FROM active_client_count
                    WHERE rm = report_month
                ) AS y
                
        FROM active_clients
    )
SELECT report_date AS "Month-Year",
        CASE
            WHEN x/y IS NULL THEN 0
            WHEN x/y IS NOT NULL THEN ROUND(x/y, 2)
        END AS "Share of inactive clients"
FROM active_vs_inactive_clients_statistics;

/* Test section */

SELECT client_id AS active_client_id
FROM active_clients
WHERE report_month = (SELECT MAX(report_month) AS last_month FROM active_clients);

SELECT  DISTINCT client_id AS not_active_client,
        --report_month AS last_active_month,
        MAX(report_month) OVER(PARTITION BY client_id) AS month_of_no_activity_begin 
FROM active_clients
WHERE client_id IN (3, 4);


SELECT  DISTINCT COUNT(DISTINCT client_id) AS not_active_client,
        MAX(report_month) OVER(PARTITION BY client_id) AS month_of_no_activity_begin 
FROM active_clients
WHERE client_id IN (3, 4)
GROUP BY    client_id,
            report_month;
