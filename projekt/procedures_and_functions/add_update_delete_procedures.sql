-- --------------------------------------------------------------------
-- Procedury dla wszystkich tabel: dodawanie, aktualizacja, usuwanie
-- --------------------------------------------------------------------

DELIMITER //

-- ----------------
-- Tabela Owners
-- ----------------

-- Dodanie nowego rekordu
CREATE PROCEDURE add_owner(
    IN p_first_name VARCHAR(50),
    IN p_last_name VARCHAR(50),
    IN p_email VARCHAR(255),
    IN p_phone VARCHAR(20)
)
BEGIN
    INSERT INTO Owners (first_name, last_name, email, phone_number)
    VALUES (p_first_name, p_last_name, p_email, p_phone);
END;
//

-- Aktualizacja pól: email, phone number
CREATE PROCEDURE update_owner_email(
    IN p_id INT,
    IN p_email VARCHAR(255)
)
BEGIN
    UPDATE Owners
    SET email = p_email
    WHERE id = p_id;
END;
//

CREATE PROCEDURE update_owner_phone(
    IN p_id INT,
    IN p_phone VARCHAR(20)
)
BEGIN
    UPDATE Owners
    SET phone_number = p_phone
    WHERE id = p_id;
END;
//

-- Usunięcie rekordu
CREATE PROCEDURE delete_owner(
    IN p_id INT
)
BEGIN
    DELETE FROM Owners WHERE id = p_id;
END;
//

-- -----------------
-- Tabela Animals
-- -----------------

-- Dodanie nowego rekordu
CREATE PROCEDURE add_animal(
    IN p_name VARCHAR(255),
    IN p_sex VARCHAR(15),
    IN p_species VARCHAR(50),
    IN p_age VARCHAR(15),
    IN p_energy_level VARCHAR(15),
    IN p_is_friendly BOOLEAN,
    IN p_notes TEXT,
    IN p_owner_id INT
)
BEGIN
    INSERT INTO Animals (name, sex, species, age, energy_level, is_friendly, notes, owner_id)
    VALUES (p_name, p_sex, p_species, p_age, p_energy_level, p_is_friendly, p_notes, p_owner_id);
END;
//

-- Aktualizacja pól: age, energy level, is friendly, notes
CREATE PROCEDURE update_animal_age(
    IN p_id INT,
    IN p_age VARCHAR(15)
)
BEGIN
    UPDATE Animals
    SET age = p_age
    WHERE id = p_id;
END;
//

CREATE PROCEDURE update_animal_energy_level(
    IN p_id INT,
    IN p_energy_level VARCHAR(15)
)
BEGIN
    UPDATE Animals
    SET energy_level = p_energy_level
    WHERE id = p_id;
END;
//

CREATE PROCEDURE update_animal_is_friendly(
    IN p_id INT,
    IN p_is_friendly BOOLEAN
)
BEGIN
    UPDATE Animals
    SET is_friendly = p_is_friendly
    WHERE id = p_id;
END;
//

CREATE PROCEDURE update_animal_notes(
    IN p_id INT,
    IN p_notes TEXT
)
BEGIN
    UPDATE Animals
    SET notes = p_notes
    WHERE id = p_id;
END;
//

-- Usunięcie rekordu
CREATE PROCEDURE delete_animal(
    IN p_id INT
)
BEGIN
    DELETE FROM Animals WHERE id = p_id;
END;
//


-- ------------------
-- Tabela Services
-- ------------------

-- Dodanie nowego rekordu
CREATE PROCEDURE add_service(
    IN p_name VARCHAR(255),
    IN p_description TEXT
)
BEGIN
    INSERT INTO Services (name, description)
    VALUES (p_name, p_description);
END;
//

-- Aktualizacja pól: description
CREATE PROCEDURE update_service_description(
    IN p_id INT,
    IN p_description TEXT
)
BEGIN
    UPDATE Services
    SET description = p_description
    WHERE id = p_id;
END;
//

-- Usunięcie rekordu
CREATE PROCEDURE delete_service(
    IN p_id INT
)
BEGIN
    DELETE FROM Services WHERE id = p_id;
END;
//

-- --------------------
-- Tabela Enclosures
-- --------------------

-- Dodanie nowego rekordu
CREATE PROCEDURE add_enclosure(
    IN p_symbol VARCHAR(50),
    IN p_species VARCHAR(50)
)
BEGIN
    INSERT INTO Enclosures (symbol, species)
    VALUES (p_symbol, p_species);
END;
//

-- Usunięcie rekordu
CREATE PROCEDURE delete_enclosure(
    IN p_id INT
)
BEGIN
    DELETE FROM Enclosures WHERE id = p_id;
END;
//

-- ----------------------
-- Tabela Reservations
-- ----------------------

-- Dodanie nowego rekordu
CREATE PROCEDURE add_reservation(
    IN p_start_date DATE,
    IN p_end_date DATE,
    IN p_status VARCHAR(50),
    IN p_notes TEXT,
    IN p_enclosure_id INT,
    IN p_owner_id INT,
    IN p_animal_id INT
)
BEGIN
    INSERT INTO Reservations (start_date, end_date, status, notes, enclosure_id, owner_id, animal_id)
    VALUES (p_start_date, p_end_date, p_status, p_notes, p_enclosure_id, p_owner_id, p_animal_id);
END;
//

-- Aktualizacja pól: start date & end date, status, notes, enclosure id
CREATE PROCEDURE update_reservation_dates(
    IN p_id INT,
    IN p_start_date DATE,
    IN p_end_date DATE
)
BEGIN
    UPDATE Reservations
    SET start_date = p_start_date,
        end_date = p_end_date
    WHERE id = p_id;
END;
//

CREATE PROCEDURE update_reservation_status(
    IN p_id INT,
    IN p_status TEXT
)
BEGIN
    UPDATE Reservations
    SET status = p_status
    WHERE id = p_id;
END;
//

CREATE PROCEDURE update_reservation_notes(
    IN p_id INT,
    IN p_notes TEXT
)
BEGIN
    UPDATE Reservations
    SET notes = p_notes
    WHERE id = p_id;
END;
//

CREATE PROCEDURE update_reservation_enclosure(
    IN p_id INT,
    IN p_enclosure_id INT
)
BEGIN
    UPDATE Reservations
    SET enclosure_id = p_enclosure_id
    WHERE id = p_id;
END;
//

-- Usunięcie rekordu
CREATE PROCEDURE delete_reservation(
    IN p_id INT
)
BEGIN
    DELETE FROM Reservations WHERE id = p_id;
END;
//

-- ------------------------------
-- Tabela Reservation_Services
-- ------------------------------

-- Dodanie nowego rekordu
CREATE PROCEDURE add_reservation_service(
    IN p_reservation_id INT,
    IN p_service_id INT
)
BEGIN
    INSERT INTO Reservation_Services (reservation_id, service_id)
    VALUES (p_reservation_id, p_service_id);
END;
//

-- Usunięcie rekordu
CREATE PROCEDURE delete_reservation_service(
    IN p_id INT
)
BEGIN
    DELETE FROM Reservation_Services WHERE id = p_id;
END;
//

DELIMITER ;