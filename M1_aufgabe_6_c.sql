SELECT
    brand,
    MAX(prices_amountmax - prices_amountmin) AS max_price_range
FROM
    shoes
WHERE
    prices_amountmin IS NOT NULL
  AND prices_amountmax IS NOT NULL
GROUP BY
    brand
ORDER BY
    max_price_range DESC
LIMIT 5;
