-- -------------------------------------------
-- Wyzwalacze do logowania zmian w tabelach 
-- -------------------------------------------

DELIMITER //

-- ----------------
-- Tabela Owners
-- ----------------
CREATE TRIGGER log_owners_insert AFTER INSERT ON Owners FOR EACH ROW
BEGIN
    INSERT INTO Change_Logs (table_name, record_id, action_type, changed_by, new_data)
    VALUES ('Owners', NEW.id, 'INSERT', CURRENT_USER(), CONCAT_WS(',', 'first_name=', NEW.first_name, 'last_name=', NEW.last_name, 'email=', NEW.email, 'phone_number=', NEW.phone_number));
END;
//

CREATE TRIGGER log_owners_update BEFORE UPDATE ON Owners FOR EACH ROW
BEGIN
    INSERT INTO Change_Logs (table_name, record_id, action_type, changed_by, old_data, new_data)
    VALUES ('Owners', OLD.id, 'UPDATE', CURRENT_USER(), CONCAT_WS(',', 'first_name=', OLD.first_name, 'last_name=', OLD.last_name, 'email=', OLD.email, 'phone_number=', OLD.phone_number), CONCAT_WS(',', 'first_name=', NEW.first_name, 'last_name=', NEW.last_name, 'email=', NEW.email, 'phone_number=', NEW.phone_number));
END;
//

CREATE TRIGGER log_owners_delete AFTER DELETE ON Owners FOR EACH ROW
BEGIN
    INSERT INTO Change_Logs (table_name, record_id, action_type, changed_by, old_data)
    VALUES ('Owners', OLD.id, 'DELETE', CURRENT_USER(), CONCAT_WS(',', 'first_name=', OLD.first_name, 'last_name=', OLD.last_name, 'email=', OLD.email, 'phone_number=', OLD.phone_number));
END;
//

-- -----------------
-- Tabela Animals
-- -----------------
CREATE TRIGGER log_animals_insert AFTER INSERT ON Animals FOR EACH ROW
BEGIN
    INSERT INTO Change_Logs (table_name, record_id, action_type, changed_by, new_data)
    VALUES ('Animals', NEW.id, 'INSERT', CURRENT_USER(), CONCAT_WS(',', 'name=', NEW.name, 'sex=', NEW.sex, 'species=', NEW.species, 'age=', NEW.age, 'energy_level=', NEW.energy_level, 'is_friendly=', NEW.is_friendly, 'notes=', NEW.notes, 'owner_id=', NEW.owner_id));
END;
//

CREATE TRIGGER log_animals_update BEFORE UPDATE ON Animals FOR EACH ROW
BEGIN
    INSERT INTO Change_Logs (table_name, record_id, action_type, changed_by, old_data, new_data)
    VALUES ('Animals', OLD.id, 'UPDATE', CURRENT_USER(), CONCAT_WS(',', 'name=', OLD.name, 'sex=', OLD.sex, 'species=', OLD.species, 'age=', OLD.age, 'energy_level=', OLD.energy_level, 'is_friendly=', OLD.is_friendly, 'notes=', OLD.notes, 'owner_id=', OLD.owner_id), CONCAT_WS(',', 'name=', NEW.name, 'sex=', NEW.sex, 'species=', NEW.species, 'age=', NEW.age, 'energy_level=', NEW.energy_level, 'is_friendly=', NEW.is_friendly, 'notes=', NEW.notes, 'owner_id=', NEW.owner_id));
END;
//

CREATE TRIGGER log_animals_delete AFTER DELETE ON Animals FOR EACH ROW
BEGIN
    INSERT INTO Change_Logs (table_name, record_id, action_type, changed_by, old_data)
    VALUES ('Animals', OLD.id, 'DELETE', CURRENT_USER(), CONCAT_WS(',', 'name=', OLD.name, 'sex=', OLD.sex, 'species=', OLD.species, 'age=', OLD.age, 'energy_level=', OLD.energy_level, 'is_friendly=', OLD.is_friendly, 'notes=', OLD.notes, 'owner_id=', OLD.owner_id));
END;
//

-- ------------------
-- Tabela Services
-- ------------------
CREATE TRIGGER log_services_insert AFTER INSERT ON Services FOR EACH ROW
BEGIN
    INSERT INTO Change_Logs (table_name, record_id, action_type, changed_by, new_data)
    VALUES ('Services', NEW.id, 'INSERT', CURRENT_USER(), CONCAT_WS(',', 'name=', NEW.name, 'description=', NEW.description));
END;
//

CREATE TRIGGER log_services_update BEFORE UPDATE ON Services FOR EACH ROW
BEGIN
    INSERT INTO Change_Logs (table_name, record_id, action_type, changed_by, old_data, new_data)
    VALUES ('Services', OLD.id, 'UPDATE', CURRENT_USER(), CONCAT_WS(',', 'name=', OLD.name, 'description=', OLD.description), CONCAT_WS(',', 'name=', NEW.name, 'description=', NEW.description));
END;
//

CREATE TRIGGER log_services_delete AFTER DELETE ON Services FOR EACH ROW
BEGIN
    INSERT INTO Change_Logs (table_name, record_id, action_type, changed_by, old_data)
    VALUES ('Services', OLD.id, 'DELETE', CURRENT_USER(), CONCAT_WS(',', 'name=', OLD.name, 'description=', OLD.description));
END;
//

-- --------------------
-- Tabela Enclosures
-- --------------------
CREATE TRIGGER log_enclosures_insert AFTER INSERT ON Enclosures FOR EACH ROW
BEGIN
    INSERT INTO Change_Logs (table_name, record_id, action_type, changed_by, new_data)
    VALUES ('Enclosures', NEW.id, 'INSERT', CURRENT_USER(), CONCAT_WS(',', 'symbol=', NEW.symbol, 'species=', NEW.species));
END;
//

CREATE TRIGGER log_enclosures_update BEFORE UPDATE ON Enclosures FOR EACH ROW
BEGIN
    INSERT INTO Change_Logs (table_name, record_id, action_type, changed_by, old_data, new_data)
    VALUES ('Enclosures', OLD.id, 'UPDATE', CURRENT_USER(), CONCAT_WS(',', 'symbol=', OLD.symbol, 'species=', OLD.species), CONCAT_WS(',', 'symbol=', NEW.symbol, 'species=', NEW.species));
END;
//

CREATE TRIGGER log_enclosures_delete AFTER DELETE ON Enclosures FOR EACH ROW
BEGIN
    INSERT INTO Change_Logs (table_name, record_id, action_type, changed_by, old_data)
    VALUES ('Enclosures', OLD.id, 'DELETE', CURRENT_USER(), CONCAT_WS(',', 'symbol=', OLD.symbol, 'species=', OLD.species));
END;
//

-- ----------------------
-- Tabela Reservations
-- ----------------------
CREATE TRIGGER log_reservations_insert AFTER INSERT ON Reservations FOR EACH ROW
BEGIN
    INSERT INTO Change_Logs (table_name, record_id, action_type, changed_by, new_data)
    VALUES ('Reservations', NEW.id, 'INSERT', CURRENT_USER(), CONCAT_WS(',', 'start_date=', NEW.start_date, 'end_date=', NEW.end_date, 'status=', NEW.status, 'notes=', NEW.notes, 'enclosure_id=', NEW.enclosure_id, 'owner_id=', NEW.owner_id, 'animal_id=', NEW.animal_id));
END;
//

CREATE TRIGGER log_reservations_update BEFORE UPDATE ON Reservations FOR EACH ROW
BEGIN
    INSERT INTO Change_Logs (table_name, record_id, action_type, changed_by, old_data, new_data)
    VALUES ('Reservations', OLD.id, 'UPDATE', CURRENT_USER(), CONCAT_WS(',', 'start_date=', OLD.start_date, 'end_date=', OLD.end_date, 'status=', OLD.status, 'notes=', OLD.notes, 'enclosure_id=', OLD.enclosure_id, 'owner_id=', OLD.owner_id, 'animal_id=', OLD.animal_id), CONCAT_WS(',', 'start_date=', NEW.start_date, 'end_date=', NEW.end_date, 'status=', NEW.status, 'notes=', NEW.notes, 'enclosure_id=', NEW.enclosure_id, 'owner_id=', NEW.owner_id, 'animal_id=', NEW.animal_id));
END;
//

CREATE TRIGGER log_reservations_delete AFTER DELETE ON Reservations FOR EACH ROW
BEGIN
    INSERT INTO Change_Logs (table_name, record_id, action_type, changed_by, old_data)
    VALUES ('Reservations', OLD.id, 'DELETE', CURRENT_USER(), CONCAT_WS(',', 'start_date=', OLD.start_date, 'end_date=', OLD.end_date, 'status=', OLD.status, 'notes=', OLD.notes, 'enclosure_id=', OLD.enclosure_id, 'owner_id=', OLD.owner_id, 'animal_id=', OLD.animal_id));
END;
//

-- ------------------------------
-- Tabela Reservation Services
-- ------------------------------
CREATE TRIGGER log_reservation_services_insert AFTER INSERT ON Reservation_Services FOR EACH ROW
BEGIN
    INSERT INTO Change_Logs (table_name, record_id, action_type, changed_by, new_data)
    VALUES ('Reservation_Services', NEW.id, 'INSERT', CURRENT_USER(), CONCAT_WS(',', 'reservation_id=', NEW.reservation_id, 'service_id=', NEW.service_id));
END;
//

CREATE TRIGGER log_reservation_services_update BEFORE UPDATE ON Reservation_Services FOR EACH ROW
BEGIN
    INSERT INTO Change_Logs (table_name, record_id, action_type, changed_by, old_data, new_data)
    VALUES ('Reservation_Services', OLD.id, 'UPDATE', CURRENT_USER(), CONCAT_WS(',', 'reservation_id=', OLD.reservation_id, 'service_id=', OLD.service_id), CONCAT_WS(',', 'reservation_id=', NEW.reservation_id, 'service_id=', NEW.service_id));
END;
//

CREATE TRIGGER log_reservation_services_delete AFTER DELETE ON Reservation_Services FOR EACH ROW
BEGIN
    INSERT INTO Change_Logs (table_name, record_id, action_type, changed_by, old_data)
    VALUES ('Reservation_Services', OLD.id, 'DELETE', CURRENT_USER(), CONCAT_WS(',', 'reservation_id=', OLD.reservation_id, 'service_id=', OLD.service_id));
END;
//

DELIMITER ;