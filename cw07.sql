-- Stwórz funkcje:
-- 1. Zwracającą nazwę pracy dla podanego parametru id, dodaj wyjątek, jeśli taka praca nie istnieje.
CREATE OR REPLACE FUNCTION GET_JOB_TITLE (
    p_job_id IN jobs.job_id%TYPE
) RETURN jobs.job_title%TYPE
AS
    v_job_title jobs.job_title%TYPE;
BEGIN
    SELECT job_title INTO v_job_title
    FROM jobs
    WHERE job_id = p_job_id;

    RETURN v_job_title;

EXCEPTION
    WHEN NO_DATA_FOUND THEN
        RAISE_APPLICATION_ERROR(-20001, 'Nie znaleziono stanowiska o ID: ' || p_job_id);
    WHEN OTHERS THEN
        RAISE_APPLICATION_ERROR(-20002, 'Błąd: ' || SQLERRM);
END;
/

BEGIN
    DBMS_OUTPUT.PUT_LINE(GET_JOB_TITLE('PU_MAN'));
END;
/

BEGIN
    DBMS_OUTPUT.PUT_LINE(GET_JOB_TITLE('IT_ADM'));
END;
/

-- 2. Zwracającą roczne zarobki (wynagrodzenie 12-to miesięczne plus premia jako wynagrodzenie * commission_pct) dla pracownika o podanym id.
CREATE OR REPLACE FUNCTION GET_ANNUAL_SALARY (
    p_emp_id IN employees.employee_id%TYPE
) RETURN NUMBER
AS
    v_salary         employees.salary%TYPE;
    v_commission     employees.commission_pct%TYPE;
    v_annual_salary  NUMBER;
BEGIN
    SELECT salary, commission_pct
    INTO v_salary, v_commission
    FROM employees
    WHERE employee_id = p_emp_id;

    v_annual_salary := (v_salary * 12) + (v_salary * NVL(v_commission, 0));

    RETURN v_annual_salary;

EXCEPTION
    WHEN NO_DATA_FOUND THEN
        RAISE_APPLICATION_ERROR(-20001, 'Nie znaleziono pracownika o ID: ' || p_emp_id);
    WHEN OTHERS THEN
        RAISE_APPLICATION_ERROR(-20002, 'Błąd: ' || SQLERRM);
END;
/

BEGIN
    DBMS_OUTPUT.PUT_LINE('Roczne zarobki: ' || GET_ANNUAL_SALARY(100));
END;
/

BEGIN
    DBMS_OUTPUT.PUT_LINE(GET_ANNUAL_SALARY(2137));
END;
/

-- 3. Biorąc w nawias numer kierunkowy z numeru telefonu podanego jako varchar.
CREATE OR REPLACE FUNCTION EXTRACT_AREA_CODE (
    p_phone IN VARCHAR2
) RETURN VARCHAR2
AS
    v_area_code VARCHAR2(10);
BEGIN
    SELECT REGEXP_SUBSTR(p_phone, '\(([^)]+)\)', 1, 1, NULL, 1)
    INTO v_area_code
    FROM dual;

    RETURN v_area_code;

EXCEPTION
    WHEN NO_DATA_FOUND THEN
        RETURN NULL;
    WHEN OTHERS THEN
        RETURN NULL;
END;
/

BEGIN
    DBMS_OUTPUT.PUT_LINE(EXTRACT_AREA_CODE('(123) 456-7890'));
    DBMS_OUTPUT.PUT_LINE(EXTRACT_AREA_CODE('123-456-7890')); 
END;
/

-- 4. Dla podanego w parametrze ciągu znaków zmieniającą pierwszą i ostatnią literę na wielką – pozostałe na małe.
CREATE OR REPLACE FUNCTION UPPERCASE_FIRST_LAST_LETTER (
    p_txt IN VARCHAR2
) RETURN VARCHAR2
AS
    v_result VARCHAR2(4000);
    v_len    PLS_INTEGER;
BEGIN
    v_len := LENGTH(p_txt);

    IF v_len = 0 THEN
        RETURN '';
    ELSIF v_len = 1 THEN
        RETURN UPPER(p_txt);
    ELSE
        v_result := 
            UPPER(SUBSTR(p_txt, 1, 1)) ||
            LOWER(SUBSTR(p_txt, 2, v_len - 2)) ||
            UPPER(SUBSTR(p_txt, -1, 1));

        RETURN v_result;
    END IF;

EXCEPTION
    WHEN OTHERS THEN
        RETURN NULL;
END;
/

BEGIN
    DBMS_OUTPUT.PUT_LINE(UPPERCASE_FIRST_LAST_LETTER('programowanie'));
    DBMS_OUTPUT.PUT_LINE(UPPERCASE_FIRST_LAST_LETTER('A'));
    DBMS_OUTPUT.PUT_LINE(UPPERCASE_FIRST_LAST_LETTER('dzień'));
END;
/

-- 5. Dla podanego pesel - przerabiającą pesel na datę urodzenia w formacie ‘yyyy-mm-dd’.
CREATE OR REPLACE FUNCTION PESEL_TO_DATE (
    p_pesel IN VARCHAR2
) RETURN VARCHAR2
AS
    v_year   NUMBER;
    v_month  NUMBER;
    v_day    NUMBER;
    v_full_date DATE;
BEGIN

    v_year  := TO_NUMBER(SUBSTR(p_pesel, 1, 2));
    v_month := TO_NUMBER(SUBSTR(p_pesel, 3, 2));
    v_day   := TO_NUMBER(SUBSTR(p_pesel, 5, 2));

    IF v_month BETWEEN 1 AND 12 THEN
        v_year := 1900 + v_year;
    ELSIF v_month BETWEEN 21 AND 32 THEN
        v_year := 2000 + v_year;
        v_month := v_month - 20;
    ELSIF v_month BETWEEN 41 AND 52 THEN
        v_year := 2100 + v_year;
        v_month := v_month - 40;
    ELSIF v_month BETWEEN 81 AND 92 THEN
        v_year := 1800 + v_year;
        v_month := v_month - 80;
    ELSE
        RAISE_APPLICATION_ERROR(-20001, 'Nieprawidłowy miesiąc w PESEL');
    END IF;

    v_full_date := TO_DATE(v_year || '-' || LPAD(v_month,2,'0') || '-' || LPAD(v_day,2,'0'), 'YYYY-MM-DD');

    RETURN TO_CHAR(v_full_date, 'YYYY-MM-DD');

EXCEPTION
    WHEN OTHERS THEN
        RETURN 'Błąd: ' || SQLERRM;
END;
/

BEGIN
    DBMS_OUTPUT.PUT_LINE(PESEL_TO_DATE('02270812345'));
    DBMS_OUTPUT.PUT_LINE(PESEL_TO_DATE('99031298765'));
    DBMS_OUTPUT.PUT_LINE(PESEL_TO_DATE('01223145678'));
END;
/

-- 6. Zwracającą liczbę pracowników oraz liczbę departamentów które znajdują się w kraju podanym jako parametr (nazwa kraju). W przypadku braku kraju - odpowiedni wyjątek.
CREATE OR REPLACE PROCEDURE GET_COUNTRY_STATS (
    p_country_name      IN  countries.country_name%TYPE,
    p_liczba_pracownikow OUT NUMBER,
    p_liczba_departamentow OUT NUMBER
) AS
    v_country_id countries.country_id%TYPE;
BEGIN
    SELECT country_id INTO v_country_id
    FROM countries
    WHERE UPPER(country_name) = UPPER(p_country_name);

    SELECT COUNT(*)
    INTO p_liczba_departamentow
    FROM departments d
    JOIN locations l ON d.location_id = l.location_id
    WHERE l.country_id = v_country_id;

    SELECT COUNT(*)
    INTO p_liczba_pracownikow
    FROM employees e
    JOIN departments d ON e.department_id = d.department_id
    JOIN locations l ON d.location_id = l.location_id
    WHERE l.country_id = v_country_id;

EXCEPTION
    WHEN NO_DATA_FOUND THEN
        RAISE_APPLICATION_ERROR(-20001, 'Nie znaleziono kraju o nazwie: ' || p_country_name);
    WHEN OTHERS THEN
        RAISE_APPLICATION_ERROR(-20002, 'Błąd: ' || SQLERRM);
END;
/

DECLARE
    v_prac NUMBER;
    v_dep  NUMBER;
BEGIN
    GET_COUNTRY_STATS('United States of America', v_prac, v_dep);
    DBMS_OUTPUT.PUT_LINE('Liczba pracowników: ' || v_prac);
    DBMS_OUTPUT.PUT_LINE('Liczba departamentów: ' || v_dep);
END;
/

BEGIN
    DECLARE
        p NUMBER;
        d NUMBER;
    BEGIN
        GET_COUNTRY_STATS('Yugoslavia', p, d);
    END;
END;
/

-- 7. Generującą unikalny identyfikator dostępu w formacie: Pierwsze 3 litery nazwiska + ostatnie 4 cyfry telefonu + inicjał imienia.
CREATE OR REPLACE FUNCTION GENERATE_ACCESS_ID (
    p_first_name IN VARCHAR2,
    p_last_name  IN VARCHAR2,
    p_phone      IN VARCHAR2
) RETURN VARCHAR2
AS
    v_id VARCHAR2(100);
    v_last4 VARCHAR2(4);
BEGIN
    v_last4 := REGEXP_SUBSTR(p_phone, '\d{4}$');

    v_id := INITCAP(SUBSTR(p_last_name, 1, 3)) ||
            v_last4 ||
            UPPER(SUBSTR(p_first_name, 1, 1));

    RETURN v_id;

EXCEPTION
    WHEN OTHERS THEN
        RETURN 'BŁĄD: ' || SQLERRM;
END;
/

BEGIN
    DBMS_OUTPUT.PUT_LINE(GENERATE_ACCESS_ID('Anna', 'Kowalski', '123-456-7890'));
    DBMS_OUTPUT.PUT_LINE(GENERATE_ACCESS_ID('Piotr', 'Nowak', '500600700'));
END;
/