-- -----------------------------------
-- Funkcje wyświetlające statystyki
-- -----------------------------------

DELIMITER //

-- -----------------------------------
-- Statystyki miesięczne rezerwacji
-- -----------------------------------
CREATE PROCEDURE get_reservation_stats(
    IN period VARCHAR(10),
    IN status_filter VARCHAR(50),
    IN species_filter VARCHAR(50)
)
BEGIN
    IF period = 'month' THEN
        SELECT
            DATE_FORMAT(r.start_date, '%Y-%m') AS period,
            COUNT(*) AS total_reservations,
            COUNT(DISTINCT r.owner_id) AS unique_owners,
            COUNT(DISTINCT r.animal_id) AS unique_animals,
            SUM(DATEDIFF(r.end_date, r.start_date)) AS total_reserved_days,
            AVG(DATEDIFF(r.end_date, r.start_date)) AS avg_duration_days,
            COUNT(rs.service_id) AS total_services_used
        FROM Reservations r
        LEFT JOIN Reservation_Services rs ON r.id = rs.reservation_id
        JOIN Animals a ON r.animal_id = a.id
        WHERE (status_filter IS NULL OR r.status = status_filter)
          AND (species_filter IS NULL OR a.species = species_filter)
        GROUP BY DATE_FORMAT(r.start_date, '%Y-%m')
        ORDER BY period;

    ELSEIF period = 'quarter' THEN
    SELECT
        CONCAT(year, '-Q', quarter) AS period,
        COUNT(*) AS total_reservations,
        COUNT(DISTINCT owner_id) AS unique_owners,
        COUNT(DISTINCT animal_id) AS unique_animals,
        SUM(duration_days) AS total_reserved_days,
        AVG(duration_days) AS avg_duration_days,
        COUNT(service_id) AS total_services_used
    FROM (
        SELECT
            r.id,
            r.owner_id,
            r.animal_id,
            rs.service_id,
            YEAR(r.start_date) AS year,
            QUARTER(r.start_date) AS quarter,
            DATEDIFF(r.end_date, r.start_date) AS duration_days,
            r.status,
            a.species
        FROM Reservations r
        LEFT JOIN Reservation_Services rs ON r.id = rs.reservation_id
        JOIN Animals a ON r.animal_id = a.id
        WHERE (status_filter IS NULL OR r.status = status_filter)
          AND (species_filter IS NULL OR a.species = species_filter)
    ) AS sub
    GROUP BY year, quarter
    ORDER BY year, quarter;

    ELSEIF period = 'year' THEN
        SELECT
            YEAR(r.start_date) AS period,
            COUNT(*) AS total_reservations,
            COUNT(DISTINCT r.owner_id) AS unique_owners,
            COUNT(DISTINCT r.animal_id) AS unique_animals,
            SUM(DATEDIFF(r.end_date, r.start_date)) AS total_reserved_days,
            AVG(DATEDIFF(r.end_date, r.start_date)) AS avg_duration_days,
            COUNT(rs.service_id) AS total_services_used
        FROM Reservations r
        LEFT JOIN Reservation_Services rs ON r.id = rs.reservation_id
        JOIN Animals a ON r.animal_id = a.id
        WHERE (status_filter IS NULL OR r.status = status_filter)
          AND (species_filter IS NULL OR a.species = species_filter)
        GROUP BY YEAR(r.start_date)
        ORDER BY period;

    ELSE
        SELECT 'Niepoprawny parametr. Użyj "month", "quarter" lub "year".' AS error_message;
    END IF;
END //


-- Statystyki wykorzystania usług
CREATE PROCEDURE get_service_usage_stats(
    IN period VARCHAR(10)
)
BEGIN
    IF period = 'month' THEN
        SELECT
            DATE_FORMAT(r.start_date, '%Y-%m') AS period,
            s.name AS service_name,
            COUNT(rs.id) AS times_used,
            ROUND(COUNT(rs.id) / COUNT(DISTINCT r.id), 2) AS avg_per_reservation
        FROM Reservations r
        LEFT JOIN Reservation_Services rs ON r.id = rs.reservation_id
        LEFT JOIN Services s ON rs.service_id = s.id
        WHERE s.name IS NOT NULL
        GROUP BY DATE_FORMAT(r.start_date, '%Y-%m'), s.name
        ORDER BY DATE_FORMAT(r.start_date, '%Y-%m'), s.name;

    ELSEIF period = 'quarter' THEN
    SELECT CONCAT(year, '-Q', quarter) AS period, service_name, times_used, avg_per_reservation FROM (
        SELECT
            YEAR(r.start_date) AS year,
            QUARTER(r.start_date) AS quarter,
            s.name AS service_name,
            COUNT(rs.id) AS times_used,
            ROUND(COUNT(rs.id) / COUNT(DISTINCT r.id), 2) AS avg_per_reservation
        FROM Reservations r
        LEFT JOIN Reservation_Services rs ON r.id = rs.reservation_id
        LEFT JOIN Services s ON rs.service_id = s.id
        WHERE s.name IS NOT NULL
        GROUP BY YEAR(r.start_date), QUARTER(r.start_date), s.name
        ORDER BY YEAR(r.start_date), QUARTER(r.start_date), times_used DESC
    ) AS sub;
        

    ELSEIF period = 'year' THEN
        SELECT
            YEAR(r.start_date) AS period,
            s.name AS service_name,
            COUNT(rs.id) AS times_used,
            ROUND(COUNT(rs.id) / COUNT(DISTINCT r.id), 2) AS avg_per_reservation
        FROM Reservations r
        LEFT JOIN Reservation_Services rs ON r.id = rs.reservation_id
        LEFT JOIN Services s ON rs.service_id = s.id
        WHERE s.name IS NOT NULL
        GROUP BY YEAR(r.start_date), s.name
        ORDER BY YEAR(r.start_date), s.name;

        ELSE
            SELECT 'Niepoprawny parametr. Użyj "month", "quarter" lub "year".' AS error_message;
        END IF;
    END //


DELIMITER ;
