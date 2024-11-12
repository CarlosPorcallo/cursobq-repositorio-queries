/* Item con sus categorías */​

SELECT DISTINCT​
    mdm.title,​
    mdm.categories,​
    mdm.description​
FROM​
    `<proyecto>.<dataset>.meta_digital_music` mdm​
LIMIT 100;​

/* Item con sus categorías */​


/* Items de los Reviews de usuarios de las compañías de una lista */​
SELECT​
    rdm.asin​
FROM​
    `<proyecto>.<dataset>.customer` AS c​
INNER JOIN `<proyecto>.<dataset>.customer_reviewer` AS cr​
ON cr.customerID = c.customerID​
INNER JOIN `<proyecto>.<dataset>.review_digital_music` as rdm​
ON rdm.reviewerID = cr.reviewerID​
INNER JOIN `<proyecto>.<dataset>.meta_digital_music` as mdm​
ON mdm.asin = rdm.asin​
WHERE​
    c.company IN (<company-list>) AND​
    mdm.title is not NULL;​
/* Items de los Reviews de usuarios de las compañías de una lista */​

/* Query empleando como subquery la consulta anterior */​
SELECT​
    mdm.title,​
    mdm.categories,​
    mdm.description​
FROM​
    `<proyecto>.<dataset>.meta_digital_music` mdm​
WHERE ​
    mdm.asin IN (​
        SELECT​
            rdm.asin​
        FROM​
            `<proyecto>.<dataset>.customer` AS c​
        INNER JOIN `<proyecto>.<dataset>.customer_reviewer` AS cr​
        ON cr.customerID = c.customerID​
        INNER JOIN `<proyecto>.<dataset>.review_digital_music` as rdm​
        ON rdm.reviewerID = cr.reviewerID​
        INNER JOIN `<proyecto>.<dataset>.meta_digital_music` as mdm​
        ON mdm.asin = rdm.asin​
        WHERE​
            c.company IN (<company-list>) AND​
            mdm.title is not NULL​
);​

/* Query empleando como subquery la consulta anterior */​

/* Query empleando como subquery la consulta anterior [usando ARRAY_STRING()] */​
SELECT​
    mdm.title,​
    ARRAY_TO_STRING(mdm.categories, ", ") AS categories,​
    mdm.description​
FROM​
    `<proyecto>.<dataset>.meta_digital_music` mdm​
WHERE ​
    mdm.asin IN (​
        SELECT​
            rdm.asin​
        FROM​
            `<proyecto>.<dataset>.customer` AS c​
        INNER JOIN `<proyecto>.<dataset>.customer_reviewer` AS cr​
        ON cr.customerID = c.customerID​
        INNER JOIN `<proyecto>.<dataset>.review_digital_music` as rdm​
        ON rdm.reviewerID = cr.reviewerID​
        INNER JOIN `<proyecto>.<dataset>.meta_digital_music` as mdm​
        ON mdm.asin = rdm.asin
        WHERE
            c.company IN (<company-list>) AND​
            mdm.title is not NULL​
);​

/* Query empleando como subquery la consulta anterior [usando ARRAY_STRING()] */​

/* Query empleando como subquery la consulta anterior [usando ARRAY_STRING()] */​

SELECT ​
    subquery.email ​
FROM (​
    SELECT​
        rdm.reviewerID,​
        c.customerID,​
        CONCAT(c.firstName, ' ', c.lastName) as customerName,​
        c.email,​
        c.country,​
        c.city,​
        c.company,​
        rdm.asin, ​
        mdm.title,​
        mdm.categories,​
        rdm.overall,​
        rdm.reviewText,​
        rdm.reviewTime​
    FROM​
        `<proyecto>.<dataset>.customer` AS c​
    INNER JOIN `<proyecto>.<dataset>.customer_reviewer` AS cr​
    ON cr.customerID = c.customerID​
    INNER JOIN `<proyecto>.<dataset>.review_digital_music` as rdm​
    ON rdm.reviewerID = cr.reviewerID​
    INNER JOIN `<proyecto>.<dataset>.meta_digital_music` as mdm​
    ON mdm.asin = rdm.asin​
    WHERE​
        c.company IN (<company-list>) AND​
        mdm.title is not NULL​
    ) AS subquery​

/* Query empleando como subquery la consulta anterior [usando ARRAY_STRING()] */​

/* subquery scallar */​

SELECT
    mdm.asin,​
    mdm.title,​
    ARRAY_TO_STRING(mdm.categories, ", "),​
    mdm.description​
FROM​
    `<proyecto>.<dataset>.meta_digital_music` AS mdm​
WHERE​
    mdm.title IS NOT NULL​
LIMIT​ 100; /* conocer conteo de reviews */​

SELECT​
    mdm.asin,​
    mdm.title,​
    ARRAY_TO_STRING(mdm.categories, ", "),​
    mdm.description,​
    (​
    SELECT​
        COUNT(1) AS conteo​
    FROM​
        `<proyecto>.<dataset>.review_digital_music` AS rdm​
    WHERE​
        rdm.asin = mdm.asin​
    GROUP BY​ rdm.asin ) AS total_reviews​
FROM​
    `<proyecto>.<dataset>.meta_digital_music` AS mdm​
WHERE​
    mdm.title IS NOT NULL​
LIMIT​ 100; ​

/* conocer conteo de reviews */ ​
/* subquery scallar */​

