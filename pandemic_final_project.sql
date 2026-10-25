-- Завдання 1. Створення бази даних та імпорт даних

CREATE DATABASE IF NOT EXISTS pandemic;
USE pandemic;

SELECT COUNT(*)
FROM infectious_cases;

-- Завдання 2. Нормалізація таблиці до 3НФ

CREATE TABLE entities (
    id INT AUTO_INCREMENT PRIMARY KEY,
    Entity VARCHAR(255),
    Code VARCHAR(10)
);

INSERT INTO entities (Entity, Code)
SELECT DISTINCT Entity, Code
FROM infectious_cases;

CREATE TABLE infectious_cases_normalized (
    id INT AUTO_INCREMENT PRIMARY KEY,
    entity_id INT,
    Year INT,
    Number_yaws TEXT,
    polio_cases INT,
    cases_guinea_worm INT,
    Number_rabies TEXT,
    Number_malaria TEXT,
    Number_hiv TEXT,
    Number_tuberculosis TEXT,
    Number_smallpox TEXT,
    Number_cholera_cases TEXT,
    FOREIGN KEY (entity_id) REFERENCES entities(id)
);

INSERT INTO infectious_cases_normalized (
    entity_id,
    Year,
    Number_yaws,
    polio_cases,
    cases_guinea_worm,
    Number_rabies,
    Number_malaria,
    Number_hiv,
    Number_tuberculosis,
    Number_smallpox,
    Number_cholera_cases
)
SELECT
    e.id,
    i.Year,
    i.Number_yaws,
    i.polio_cases,
    i.cases_guinea_worm,
    i.Number_rabies,
    i.Number_malaria,
    i.Number_hiv,
    i.Number_tuberculosis,
    i.Number_smallpox,
    i.Number_cholera_cases
FROM infectious_cases AS i
INNER JOIN entities AS e
    ON i.Entity = e.Entity
    AND i.Code <=> e.Code;

-- Перевірка кількості записів

SELECT
    (SELECT COUNT(*) FROM infectious_cases) AS original_count,
    (SELECT COUNT(*) FROM infectious_cases_normalized) AS normalized_count,
    (SELECT COUNT(*) FROM entities) AS entities_count;

-- Завдання 3. Аналіз даних Number_rabies

SELECT
    e.Entity,
    e.Code,
    AVG(CAST(n.Number_rabies AS DECIMAL(15, 2))) AS avg_rabies,
    MIN(CAST(n.Number_rabies AS DECIMAL(15, 2))) AS min_rabies,
    MAX(CAST(n.Number_rabies AS DECIMAL(15, 2))) AS max_rabies,
    SUM(CAST(n.Number_rabies AS DECIMAL(15, 2))) AS sum_rabies
FROM infectious_cases_normalized AS n
INNER JOIN entities AS e
    ON n.entity_id = e.id
WHERE n.Number_rabies IS NOT NULL
    AND TRIM(n.Number_rabies) <> ''
GROUP BY e.id, e.Entity, e.Code
ORDER BY avg_rabies DESC
LIMIT 10;

-- Завдання 4. Розрахунок різниці в роках

SELECT
    Year,
    MAKEDATE(Year, 1) AS start_date,
    CURDATE() AS today_date,
    TIMESTAMPDIFF(
        YEAR,
        MAKEDATE(Year, 1),
        CURDATE()
    ) AS years_difference
FROM infectious_cases_normalized;

-- Завдання 5. Створення власної функції

DELIMITER //

CREATE FUNCTION calculate_years_difference(input_year INT)
RETURNS INT
NOT DETERMINISTIC
NO SQL
BEGIN
    RETURN TIMESTAMPDIFF(
        YEAR,
        MAKEDATE(input_year, 1),
        CURDATE()
    );
END //

DELIMITER ;

-- Перевірка роботи власної функції

SELECT
    Year,
    calculate_years_difference(Year) AS years_difference
FROM infectious_cases_normalized;