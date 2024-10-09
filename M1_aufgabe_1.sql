CREATE TABLE shoes (
    id VARCHAR ,
    asins VARCHAR,
    brand VARCHAR,
    categories VARCHAR,
    colors VARCHAR,
    count VARCHAR,
    dateadded VARCHAR,
    dateupdated VARCHAR,
    descriptions VARCHAR,
    dimension VARCHAR,
    ean VARCHAR,
    features VARCHAR,
    flavors VARCHAR,
    imageurls VARCHAR,
    isbn VARCHAR,
    keys VARCHAR,
    manufacturer VARCHAR,
    manufacturernumber VARCHAR,
    merchants VARCHAR,
    name VARCHAR,
    prices_amountmin VARCHAR,
    prices_amountmax VARCHAR,
    prices_availability VARCHAR,
    prices_color VARCHAR,
    prices_condition VARCHAR,
    prices_count VARCHAR,
    prices_currency VARCHAR,
    prices_dateadded VARCHAR,
    prices_dateseen VARCHAR,
    prices_flavor VARCHAR,
    prices_issale VARCHAR,
    prices_merchant VARCHAR,
    prices_offer VARCHAR,
    sourceurls VARCHAR,
    upc VARCHAR,
    vin VARCHAR,
    websiteids VARCHAR,
    weight VARCHAR
);

UPDATE shoes
SET prices_amountmin = NULL
WHERE prices_amountmin = '28. Feb';

ALTER TABLE shoes
    ALTER COLUMN prices_amountmin
        SET DATA TYPE NUMERIC
    USING prices_amountmin::NUMERIC;

UPDATE shoes
SET ean = REPLACE(ean, ',', '.')::BIGINT
WHERE ean ~ '[0-9]+,[0-9]+E[0-9]+';




DROP TABLE shoes;


COPY Public."shoes" FROM 'C:\Users\Arnav\OneDrive - Fachhochschule Aachen\Desktop\BI_WS24\M1' DELIMITER ';' CSV HEADER;
