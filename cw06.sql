-- 1. Dodającą wiersz do tabeli Jobs – z dwoma parametrami wejściowymi określającymi Job_id, Job_title, przetestuj działanie wrzuć wyjątki – co najmniej when others.
CREATE OR REPLACE PROCEDURE DODAJ_STANOWISKO (
    p_job_id     IN jobs.job_id%TYPE,
    p_job_title  IN jobs.job_title%TYPE
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
END;
/

BEGIN
    DODAJ_STANOWISKO('TEST_JOB', 'Stanowisko pracy');
END;
/

-- 2. Modyfikującą title w tabeli Jobs – z dwoma parametrami (id dla którego ma być modyfikacja oraz nową wartość) dla Job_title – przetestować działanie, dodać swój wyjątek dla no Jobs updated – najpierw sprawdzić numer błędu.
CREATE OR REPLACE PROCEDURE ZMIEN_TYTUL_STANOWISKA (
    p_job_id     IN jobs.job_id%TYPE,
    p_new_title  IN jobs.job_title%TYPE
) AS
    v_liczba_zmian NUMBER;
    e_brak_zmiany EXCEPTION;
    PRAGMA EXCEPTION_INIT(e_brak_zmiany, -20017);

BEGIN
    UPDATE jobs
    SET job_title = p_new_title
    WHERE job_id = p_job_id;

    v_liczba_zmian := SQL%ROWCOUNT;

    IF v_liczba_zmian = 0 THEN
        RAISE_APPLICATION_ERROR(-20017, 'Nie znaleziono stanowiska o podanym ID – brak zmian.');
    ELSE
        DBMS_OUTPUT.PUT_LINE('Zmieniono tytuł dla ' || v_liczba_zmian || ' stanowiska(ek).');
    END IF;

EXCEPTION
    WHEN e_brak_zmiany THEN
        DBMS_OUTPUT.PUT_LINE('Błąd użytkownika: ' || SQLERRM);
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Inny błąd: ' || SQLERRM);
END;
/

BEGIN
    ZMIEN_TYTUL_STANOWISKA('TEST_JOB', 'Nowa nazwa stanowiska');
END;
/

BEGIN
    ZMIEN_TYTUL_STANOWISKA('TES_JOB', 'Nowa nazwa stanowiska');
END;
/

-- 3. Usuwającą wiersz z tabeli Jobs o podanym Job_id– przetestować działanie, dodaj wyjątek dla no Jobs deleted.
CREATE OR REPLACE PROCEDURE USUN_STANOWISKO (
    p_job_id IN jobs.job_id%TYPE
) AS
    v_liczba_usunietych NUMBER;
    e_brak_usuniecia EXCEPTION;
    PRAGMA EXCEPTION_INIT(e_brak_usuniecia, -20018);

BEGIN
    DELETE FROM jobs
    WHERE job_id = p_job_id;
    v_liczba_usunietych := SQL%ROWCOUNT;

    IF v_liczba_usunietych = 0 THEN
        RAISE_APPLICATION_ERROR(-20018, 'Nie znaleziono stanowiska do usunięcia.');
    ELSE
        DBMS_OUTPUT.PUT_LINE('Usunięto stanowisko: ' || p_job_id);
    END IF;

EXCEPTION
    WHEN e_brak_usuniecia THEN
        DBMS_OUTPUT.PUT_LINE('Błąd użytkownika: ' || SQLERRM);
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Inny błąd: ' || SQLERRM);
END;
/

BEGIN
    USUN_STANOWISKO('TEST_JOB');
END;
/

BEGIN
    USUN_STANOWISKO('TES_JOB');
END;
/

-- 4. Wyciągającą zarobki i nazwisko (parametry zwracane przez procedurę) z tabeli employees dla pracownika o przekazanym jako parametr id.
CREATE OR REPLACE PROCEDURE INFO_PRACOWNIKA (
    p_id     IN  employees.employee_id%TYPE,
    p_salary     OUT employees.salary%TYPE,
    p_last_name  OUT employees.last_name%TYPE
) AS
    e_nie_znaleziono_pracownika EXCEPTION;
    PRAGMA EXCEPTION_INIT(e_nie_znaleziono_pracownika, -20019);
BEGIN
    SELECT salary, last_name
    INTO p_salary, p_last_name
    FROM employees
    WHERE employee_id = p_id;

EXCEPTION
    WHEN NO_DATA_FOUND THEN
        RAISE_APPLICATION_ERROR(-20019, 'Nie znaleziono pracownika o podanym ID.');
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Inny błąd: ' || SQLERRM);
END;
/

DECLARE
    v_salary    employees.salary%TYPE;
    v_last_name employees.last_name%TYPE;
BEGIN
    INFO_PRACOWNIKA(115, v_salary, v_last_name);

    DBMS_OUTPUT.PUT_LINE('Nazwisko: ' || v_last_name);
    DBMS_OUTPUT.PUT_LINE('Zarobki: ' || v_salary);
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Błąd: ' || SQLERRM);
END;
/

-- 5. Dodającą do tabeli employees wiersz – większość parametrów ustawić na domyślne (id poprzez sekwencję), stworzyć wyjątek jeśli wynagrodzenie dodawanego pracownika jest wyższe niż 20000.
CREATE SEQUENCE employees_seq
START WITH 207
INCREMENT BY 1
NOCACHE;


CREATE OR REPLACE PROCEDURE DODAJ_PRACOWNIKA (
    p_first_name   IN employees.first_name%TYPE DEFAULT 'Jan',
    p_last_name    IN employees.last_name%TYPE DEFAULT 'Kowalski',
    p_email        IN employees.email%TYPE DEFAULT 'jan.kowalski',
    p_hire_date    IN employees.hire_date%TYPE DEFAULT SYSDATE,
    p_job_id       IN employees.job_id%TYPE DEFAULT 'IT_PROG',
    p_salary       IN employees.salary%TYPE DEFAULT 5000,
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
END;
/

BEGIN
    DODAJ_PRACOWNIKA;
END;
/

BEGIN
    DODAJ_PRACOWNIKA(p_first_name => 'Adam', p_last_name => 'Nowak', p_salary => 25000);
END;
/

-- 6. Przyjmującą jako parametr wejściowy id managera, a parametrem wyjściowym zwraca średnią zarobków osób podległych pod tego managera
CREATE OR REPLACE PROCEDURE SREDNIA_ZAROBKOW_MANAGER (
    p_manager_id IN employees.manager_id%TYPE,
    p_avg_salary OUT NUMBER
) AS
BEGIN
    SELECT AVG(salary)
    INTO p_avg_salary
    FROM employees
    WHERE manager_id = p_manager_id;

    IF p_avg_salary IS NULL THEN
        DBMS_OUTPUT.PUT_LINE('Manager o ID ' || p_manager_id || ' nie ma podwładnych.');
    ELSE
        DBMS_OUTPUT.PUT_LINE('Średnia pensja podwładnych: ' || p_avg_salary);
    END IF;

EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Błąd: ' || SQLERRM);
END;
/

DECLARE
    v_avg_salary NUMBER;
BEGIN
    SREDNIA_ZAROBKOW_MANAGER(145, v_avg_salary);
    DBMS_OUTPUT.PUT_LINE('Zwrócona średnia pensja: ' || NVL(TO_CHAR(v_avg_salary), 'brak danych'));
END;
/

-- 7. Aktualizującą wynagrodzenia w departamencie, przyjmującą department_id i procent podwyżki. Zwiększ wynagrodzenia wszystkich pracowników w danym departamencie o podany procent. Sprawdź czy nowe wynagrodzenie mieści się w przedziale min/max_salary z tabeli jobs dla aktualnego stanowiska pracownika. Dodaj wyjątek dla nieistniejącego department_id (sprawdź błąd ORA-02291).
CREATE OR REPLACE PROCEDURE AKTUALIZUJ_WYNAGRODZENIA (
    p_dept_id     IN employees.department_id%TYPE,
    p_procent     IN NUMBER
) AS
    e_nieistniejacy_dept EXCEPTION;
    PRAGMA EXCEPTION_INIT(e_nieistniejacy_dept, -2291);

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
END;
/

BEGIN
    AKTUALIZUJ_WYNAGRODZENIA(p_dept_id => 50, p_procent => 10);
END;
/

BEGIN
    AKTUALIZUJ_WYNAGRODZENIA(p_dept_id => 5, p_procent => 10);
END;
/

-- 8. Przenosząca pracownika między departamentami z parametrami employee_id i new_department_id. Sprawdź czy nowy departament istnieje. Dodaj własny wyjątek gdy pracownik nie istnieje.
CREATE OR REPLACE PROCEDURE PRZENIES_PRACOWNIKA (
    p_employee_id        IN employees.employee_id%TYPE,
    p_new_department_id  IN employees.department_id%TYPE
) AS
    v_dummy       NUMBER;
    e_brak_pracownika EXCEPTION;

BEGIN
    SELECT 1 INTO v_dummy
    FROM employees
    WHERE employee_id = p_employee_id;

    SELECT 1 INTO v_dummy
    FROM departments
    WHERE department_id = p_new_department_id;

    UPDATE employees
    SET department_id = p_new_department_id
    WHERE employee_id = p_employee_id;

    DBMS_OUTPUT.PUT_LINE('Pracownik ' || p_employee_id || ' został przeniesiony do działu ' || p_new_department_id);

EXCEPTION
    WHEN NO_DATA_FOUND THEN
        RAISE_APPLICATION_ERROR(-20010, 'Nie znaleziono pracownika lub nowego działu.');
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Błąd: ' || SQLERRM);
END;
/

BEGIN
    PRZENIES_PRACOWNIKA(p_employee_id => 100, p_new_department_id => 80); 
END;
/

BEGIN
    PRZENIES_PRACOWNIKA(9999, 80);
END;
/

-- 9. Usuwająca departament po department_id tylko jeśli nie ma przypisanych pracowników. Użyj wyjątku WHEN OTHERS i zwróć komunikat o błędzie.
CREATE OR REPLACE PROCEDURE USUN_DEPARTAMENT (
    p_department_id IN departments.department_id%TYPE
) AS
    v_ile NUMBER;

BEGIN
    SELECT COUNT(*) INTO v_ile
    FROM employees
    WHERE department_id = p_department_id;

    IF v_ile > 0 THEN
        DBMS_OUTPUT.PUT_LINE('Nie można usunąć działu ' || p_department_id || ', bo ma przypisanych pracowników (' || v_ile || ').');
    ELSE
        DELETE FROM departments
        WHERE department_id = p_department_id;

        IF SQL%ROWCOUNT = 0 THEN
            DBMS_OUTPUT.PUT_LINE('Dział o ID ' || p_department_id || ' nie istnieje.');
        ELSE
            DBMS_OUTPUT.PUT_LINE('Dział o ID ' || p_department_id || ' został usunięty.');
        END IF;
    END IF;

EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Wystąpił błąd: ' || SQLERRM);
END;
/

BEGIN
    USUN_DEPARTAMENT(50);
END;
/

BEGIN
    USUN_DEPARTAMENT(290);
END;
/

