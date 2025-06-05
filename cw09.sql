-- 1. Składającą się ze stworzonych procedur i funkcji podczas zajęć
CREATE OR REPLACE PACKAGE hr_tools_pkg IS

  PROCEDURE dodaj_pracownika (
    p_first_name    IN employees.first_name%TYPE DEFAULT 'Jan',
    p_last_name     IN employees.last_name%TYPE DEFAULT 'Kowalski',
    p_email         IN employees.email%TYPE DEFAULT 'jan.kowalski',
    p_hire_date     IN employees.hire_date%TYPE DEFAULT SYSDATE,
    p_job_id        IN employees.job_id%TYPE DEFAULT 'IT_PROG',
    p_salary        IN employees.salary%TYPE DEFAULT 5000,
    p_department_id IN employees.department_id%TYPE DEFAULT 60
  );

  PROCEDURE dodaj_stanowisko (
    p_job_id    IN jobs.job_id%TYPE,
    p_job_title IN jobs.job_title%TYPE
  );

  PROCEDURE aktualizuj_wynagrodzenia (
    p_dept_id IN employees.department_id%TYPE,
    p_procent IN NUMBER
  );

END hr_tools_pkg;
/

CREATE OR REPLACE PACKAGE BODY hr_tools_pkg IS

  PROCEDURE dodaj_pracownika (
    p_first_name    IN employees.first_name%TYPE DEFAULT 'Jan',
    p_last_name     IN employees.last_name%TYPE DEFAULT 'Kowalski',
    p_email         IN employees.email%TYPE DEFAULT 'jan.kowalski',
    p_hire_date     IN employees.hire_date%TYPE DEFAULT SYSDATE,
    p_job_id        IN employees.job_id%TYPE DEFAULT 'IT_PROG',
    p_salary        IN employees.salary%TYPE DEFAULT 5000,
    p_department_id IN employees.department_id%TYPE DEFAULT 60
  ) AS
    e_za_duza_pensja EXCEPTION;
    PRAGMA EXCEPTION_INIT(e_za_duza_pensja, -20020);
  BEGIN
    IF p_salary > 20000 THEN
      RAISE_APPLICATION_ERROR(-20020, 'Wynagrodzenie przekracza dozwolony limit (20000).');
    END IF;

    INSERT INTO employees (
      employee_id, first_name, last_name, email, hire_date, job_id, salary, department_id
    ) VALUES (
      employees_seq.NEXTVAL, p_first_name, p_last_name, p_email, p_hire_date, p_job_id, p_salary, p_department_id
    );

    DBMS_OUTPUT.PUT_LINE('Dodano pracownika: ' || p_first_name || ' ' || p_last_name);

  EXCEPTION
    WHEN e_za_duza_pensja THEN
      DBMS_OUTPUT.PUT_LINE('Błąd użytkownika: ' || SQLERRM);
    WHEN OTHERS THEN
      DBMS_OUTPUT.PUT_LINE('Inny błąd: ' || SQLERRM);
  END dodaj_pracownika;


  PROCEDURE dodaj_stanowisko (
    p_job_id    IN jobs.job_id%TYPE,
    p_job_title IN jobs.job_title%TYPE
  ) AS
  BEGIN
    INSERT INTO jobs (job_id, job_title, min_salary, max_salary)
    VALUES (p_job_id, p_job_title, NULL, NULL);

    DBMS_OUTPUT.PUT_LINE('Dodano stanowisko: ' || p_job_id || ' - ' || p_job_title);

  EXCEPTION
    WHEN DUP_VAL_ON_INDEX THEN
      DBMS_OUTPUT.PUT_LINE('Błąd: Stanowisko o podanym ID już istnieje.');
    WHEN OTHERS THEN
      DBMS_OUTPUT.PUT_LINE('Inny błąd: ' || SQLERRM);
  END dodaj_stanowisko;


  PROCEDURE aktualizuj_wynagrodzenia (
    p_dept_id IN employees.department_id%TYPE,
    p_procent IN NUMBER
  ) AS
    e_nieistniejacy_dept EXCEPTION;
    PRAGMA EXCEPTION_INIT(e_nieistniejacy_dept, -02291);
  BEGIN
    UPDATE employees e
    SET salary = salary + (salary * p_procent / 100)
    WHERE department_id = p_dept_id
      AND EXISTS (
        SELECT 1
        FROM jobs j
        WHERE j.job_id = e.job_id
          AND salary + (salary * p_procent / 100) BETWEEN j.min_salary AND j.max_salary
      );

    IF SQL%ROWCOUNT = 0 THEN
      DBMS_OUTPUT.PUT_LINE('Nie dokonano żadnych zmian – sprawdź warunki.');
    ELSE
      DBMS_OUTPUT.PUT_LINE('Zaktualizowano ' || SQL%ROWCOUNT || ' pracownika(ów).');
    END IF;

  EXCEPTION
    WHEN e_nieistniejacy_dept THEN
      DBMS_OUTPUT.PUT_LINE('Błąd: Nie istnieje dział o podanym ID (ORA-02291)');
    WHEN OTHERS THEN
      DBMS_OUTPUT.PUT_LINE('Inny błąd: ' || SQLERRM);
  END aktualizuj_wynagrodzenia;

END hr_tools_pkg;
/

-- 2. Stworzyć paczkę z procedurami i funkcjami do obsługi tabeli REGIONS (CRUD), gdzie odczyt z różnymi parametrami
CREATE OR REPLACE PACKAGE regions_pkg IS

  -- CREATE
  PROCEDURE add_region(p_region_id NUMBER, p_region_name VARCHAR2);

  -- READ (po ID)
  FUNCTION get_region_name(p_region_id NUMBER) RETURN VARCHAR2;

  -- READ (lista po nazwie - parametryzowany LIKE)
  PROCEDURE find_regions_by_name(p_name_pattern VARCHAR2, p_results OUT SYS_REFCURSOR);

  -- UPDATE
  PROCEDURE update_region_name(p_region_id NUMBER, p_new_name VARCHAR2);

  -- DELETE
  PROCEDURE delete_region(p_region_id NUMBER);

END regions_pkg;
/

CREATE OR REPLACE PACKAGE BODY regions_pkg IS

  PROCEDURE add_region(p_region_id NUMBER, p_region_name VARCHAR2) IS
  BEGIN
    INSERT INTO regions(region_id, region_name)
    VALUES (p_region_id, p_region_name);
  END add_region;

  FUNCTION get_region_name(p_region_id NUMBER) RETURN VARCHAR2 IS
    v_name VARCHAR2(50);
  BEGIN
    SELECT region_name INTO v_name FROM regions WHERE region_id = p_region_id;
    RETURN v_name;
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      RETURN NULL;
  END get_region_name;

  PROCEDURE find_regions_by_name(p_name_pattern VARCHAR2, p_results OUT SYS_REFCURSOR) IS
  BEGIN
    OPEN p_results FOR
      SELECT region_id, region_name
      FROM regions
      WHERE region_name LIKE p_name_pattern;
  END find_regions_by_name;

  PROCEDURE update_region_name(p_region_id NUMBER, p_new_name VARCHAR2) IS
  BEGIN
    UPDATE regions SET region_name = p_new_name WHERE region_id = p_region_id;
  END update_region_name;

  PROCEDURE delete_region(p_region_id NUMBER) IS
  BEGIN
    DELETE FROM regions WHERE region_id = p_region_id;
  END delete_region;

END regions_pkg;
/


-- Dodaj region
BEGIN
  regions_pkg.add_region(10, 'Antarctica');
END;
/

-- Pobierz nazwę regionu
DECLARE
  v_name VARCHAR2(50);
BEGIN
  v_name := regions_pkg.get_region_name(10);
  DBMS_OUTPUT.PUT_LINE('Region name: ' || v_name);
END;
/

-- Znajdź regiony z nazwą zawierającą 'A'
DECLARE
  rc SYS_REFCURSOR;
  v_id NUMBER;
  v_name VARCHAR2(50);
BEGIN
  regions_pkg.find_regions_by_name('%A%', rc);
  LOOP
    FETCH rc INTO v_id, v_name;
    EXIT WHEN rc%NOTFOUND;
    DBMS_OUTPUT.PUT_LINE('ID: ' || v_id || ', Name: ' || v_name);
  END LOOP;
  CLOSE rc;
END;
/

-- Aktualizuj nazwę regionu
BEGIN
  regions_pkg.update_region_name(10, 'New Antarctica');
END;
/

-- Usuń region
BEGIN
  regions_pkg.delete_region(10);
END;
/

-- 3. Rozszerzenie pakietu REGIONS o obsługę wyjątków. Dodaj niestandardowe wyjątki dla:
-- a. Próby dodania regionu o istniejącej nazwie
BEGIN
  regions_pkg.add_region(10, 'Europe');
END;
/

-- b. Usunięcia regionu z przypisanymi krajami
BEGIN
  regions_pkg.delete_region(1);
END;
/

-- c. Zaimplementuj procedurę logującą błędy do tabeli audytowej
SELECT * FROM region_errors_audit;


CREATE TABLE region_errors_audit (
    id           NUMBER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    error_msg    VARCHAR2(4000),
    error_time   TIMESTAMP DEFAULT SYSTIMESTAMP
);

CREATE OR REPLACE PACKAGE regions_pkg IS
  PROCEDURE add_region(p_region_id NUMBER, p_region_name VARCHAR2);
  FUNCTION get_region_name(p_region_id NUMBER) RETURN VARCHAR2;
  PROCEDURE find_regions_by_name(p_name_pattern VARCHAR2, p_results OUT SYS_REFCURSOR);
  PROCEDURE update_region_name(p_region_id NUMBER, p_new_name VARCHAR2);
  PROCEDURE delete_region(p_region_id NUMBER);


  PROCEDURE log_error(p_error_msg VARCHAR2);

END regions_pkg;
/

CREATE OR REPLACE PACKAGE BODY regions_pkg IS

  ex_region_exists EXCEPTION;
  PRAGMA EXCEPTION_INIT(ex_region_exists, -20001);

  ex_region_has_countries EXCEPTION;
  PRAGMA EXCEPTION_INIT(ex_region_has_countries, -20002);

  PROCEDURE log_error(p_error_msg VARCHAR2) IS
  BEGIN
    INSERT INTO region_errors_audit(error_msg)
    VALUES (p_error_msg);
    COMMIT;
  EXCEPTION
    WHEN OTHERS THEN NULL; 
  END;

  PROCEDURE add_region(p_region_id NUMBER, p_region_name VARCHAR2) IS
    v_exists NUMBER;
  BEGIN
    SELECT COUNT(*) INTO v_exists
    FROM regions
    WHERE UPPER(region_name) = UPPER(p_region_name);

    IF v_exists > 0 THEN
      log_error('Dodawanie regionu: już istnieje region o nazwie "' || p_region_name || '"');
      RAISE_APPLICATION_ERROR(-20001, 'Region with this name already exists.');
    END IF;

    INSERT INTO regions(region_id, region_name)
    VALUES (p_region_id, p_region_name);
  END add_region;

  FUNCTION get_region_name(p_region_id NUMBER) RETURN VARCHAR2 IS
    v_name VARCHAR2(50);
  BEGIN
    SELECT region_name INTO v_name FROM regions WHERE region_id = p_region_id;
    RETURN v_name;
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      RETURN NULL;
  END get_region_name;

  PROCEDURE find_regions_by_name(p_name_pattern VARCHAR2, p_results OUT SYS_REFCURSOR) IS
  BEGIN
    OPEN p_results FOR
      SELECT region_id, region_name
      FROM regions
      WHERE region_name LIKE p_name_pattern;
  END find_regions_by_name;

  PROCEDURE update_region_name(p_region_id NUMBER, p_new_name VARCHAR2) IS
  BEGIN
    UPDATE regions SET region_name = p_new_name WHERE region_id = p_region_id;
  END update_region_name;

  PROCEDURE delete_region(p_region_id NUMBER) IS
    v_country_count NUMBER;
  BEGIN
    SELECT COUNT(*) INTO v_country_count
    FROM countries
    WHERE region_id = p_region_id;

    IF v_country_count > 0 THEN
      log_error('Usuwanie regionu: region_id=' || p_region_id || ' ma przypisane kraje.');
      RAISE_APPLICATION_ERROR(-20002, 'Region has assigned countries. Cannot delete.');
    END IF;

    DELETE FROM regions WHERE region_id = p_region_id;
  END delete_region;

END regions_pkg;
/

-- 4. Pakiet do obliczeń statystycznych dla departamentów
-- a. Średnią pensję w departamencie
BEGIN
  DBMS_OUTPUT.PUT_LINE('AVG: ' || dept_stats_pkg.get_avg_salary_by_dept(60));
END;
/

-- b. Minimalną i maksymalną pensję dla stanowiska
DECLARE
  v_min NUMBER;
  v_max NUMBER;
BEGIN
  dept_stats_pkg.get_min_max_salary_by_job('IT_PROG', v_min, v_max);
  DBMS_OUTPUT.PUT_LINE('MIN: ' || v_min || ', MAX: ' || v_max);
END;
/

-- c. Dodaj procedurę generującą raport tekstowy.
BEGIN
  dept_stats_pkg.generate_salary_report;
END;
/


CREATE OR REPLACE PACKAGE dept_stats_pkg IS

  FUNCTION get_avg_salary_by_dept(p_dept_id NUMBER) RETURN NUMBER;

  PROCEDURE get_min_max_salary_by_job(
    p_job_id    VARCHAR2,
    p_min OUT NUMBER,
    p_max OUT NUMBER
  );

  PROCEDURE generate_salary_report;

END dept_stats_pkg;
/

CREATE OR REPLACE PACKAGE BODY dept_stats_pkg IS

  FUNCTION get_avg_salary_by_dept(p_dept_id NUMBER) RETURN NUMBER IS
    v_avg NUMBER;
  BEGIN
    SELECT AVG(salary)
    INTO v_avg
    FROM employees
    WHERE department_id = p_dept_id;

    RETURN v_avg;
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      RETURN NULL;
  END;

  PROCEDURE get_min_max_salary_by_job(
    p_job_id    VARCHAR2,
    p_min OUT NUMBER,
    p_max OUT NUMBER
  ) IS
  BEGIN
    SELECT MIN(salary), MAX(salary)
    INTO p_min, p_max
    FROM employees
    WHERE job_id = p_job_id;
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      p_min := NULL;
      p_max := NULL;
  END;

  PROCEDURE generate_salary_report IS
    CURSOR c IS
      SELECT department_id
      FROM departments;

    v_dept_id departments.department_id%TYPE;
    v_avg_salary NUMBER;
    v_output VARCHAR2(4000);
  BEGIN
    FOR rec IN c LOOP
      v_avg_salary := get_avg_salary_by_dept(rec.department_id);
      v_output := 'Department ' || rec.department_id || ': Average Salary = ' || NVL(TO_CHAR(v_avg_salary, '99990.00'), 'N/A');
      DBMS_OUTPUT.PUT_LINE(v_output);
    END LOOP;
  END;

END dept_stats_pkg;
/

-- 5. Pakiet do automatycznej walidacji i aktualizacji danych
-- a. Automatyczna korekta formatu numerów telefonów
BEGIN
  data_utils_pkg.normalize_phone_numbers('+48');
END;
/

BEGIN
  data_utils_pkg.normalize_phone_numbers('+1');
END;
/

-- b. Masowa aktualizacja pensji dla stanowisk z określonym procentem podwyżki
BEGIN
  data_utils_pkg.increase_salary_by_job('IT_PROG', 10);
END;
/


CREATE OR REPLACE PACKAGE data_utils_pkg IS

  PROCEDURE normalize_phone_numbers(p_prefix VARCHAR2 DEFAULT '+48');

  PROCEDURE increase_salary_by_job(p_job_id VARCHAR2, p_percent NUMBER);

END data_utils_pkg;
/


CREATE OR REPLACE PACKAGE BODY data_utils_pkg IS

  PROCEDURE normalize_phone_numbers(p_prefix VARCHAR2 DEFAULT '+48') IS
  BEGIN
    FOR emp IN (
      SELECT employee_id, phone_number
      FROM employees
      WHERE phone_number IS NOT NULL
    ) LOOP
      UPDATE employees
      SET phone_number = p_prefix || REGEXP_REPLACE(emp.phone_number, '[^0-9]', '')
      WHERE employee_id = emp.employee_id;
    END LOOP;

    COMMIT;
  END normalize_phone_numbers;

  PROCEDURE increase_salary_by_job(p_job_id VARCHAR2, p_percent NUMBER) IS
  BEGIN
    UPDATE employees
    SET salary = salary * (1 + p_percent / 100)
    WHERE job_id = p_job_id;

    COMMIT;
  END increase_salary_by_job;

END data_utils_pkg;
/