-- Utworzenie bazy danych
CREATE DATABASE IF NOT EXISTS Animal_Hotel;
USE Animal_Hotel;

-- Utworzenie tabel
CREATE TABLE IF NOT EXISTS Owners (
    id INT AUTO_INCREMENT PRIMARY KEY,
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    email VARCHAR(255) DEFAULT NULL,
    phone_number VARCHAR(20) NOT NULL
);

CREATE TABLE IF NOT EXISTS Animals (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    sex VARCHAR(15) NOT NULL,
    species VARCHAR(50) NOT NULL,
    age VARCHAR(15),
    energy_level VARCHAR(15),
    is_friendly BOOLEAN DEFAULT 0,
    notes TEXT DEFAULT NULL,
    owner_id INT NOT NULL,
    FOREIGN KEY (owner_id) REFERENCES Owners(id) ON DELETE CASCADE
);

CREATE TABLE IF NOT EXISTS Services (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(255) NOT NULL UNIQUE,
    description TEXT DEFAULT NULL
);

CREATE TABLE IF NOT EXISTS Enclosures (
    id INT AUTO_INCREMENT PRIMARY KEY,
    symbol VARCHAR(50) NOT NULL UNIQUE,
    species VARCHAR(50) NOT NULL
);

CREATE TABLE IF NOT EXISTS Reservations (
    id INT AUTO_INCREMENT PRIMARY KEY,
    start_date DATE NOT NULL,
    end_date DATE NOT NULL,
    status VARCHAR(50) NOT NULL,
    notes TEXT DEFAULT NULL,
    enclosure_id INT DEFAULT NULL,
    owner_id INT NOT NULL,
    animal_id INT NOT NULL,
    FOREIGN KEY (enclosure_id) REFERENCES Enclosures(id) ON DELETE SET NULL,
    FOREIGN KEY (owner_id) REFERENCES Owners(id) ON DELETE CASCADE,
    FOREIGN KEY (animal_id) REFERENCES Animals(id) ON DELETE CASCADE
);

CREATE TABLE IF NOT EXISTS Reservation_Services (
    id INT AUTO_INCREMENT PRIMARY KEY,
    reservation_id INT NOT NULL,
    service_id INT NOT NULL,
    UNIQUE (reservation_id, service_id),
    FOREIGN KEY (reservation_id) REFERENCES Reservations(id) ON DELETE CASCADE,
    FOREIGN KEY (service_id) REFERENCES Services(id) ON DELETE CASCADE
);

-- Utworzenie tabel archiwalnych
CREATE TABLE IF NOT EXISTS Owners_Archived LIKE Owners;
CREATE TABLE IF NOT EXISTS Animals_Archived LIKE Animals;
CREATE TABLE IF NOT EXISTS Services_Archived LIKE Services;
CREATE TABLE IF NOT EXISTS Enclosures_Archived LIKE Enclosures;
CREATE TABLE IF NOT EXISTS Reservations_Archived LIKE Reservations;
CREATE TABLE IF NOT EXISTS Reservation_Services_Archived LIKE Reservation_Services;

-- Utworzenie dziennika zmian
CREATE TABLE IF NOT EXISTS Change_Logs (
    log_id INT AUTO_INCREMENT PRIMARY KEY,
    table_name VARCHAR(50),
    record_id INT,
    action_type VARCHAR(10),         -- 'INSERT', 'UPDATE', 'DELETE'
    action_time DATETIME DEFAULT CURRENT_TIMESTAMP,
    changed_by VARCHAR(100),         -- użytkownik, CURRENT_USER()
    old_data TEXT,
    new_data TEXT
);
