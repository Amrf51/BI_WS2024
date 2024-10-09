SELECT brand, COUNT(DISTINCT id) AS brand_count
FROM shoes
WHERE brand IS NOT NULL
GROUP BY brand
ORDER BY brand_count DESC
LIMIT 5;


SELECT MAX(weight) AS max_weight, MIN(weight) AS min_weight
FROM shoes
WHERE weight IS NOT NULL;


SELECT DISTINCT prices_condition
FROM shoes
WHERE prices_condition IS NOT NULL;


SELECT prices_condition, COUNT(DISTINCT id) AS shoe_count
FROM shoes
WHERE prices_condition IS NOT NULL
GROUP BY prices_condition;


SELECT DISTINCT prices_currency
FROM shoes
WHERE prices_currency IS NOT NULL;


SELECT prices_currency, COUNT(DISTINCT id) AS currency_count
FROM shoes
WHERE prices_currency IS NOT NULL
GROUP BY prices_currency;


SELECT brand, AVG(prices_amountmin) AS avg_price
FROM shoes
WHERE prices_currency = 'USD' AND prices_amountmin IS NOT NULL
GROUP BY brand
ORDER BY avg_price DESC
LIMIT 1;


SELECT prices_merchant, COUNT(DISTINCT id) AS merchant_count
FROM shoes
WHERE prices_merchant IS NOT NULL
GROUP BY prices_merchant
ORDER BY merchant_count DESC
LIMIT 5;
