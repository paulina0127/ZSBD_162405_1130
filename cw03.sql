-- 1. Utwórz widok v_wysokie_pensje, dla tabeli employees który pokaże wszystkich pracowników zarabiających więcej niż 6000.
CREATE VIEW v_wysokie_pensje AS SELECT employee_id, first_name, last_name, salary FROM employees WHERE salary > 6000;

-- 2. Zmień definicję widoku v_wysokie_pensje aby pokazywał tylko pracowników zarabiających powyżej 12000.
CREATE OR REPLACE VIEW v_wysokie_pensje AS SELECT employee_id, first_name, last_name, salary FROM employees WHERE salary > 12000;

-- 3. Usuń widok v_wysokie_pensje.
DROP VIEW v_wysokie_pensje;

-- 4. Stwórz widok dla tabeli employees zawierający: employee_id, last_name, first_name, dla pracowników z departamentu o nazwie Finance.
CREATE VIEW v_finance_employees AS SELECT e.employee_id, e.first_name, e.last_name FROM employees e JOIN departments d ON e.department_id = d.department_id WHERE d.department_name = 'Finance';

-- 5. Stwórz widok dla tabeli employees zawierający: employee_id, last_name, first_name, salary, job_id, email, hire_date dla pracowników mających zarobki pomiędzy 5000 a 12000.
CREATE VIEW v_high_salary_employees AS SELECT employee_id, first_name, last_name, salary, job_id, email, hire_date FROM employees WHERE salary BETWEEN 5000 and 12000;

-- 6. Poprzez utworzone widoki sprawdź czy możesz:
-- a. dodać nowego pracownika
INSERT INTO v_finance_employees (employee_id, first_name, last_name) VALUES (207, 'Kruk', 'Jan');

-- b. edytować pracownika
UPDATE v_high_salary_employees
SET salary = 12000
WHERE employee_id = 103;

-- c. usunąć pracownika
DELETE FROM v_high_salary_employees
WHERE employee_id = 104;

-- 7. Stwórz widok, który dla każdego działu który zatrudnia przynajmniej 4 pracowników wyświetli: identykator działu, nazwę działu, liczbę pracowników w dziale, średnią pensja w dziale i najwyższa pensja w dziale.
CREATE VIEW v_departments AS SELECT d.department_id, d.department_name, COUNT(e.employee_id) as employee_count, ROUND(AVG(e.salary), 2) as avg_salary, MAX(e.salary) as max_salary FROM departments d JOIN employees e ON d.department_id = e.department_id GROUP BY d.department_id, d.department_name HAVING COUNT(e.employee_id) >= 4;

-- a. Sprawdź czy możesz dodać dane do tego widoku.
INSERT INTO v_departments VALUES (10, 'Administration', 20, 8000, 12000);
SELECT * FROM USER_UPDATABLE_COLUMNS WHERE TABLE_NAME = 'v_departments';

-- 8. Stwórz analogiczny widok z zadania 3 z dodaniem warunku ‘WITH CHECK OPTION’.
CREATE VIEW v_new_high_salary_employees AS SELECT employee_id, first_name, last_name, salary, job_id, email, hire_date FROM employees WHERE salary BETWEEN 5000 and 12000 WITH CHECK OPTION;

-- a. Sprawdź czy możesz:
-- i. dodać pracownika z zarobkami pomiędzy 5000 a 12000.
INSERT INTO v_new_high_salary_employees VALUES (207, 'Jan', 'Kowalski', 5500, 'HR_REP', 'jank', DATE '2025-03-06');

-- ii. dodać pracownika z zarobkami powyżej 12000.
INSERT INTO v_new_high_salary_employees VALUES (208, 'Jan', 'Kowalski', 13000, 'HR_REP', 'jank', DATE '2025-03-06');

SELECT * from V_NEW_HIGH_SALARY_EMPLOYEES;

-- 9. Utwórz widok zmaterializowany v_managerowie, który pokaże tylko menedżerów w raz z nazwami ich działów.
CREATE MATERIALIZED VIEW v_managerowie AS
SELECT DISTINCT e.employee_id, e.first_name, e.last_name, d.department_name FROM employees e JOIN departments d ON e.department_id = d.department_id WHERE e.employee_id IN (SELECT DISTINCT manager_id FROM employees WHERE manager_id IS NOT NULL);

-- 10. Stwórz widok v_najlepiej_oplacani, który zawiera tylko 10 najlepiej opłacanych pracowników.
CREATE VIEW v_najlepiej_oplacani AS SELECT employee_id, first_name, last_name, salary from employees ORDER BY salary DESC FETCH FIRST 10 ROWS ONLY;