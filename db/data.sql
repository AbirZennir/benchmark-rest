INSERT INTO category (code, name)
VALUES 
('CAT0001', 'Informatique'),
('CAT0002', 'Électronique'),
('CAT0003', 'Maison');

INSERT INTO item (sku, name, price, stock, category_id)
VALUES
('ITM0001', 'Laptop Dell', 7500.00, 10, 1),
('ITM0002', 'Télévision LG', 5600.00, 5, 2),
('ITM0003', 'Aspirateur', 1200.00, 8, 3);
