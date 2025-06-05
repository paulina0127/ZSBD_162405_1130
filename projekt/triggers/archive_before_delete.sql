-- --------------------------------------------
-- Wyzwalacze archiwizujące usunięte rekordy
-- --------------------------------------------

DELIMITER //

-- Tabela Owners
CREATE TRIGGER archive_owner_before_delete
BEFORE DELETE ON Owners
FOR EACH ROW
BEGIN
    INSERT INTO Owners_Archived
    SELECT * FROM Owners WHERE id = OLD.id;
END;
//


-- Tabela Animals
CREATE TRIGGER archive_animal_before_delete
BEFORE DELETE ON Animals
FOR EACH ROW
BEGIN
    INSERT INTO Animals_Archived
    SELECT * FROM Animals WHERE id = OLD.id;
END;
//


-- Tabela Services
CREATE TRIGGER archive_service_before_delete
BEFORE DELETE ON Services
FOR EACH ROW
BEGIN
    INSERT INTO Services_Archived
    SELECT * FROM Services WHERE id = OLD.id;
END;
//


-- Tabela Enclosures
CREATE TRIGGER archive_enclosure_before_delete
BEFORE DELETE ON Enclosures
FOR EACH ROW
BEGIN
    INSERT INTO Enclosures_Archived
    SELECT * FROM Enclosures WHERE id = OLD.id;
END;
//


-- Tabela Reservations
CREATE TRIGGER archive_reservation_before_delete
BEFORE DELETE ON Reservations
FOR EACH ROW
BEGIN
    INSERT INTO Reservations_Archived
    SELECT * FROM Reservations WHERE id = OLD.id;
END;
//

-- Tabele Reservation Services
CREATE TRIGGER archive_reservation_services_before_delete
BEFORE DELETE ON Reservation_Services
FOR EACH ROW
BEGIN
    INSERT INTO Reservation_Services_Archived
    SELECT * FROM Reservation_Services WHERE id = OLD.id;
END;
//

DELIMITER ;
