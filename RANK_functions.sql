CREATE TABLE  table1(
    id          NUMBER      NOT NULL,
    name        VARCHAR2(10),
    class_item  VARCHAR2(1)
);

DROP TABLE table1;

INSERT INTO table1(id, name, class_item) VALUES(1, 'Arhpa', 'A');
INSERT INTO table1(id, name, class_item) VALUES(2, 'accordeon', NULL);
INSERT INTO table1(id, name, class_item) VALUES(3, 'Baraban', 'B');
INSERT INTO table1(id, name, class_item) VALUES(4, 'royal', NULL);
INSERT INTO table1(id, name, class_item) VALUES(5, 'truba', 'A');
INSERT INTO table1(id, name, class_item) VALUES(6, 'Pianino', 'C');

SELECT *
FROM table1
WHERE NAME LIKE 'A%' OR NAME LIKE 'a%';

SELECT id
FROM table1
WHERE class_item <> 'A';        -- 3, 6

----------------------------------
/*   Nth highest salary query   */
----------------------------------

CREATE TABLE employee(
    employee_name   VARCHAR2(20)    NOT NULL,
    salary          NUMBER          NOT NULL
);

DROP TABLE employee;

INSERT INTO employee VALUES ('Tom',1500000);
INSERT INTO employee VALUES ('Dick',3900000);
INSERT INTO employee VALUES ('Hary',7700000);
INSERT INTO employee VALUES ('Mike',15000000);
INSERT INTO employee VALUES ('Harvey',33300000);
INSERT INTO employee VALUES ('Brush',2500000);

INSERT INTO employee VALUES ('Harvey2',33300000);


/*
        RANK() OVER (
            [PARTITION BY expression, ]
            ORDER BY expression (ASC | DESC) );
*/
SELECT  employee_name,
        salary, 
        RANK() OVER (ORDER BY salary DESC) AS "Salary ranks"
FROM employee;


SELECT  EMPLOYEE_NAME,
        SALARY,
        salary_rank
FROM (
    SELECT  employee_name, salary, 
            RANK() OVER(ORDER BY salary DESC) AS salary_rank
    FROM employee
)
WHERE salary_rank = 3;



/*
        DENSE_RANK()
*/
SELECT  employee_name,
        salary, 
        DENSE_RANK() OVER (ORDER BY salary DESC) AS "Salary ranks"
FROM employee;


SELECT  EMPLOYEE_NAME,
        SALARY,
        salary_rank
FROM (
    SELECT  employee_name, salary, 
            DENSE_RANK() OVER(ORDER BY salary DESC) AS salary_rank
    FROM employee
)
WHERE salary_rank = 3;



/*
        ROW_NUMBER( )
            OVER ([ query_partition_clause ] order_by_clause)
            
        ROW_NUMBER() OVER([PARTITION BY ...] ORDER BY ... DESC / ASC) RowNumber
*/
SELECT  EMPLOYEE_NAME,
        SALARY,
        ROW_NUMBER() OVER(ORDER BY salary DESC) row_number
FROM    employee;


SELECT  employee_name ,
        salary ,
        row_number 
FROM (
    SELECT  EMPLOYEE_NAME,
            SALARY,
            ROW_NUMBER() OVER(ORDER BY salary DESC) row_number
    FROM    employee
)
WHERE row_number = 3;
