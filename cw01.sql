-- ZADANIE 1
CREATE TABLE regions (
    region_id int not null primary key,
    region_name varchar(255) not null
);

CREATE TABLE countries (
    country_id int not null primary key,
    country_name varchar(255) not null,
    region_id int not null
);

CREATE TABLE locations (
    location_id int not null primary key,
    street_address varchar(255) not null,
    postal_code varchar(255) not null,
    city varchar(255) not null,
    state_province varchar(255) not null,
    country_id int not null
);

ALTER TABLE countries
ADD FOREIGN KEY (region_id) REFERENCES regions(region_id);

ALTER TABLE locations
ADD FOREIGN KEY (country_id) REFERENCES countries(country_id);

CREATE TABLE jobs (
    job_id int not null primary key,
    job_title varchar(255) not null,
    min_salary float,
    max_salary float
);

ALTER TABLE jobs
ADD CONSTRAINT chk_salary CHECK (max_salary - min_salary >= 2000);

CREATE TABLE job_history (
    employee_id int not null,
    start_date date not null,
    job_id int not null,
    department_id int not null,
    foreign key (job_id) references jobs(job_id)
);

CREATE TABLE departments (
    department_id int not null primary key,
    department_name varchar(255) not null,
    manager_id int not null,
    location_id int not null,
    foreign key (location_id) references locations(location_id)
);

CREATE TABLE employees (
    employee_id int not null primary key,
    first_name varchar(255) not null,
    last_name varchar(255) not null,
    email varchar(255),
    phone_number varchar(255) not null,
    hire_date date not null,
    job_id int not null,
    foreign key (job_id) references jobs(job_id),
    salary float not null,
    manager_id int,
    department_id int
);

ALTER TABLE job_history
ADD FOREIGN KEY (department_id) REFERENCES departments(department_id);

ALTER TABLE job_history
ADD FOREIGN KEY (employee_id) REFERENCES employees(employee_id);

ALTER TABLE departments
ADD FOREIGN KEY (manager_id) REFERENCES employees(employee_id);

ALTER TABLE employees ADD commission_pct float;

ALTER TABLE employees
ADD FOREIGN KEY (manager_id) REFERENCES employees(employee_id);

ALTER TABLE employees
ADD FOREIGN KEY (department_id) REFERENCES departments(department_id);

-- ZADANIE 2
INSERT ALL
    INTO jobs VALUES (1, 'Sprzątaczka', 3500, 6000)
    INTO jobs VALUES (2, 'Sekretarka', 4500, 7000)
    INTO jobs VALUES (3, 'Kucharka', 4500, 7000)
    INTO jobs VALUES (4, 'Magazynier', 4000, 6000)
SELECT * FROM DUAL;

-- ZADANIE 3
INSERT ALL
    INTO employees VALUES (1, 'Jan', 'Kowalski', 'jank@example.com', '111 111 111',  DATE '2025-03-06', 1, 4000, NULL, NULL, NULL)
    INTO employees VALUES (2, 'Aneta', 'Kowalska', 'anetak@example.com', '111 999 111',  DATE '2024-04-01', 2, 5000, NULL, NULL, NULL)
    INTO employees VALUES (3, 'Anna', 'Nowak', 'annan@example.com', '111 123 123',  DATE '2021-01-01', 3, 6000, NULL, NULL, NULL)
    INTO employees VALUES (4, 'Bartosz', 'Kruk', 'bartoszk@example.com', '123 555 111',  DATE '2025-03-06', 4, 5500, NULL, NULL, NULL)
SELECT * FROM DUAL;

-- ZADANIE 4
UPDATE employees SET manager_id = 1 WHERE employee_id = 2;
UPDATE employees SET manager_id = 1 WHERE employee_id = 3;

-- ZADANIE 5
UPDATE jobs
SET 
    min_salary = min_salary + 500,
    max_salary = max_salary + 500
WHERE 
    UPPER(job_title) LIKE '%B%' OR UPPER(job_title) LIKE '%S%';

-- ZADANIE 6
DELETE FROM jobs WHERE max_salary > 9000;

-- ZADANIE 7
DROP TABLE regions;
show recyclebin;
flashback TABLE "BIN$13ah36UmQtqakGIg0xh3FQ==$0" TO BEFORE DROP;