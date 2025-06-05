-- ------------
-- Procedury
-- ------------

DELIMITER //

-- -------------------------------------
-- Zwraca imię i nazwisko właściciela
-- -------------------------------------
CREATE PROCEDURE get_owner_name(
    IN p_id INT,
    OUT p_full_name VARCHAR(255)
)
BEGIN
    DECLARE temp_name VARCHAR(255) DEFAULT 'Brak właściciela';
    DECLARE CONTINUE HANDLER FOR NOT FOUND SET temp_name = 'Brak właściciela';

    SELECT CONCAT(first_name, ' ', last_name)
    INTO temp_name
    FROM Owners
    WHERE id = p_id;

    SET p_full_name = temp_name;
END //

-- -------------------------------------
-- Zwraca zwierzęta wybranego gatunku
-- -------------------------------------
CREATE PROCEDURE get_animals_by_species(
    IN p_species VARCHAR(50)
)
BEGIN
    IF p_species IS NULL OR p_species = '' THEN
        SELECT * FROM Animals;
    ELSE
        SELECT * FROM Animals WHERE species = p_species;
    END IF;
END //

-- -------------------------------------
-- Zwraca dostępność miejsc w hotelu
-- -------------------------------------
CREATE PROCEDURE check_enclosure_availability(
    IN species_name VARCHAR(50),
    IN start_date DATE,
    IN end_date DATE
)
BEGIN
    IF species_name IS NULL OR species_name = '' THEN
        SELECT 'Nie podano gatunku' AS error_message;
    ELSEIF start_date IS NULL OR end_date IS NULL THEN
        SELECT 'Nie podano daty rozpoczęcia lub zakończenia' AS error_message;
    ELSE
        SELECT e.id, e.symbol
        FROM Enclosures e
        WHERE e.species = species_name
          AND e.id NOT IN (
              SELECT enclosure_id
              FROM Reservations
              WHERE start_date <= end_date
                AND end_date >= start_date
                AND (
                    (start_date BETWEEN Reservations.start_date AND Reservations.end_date) OR
                    (end_date BETWEEN Reservations.start_date AND Reservations.end_date) OR
                    (Reservations.start_date BETWEEN start_date AND end_date) OR
                    (Reservations.end_date BETWEEN start_date AND end_date)
                )
          );
    END IF;
END //

-- -----------------------------------------
-- Zwraca historię rezerwacji właściciela
-- -----------------------------------------
CREATE PROCEDURE get_owner_reservation_history(IN owner_id_input INT)
BEGIN
    DECLARE owner_exists INT;

    SELECT COUNT(*) INTO owner_exists FROM Owners WHERE id = owner_id_input;

    IF owner_exists = 0 THEN
        SELECT 'Nie znaleziono właściciela' AS error_message;
    ELSE
        SELECT r.id AS reservation_id, a.name AS animal_name, r.start_date, r.end_date, r.status
        FROM Reservations r
        JOIN Animals a ON r.animal_id = a.id
        WHERE r.owner_id = owner_id_input
        ORDER BY r.start_date DESC;
    END IF;
END //

-- ---------------------------------------------------------------
-- Zwraca częstotliwość wykorzystywania usług dla danego okresu
-- ---------------------------------------------------------------
CREATE PROCEDURE service_usage(IN from_date DATE, IN to_date DATE)
BEGIN
    IF from_date IS NULL OR to_date IS NULL OR from_date > to_date THEN
        SELECT 'Nieprawidłowy zakres dat' AS error_message;
    ELSE
        SELECT s.name AS service_name, COUNT(rs.id) AS usage_count
        FROM Reservation_Services rs
        JOIN Services s ON rs.service_id = s.id
        JOIN Reservations r ON rs.reservation_id = r.id
        WHERE r.start_date BETWEEN from_date AND to_date
        GROUP BY s.name
        ORDER BY usage_count DESC;
    END IF;
END //

DELIMITER ;
