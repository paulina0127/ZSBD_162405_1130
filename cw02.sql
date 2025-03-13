BEGIN
    FOR tbl IN (SELECT table_name FROM all_tables WHERE owner = 'HR') LOOP
        EXECUTE IMMEDIATE 'CREATE TABLE INF2S_HRYCIUKP.' || tbl.table_name || ' AS SELECT * FROM HR.' || tbl.table_name;
    END LOOP;
END;
/

-- pk
ALTER TABLE regions
ADD CONSTRAINT regions_pk PRIMARY KEY (region_id);

ALTER TABLE countries
ADD CONSTRAINT countries_pk PRIMARY KEY (country_id);

ALTER TABLE departments
ADD CONSTRAINT depatments_pk PRIMARY KEY (department_id);

ALTER TABLE employees
ADD CONSTRAINT employees_pk PRIMARY KEY (employee_id);

ALTER TABLE jobs
ADD CONSTRAINT jobs_pk PRIMARY KEY (job_id);

ALTER TABLE locations
ADD CONSTRAINT locations_pk PRIMARY KEY (location_id);

ALTER TABLE products
ADD CONSTRAINT products_pk PRIMARY KEY (product_id);

ALTER TABLE sales
ADD CONSTRAINT sales_pk PRIMARY KEY (sale_id);

-- fk
ALTER TABLE countries
ADD FOREIGN KEY (region_id) REFERENCES regions(region_id);

ALTER TABLE locations
ADD FOREIGN KEY (country_id) REFERENCES countries(country_id);

ALTER TABLE departments
ADD FOREIGN KEY (manager_id) REFERENCES employees(employee_id);

ALTER TABLE departments
ADD FOREIGN KEY (location_id) REFERENCES locations(location_id);

ALTER TABLE employees
ADD FOREIGN KEY (manager_id) REFERENCES employees(employee_id);

ALTER TABLE employees
ADD FOREIGN KEY (department_id) REFERENCES departments(department_id);

ALTER TABLE job_history
ADD FOREIGN KEY (employee_id) REFERENCES employees(employee_id);

ALTER TABLE job_history
ADD FOREIGN KEY (department_id) REFERENCES departments(department_id);

ALTER TABLE job_history
ADD FOREIGN KEY (job_id) REFERENCES jobs(job_id);

ALTER TABLE sales
ADD FOREIGN KEY (employee_id) REFERENCES employees(employee_id);

ALTER TABLE sales
ADD FOREIGN KEY (product_id) REFERENCES products(product_id);

-- 1. Z tabeli employees wypisz w jednej kolumnie nazwisko i zarobki – nazwij kolumnę wynagrodzenie, dla osób z departamentów 20 i 50 z zarobkami pomiędzy 2000 a 7000, uporządkuj kolumny według nazwiska.
SELECT last_name || ' - ' || salary AS wynagrodzenie 
FROM employees
WHERE department_id IN (20, 50) 
AND salary BETWEEN 2000 AND 7000
ORDER BY last_name;

-- 2. Z tabeli employees wyciągnąć informację data zatrudnienia, nazwisko oraz kolumnę podaną przez użytkownika dla osób mających menadżera zatrudnionych w roku 2005. Uporządkować według kolumny podanej przez użytkownika.
SELECT hire_date, last_name, &user_input
FROM employees
WHERE manager_id IS NOT NULL
AND EXTRACT(YEAR FROM hire_date) = 2005
ORDER BY &user_input;

-- 3: Wypisać imiona i nazwiska razem, zarobki oraz numer telefonu porządkując dane według pierwszej kolumny malejąco a następnie drugiej rosnąco (użyć numerów do porządkowania) dla osób z trzecią literą nazwiska ‘e’ oraz częścią imienia podaną przez użytkownika.
SELECT e.first_name || ' ' || e.last_name AS full_name,
       e.salary,
       e.phone_number
FROM employees e
WHERE LOWER(SUBSTR(e.last_name, 3, 1)) = 'e'
AND LOWER(e.first_name) LIKE '%' || LOWER(:user_input) || '%'
ORDER BY 1 DESC, 2 ASC;

-- 4: Wypisać imię i nazwisko, liczbę miesięcy przepracowanych – funkcje months_between oraz round oraz kolumnę wysokość_dodatku jako (użyć CASE lub DECODE):
-- ● 10% wynagrodzenia dla liczby miesięcy do 150
-- ● 20% wynagrodzenia dla liczby miesięcy od 150 do 200
-- ● 30% wynagrodzenia dla liczby miesięcy od 200
-- ● uporządkować według liczby miesięcy
SELECT e.first_name || ' ' || e.last_name AS full_name,
       ROUND(MONTHS_BETWEEN(SYSDATE, e.hire_date)) AS months_worked,
       ROUND(
           CASE
               WHEN MONTHS_BETWEEN(SYSDATE, e.hire_date) < 150 THEN e.salary * 0.10
               WHEN MONTHS_BETWEEN(SYSDATE, e.hire_date) BETWEEN 150 AND 200 THEN e.salary * 0.20
               ELSE e.salary * 0.30
           END, 2) AS height_of_bonus
FROM employees e
ORDER BY months_worked;

-- 5: Dla każdego z działów w których minimalna płaca jest wyższa niż 5000 wypisz sumę oraz średnią zarobków zaokrągloną do całości nazwij odpowiednio kolumny.
SELECT d.department_name,
       ROUND(SUM(e.salary)) AS total_salary,
       ROUND(AVG(e.salary)) AS avg_salary
FROM employees e
JOIN departments d ON e.department_id = d.department_id
GROUP BY d.department_name
HAVING MIN(e.salary) > 5000;

-- 6: Wypisać nazwisko, numer departamentu, nazwę departamentu, id pracy, dla osób z pracujących w Toronto.
SELECT e.last_name,
       e.department_id,
       d.department_name,
       e.job_id
FROM employees e
JOIN departments d ON e.department_id = d.department_id
JOIN locations l ON d.location_id = l.location_id
WHERE l.city = 'Toronto';

-- 7: Dla pracowników o imieniu „Jennifer” wypisz imię i nazwisko tego pracownika oraz osoby które z nim współpracują.
SELECT e.first_name || ' ' || e.last_name AS full_name,
       m.first_name || ' ' || m.last_name AS manager_name
FROM employees e
LEFT JOIN employees m ON e.manager_id = m.employee_id
WHERE e.first_name = 'Jennifer';

-- 8: Wypisać wszystkie departamenty w których nie ma pracowników.
SELECT d.department_id, d.department_name
FROM departments d
LEFT JOIN employees e ON d.department_id = e.department_id
WHERE e.employee_id IS NULL;

-- 9: Wypisz imię i nazwisko, id pracy, nazwę departamentu, zarobki, oraz odpowiedni grade dla każdego pracownika.
SELECT e.first_name || ' ' || e.last_name AS full_name,
       e.job_id,
       d.department_name,
       e.salary,
       (SELECT j.grade from job_grades j WHERE salary BETWEEN j.min_salary AND j.max_salary) as job_grade
FROM employees e
JOIN departments d ON e.department_id = d.department_id;

-- 10: Wypisz imię nazwisko oraz zarobki dla osób które zarabiają więcej niż średnia wszystkich, uporządkuj malejąco według zarobków.
SELECT first_name, last_name, salary FROM employees WHERE salary > (SELECT AVG(salary) FROM employees)
ORDER BY salary DESC;

-- 11. Wypisz id imię i nazwisko osób, które pracują w departamencie z osobami mającymi w nazwisku „u”.
SELECT e.employee_id, e.first_name, e.last_name
FROM employees e
WHERE e.department_id IN (
    SELECT DISTINCT e1.department_id
    FROM employees e1
    WHERE e1.last_name LIKE '%u%'
);

-- 12. Znajdź pracowników, którzy pracują dłużej niż średnia długość zatrudnienia w firmie.
SELECT e.first_name, e.last_name, e.hire_date,
       ROUND(MONTHS_BETWEEN(SYSDATE, e.hire_date), 0) AS employment_duration
FROM employees e
WHERE MONTHS_BETWEEN(SYSDATE, e.hire_date) > (
    SELECT AVG(MONTHS_BETWEEN(SYSDATE, hire_date))
    FROM employees
);

-- 13. Wypisz nazwę departamentu, liczbę pracowników oraz średnie wynagrodzenie w każdym departamencie. Sortuj według liczby pracowników malejąco.
SELECT d.department_name, 
       COUNT(e.employee_id) AS employee_count, 
       ROUND(AVG(e.salary), 2) AS avg_salary
FROM departments d
JOIN employees e ON d.department_id = e.department_id
GROUP BY d.department_name
ORDER BY employee_count DESC;

-- 14. Wypisz imiona i nazwiska pracowników, którzy zarabiają mniej niż jakikolwiek pracownik w departamencie „IT”.
SELECT e.first_name, e.last_name, e.salary
FROM employees e
WHERE e.salary < (
    SELECT MIN(salary)
    FROM employees e
    JOIN departments d ON e.department_id = d.department_id
    WHERE d.department_name = 'IT'
);

-- 15. Znajdź departamenty, w których pracuje co najmniej jeden pracownik zarabiający więcej niż średnia pensja w całej firmie.
SELECT DISTINCT d.department_name
FROM employees e
JOIN departments d ON e.department_id = d.department_id
WHERE e.salary > (SELECT AVG(salary) FROM employees);

-- 16. Wypisz pięć najlepiej opłacanych stanowisk pracy wraz ze średnimi zarobkami.
SELECT j.job_title, ROUND(AVG(e.salary), 2) AS avg_salary
FROM employees e
JOIN jobs j ON e.job_id = j.job_id
GROUP BY j.job_title
ORDER BY avg_salary DESC
FETCH FIRST 5 ROWS ONLY;

-- 17. Dla każdego regionu, wypisz nazwę regionu, liczbę krajów oraz liczbę pracowników, którzy tam pracują.
SELECT r.region_name, 
       COUNT(DISTINCT c.country_id) AS country_count, 
       COUNT(e.employee_id) AS employee_count
FROM regions r
JOIN countries c ON r.region_id = c.region_id
JOIN locations l ON c.country_id = l.country_id
JOIN departments d ON l.location_id = d.location_id
JOIN employees e ON d.department_id = e.department_id
GROUP BY r.region_name
ORDER BY employee_count DESC;

-- 18. Podaj imiona i nazwiska pracowników, którzy zarabiają więcej niż ich menedżerowie.
SELECT e.first_name, e.last_name, e.salary AS employee_salary, 
       m.first_name AS manager_first_name, m.last_name AS manager_last_name, m.salary AS manager_salary
FROM employees e
JOIN employees m ON e.manager_id = m.employee_id
WHERE e.salary > m.salary;

-- 19. Policz, ilu pracowników zaczęło pracę w każdym miesiącu (bez względu na rok).
SELECT TO_CHAR(hire_date, 'Month', 'NLS_DATE_LANGUAGE=POLISH') AS month_name,
       COUNT(*) AS employee_count
FROM employees
GROUP BY TO_CHAR(hire_date, 'MM'), 
         TO_CHAR(hire_date, 'Month', 'NLS_DATE_LANGUAGE=POLISH')
ORDER BY TO_NUMBER(TO_CHAR(hire_date, 'MM'));


-- 20. Znajdź trzy departamenty z najwyższą średnią pensją i wypisz ich nazwę oraz średnie wynagrodzenie.
SELECT d.department_name, ROUND(AVG(e.salary), 2) AS avg_salary
FROM employees e
JOIN departments d ON e.department_id = d.department_id
GROUP BY d.department_name
ORDER BY avg_salary DESC
FETCH FIRST 3 ROWS ONLY;
