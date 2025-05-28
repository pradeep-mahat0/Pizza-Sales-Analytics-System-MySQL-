-- Create log tables
CREATE TABLE IF NOT EXISTS order_details_log (
    log_id INT AUTO_INCREMENT PRIMARY KEY,
    order_details_id INT,
    old_quantity INT,
    new_quantity INT,
    changed_at DATETIME
);

CREATE TABLE IF NOT EXISTS pizza_price_log (
    log_id INT AUTO_INCREMENT PRIMARY KEY,
    pizza_id TEXT,
    old_price DOUBLE,
    new_price DOUBLE,
    changed_at DATETIME
);

CREATE TABLE IF NOT EXISTS order_log (
    log_id INT AUTO_INCREMENT PRIMARY KEY,
    order_id INT,
    order_date DATE,
    logged_at DATETIME
);

-- Trigger 1: Log quantity update in order_details
DELIMITER //
CREATE TRIGGER trg_log_quantity_update
BEFORE UPDATE ON order_details
FOR EACH ROW
BEGIN
    IF NEW.quantity <> OLD.quantity THEN
        INSERT INTO order_details_log(order_details_id, old_quantity, new_quantity, changed_at)
        VALUES (OLD.order_details_id, OLD.quantity, NEW.quantity, NOW());
    END IF;
END;
//
DELIMITER ;

-- Trigger 2: Log price changes in pizzas
DELIMITER //
CREATE TRIGGER trg_log_price_change
BEFORE UPDATE ON pizzas
FOR EACH ROW
BEGIN
    IF NEW.price <> OLD.price THEN
        INSERT INTO pizza_price_log(pizza_id, old_price, new_price, changed_at)
        VALUES (OLD.pizza_id, OLD.price, NEW.price, NOW());
    END IF;
END;
//
DELIMITER ;

-- Trigger 3: Prevent negative quantity insert
DELIMITER //
CREATE TRIGGER trg_prevent_negative_quantity
BEFORE INSERT ON order_details
FOR EACH ROW
BEGIN
    IF NEW.quantity < 0 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Quantity cannot be negative';
    END IF;
END;
//
DELIMITER ;

-- Trigger 4: Log new orders
DELIMITER //
CREATE TRIGGER trg_log_new_order
AFTER INSERT ON orders
FOR EACH ROW
BEGIN
    INSERT INTO order_log(order_id, order_date, logged_at)
    VALUES (NEW.order_id, NEW.order_date, NOW());
END;
//
DELIMITER ;
