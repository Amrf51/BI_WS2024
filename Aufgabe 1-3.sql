GRANT ALL PRIVILEGES ON DATABASE bi to bi;
GRANT ALL ON SCHEMA public TO bi;

CREATE TABLE shoes_v2 AS
SELECT
    brand,

    weight,  -- original weight column
    -- Create a new cleaned numeric column for weight
    CASE
        -- REGEXP_REPLACE(weight, '[^0-9.]', '', 'g') --More Flexibel
        WHEN weight ILIKE '%lbs%' THEN CAST(SPLIT_PART(weight, ' ', 1) AS NUMERIC) * 453.592
        WHEN weight ILIKE '%g%' THEN CAST(SPLIT_PART(weight, ' ', 1) AS NUMERIC) -- Already in grams, leave it
        ELSE NULL
        END AS weight_grams,

    prices_condition,  -- shoe condition (no changes needed)
    prices_currency,  -- currency (no changes needed)

    prices_amountmin,  -- original price column
    -- Create a new column for converted price (VARCHAR -> FLOAT)
    CAST(NULLIF(prices_amountmin, '') AS FLOAT) AS price_numeric,

    prices_merchant  -- merchant platform (no changes needed)
FROM shoes;

--Welche Schuhmarke ist am häufigsten vertreten? Finden Sie die Top 5
--absteigend sortiert.
SELECT brand, COUNT(*) AS per_brand
FROM shoes_v2
GROUP BY brand
ORDER BY per_Brand DESC
LIMIT 5;

--Was ist das größte und geringste Gewicht der Schuhe?
SELECT MAX(weight_grams) AS Max_Weight,
       MIN(weight_grams) AS Min_Weight
FROM shoes_v2
WHERE weight_grams IS NOT NULL;

--Welche Zustände (condition) der Schuhe gibt es im Datensatz?
SELECT DISTINCT UPPER(prices_condition)
FROM shoes_v2
WHERE prices_condition IS NOT NULL;

--Wie viele Schuhe gibt es pro Zustand (condition)?
SELECT DISTINCT UPPER(prices_condition), COUNT(*) AS condition_count
FROM shoes_v2
WHERE prices_condition IS NOT NULL
GROUP BY UPPER(prices_condition);

--Welche Währungen kommen vor?
SELECT DISTINCT UPPER(prices_currency)
FROM shoes_v2;

--Wie häufig kommen die unterschiedlichen Währungen vor?
SELECT DISTINCT UPPER(prices_currency), COUNT(*)
FROM shoes_v2
WHERE prices_currency IS NOT NULL
GROUP BY prices_currency;


--Welche Schuhmarke ist im Durchschnitt die teuerste bei der Währung USD?
--(Es soll ausschließlich die Währung USD betrachtet werden.)
SELECT DISTINCT UPPER(brand) AS brand, AVG(price_numeric) AS price_avg
FROM shoes_v2
WHERE UPPER(prices_currency) = 'USD' AND price_numeric IS NOT NULL AND brand IS NOT NULL
GROUP BY brand
ORDER BY price_avg DESC
LIMIT 1;

--Bei welchen Plattformen (wie Walmart) wurden die meisten Preise entdeckt?
--Zeigen Sie die Top 5.
SELECT DISTINCT UPPER(prices_merchant), COUNT(*) AS merchant_count
FROM shoes_v2
WHERE prices_merchant IS NOT NULL
GROUP BY prices_merchant
ORDER BY merchant_count DESC
LIMIT 5;
-- or if all WALMART.COM will be considered WALMART.COM
SELECT
    CASE
        WHEN prices_merchant ILIKE '%WALMART.COM%' THEN 'WALMART'
        ELSE prices_merchant
        END AS merchant,
    COUNT(*) AS merchant_count
FROM shoes_v2
WHERE prices_merchant IS NOT NULL
GROUP BY
    CASE
        WHEN prices_merchant ILIKE '%WALMART.COM%' THEN 'WALMART'
        ELSE prices_merchant
        END
ORDER BY merchant_count DESC
LIMIT 5;
