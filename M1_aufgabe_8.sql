-- Create dimension tables
CREATE TABLE DIM_PRODUCT (
                             product_id SERIAL PRIMARY KEY,
                             manufacturer_id INT,
                             brand VARCHAR(255),
                             categories TEXT,
                             name VARCHAR(255),
                             weight VARCHAR(50),
                             colors VARCHAR,
                             image_urls VARCHAR,
                             source_id VARCHAR(255)
);

CREATE TABLE DIM_CONDITION (
                               condition_id SERIAL PRIMARY KEY,
                               prices_condition VARCHAR(50)
);

CREATE TABLE DIM_MANUFACTURER (
                                  manufacturer_id SERIAL PRIMARY KEY,
                                  manufacturer VARCHAR(255),
                                  manufacturer_number VARCHAR(255)
);

CREATE TABLE DIM_DATE (
                          date_id SERIAL PRIMARY KEY,
                          dateadded TIMESTAMP,
                          dateupdated TIMESTAMP
);

CREATE TABLE DIM_MERCHANT (
                              merchant_id SERIAL PRIMARY KEY,
                              merchants_name VARCHAR(255)
);

-- Create fact table
CREATE TABLE FACT_SALES (
                            sales_id SERIAL PRIMARY KEY,
                            date_id INT REFERENCES DIM_DATE(date_id),
                            product_id INT REFERENCES DIM_PRODUCT(product_id),
                            merchant_id INT REFERENCES DIM_MERCHANT(merchant_id),
                            manufacturer_id INT REFERENCES DIM_MANUFACTURER(manufacturer_id),
                            condition_id INT REFERENCES DIM_CONDITION(condition_id),
                            prices_amountmin NUMERIC,
                            prices_amountmax NUMERIC,
                            prices_currency VARCHAR(10)
);

-- Insert data into dimension product table
INSERT INTO DIM_PRODUCT (manufacturer_id, brand, categories, name, weight, colors, image_urls, source_id)
SELECT
    DISTINCT ON (id)
    NULL, -- manufacturer_id will be updated later
    brand,
    categories,
    name,
    weight,
    colors,
    imageurls,
    id
FROM
    shoes;


-- Insert data into dimension condition table
INSERT INTO DIM_CONDITION (prices_condition)
SELECT DISTINCT prices_condition
FROM shoes
WHERE prices_condition IS NOT NULL;


-- Insert data into dimension manufacturer table
INSERT INTO DIM_MANUFACTURER (manufacturer, manufacturer_number)
SELECT DISTINCT manufacturer, manufacturernumber
FROM shoes
WHERE (manufacturer) IS NOT NULL OR
      manufacturernumber IS NOT NULL;


-- Insert data into dimension date table
INSERT INTO DIM_DATE (dateadded, dateupdated)
SELECT DISTINCT
    CASE
        WHEN dateadded ~ '^\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}Z$'
            THEN dateadded::timestamp
        ELSE NULL
        END as dateadded,
    CASE
        WHEN dateupdated ~ '^\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}Z$'
            THEN dateupdated::timestamp
        ELSE NULL
        END as dateupdated
FROM shoes
WHERE dateadded IS NOT NULL OR dateupdated IS NOT NULL;



-- Add UNIQUE constraint to merchants_name if it doesn't exist
ALTER TABLE DIM_MERCHANT ADD CONSTRAINT unique_merchant_name UNIQUE (merchants_name);
-- Insert data into DIM_MERCHANT table
WITH extracted_merchants AS (
    SELECT DISTINCT
        trim(
                substring(
                        merchant_string
                        FROM 'name:([^}]+)'
                )
        ) AS merchant_name
    FROM (
             SELECT unnest(string_to_array(trim(both '[]' from merchants), '},')) AS merchant_string
             FROM shoes
             WHERE merchants IS NOT NULL AND merchants != ''
         ) as expanded
)

-- Insert data into dimension merchant table
INSERT INTO DIM_MERCHANT (merchants_name)
SELECT merchant_name
FROM extracted_merchants
WHERE merchant_name != ''
ON CONFLICT (merchants_name) DO NOTHING;

SELECT COUNT(*) FROM DIM_MERCHANT;



-- Update manufacturer_id in DIM_PRODUCT as it was null earlier
UPDATE DIM_PRODUCT dp
SET manufacturer_id = (
    SELECT dm.manufacturer_id
    FROM shoes s
             JOIN DIM_MANUFACTURER dm ON
        COALESCE(s.manufacturer, s.manufacturernumber) = COALESCE(dm.manufacturer, dm.manufacturer_number)
    WHERE s.id = dp.source_id
    LIMIT 1
);



-- Insert data into fact table
INSERT INTO FACT_SALES (date_id, product_id, merchant_id, manufacturer_id, condition_id, prices_amountmin, prices_amountmax, prices_currency)
SELECT
    dd.date_id,
    dp.product_id,
    dm.merchant_id,
    dmanuf.manufacturer_id,
    dc.condition_id,
    s.prices_amountmin::NUMERIC,
    s.prices_amountmax::NUMERIC,
    s.prices_currency
FROM
    shoes s
        JOIN DIM_PRODUCT dp ON s.id = dp.source_id
        LEFT JOIN DIM_DATE dd ON s.dateadded::timestamp = dd.dateadded OR s.dateupdated::timestamp = dd.dateupdated
        LEFT JOIN LATERAL (
        SELECT dm.merchant_id
        FROM DIM_MERCHANT dm
        WHERE s.merchants LIKE '%' || dm.merchants_name || '%'
        LIMIT 1
        ) dm ON true
        LEFT JOIN DIM_MANUFACTURER dmanuf ON (s.manufacturer = dmanuf.manufacturer AND dmanuf.manufacturer IS NOT NULL)
                                                 OR (s.manufacturernumber = dmanuf.manufacturer_number AND dmanuf.manufacturer_number IS NOT NULL)
        LEFT JOIN DIM_CONDITION dc ON s.prices_condition = dc.prices_condition;


-- Let's check how many rows were inserted
SELECT COUNT(*) FROM FACT_SALES;