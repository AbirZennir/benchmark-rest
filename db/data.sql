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
