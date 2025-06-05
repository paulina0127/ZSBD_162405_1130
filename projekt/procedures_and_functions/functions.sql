-- ----------
-- Funkcje 
-- ----------

DELIMITER //

-- --------------------------------------------------------
-- Funkcja zwracająca nazwę najbardziej popularną usługę
-- --------------------------------------------------------
CREATE FUNCTION get_most_used_service()
RETURNS VARCHAR(255)
DETERMINISTIC
READS SQL DATA
BEGIN
    DECLARE most_used_service VARCHAR(255) DEFAULT 'Brak danych';
    DECLARE CONTINUE HANDLER FOR NOT FOUND SET most_used_service = 'Brak danych';

    SELECT name INTO most_used_service
    FROM (
        SELECT s.name,
               COUNT(*) AS usage_count,
               RANK() OVER (ORDER BY COUNT(*) DESC) AS usage_rank
        FROM Reservation_Services rs
        JOIN Services s ON rs.service_id = s.id
        GROUP BY s.name
    ) ranked
    WHERE usage_rank = 1
    LIMIT 1;

    RETURN most_used_service;
END //


-- ----------------------------------------------------------
-- Funkcja zwracająca ile razy usługa została wykorzystana
-- ----------------------------------------------------------
CREATE FUNCTION get_service_usage_count(p_service_id INT)
RETURNS INT
DETERMINISTIC
READS SQL DATA
BEGIN
    DECLARE result INT DEFAULT 0;
    DECLARE service_exists INT;

    SELECT COUNT(*) INTO service_exists FROM Services WHERE id = p_service_id;

    IF service_exists = 0 THEN
        RETURN -1; -- Nie ma takiej usługi
    END IF;

    SELECT COUNT(*) INTO result
    FROM Reservation_Services
    WHERE service_id = p_service_id;

    RETURN result;
END //


-- ------------------------------------------------
-- Funkcja zwracająca ilość zwierząt właściciela
-- ------------------------------------------------
CREATE FUNCTION count_animals_by_owner(p_owner_id INT)
RETURNS INT
DETERMINISTIC
BEGIN
    DECLARE animal_count INT DEFAULT 0;
    DECLARE owner_exists INT;

    SELECT COUNT(*) INTO owner_exists FROM Owners WHERE id = p_owner_id;

    IF owner_exists = 0 THEN
        RETURN -1; -- Nie ma takiego właściciela
    END IF;

    SELECT COUNT(*) INTO animal_count
    FROM Animals
    WHERE owner_id = p_owner_id;

    RETURN animal_count;
END //


-- -----------------------------------------------------------------------
-- Funkcja zwracająca liczbę powracających właścicieli (rezerwacje > 1)
-- -----------------------------------------------------------------------
CREATE FUNCTION get_returning_owners_count()
RETURNS INT
DETERMINISTIC
BEGIN
    DECLARE count_returning INT;

    SELECT COUNT(*) INTO count_returning
    FROM (
        SELECT owner_id
        FROM Reservations
        GROUP BY owner_id
        HAVING COUNT(*) > 1
    ) AS subquery;

    RETURN count_returning;
END //


-- ----------------------------------------------------------
-- Funkcja zwracająca czy właściciel ma aktywną rezerwację
-- ----------------------------------------------------------
CREATE FUNCTION has_active_reservation(p_owner_id INT)
RETURNS VARCHAR(5)
DETERMINISTIC
BEGIN
    DECLARE result VARCHAR(5) DEFAULT 'NIE';
    DECLARE owner_exists INT;

    SELECT COUNT(*) INTO owner_exists FROM Owners WHERE id = p_owner_id;

    IF owner_exists = 0 THEN
        RETURN 'NIE'; -- Brak takiego właściciela
    END IF;

    IF EXISTS (
        SELECT 1 FROM Reservations
        WHERE owner_id = p_owner_id
          AND CURDATE() BETWEEN start_date AND end_date
    ) THEN
        SET result = 'TAK';
    END IF;

    RETURN result;
END //

DELIMITER ;
