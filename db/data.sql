-- 2000 catégories CAT0001..CAT2000
INSERT INTO category(code, name)
SELECT 'CAT' || lpad(gs::text, 4, '0'), 'Category ' || gs
FROM generate_series(1, 2000) AS gs;

-- 100k items (~50 par catégorie), prix/stock aléatoires
WITH params AS (
  SELECT 100000 AS total_rows
),
nums AS (
  SELECT gs AS n FROM generate_series(1, (SELECT total_rows FROM params)) gs
),
pick_cat AS (
  SELECT n, ((n - 1) % 2000) + 1 AS c
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
