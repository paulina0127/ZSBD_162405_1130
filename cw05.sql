-- 1. Stworzyć blok anonimowy wypisujący zmienną numer_max równą maksymalnemu numerowi Departamentu i dodaj do tabeli departamenty – departament z numerem o 10 wiekszym, typ pola dla zmiennej z nazwą nowego departamentu (zainicjować na EDUCATION) ustawić taki jak dla pola department_name w tabeli (%TYPE)
DECLARE
    numer_max       NUMBER;
    nowy_numer      NUMBER;
    nowa_nazwa      departments.department_name%TYPE := 'Education';

BEGIN
    SELECT MAX(department_id) INTO numer_max FROM departments;
    
    nowy_numer := numer_max + 10;
    
    DBMS_OUTPUT.PUT_LINE('Maksymalny numer departamentu: ' || numer_max);
    
    INSERT INTO departments (department_id, department_name)
    VALUES (nowy_numer, nowa_nazwa);

    DBMS_OUTPUT.PUT_LINE('Dodano nowy departament: ' || nowy_numer || ' - ' || nowa_nazwa);

    COMMIT;
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Błąd: ' || SQLERRM);
        ROLLBACK;
END;
/

-- 2. Do poprzedniego skryptu dodaj instrukcje zmieniającą location_id (3000) dla dodanego departamentu
DECLARE
    numer_max       NUMBER;
    nowy_numer      NUMBER;
    nowa_nazwa      departments.department_name%TYPE := 'Education';

BEGIN
    SELECT MAX(department_id) INTO numer_max FROM departments;
    
    nowy_numer := numer_max + 10;
    
    DBMS_OUTPUT.PUT_LINE('Maksymalny numer departamentu: ' || numer_max);
    
    INSERT INTO departments (department_id, department_name, location_id)
    VALUES (nowy_numer, nowa_nazwa, NULL);

    UPDATE departments
    SET location_id = 3000
    WHERE department_id = nowy_numer;

    DBMS_OUTPUT.PUT_LINE('Dodano nowy departament: ' || nowy_numer || ' - ' || nowa_nazwa);
    DBMS_OUTPUT.PUT_LINE('Zmieniono location_id na 3000 dla departamentu: ' || nowy_numer);

    COMMIT;
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Błąd: ' || SQLERRM);
        ROLLBACK;
END;
/

-- 3. Stwórz tabelę nowa z jednym polem typu varchar a następnie wpisz do niej za pomocą pętli liczby od 1 do 10 bez liczb 4 i 6
CREATE TABLE nowa (
    nr VARCHAR2(10)
);

DECLARE
    i NUMBER;
BEGIN
    FOR i IN 1..10 LOOP
        IF i NOT IN (4, 6) THEN
            INSERT INTO nowa (nr) VALUES (TO_CHAR(i));
        END IF;
    END LOOP;

    COMMIT;
END;
/


-- 4. Wyciągnąć informacje z tabeli countries do jednej zmiennej (%ROWTYPE) dla kraju o identykatorze ‘CA’. Wypisać nazwę i region_id na ekran
DECLARE
    v_country countries%ROWTYPE;

BEGIN
    SELECT * INTO v_country
    FROM countries
    WHERE country_id = 'CA';


    DBMS_OUTPUT.PUT_LINE('Nazwa kraju: ' || v_country.country_name);
    DBMS_OUTPUT.PUT_LINE('Region ID: ' || v_country.region_id);
    
EXCEPTION
    WHEN NO_DATA_FOUND THEN
        DBMS_OUTPUT.PUT_LINE('Nie znaleziono kraju o identyfikatorze ''CA''');
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Wystąpił błąd: ' || SQLERRM);
END;
/

-- 5. Stworzyć blok anonimowy, który zwiększy min_salary o 5% dla stanowisk z job_title zawierającego słowo "Manager". Użyj zmiennej typu jobs%ROWTYPE. Wyświetl liczbę zaktualizowanych rekordów.
DECLARE
    v_job jobs%ROWTYPE;

    v_updated_count NUMBER := 0;

BEGIN
    FOR v_job IN (SELECT * FROM jobs WHERE job_title LIKE '%Manager%') LOOP

        UPDATE jobs
        SET min_salary = min_salary * 1.05
        WHERE job_id = v_job.job_id;
        
        v_updated_count := v_updated_count + 1;
    END LOOP;
    
    DBMS_OUTPUT.PUT_LINE('Liczba zaktualizowanych rekordów: ' || v_updated_count);
END;
/

-- a. Cofnąć wprowadzone zmiany
BEGIN
    ROLLBACK;
    DBMS_OUTPUT.PUT_LINE('Zmiany zostały cofnięte (rollback)');
END;
/

-- 6. Zadeklaruj zmienną przechowującą dane z tabeli JOBS. Znajdź i wypisz na ekran informacje o stanowisku o najwyższej maksymalnej pensji (max_salary).
DECLARE
    v_job jobs%ROWTYPE;

BEGIN
    SELECT *
    INTO v_job
    FROM jobs
    WHERE max_salary = (SELECT MAX(max_salary) FROM jobs);

    DBMS_OUTPUT.PUT_LINE('Job ID: ' || v_job.job_id);
    DBMS_OUTPUT.PUT_LINE('Job Title: ' || v_job.job_title);
    DBMS_OUTPUT.PUT_LINE('Min Salary: ' || v_job.min_salary);
    DBMS_OUTPUT.PUT_LINE('Max Salary: ' || v_job.max_salary);
    
EXCEPTION
    WHEN NO_DATA_FOUND THEN
        DBMS_OUTPUT.PUT_LINE('Nie znaleziono stanowiska o najwyższej maksymalnej pensji.');
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Wystąpił błąd: ' || SQLERRM);
END;
/

-- 7. Zadeklaruj kursor z parametrem dla region_id. Dla regionu Europe (ID=1) wypisz wszystkie kraje i ich liczbę pracowników wykorzystując podzapytanie
DECLARE
    CURSOR c_countries(p_region_id NUMBER) IS
        SELECT c.country_id, c.country_name,
               (SELECT COUNT(*) 
                FROM employees e 
                JOIN departments d ON e.department_id = d.department_id
                JOIN locations l ON d.location_id = l.location_id
                WHERE l.country_id = c.country_id) AS employee_count
        FROM countries c
        JOIN locations l ON c.country_id = l.country_id
        WHERE c.region_id = p_region_id
        GROUP BY c.country_id, c.country_name;

    v_country c_countries%ROWTYPE;

    v_country_count NUMBER := 0;

BEGIN
    OPEN c_countries(1);

    LOOP
        FETCH c_countries INTO v_country;
        EXIT WHEN c_countries%NOTFOUND;
        
        DBMS_OUTPUT.PUT_LINE('Kraj: ' || v_country.country_name || 
                             ', Liczba pracowników: ' || v_country.employee_count);
                             
        v_country_count := v_country_count + 1;
    END LOOP;

    CLOSE c_countries;

    DBMS_OUTPUT.PUT_LINE('Łączna liczba krajów w regionie Europe: ' || v_country_count);
END;
/

-- 8. Zadeklaruj kursor jako wynagrodzenie, nazwisko dla departamentu o numerze 50. Dla elementów kursora wypisać na ekran, jeśli wynagrodzenie jest wyższe niż 3100: nazwisko osoby i tekst ‘nie dawać podwyżki’ w przeciwnym przypadku: nazwisko + ‘dać podwyżkę’
DECLARE
    CURSOR c_pracownicy IS
        SELECT last_name, salary
        FROM employees
        WHERE department_id = 50;

    v_pracownik c_pracownicy%ROWTYPE;

BEGIN
    OPEN c_pracownicy;

    LOOP
        FETCH c_pracownicy INTO v_pracownik;
        EXIT WHEN c_pracownicy%NOTFOUND;

        IF v_pracownik.salary > 3100 THEN
            DBMS_OUTPUT.PUT_LINE(v_pracownik.last_name || ' - nie dawać podwyżki');
        ELSE
            DBMS_OUTPUT.PUT_LINE(v_pracownik.last_name || ' - dać podwyżkę');
        END IF;
    END LOOP;

    CLOSE c_pracownicy;
END;
/

-- 9. Zadeklarować kursor zwracający zarobki imię i nazwisko pracownika z parametrami, gdzie pierwsze dwa parametry określają widełki zarobków a trzeci część imienia pracownika. Wypisać na ekran pracowników:
-- a. z widełkami 1000- 5000 z częścią imienia a (może być również A)
DECLARE
    CURSOR c_pracownicy(p_min_salary NUMBER, p_max_salary NUMBER, p_name_part VARCHAR2) IS
        SELECT first_name, last_name, salary
        FROM employees
        WHERE salary BETWEEN p_min_salary AND p_max_salary
        AND LOWER(first_name) LIKE '%' || LOWER(p_name_part) || '%';

    v_pracownik c_pracownicy%ROWTYPE;

BEGIN
    OPEN c_pracownicy(1000, 5000, 'a');

    LOOP
        FETCH c_pracownicy INTO v_pracownik;
        EXIT WHEN c_pracownicy%NOTFOUND;

        DBMS_OUTPUT.PUT_LINE('Pracownik: ' || v_pracownik.first_name || ' ' || v_pracownik.last_name ||
                             ', Pensja: ' || v_pracownik.salary);
    END LOOP;

    CLOSE c_pracownicy;
END;
/

-- b. z widełkami 5000-20000 z częścią imienia u (może być również U)
DECLARE
    CURSOR c_pracownicy(p_min_salary NUMBER, p_max_salary NUMBER, p_name_part VARCHAR2) IS
        SELECT first_name, last_name, salary
        FROM employees
        WHERE salary BETWEEN p_min_salary AND p_max_salary
        AND LOWER(first_name) LIKE '%' || LOWER(p_name_part) || '%';

    v_pracownik c_pracownicy%ROWTYPE;

BEGIN
    OPEN c_pracownicy(5000, 20000, 'u');

    LOOP
        FETCH c_pracownicy INTO v_pracownik;
        EXIT WHEN c_pracownicy%NOTFOUND;

        DBMS_OUTPUT.PUT_LINE('Pracownik: ' || v_pracownik.first_name || ' ' || v_pracownik.last_name ||
                             ', Pensja: ' || v_pracownik.salary);
    END LOOP;

    CLOSE c_pracownicy;
END;
/

-- 10.Stwórz blok anonimowy, który dla każdego menedżera (manager_id) obliczy:
-- a. liczbę podwładnych
DECLARE
    v_liczba_podwladnych NUMBER;
    
    CURSOR c_menedzerowie IS
        SELECT DISTINCT manager_id 
        FROM employees
        WHERE manager_id IS NOT NULL;
    
    v_manager_id employees.manager_id%TYPE;

BEGIN
    OPEN c_menedzerowie;
    
    LOOP
        FETCH c_menedzerowie INTO v_manager_id;
        EXIT WHEN c_menedzerowie%NOTFOUND;
        
        SELECT COUNT(*) INTO v_liczba_podwladnych
        FROM employees
        WHERE manager_id = v_manager_id;

        DBMS_OUTPUT.PUT_LINE('Menedżer ID: ' || v_manager_id || 
                             ' - Liczba podwładnych: ' || v_liczba_podwladnych);
    END LOOP;
    
    CLOSE c_menedzerowie;
END;
/

-- b. różnicę między najwyższą i najniższą pensją w zespole
DECLARE
    v_max_salary NUMBER;
    v_min_salary NUMBER;
    v_roznica NUMBER;
    
    CURSOR c_menedzerowie IS
        SELECT DISTINCT manager_id 
        FROM employees
        WHERE manager_id IS NOT NULL;
    
    v_manager_id employees.manager_id%TYPE;

BEGIN
    OPEN c_menedzerowie;
    
    LOOP
        FETCH c_menedzerowie INTO v_manager_id;
        EXIT WHEN c_menedzerowie%NOTFOUND;
        
        SELECT NVL(MAX(salary), 0), NVL(MIN(salary), 0) 
        INTO v_max_salary, v_min_salary
        FROM employees
        WHERE manager_id = v_manager_id;
        
        v_roznica := v_max_salary - v_min_salary;
        
        DBMS_OUTPUT.PUT_LINE('Menedżer ID: ' || v_manager_id || 
                             ' - Różnica pensji: ' || v_roznica);
    END LOOP;
    
    CLOSE c_menedzerowie;
END;
/

-- c. Wyniki zapisz do nowej tabeli STATYSTYKI_MENEDZEROW
BEGIN
        EXECUTE IMMEDIATE '
            CREATE TABLE statystyki_menedzerow (
                manager_id NUMBER PRIMARY KEY,
                liczba_podwladnych NUMBER,
                roznica_pensji NUMBER
            )';
    EXCEPTION
        WHEN OTHERS THEN
            IF SQLCODE = -955 THEN 
                DBMS_OUTPUT.PUT_LINE('Tabela statystyki_menedzerow już istnieje.');
            ELSE
                RAISE;
            END IF;
    END;
/

DECLARE
    v_liczba_podwladnych NUMBER;
    v_max_salary NUMBER;
    v_min_salary NUMBER;
    v_roznica NUMBER;
    
    CURSOR c_menedzerowie IS
        SELECT DISTINCT manager_id 
        FROM employees
        WHERE manager_id IS NOT NULL;

    v_manager_id employees.manager_id%TYPE;

BEGIN
    OPEN c_menedzerowie;
    
    LOOP
        FETCH c_menedzerowie INTO v_manager_id;
        EXIT WHEN c_menedzerowie%NOTFOUND;
        
        SELECT COUNT(*) INTO v_liczba_podwladnych
        FROM employees
        WHERE manager_id = v_manager_id;
        
        SELECT NVL(MAX(salary), 0), NVL(MIN(salary), 0) 
        INTO v_max_salary, v_min_salary
        FROM employees
        WHERE manager_id = v_manager_id;
        
        v_roznica := v_max_salary - v_min_salary;
        
        INSERT INTO statystyki_menedzerow (manager_id, liczba_podwladnych, roznica_pensji)
        VALUES (v_manager_id, v_liczba_podwladnych, v_roznica);
    END LOOP;
    
    CLOSE c_menedzerowie;

    COMMIT;
    
    DBMS_OUTPUT.PUT_LINE('Dane zostały zapisane do tabeli statystyki_menedzerow.');
END;
/
