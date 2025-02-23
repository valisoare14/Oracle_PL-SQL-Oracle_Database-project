SELECT * FROM employees;
SELECT * FROM accountants;
SELECT * FROM contributions;
SELECT * FROM headquarters;
SELECT * FROM accounts;
SELECT * FROM employee_details;

--------------------------------------------------------------------------------
-- 1) SIMPLE PL/SQL BLOCK: SELECT + DBMS_OUTPUT
--------------------------------------------------------------------------------
SET SERVEROUTPUT ON;
DECLARE
   v_last_name  employees.last_name%TYPE;
BEGIN
   SELECT last_name
     INTO v_last_name
     FROM employees
    WHERE employee_id = 1;

   DBMS_OUTPUT.PUT_LINE('Extracted last_name: ' || v_last_name);
END;
/
SELECT * FROM employees;

--------------------------------------------------------------------------------
-- 2) CREATE A TABLE (manager_table) DYNAMICALLY, 
--    THEN INSERT A RECORD UPON CREATION (DEMO)
--------------------------------------------------------------------------------
SET SERVEROUTPUT ON;
VARIABLE g_employee_id NUMBER; -- global variable

DECLARE
   v_sql VARCHAR2(200);
BEGIN
   :g_employee_id := 1; -- initialize the global variable

   v_sql := 'CREATE TABLE manager_table AS '
         || 'SELECT * FROM employees WHERE employee_id = '
         || :g_employee_id;

   DBMS_OUTPUT.PUT_LINE(v_sql);
   EXECUTE IMMEDIATE v_sql;
END;
/
SELECT * FROM manager_table;
DROP TABLE manager_table CASCADE CONSTRAINTS;

--------------------------------------------------------------------------------
-- 3) ADD A NEW COLUMN (number_of_employees) TO HEADQUARTERS
--------------------------------------------------------------------------------
SET SERVEROUTPUT ON;
DECLARE
   v_sql_to_execute VARCHAR2(200);
BEGIN
   v_sql_to_execute := 'ALTER TABLE headquarters ADD (number_of_employees NUMBER(7))';
   DBMS_OUTPUT.PUT_LINE(v_sql_to_execute);
   EXECUTE IMMEDIATE v_sql_to_execute;
END;
/
SELECT * FROM headquarters;

--------------------------------------------------------------------------------
-- 4) ADD A NEW RECORD TO EMPLOYEES
--------------------------------------------------------------------------------
BEGIN
   INSERT INTO employees
   VALUES(8, 3, 'DRAGHICI', 'ALIN', 29, 1600);
END;
/
SELECT * FROM employees;

--------------------------------------------------------------------------------
-- 5) ADD A NEW RECORD TO ACCOUNTANTS USING SUBSTITUTION VARIABLES
--------------------------------------------------------------------------------
BEGIN
   INSERT INTO accountants
   VALUES(&accountant_id, &chief_accountant_id, '&last_name', '&first_name', &headquarters_id);
END;
/
SELECT * FROM accountants;

--------------------------------------------------------------------------------
-- 6) INCREASE THE SALARY BY 10% FOR EMPLOYEES WHO EARN LESS THAN A GIVEN THRESHOLD
--------------------------------------------------------------------------------
DECLARE
   v_percentage      NUMBER := 0.1;
   v_salary_threshold NUMBER := 2400;
BEGIN
   UPDATE employees
      SET salary = salary * (1 + v_percentage)
    WHERE salary < v_salary_threshold;
END;
/
SELECT * FROM employees;

--------------------------------------------------------------------------------
-- 7) READ AN EMPLOYEE ID; IF THE SALARY IS:
--    - <3000, THEN DOUBLE IT
--    - BETWEEN 3000 AND 5000, THEN INCREASE BY 1.5
--    - ELSE, INCREASE BY 1.25
--------------------------------------------------------------------------------
SET SERVEROUTPUT ON;
DECLARE
   v_id     employees.employee_id%TYPE;
   v_salary employees.salary%TYPE;
BEGIN
   v_id := &employee_id;   -- user inputs ID

   SELECT salary
     INTO v_salary
     FROM employees
    WHERE employee_id = v_id;

   DBMS_OUTPUT.PUT_LINE('Old salary: ' || v_salary);

   IF v_salary < 3000 THEN
      v_salary := 2 * v_salary;
   ELSIF v_salary BETWEEN 3000 AND 5000 THEN
      v_salary := 1.5 * v_salary;
   ELSE
      v_salary := 1.25 * v_salary;
   END IF;

   DBMS_OUTPUT.PUT_LINE('New salary: ' || v_salary);
END;
/

--------------------------------------------------------------------------------
-- 8) DISPLAY EMPLOYEES WITH IDs 3 TO 7 IN ORDER, AS LONG AS THEIR SALARY 
--    IS LOWER THAN THE AVERAGE SALARY
--------------------------------------------------------------------------------
SET SERVEROUTPUT ON;
DECLARE
   v_avg_salary employees.salary%TYPE;
   v_salary     employees.salary%TYPE;
BEGIN
   SELECT AVG(salary)
     INTO v_avg_salary
     FROM employees;

   DBMS_OUTPUT.PUT_LINE('Average salary: ' || v_avg_salary);

   FOR v_id IN 3..8 LOOP
      SELECT salary
        INTO v_salary
        FROM employees
       WHERE employee_id = v_id;

      DBMS_OUTPUT.PUT_LINE('Employee with ID '||v_id||' has salary '||v_salary);

      -- The exit logic was reversed in the original sample; 
      -- we keep it as is (exits when salary < average).
      EXIT WHEN v_salary < v_avg_salary;
   END LOOP;
END;
/

--------------------------------------------------------------------------------
-- 9) IF STATEMENT:
--    BASED ON THE EMPLOYEE'S ID, INCREASE THE SALARY DEPENDING ON THEIR 
--    YEARS_OF_EXPERIENCE (FROM EMPLOYEE_DETAILS)
--    - <20 => SALARY *1.25
--    - 20..30 => SALARY *1.5
--    - >30 => SALARY *2
--------------------------------------------------------------------------------
SET SERVEROUTPUT ON;
ACCEPT g_id PROMPT 'Please enter an employee_id (1-10): '
DECLARE
   v_experience       employee_details.years_of_experience%TYPE;
   v_id               employees.employee_id%TYPE;
   v_salary           employees.salary%TYPE;
BEGIN
   v_id := &g_id;

   SELECT e.salary, d.years_of_experience
     INTO v_salary, v_experience
     FROM employees e
          JOIN employee_details d ON e.employee_id = d.employee_id
    WHERE e.employee_id = v_id;

   DBMS_OUTPUT.PUT_LINE('Initial salary: ' || v_salary);

   IF v_experience < 20 THEN
      v_salary := v_salary * 1.25;
   ELSIF v_experience BETWEEN 20 AND 30 THEN
      v_salary := v_salary * 1.5;
   ELSE
      v_salary := v_salary * 2;
   END IF;

   DBMS_OUTPUT.PUT_LINE('Final salary: ' || v_salary);

   UPDATE employees
      SET salary = v_salary
    WHERE employee_id = v_id;
END;
/
ROLLBACK;

--------------------------------------------------------------------------------
-- 10) CASE..WHEN..THEN:
--     UPDATE THE SOCIAL_SECURITY (cas) FOR AN EMPLOYEE GIVEN THEIR LAST_NAME
--     DEPENDING ON THEIR AGE:
--       20..35 => cas *0.95
--       35..50 => cas *0.90
--       50..69 => cas *0.80
--------------------------------------------------------------------------------
SET SERVEROUTPUT ON;
ACCEPT g_last_name PROMPT 'Enter the employee LAST NAME: '
DECLARE
   v_last_name   employees.last_name%TYPE;
   v_social_sec  contributions.social_security%TYPE;
   v_age         employees.age%TYPE;
BEGIN
   v_last_name := '&g_last_name';

   SELECT c.social_security, e.age
     INTO v_social_sec, v_age
     FROM contributions c
          JOIN employees e ON e.employee_id = c.employee_id
    WHERE e.last_name = v_last_name;

   DBMS_OUTPUT.PUT_LINE('Social Security before: ' || v_social_sec);

   CASE
      WHEN v_age BETWEEN 20 AND 35 THEN
         v_social_sec := v_social_sec * 0.95;
      WHEN v_age BETWEEN 35 AND 50 THEN
         v_social_sec := v_social_sec * 0.90;
      ELSE
         v_social_sec := v_social_sec * 0.80;
   END CASE;

   DBMS_OUTPUT.PUT_LINE('Social Security after: ' || v_social_sec);

   UPDATE contributions
      SET social_security = v_social_sec
    WHERE employee_id = (
          SELECT employee_id 
            FROM employees 
           WHERE last_name = v_last_name
          );
EXCEPTION
   WHEN NO_DATA_FOUND THEN
      DBMS_OUTPUT.PUT_LINE('No employee found with that last name!');
END;
/
ROLLBACK;

--------------------------------------------------------------------------------
-- 11) LOOP..END LOOP:
--     DISPLAY THE LAST_NAME OF EACH EMPLOYEE
--------------------------------------------------------------------------------
SET SERVEROUTPUT ON;
DECLARE
   v_last_name employees.last_name%TYPE;
   i          NUMBER;
BEGIN
   i := 1;

   LOOP
      SELECT last_name
        INTO v_last_name
        FROM employees
       WHERE employee_id = i;

      DBMS_OUTPUT.PUT_LINE('Employee last name: ' || v_last_name);

      i := i + 1;
      EXIT WHEN i > 10;
   END LOOP;
END;
/

--------------------------------------------------------------------------------
-- 12) FOR..LOOP..END LOOP:
--     SHOW THE TOTAL BALANCE FROM ALL ACCOUNTS FOR EMPLOYEES WITH ID=1..5
--------------------------------------------------------------------------------
SET SERVEROUTPUT ON;
DECLARE
   v_sum NUMBER(7);
BEGIN
   FOR v_id IN 1..5 LOOP
      v_sum := 0;

      FOR v_record IN (
         SELECT balance AS bal 
           FROM accounts 
          WHERE employee_id = v_id
      ) LOOP
         v_sum := v_sum + v_record.bal;
         EXIT WHEN SQL%NOTFOUND;
      END LOOP;

      DBMS_OUTPUT.PUT_LINE('Employee with ID ' || v_id 
                           || ' has total account balances: ' 
                           || v_sum);

      EXIT WHEN v_id = 5;
   END LOOP;
END;
/

--------------------------------------------------------------------------------
-- 13) DISPLAY THE PLACE_OF_BIRTH FOR AN EMPLOYEE BY FIRST_NAME,
--     HANDLE NO_DATA_FOUND IF NOT FOUND
--------------------------------------------------------------------------------
SET SERVEROUTPUT ON;
ACCEPT g_first_name PROMPT 'Enter the employee FIRST NAME: '
DECLARE
   v_place_of_birth employee_details.place_of_birth%TYPE;
BEGIN
   SELECT d.place_of_birth
     INTO v_place_of_birth
     FROM employees e
          JOIN employee_details d ON e.employee_id = d.employee_id
    WHERE e.first_name = '&g_first_name';

   DBMS_OUTPUT.PUT_LINE('Place of birth: ' || v_place_of_birth);
EXCEPTION
   WHEN NO_DATA_FOUND THEN
      DBMS_OUTPUT.PUT_LINE('No employee found with that first name!');
END;
/

--------------------------------------------------------------------------------
-- 14) DISPLAY THE ACCOUNTANT WITH headquarters_id=4
--     IF MORE THAN ONE ROW IS FOUND => TOO_MANY_ROWS EXCEPTION
--------------------------------------------------------------------------------
SET SERVEROUTPUT ON;
DECLARE
   v_last_name  accountants.last_name%TYPE;
   v_first_name accountants.first_name%TYPE;
BEGIN
   SELECT last_name, first_name
     INTO v_last_name, v_first_name
     FROM accountants
    WHERE headquarters_id = 4;
EXCEPTION
   WHEN TOO_MANY_ROWS THEN
      DBMS_OUTPUT.PUT_LINE('Multiple accountants exist for headquarters_id=4');
END;
/

--------------------------------------------------------------------------------
-- 15) SET AN EMPLOYEE_ID TO NULL, RAISING AN EXCEPTION IF IT BREAKS A NOT NULL
--------------------------------------------------------------------------------
SET SERVEROUTPUT ON;
ACCEPT g_id PROMPT 'Enter an employee_id: '
DECLARE
   v_ex EXCEPTION;
   PRAGMA EXCEPTION_INIT(v_ex, -01407); 
   -- -01407: cannot update (string) to NULL
BEGIN
   UPDATE employees
      SET employee_id = NULL
    WHERE employee_id = &g_id;
EXCEPTION
   WHEN v_ex THEN
      DBMS_OUTPUT.PUT_LINE('NOT NULL integrity constraint violated');
END;
/

--------------------------------------------------------------------------------
-- 16) INSERT A NEW HEADQUARTERS WITH THE SAME LOCATION AS headquarters_id=7
--     HANDLE UNIQUE CONSTRAINT VIOLATION
--------------------------------------------------------------------------------
SET SERVEROUTPUT ON;
DECLARE
   v_ex       EXCEPTION;
   PRAGMA EXCEPTION_INIT(v_ex, -00001);  -- unique constraint violated
   v_location headquarters.location%TYPE;
BEGIN
   SELECT location 
     INTO v_location
     FROM headquarters
    WHERE headquarters_id = 7;

   INSERT INTO headquarters 
   VALUES (11, 'hugaf', v_location, 31);

EXCEPTION
   WHEN v_ex THEN
      DBMS_OUTPUT.PUT_LINE('UNIQUE integrity constraint violated');
END;
/

--------------------------------------------------------------------------------
-- 17) READ AN EMPLOYEE_ID FROM USER; IF > 10, RAISE EXCEPTION;
--     OTHERWISE DISPLAY LAST_NAME & FIRST_NAME
--------------------------------------------------------------------------------
SET SERVEROUTPUT ON;
ACCEPT g_id PROMPT 'Enter an employee_id: '
DECLARE
   v_last_name   employees.last_name%TYPE;
   v_first_name  employees.first_name%TYPE;
   v_id          employees.employee_id%TYPE;
   v_ex          EXCEPTION;
BEGIN
   v_id := &g_id;

   IF v_id > 10 THEN
      RAISE v_ex;
   END IF;

   SELECT last_name, first_name
     INTO v_last_name, v_first_name
     FROM employees
    WHERE employee_id = v_id;

   DBMS_OUTPUT.PUT_LINE('Employee: ' || v_last_name || ' ' || v_first_name);
EXCEPTION
   WHEN v_ex THEN
      DBMS_OUTPUT.PUT_LINE('Invalid ID!');
END;
/

--------------------------------------------------------------------------------
-- 18) IMPLICIT CURSOR:
--     UPDATE THE LAST_NAME OF THE ACCOUNTANT WITH headquarters_id=2
--     DISPLAY SQL%ROWCOUNT
--------------------------------------------------------------------------------
SET SERVEROUTPUT ON;
DECLARE
   v_new_name VARCHAR2(50);
BEGIN
   UPDATE accountants
      SET last_name = '&last_name'
    WHERE headquarters_id = 2;

   DBMS_OUTPUT.PUT_LINE('Affected rows: ' || SQL%ROWCOUNT);
END;
/
ROLLBACK;

--------------------------------------------------------------------------------
-- 19) IMPLICIT CURSOR:
--     UPDATE THE SALARY OF EMPLOYEE_ID=12 WITH A USER-SPECIFIED VALUE
--------------------------------------------------------------------------------
SET SERVEROUTPUT ON;
BEGIN
   UPDATE employees
      SET salary = &NewSalary
    WHERE employee_id = 12;

   IF SQL%NOTFOUND THEN
      DBMS_OUTPUT.PUT_LINE('No employee found with the given ID!');
   END IF;
END;
/
ROLLBACK;

--------------------------------------------------------------------------------
-- 20) EXPLICIT CURSOR WITH PARAMETER:
--     DISPLAY LAST_NAME & FIRST_NAME OF ACCOUNTANTS WHO HAVE A headquarters_id 
--     EQUAL TO THE USER-ENTERED PARAMETER (original logic used "id_sediu=g_id")
--------------------------------------------------------------------------------
SET SERVEROUTPUT ON;
ACCEPT z_id PROMPT 'Enter a headquarters_id: '
DECLARE
   CURSOR accountants_cursor (p_headquarters_id NUMBER) IS
      SELECT last_name, first_name
        FROM accountants
       WHERE headquarters_id = p_headquarters_id;

   rec accountants_cursor%ROWTYPE;
BEGIN
   OPEN accountants_cursor(&z_id);

   LOOP
      FETCH accountants_cursor INTO rec;
      EXIT WHEN accountants_cursor%NOTFOUND;

      DBMS_OUTPUT.PUT_LINE(rec.last_name || ' ' || rec.first_name);
   END LOOP;

   CLOSE accountants_cursor;
END;
/

--------------------------------------------------------------------------------
-- 21) EXPLICIT CURSOR WITH PARAMETER:
--     DISPLAY THE BALANCE OF ACCOUNTS WHERE credit_score >= USER-ENTERED VALUE
--------------------------------------------------------------------------------
SET SERVEROUTPUT ON;
ACCEPT gg_sc_credit PROMPT 'Enter credit score: '
DECLARE
   CURSOR balance_cursor (p_credit_score NUMBER) IS
      SELECT balance, employee_id
        FROM accounts
       WHERE credit_score >= p_credit_score;

   rec balance_cursor%ROWTYPE;
BEGIN
   OPEN balance_cursor(&gg_sc_credit);

   LOOP
      FETCH balance_cursor INTO rec;
      EXIT WHEN balance_cursor%NOTFOUND;

      DBMS_OUTPUT.PUT_LINE(
         'Employee with ID ' || rec.employee_id 
         || ' has balance: ' || rec.balance
      );
   END LOOP;

   CLOSE balance_cursor;
END;
/

--------------------------------------------------------------------------------
-- 22) EXPLICIT CURSOR (NO PARAMS):
--     DISPLAY THE ACCOUNTANT_ID AND LAST_NAME FOR ACCOUNTANTS IN headquarters_id=4
--------------------------------------------------------------------------------
SET SERVEROUTPUT ON;
DECLARE
   CURSOR c_accountants IS
      SELECT accountant_id, last_name
        FROM accountants
       WHERE headquarters_id = 4;

   v_rec c_accountants%ROWTYPE;
BEGIN
   OPEN c_accountants;

   LOOP
      FETCH c_accountants INTO v_rec;
      EXIT WHEN c_accountants%NOTFOUND;

      DBMS_OUTPUT.PUT_LINE(
         'Last Name: ' || v_rec.last_name 
         || ' | ID: ' || v_rec.accountant_id
      );
   END LOOP;

   CLOSE c_accountants;
END;
/

--------------------------------------------------------------------------------
-- 23) EXPLICIT CURSOR (NO PARAMS):
--     DISPLAY TOTAL CONTRIBUTIONS (social_security + health_insurance + tax)
--     FOR EACH EMPLOYEE
--------------------------------------------------------------------------------
SET SERVEROUTPUT ON;
DECLARE
   CURSOR contributions_cursor IS
      SELECT social_security, health_insurance, tax
        FROM contributions;

   v_sum          NUMBER(7);
   v_last_name    employees.last_name%TYPE;
   v_first_name   employees.first_name%TYPE;
BEGIN
   FOR rec IN contributions_cursor LOOP
      v_sum := 0;

      IF rec.social_security IS NOT NULL THEN
         v_sum := v_sum + rec.social_security;
      END IF;
      IF rec.health_insurance IS NOT NULL THEN
         v_sum := v_sum + rec.health_insurance;
      END IF;
      IF rec.tax IS NOT NULL THEN
         v_sum := v_sum + rec.tax;
      END IF;

      -- Match on social_security to find the correct employee
      SELECT e.last_name, e.first_name
        INTO v_last_name, v_first_name
        FROM employees e
             JOIN contributions c ON e.employee_id = c.employee_id
       WHERE c.social_security = rec.social_security;

      DBMS_OUTPUT.PUT_LINE(
         'Employee ' || v_last_name || ' ' || v_first_name 
         || ' has total contributions: ' || v_sum
      );
   END LOOP;
END;
/

--------------------------------------------------------------------------------
-- 24) EXPLICIT CURSOR (NO PARAMS):
--     DISPLAY HEADQUARTERS_NAME FOR HEADQUARTERS WITH EVEN IDs (2..10)
--------------------------------------------------------------------------------
SET SERVEROUTPUT ON;
DECLARE
   CURSOR hq_cursor IS
      SELECT headquarters_name, headquarters_id
        FROM headquarters;

   v_rec hq_cursor%ROWTYPE;
   i     NUMBER;
BEGIN
   OPEN hq_cursor;

   LOOP
      FETCH hq_cursor INTO v_rec;
      EXIT WHEN hq_cursor%NOTFOUND;

      FOR i IN 2..10 LOOP
         IF v_rec.headquarters_id = i THEN
            DBMS_OUTPUT.PUT_LINE(
               'Headquarters name: ' || v_rec.headquarters_name
            );
         END IF;
      END LOOP;
   END LOOP;
END;
/

--------------------------------------------------------------------------------
-- 25) PACKAGE SPECIFICATION & BODY (CONTRIBUTIONS_PACKAGE)
--------------------------------------------------------------------------------
CREATE OR REPLACE PACKAGE contributions_package IS
   FUNCTION get_social_security (p_employee_id employees.employee_id%TYPE) 
      RETURN NUMBER;

   FUNCTION get_health_insurance (p_employee_id employees.employee_id%TYPE) 
      RETURN NUMBER;

   FUNCTION get_tax (p_employee_id employees.employee_id%TYPE) 
      RETURN NUMBER;

   PROCEDURE increase_social_security (
      p_employee_id contributions.employee_id%TYPE, 
      p_percent     NUMBER
   );

   PROCEDURE increase_health_insurance (
      p_employee_id contributions.employee_id%TYPE, 
      p_percent     NUMBER
   );

   PROCEDURE increase_tax (
      p_employee_id contributions.employee_id%TYPE, 
      p_percent     NUMBER
   );
END;
/
--------------------------------------------------------------------------------
CREATE OR REPLACE PACKAGE BODY contributions_package IS

   FUNCTION get_social_security (p_employee_id IN employees.employee_id%TYPE)
      RETURN NUMBER
   IS
      v_val NUMBER;
   BEGIN
      SELECT social_security
        INTO v_val
        FROM contributions
       WHERE employee_id = p_employee_id;
      RETURN v_val;
   END;

   FUNCTION get_health_insurance (p_employee_id IN employees.employee_id%TYPE)
      RETURN NUMBER
   IS
      v_val NUMBER;
   BEGIN
      SELECT health_insurance
        INTO v_val
        FROM contributions
       WHERE employee_id = p_employee_id;
      RETURN v_val;
   END;

   FUNCTION get_tax (p_employee_id IN employees.employee_id%TYPE)
      RETURN NUMBER
   IS
      v_val NUMBER;
   BEGIN
      SELECT tax
        INTO v_val
        FROM contributions
       WHERE employee_id = p_employee_id;
      RETURN v_val;
   END;

   PROCEDURE increase_social_security (
      p_employee_id IN contributions.employee_id%TYPE,
      p_percent     IN NUMBER
   ) IS
      v_old NUMBER;
   BEGIN
      SELECT social_security
        INTO v_old
        FROM contributions
       WHERE employee_id = p_employee_id;

      DBMS_OUTPUT.PUT_LINE('Social Security before: ' || v_old);

      UPDATE contributions
         SET social_security = social_security * (1 + p_percent)
       WHERE employee_id = p_employee_id;

      SELECT social_security
        INTO v_old
        FROM contributions
       WHERE employee_id = p_employee_id;

      DBMS_OUTPUT.PUT_LINE('Social Security after: ' || v_old);
   END;

   PROCEDURE increase_health_insurance (
      p_employee_id IN contributions.employee_id%TYPE,
      p_percent     IN NUMBER
   ) IS
      v_old NUMBER;
   BEGIN
      SELECT health_insurance
        INTO v_old
        FROM contributions
       WHERE employee_id = p_employee_id;

      DBMS_OUTPUT.PUT_LINE('Health Insurance before: ' || v_old);

      UPDATE contributions
         SET health_insurance = health_insurance * (1 + p_percent)
       WHERE employee_id = p_employee_id;

      SELECT health_insurance
        INTO v_old
        FROM contributions
       WHERE employee_id = p_employee_id;

      DBMS_OUTPUT.PUT_LINE('Health Insurance after: ' || v_old);
   END;

   PROCEDURE increase_tax (
      p_employee_id IN contributions.employee_id%TYPE,
      p_percent     IN NUMBER
   ) IS
      v_old NUMBER;
   BEGIN
      SELECT tax
        INTO v_old
        FROM contributions
       WHERE employee_id = p_employee_id;

      DBMS_OUTPUT.PUT_LINE('Tax before: ' || v_old);

      UPDATE contributions
         SET tax = tax * (1 + p_percent)
       WHERE employee_id = p_employee_id;

      SELECT tax
        INTO v_old
        FROM contributions
       WHERE employee_id = p_employee_id;

      DBMS_OUTPUT.PUT_LINE('Tax after: ' || v_old);
   END;
END;
/

--------------------------------------------------------------------------------
-- EXAMPLE OF DROPPING THE PACKAGE
--------------------------------------------------------------------------------
DROP PACKAGE contributions_package;
DROP PACKAGE BODY contributions_package;

--------------------------------------------------------------------------------
-- EXAMPLE USAGE OF THE PACKAGE (UNCOMMENT IF PACKAGE EXISTS)
--------------------------------------------------------------------------------
SET SERVEROUTPUT ON;
BEGIN
   DBMS_OUTPUT.PUT_LINE(contributions_package.get_social_security(1));
   DBMS_OUTPUT.PUT_LINE(contributions_package.get_health_insurance(1));
   DBMS_OUTPUT.PUT_LINE(contributions_package.get_tax(1));

   contributions_package.increase_social_security(1, 0.15);
   contributions_package.increase_health_insurance(1, 0.15);
   contributions_package.increase_tax(1, 0.15);
END;
/

--------------------------------------------------------------------------------
-- 26) TRIGGERS
--------------------------------------------------------------------------------
-- a) TRIGGER TO PREVENT SALARY FROM EXCEEDING 10,000
CREATE OR REPLACE TRIGGER trg_max_salary
BEFORE INSERT OR UPDATE
ON employees
FOR EACH ROW
DECLARE
   v_max NUMBER := 10000;
BEGIN
   IF :NEW.salary > v_max THEN
      RAISE_APPLICATION_ERROR(-20202, 'Cannot exceed the maximum allowed salary (10000)');
   END IF;
END;
/
BEGIN
   UPDATE employees
      SET salary = 10500
    WHERE employee_id = 1;
END;
/
DROP TRIGGER trg_max_salary;
ROLLBACK;

--------------------------------------------------------------------------------
-- b) TRIGGER TO PREVENT DELETION OF HEADQUARTERS WITH headquarters_id=1
CREATE OR REPLACE TRIGGER trg_headquarters_no_delete
BEFORE DELETE ON headquarters
FOR EACH ROW
BEGIN
   IF :OLD.headquarters_id = 1 THEN
      RAISE_APPLICATION_ERROR(-20203, 'Cannot delete headquarters with ID=1');
   END IF;
END;
/
BEGIN
   DELETE FROM headquarters
    WHERE headquarters_id = 1;
END;
/
DROP TRIGGER trg_headquarters_no_delete;
