-- --------------------------------------------------------------------------
-- Wyzwalacze sprawdzające poprawność danych przy dodawaniu nowego rekordu
-- --------------------------------------------------------------------------

DELIMITER //

-- Tabela Owners
CREATE TRIGGER validate_owner_create
BEFORE INSERT ON Owners
FOR EACH ROW
BEGIN
    IF LENGTH(NEW.first_name) = 0 OR LENGTH(NEW.last_name) = 0 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Imię i nazwisko są wymagane.';
    END IF;

    IF NEW.phone_number IS NULL OR LENGTH(NEW.phone_number) < 7 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Numer telefonu jest nieprawidłowy.';
    END IF;

    IF NEW.email IS NOT NULL AND NOT NEW.email REGEXP '^[^@\\s]+@[^@\\s]+\\.[^@\\s]+$' THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Nieprawidłowy format adresu e-mail.';
    END IF;
END;
//


-- Tablera Animals
CREATE TRIGGER validate_animal_create
BEFORE INSERT ON Animals
FOR EACH ROW
BEGIN
    IF LENGTH(NEW.name) = 0 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Imię zwierzęcia jest wymagane.';
    END IF;

    IF NOT (NEW.sex IN ('Samiec', 'Samica')) THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Nieprawidłowa płeć (dozwolone: samiec, samica).';
    END IF;

    IF NOT (NEW.species IN ('Pies', 'Kot', 'Królik')) THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Nieprawidłowy gatunek (dozwolone: pies, kot, królik).';
    END IF;

    IF NOT (NEW.age IN ('Młody', 'Dorosły', 'Senior')) THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Nieprawidłowy wiek (dozwolone: młody, dorosły, senior).';
    END IF;

    IF NEW.energy_level IS NOT NULL AND NOT NEW.energy_level IN ('Kanapowiec', 'Aktywny', 'Bardzo aktywny') THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Nieprawidłowy poziom energii (kanapowiec, aktywny, bardzo aktywny)';
    END IF;
END;
//


-- Tabela Services
CREATE TRIGGER validate_service_create
BEFORE INSERT ON Services
FOR EACH ROW
BEGIN
    IF LENGTH(NEW.name) = 0 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Nazwa usługi jest wymagana.';
    END IF;
END;
//


-- Tabela Enclosures
CREATE TRIGGER validate_enclosure_create
BEFORE INSERT ON Enclosures
FOR EACH ROW
BEGIN
    IF LENGTH(NEW.symbol) = 0 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Symbol kojca jest wymagany.';
    END IF;

     IF NOT (NEW.species IN ('Pies', 'Kot', 'Królik')) THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Nieprawidłowy gatunek (dozwolone: pies, kot, królik).';
    END IF;
END;
//


-- Tabela Reservations
CREATE TRIGGER validate_reservation_create
BEFORE INSERT ON Reservations
FOR EACH ROW
BEGIN
    IF NEW.start_date >= NEW.end_date THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Data rozpoczęcia musi być przed datą zakończenia.';
    END IF;

    IF NOT NEW.status IN ('Potwierdzona', 'Zakończona', 'Anulowana') THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Nieprawidłowy status (dozwolone: potwierdzona, zakończona, anulowana).';
    END IF;
END;
//

DELIMITER ;
