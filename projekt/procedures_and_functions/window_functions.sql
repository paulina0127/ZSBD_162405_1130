-- --------------------
-- Funkcje okienkowe
-- --------------------

DELIMITER //

-- -----------------------------------
-- Rezerwacje dla danego zwierzęcia
-- -----------------------------------
CREATE PROCEDURE get_animal_reservations (
    IN p_animal_id INT
)
BEGIN
    DECLARE animal_exists INT;

    SELECT COUNT(*) INTO animal_exists FROM Animals WHERE id = p_animal_id;

    IF animal_exists = 0 THEN
        SELECT 'Nie znaleziono zwierzęcia o podanym ID' AS error_message;
    ELSE
        SELECT
            r.id AS reservation_id,
            r.start_date,
            r.end_date,
            DATEDIFF(r.end_date, r.start_date) AS duration_days,
            r.status,
            a.name AS animal_name,
            o.first_name,
            o.last_name,
            COUNT(*) OVER (PARTITION BY r.owner_id) AS total_reservations_by_owner
        FROM Reservations r
        JOIN Animals a ON r.animal_id = a.id
        JOIN Owners o ON r.owner_id = o.id
        WHERE a.id = p_animal_id;
    END IF;
END //

-- -----------------------------------------------
-- Średnia liczba dni rezerwacji na właściciela 
-- -----------------------------------------------
CREATE PROCEDURE get_owner_reservation_days()
BEGIN
    IF (SELECT COUNT(*) FROM Reservations) = 0 THEN
        SELECT 'Brak rezerwacji w systemie' AS info;
    ELSE
        SELECT
            r.owner_id,
            o.first_name,
            o.last_name,
            AVG(DATEDIFF(r.end_date, r.start_date)) OVER (PARTITION BY r.owner_id) AS avg_reservation_days
        FROM Reservations r
        JOIN Owners o ON o.id = r.owner_id;
    END IF;
END //

-- -----------------------------------------
-- Ranking właścicieli wg liczby zwierząt
-- -----------------------------------------
CREATE PROCEDURE get_owner_ranking()
BEGIN
    IF (SELECT COUNT(*) FROM Owners) = 0 THEN
        SELECT 'Brak właścicieli w systemie' AS info;
    ELSE
        SELECT 
            o.id AS owner_id,
            CONCAT(o.first_name, ' ', o.last_name) AS owner_name,
            COUNT(a.id) AS animal_count,
            RANK() OVER (ORDER BY COUNT(a.id) DESC) AS owner_rank
        FROM Owners o
        LEFT JOIN Animals a ON a.owner_id = o.id
        GROUP BY o.id;
    END IF;
END //

DELIMITER ;
