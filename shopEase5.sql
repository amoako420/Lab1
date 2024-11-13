use lab1;



SELECT COUNT(*) FROM order_items;


DELIMITER //

CREATE TRIGGER update_inventory
AFTER INSERT ON order_items
FOR EACH ROW
BEGIN
    DECLARE current_stock INT;
    DECLARE error_message VARCHAR(255);

    -- Retrieve the current stock for the product
    SELECT stock_count INTO current_stock
    FROM order_items
    WHERE product_id = NEW.product_id;

    -- Check if there is enough stock
    IF current_stock < NEW.quantity THEN
        -- Set the error message in a variable
        SET error_message = CONCAT('Insufficient stock for product ', NEW.product_id, 
                                   '. Current stock: ', current_stock);

        -- Raise an error with the message
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = error_message;
    ELSE
        -- Update the inventory to decrease the stock count
        UPDATE order_items
        SET stock_count = stock_count - NEW.quantity
        WHERE product_id = NEW.product_id;
    END IF;
END //

DELIMITER ;

-- Stored Procedure
DELIMITER //

CREATE PROCEDURE UpdateCustomerStatus(IN CustomerID INT)
BEGIN
    DECLARE total_order_value DECIMAL(10, 2);

    -- Calculate the total order value for the customer
    SELECT SUM(order_total) INTO total_order_value
    FROM Orders
    WHERE customer_id = CustomerID;

    -- Update customer status based on the total order value
    IF total_order_value > 10000 THEN
        UPDATE Customers
        SET status = 'VIP'
        WHERE customer_id = CustomerID;
    ELSE
        UPDATE Customers
        SET status = 'Regular'
        WHERE customer_id = CustomerID;
    END IF;
END //

DELIMITER ;




	