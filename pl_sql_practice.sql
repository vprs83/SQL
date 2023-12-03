SET SERVEROUTPUT ON;

CREATE TABLE employees (
    first_name  VARCHAR(100) NOT NULL,
    last_name   VARCHAR(100)
);

DROP TABLE employees;

SELECT * FROM employees;

DECLARE
  surname  employees.last_name%TYPE;
BEGIN
  DBMS_OUTPUT.PUT_LINE('surname=' || surname);
END;

DECLARE
  surname  employees.last_name%TYPE;
BEGIN
  DBMS_OUTPUT.PUT_LINE('surname=' || surname);
END;

DECLARE
  surname  employees.last_name%TYPE;
  surname  VARCHAR(100);    -- Second declaration will be marked as error
BEGIN
  DBMS_OUTPUT.PUT_LINE('surname=' || surname);
END;

<<outer>>  -- label
DECLARE
  birthdate DATE := TO_DATE('09-AUG-70', 'DD-MON-YY');
BEGIN
  DECLARE
    birthdate DATE := TO_DATE('29-SEP-70', 'DD-MON-YY');
  BEGIN
    IF birthdate = outer.birthdate THEN
      DBMS_OUTPUT.PUT_LINE ('Same Birthday');
    ELSE
      DBMS_OUTPUT.PUT_LINE ('Different Birthday');
    END IF;
  END;
END;

DECLARE
  x NUMBER := 5;
  y NUMBER := NULL;
BEGIN
  IF x != y THEN  -- yields NULL, not TRUE
    DBMS_OUTPUT.PUT_LINE('x != y');  -- not run
  ELSIF x = y THEN -- also yields NULL
    DBMS_OUTPUT.PUT_LINE('x = y');
  ELSE
    DBMS_OUTPUT.PUT_LINE
      ('Can''t tell if x and y are equal or not.');
  END IF;
END;

/*
    
*/

CREATE OR REPLACE PROCEDURE print_boolean (
  b_name   VARCHAR2,
  b_value  BOOLEAN
) AUTHID DEFINER IS
BEGIN
  IF b_value IS NULL THEN
    DBMS_OUTPUT.PUT_LINE (b_name || ' = NULL');
  ELSIF b_value = TRUE THEN
    DBMS_OUTPUT.PUT_LINE (b_name || ' = TRUE');
  ELSE
    DBMS_OUTPUT.PUT_LINE (b_name || ' = FALSE');
  END IF;
END;

DECLARE
  x  BOOLEAN := TRUE;
  y  BOOLEAN := FALSE;
BEGIN
  print_boolean ('x AND NOT y', x AND NOT y);
  print_boolean ('NOT (x AND y)', NOT (x AND y));
  print_boolean ('(NOT x) AND y', (NOT x) AND y);
END;


DECLARE
  on_hand  INTEGER := 0;
  on_order INTEGER := 100;
BEGIN
  -- Does not cause divide-by-zero error;
  -- evaluation stops after first expression
  
  IF ((on_order / on_hand) < 5) OR (on_hand = 0) THEN
    DBMS_OUTPUT.PUT_LINE('On hand quantity is zero.');
  END IF;
END;

CREATE TABLE test (name VARCHAR2(15));
INSERT INTO test VALUES ('Gaardiner');
INSERT INTO test VALUES ('Gaberd');
INSERT INTO test VALUES ('Gaasten');
INSERT INTO test VALUES ('GAASTEN');

DELETE FROM test WHERE name='GABERD';

SELECT * FROM test ORDER BY name;

SELECT * FROM test ORDER BY NLSSORT(name, 'NLS_SORT = XDanish_CI'); -- XDanish vs XDanish_CI

/* */

DECLARE
  grade CHAR(1) := 'B';
  appraisal VARCHAR2(20);
BEGIN
  appraisal :=
    CASE grade
      WHEN 'A' THEN 'Excellent'
      WHEN 'B' THEN 'Very Good'
      WHEN 'C' THEN 'Good'
      WHEN 'D' THEN 'Fair'
      WHEN 'F' THEN 'Poor'
      ELSE 'No such grade'
    END;
    DBMS_OUTPUT.PUT_LINE ('Grade ' || grade || ' is ' || appraisal);
END;
 

DECLARE
    grade       CHAR(1)         := 'B';     -- change to 'X'
    appraisal   VARCHAR2(120);
    id          NUMBER          := 8429862;
    attendance  NUMBER          := 150;     -- change to 1150
    min_days    CONSTANT NUMBER := 200;

    FUNCTION attends_this_school (id NUMBER) 
    RETURN BOOLEAN 
    IS
    BEGIN
        RETURN TRUE;
    END;
BEGIN
    appraisal :=
                  CASE
                    WHEN attends_this_school(id) = FALSE
                        THEN 'Student not enrolled'
                        
                    WHEN grade = 'F' OR attendance < min_days
                        THEN 'Poor (poor performance or bad attendance)'
                        
                    WHEN grade = 'A' THEN 'Excellent'
                    WHEN grade = 'B' THEN 'Very Good'
                    WHEN grade = 'C' THEN 'Good'
                    WHEN grade = 'D' THEN 'Fair'
                    --ELSE 'No such grade'      -- comment out for NULL output
                  END;
                  
    IF appraisal IS NULL THEN appraisal := 'extremely terrible'; 
    END IF;
    DBMS_OUTPUT.PUT_LINE('Result for student ' || id || ' is ' || appraisal);
END;

DECLARE
  p1 PLS_INTEGER := 2147483646;
  p2 PLS_INTEGER := 1;
  n NUMBER;
BEGIN
  n := p1 + p2;
  DBMS_OUTPUT.PUT_LINE(n);
END;

DECLARE
  a NATURAL := 1;
  b PLS_INTEGER := -2783910;
BEGIN
  a := b;
END;


DECLARE
  n SIMPLE_INTEGER := 2147483645;
BEGIN
  FOR j IN 1..4 LOOP
    n := n + 2;
    DBMS_OUTPUT.PUT_LINE(TO_CHAR(n, 'S9999999999'));
  END LOOP;
  FOR j IN 1..4 LOOP
   n := n - 1;
   DBMS_OUTPUT.PUT_LINE(TO_CHAR(n, 'S9999999999'));
  END LOOP;
END;


BEGIN
  FOR i IN 1..3 LOOP
    DBMS_OUTPUT.PUT_LINE ('Inside loop, i is ' || TO_CHAR(i));
  END LOOP;
  
  --DBMS_OUTPUT.PUT_LINE ('Outside loop, i is ' || TO_CHAR(i));
END;

DECLARE
    iteration_counter NUMBER := 0;
BEGIN
  FOR i MUTABLE IN 1..3 LOOP
    iteration_counter := iteration_counter + 1;
    IF i < 3 THEN
      DBMS_OUTPUT.PUT_LINE (TO_CHAR(i));
    ELSE
      i := 2;
    END IF;
    IF iteration_counter = 6 THEN
        EXIT; 
    END IF;
    DBMS_OUTPUT.PUT_LINE('Iteration_counter: ' || TO_CHAR(iteration_counter));
    DBMS_OUTPUT.PUT_LINE('Current "i" value": ' || TO_CHAR(i));
  END LOOP;
END;

DECLARE
   i PLS_INTEGER;
BEGIN
   FOR i IN 1..3, REVERSE i+1..i+10, 51..55 LOOP
      DBMS_OUTPUT.PUT_LINE(i);
   END LOOP;
END;

DECLARE
   TYPE intvec_t IS TABLE OF PLS_INTEGER INDEX BY PLS_INTEGER;
   vec intvec_t := intvec_t(3 => 10, 1 => 11, 100 => 34);
BEGIN
   FOR i IN VALUES OF vec LOOP
      DBMS_OUTPUT.PUT_LINE(i);
   END LOOP;
END;

BEGIN
   FOR power IN 1, REPEAT power*2 WHILE power <= 64 LOOP
      DBMS_OUTPUT.PUT_LINE(power);
   END LOOP;
END;


DECLARE 
    TYPE r IS RECORD(a PLS_INTEGER, b PLS_INTEGER, c NUMBER);  
    rec r;
BEGIN  
    rec := r(1, c => 3.0, OTHERS => 2);  
-- rec contains [ 1, 2, 3.0 ]
    DBMS_OUTPUT.PUT_LINE(' ' || rec.a || ', ' || rec.b || ', ' || TO_CHAR(rec.c));
END;

DECLARE
  TYPE nested_typ IS TABLE OF NUMBER;
 
  nt1    nested_typ := nested_typ(1,2,3);
  nt2    nested_typ := nested_typ(3,2,1,3,3,3,3);
  nt3    nested_typ := nested_typ(2,3,1,3,3,3,2);
  nt4    nested_typ := nested_typ(1,2,4);
  answer nested_typ;
 
  PROCEDURE print_nested_table (nt nested_typ) IS
    output VARCHAR2(128);
  BEGIN
    IF nt IS NULL THEN
      DBMS_OUTPUT.PUT_LINE('Result: null set');
    ELSIF nt.COUNT = 0 THEN
      DBMS_OUTPUT.PUT_LINE('Result: empty set');
    ELSE
      FOR i IN nt.FIRST .. nt.LAST LOOP  -- For first to last element
        output := output || nt(i) || ' ';
      END LOOP;
      DBMS_OUTPUT.PUT_LINE('Result: ' || output);
    END IF;
  END print_nested_table;
 
BEGIN
--  answer := nt1 MULTISET UNION nt4;
--  print_nested_table(answer);
--  answer := nt1 MULTISET UNION nt3;
--  print_nested_table(answer);
--  answer := nt1 MULTISET UNION DISTINCT nt3;
--  print_nested_table(answer);
  answer := nt2 MULTISET INTERSECT nt3;
  print_nested_table(answer);
--  answer := nt2 MULTISET INTERSECT DISTINCT nt3;
--  print_nested_table(answer);
--  answer := SET(nt3);
--  print_nested_table(answer);
--  answer := nt3 MULTISET EXCEPT nt2;
--  print_nested_table(answer);
--  answer := nt3 MULTISET EXCEPT DISTINCT nt2;
--  print_nested_table(answer);
END;
