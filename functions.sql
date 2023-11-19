SET SERVEROUTPUT ON;

SELECT INITCAP('klgjhRTfRTERee') Result FROM dual;
SELECT CONCAT('Today is ', SYSDATE) Result FROM dual;
SELECT CONCAT('You are ', CONCAT('my', ' friend')) Result FROM dual;
SELECT LPAD('Volume', 10, '#') FROM dual;
SELECT RPAD('Volume', 20, ' FBI ') FROM dual;
SELECT ROUND(AVG(quantity),2) FROM OrderDetails;