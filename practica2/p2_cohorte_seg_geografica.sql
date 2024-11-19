--https://latitude.to/map

/* Conteo por país con sus coordenadas */
WITH customer_country_count AS (
  SELECT DISTINCT
    c.country,
    cc.latitude,
    cc.longitude,
    COUNT(c.customerID) OVER (PARTITION BY c.country) AS conteo,
  FROM `<proyecto>.p2_cohortes.customer` AS c
  INNER JOIN `<proyecto>.p2_cohortes.country_coordinates` AS cc
  ON cc.country = c.country
)

SELECT 
  country,
  latitude,
  longitude,
  conteo
FROM customer_country_count
ORDER BY conteo DESC

/* Obtener listado de países */
/* De ellos obtener aquel con mayor número de suscripciones  */
/* Obtener suscripciones por año del país encontrado */
/* Para cada año obtener suscripciones por mes */
/* Obtener el año y mes con mayor número de suscripciones */
/* Del año y mes con mayor número de suscripciones obtener el listado detallado de usuarios */
/* Del año y mes con mayor número de suscripciones la relación entre clientes registrados y con interacciones (reviews) */
/* Seleccionar una muestra pequeña y en base a sus reviews obtener las principales categorías reseñadas por individuo (género musical, formato) */
/* se crea un reporte */
/* se crea una tabla con los resultados del reporte previo */


/* Obtener listado de países */
SELECT DISTINCT
  COUNT(c.customerID) OVER (PARTITION BY c.country) AS conteo,
  c.country
FROM `<proyecto>.p2_cohortes.customer` AS c

/* De ellos obtener aquel con mayor número de suscripciones  */
WITH customer_country_count AS (
    SELECT DISTINCT
      COUNT(c.customerID) OVER (PARTITION BY c.country) AS conteo,
      c.country
    FROM `<proyecto>.p2_cohortes.customer` AS c
)

SELECT 
    ccc.conteo,
    ccc.country
FROM customer_country_count AS ccc
ORDER BY ccc.conteo DESC
LIMIT 1

/* Obtener suscripciones por año del país encontrado */
WITH customer_country_count AS (
    SELECT DISTINCT
      COUNT(c.customerID) OVER (PARTITION BY c.country) AS conteo,
      c.country
    FROM `<proyecto>.p2_cohortes.customer` AS c
),
max_country_customer_count AS (
    SELECT 
        ccc.conteo,
        ccc.country
    FROM customer_country_count AS ccc
    ORDER BY ccc.conteo DESC
    LIMIT 1
)

SELECT DISTINCT
    c.country,
    EXTRACT(year FROM c.subscriptionDate) AS subscriptionYear,
    COUNT(c.customerID) OVER (PARTITION BY EXTRACT(year FROM c.subscriptionDate) ORDER BY EXTRACT(year FROM c.subscriptionDate)) AS customerCount
FROM `<proyecto>.p2_cohortes.customer` AS c
WHERE
    c.country = (SELECT mccc.country FROM max_country_customer_count AS mccc)
  
/* Para cada año obtener suscripciones por mes */
WITH customer_country_count AS (
    SELECT DISTINCT
      COUNT(c.customerID) OVER (PARTITION BY c.country) AS conteo,
      c.country
    FROM `<proyecto>.p2_cohortes.customer` AS c
),
max_country_customer_count AS (
    SELECT 
        ccc.conteo,
        ccc.country
    FROM customer_country_count AS ccc
    ORDER BY ccc.conteo DESC
    LIMIT 1
),
suscriptions_by_year_max_country AS (
  SELECT DISTINCT
    c.country,
    EXTRACT(year FROM c.subscriptionDate) AS subscriptionYear,
    COUNT(c.customerID) OVER (PARTITION BY EXTRACT(year FROM c.subscriptionDate) ORDER BY EXTRACT(year FROM c.subscriptionDate)) AS customerCount
  FROM `<proyecto>.p2_cohortes.customer` AS c
  WHERE
    c.country = (SELECT mccc.country FROM max_country_customer_count AS mccc)
)

SELECT DISTINCT
  symc.country,
  symc.subscriptionYear,
  symc.customerCount,
  EXTRACT(month FROM c.subscriptionDate) AS subscriptionMonthNumber,
  CASE EXTRACT(month FROM c.subscriptionDate)
    WHEN 1 THEN "Enero"
    WHEN 2 THEN "Febrero"
    WHEN 3 THEN "Marzo"
    WHEN 4 THEN "Abril"
    WHEN 5 THEN "Mayo"
    WHEN 6 THEN "Junio"
    WHEN 7 THEN "Julio"
    WHEN 8 THEN "Agosto"
    WHEN 9 THEN "Septiembre"
    WHEN 10 THEN "Octubre"
    WHEN 11 THEN "Noviembre"
    ELSE "Diciembre"
  END
  AS subscriptionMonth,
  COUNT(c.customerID) OVER (PARTITION BY FORMAT_DATE('%b-%Y', c.subscriptionDate)) AS customerCountByMonth
FROM suscriptions_by_year_max_country AS symc
INNER JOIN `<proyecto>.p2_cohortes.customer` as c
ON EXTRACT(year from c.subscriptionDate) = symc.subscriptionYear
WHERE
  c.country = symc.country
ORDER BY symc.subscriptionYear, subscriptionMonthNumber ASC

/* Obtener el año y mes con mayor número de suscripciones */
WITH customer_country_count AS (
    SELECT DISTINCT
      COUNT(c.customerID) OVER (PARTITION BY c.country) AS conteo,
      c.country
    FROM `<proyecto>.p2_cohortes.customer` AS c
),
max_country_customer_count AS (
    SELECT 
        ccc.conteo,
        ccc.country
    FROM customer_country_count AS ccc
    ORDER BY ccc.conteo DESC
    LIMIT 1
),
suscriptions_by_year_max_country AS (
  SELECT DISTINCT
    c.country,
    EXTRACT(year FROM c.subscriptionDate) AS subscriptionYear,
    COUNT(c.customerID) OVER (PARTITION BY EXTRACT(year FROM c.subscriptionDate) ORDER BY EXTRACT(year FROM c.subscriptionDate)) AS customerCount
  FROM `<proyecto>.p2_cohortes.customer` AS c
  WHERE
    c.country = (SELECT mccc.country FROM max_country_customer_count AS mccc)
),
max_subscription_by_year_max_country AS (
    SELECT
      symc.country,
      symc.subscriptionYear,
      symc.customerCount
    FROM suscriptions_by_year_max_country AS symc
    ORDER BY symc.customerCount DESC
    LIMIT 1
  ),
subscriptions_by_month_year_max_country AS (
  SELECT DISTINCT
    symc.country,
    symc.subscriptionYear,
    symc.customerCount,
    EXTRACT(month FROM c.subscriptionDate) AS subscriptionMonthNumber,
    CASE EXTRACT(month FROM c.subscriptionDate)
      WHEN 1 THEN "Enero"
      WHEN 2 THEN "Febrero"
      WHEN 3 THEN "Marzo"
      WHEN 4 THEN "Abril"
      WHEN 5 THEN "Mayo"
      WHEN 6 THEN "Junio"
      WHEN 7 THEN "Julio"
      WHEN 8 THEN "Agosto"
      WHEN 9 THEN "Septiembre"
      WHEN 10 THEN "Octubre"
      WHEN 11 THEN "Noviembre"
      ELSE "Diciembre"
    END
    AS subscriptionMonth,
    COUNT(c.customerID) OVER (PARTITION BY FORMAT_DATE('%b-%Y', c.subscriptionDate)) AS customerCountByMonth
  FROM suscriptions_by_year_max_country AS symc
  INNER JOIN `<proyecto>.p2_cohortes.customer` as c
  ON EXTRACT(year from c.subscriptionDate) = symc.subscriptionYear
  WHERE
    c.country = symc.country AND
    EXTRACT(year FROM c.subscriptionDate) = (
      SELECT msymc.subscriptionYear FROM max_subscription_by_year_max_country AS msymc
    )
  ORDER BY symc.subscriptionYear, subscriptionMonthNumber ASC
)

SELECT 
  smymc.country,
  smymc.subscriptionYear,
  smymc.customerCount,
  smymc.subscriptionMonthNumber,
  smymc.subscriptionMonth,
  smymc.customerCountByMonth
FROM subscriptions_by_month_year_max_country AS smymc
ORDER BY customerCountByMonth DESC
LIMIT 1

/* Del año y mes con mayor número de suscripciones obtener el listado detallado de usuarios */
WITH customer_country_count AS (
    SELECT DISTINCT
      COUNT(c.customerID) OVER (PARTITION BY c.country) AS conteo,
      c.country
    FROM `<proyecto>.p2_cohortes.customer` AS c
),
max_country_customer_count AS (
    SELECT 
        ccc.conteo,
        ccc.country
    FROM customer_country_count AS ccc
    ORDER BY ccc.conteo DESC
    LIMIT 1
),
suscriptions_by_year_max_country AS (
  SELECT DISTINCT
    c.country,
    EXTRACT(year FROM c.subscriptionDate) AS subscriptionYear,
    COUNT(c.customerID) OVER (PARTITION BY EXTRACT(year FROM c.subscriptionDate) ORDER BY EXTRACT(year FROM c.subscriptionDate)) AS customerCount
  FROM `<proyecto>.p2_cohortes.customer` AS c
  WHERE
    c.country = (SELECT mccc.country FROM max_country_customer_count AS mccc)
),
max_subscription_by_year_max_country AS (
    SELECT
      symc.country,
      symc.subscriptionYear,
      symc.customerCount
    FROM suscriptions_by_year_max_country AS symc
    ORDER BY symc.customerCount DESC
    LIMIT 1
  ),
subscriptions_by_month_year_max_country AS (
  SELECT DISTINCT
    symc.country,
    symc.subscriptionYear,
    symc.customerCount,
    EXTRACT(month FROM c.subscriptionDate) AS subscriptionMonthNumber,
    CASE EXTRACT(month FROM c.subscriptionDate)
      WHEN 1 THEN "Enero"
      WHEN 2 THEN "Febrero"
      WHEN 3 THEN "Marzo"
      WHEN 4 THEN "Abril"
      WHEN 5 THEN "Mayo"
      WHEN 6 THEN "Junio"
      WHEN 7 THEN "Julio"
      WHEN 8 THEN "Agosto"
      WHEN 9 THEN "Septiembre"
      WHEN 10 THEN "Octubre"
      WHEN 11 THEN "Noviembre"
      ELSE "Diciembre"
    END
    AS subscriptionMonth,
    COUNT(c.customerID) OVER (PARTITION BY FORMAT_DATE('%b-%Y', c.subscriptionDate)) AS customerCountByMonth
  FROM suscriptions_by_year_max_country AS symc
  INNER JOIN `<proyecto>.p2_cohortes.customer` as c
  ON EXTRACT(year from c.subscriptionDate) = symc.subscriptionYear
  WHERE
    c.country = symc.country AND
    EXTRACT(year FROM c.subscriptionDate) = (
      SELECT msymc.subscriptionYear FROM max_subscription_by_year_max_country AS msymc
    )
  ORDER BY symc.subscriptionYear, subscriptionMonthNumber ASC
),
max_subscriptions_by_month_year_max_country AS (
  SELECT 
    smymc.country,
    smymc.subscriptionYear,
    smymc.customerCount,
    smymc.subscriptionMonthNumber,
    smymc.subscriptionMonth,
    smymc.customerCountByMonth
  FROM subscriptions_by_month_year_max_country AS smymc
  ORDER BY customerCountByMonth DESC
  LIMIT 1
)

SELECT
  c.customerID,
  CONCAT(c.firstName, ' ', c.lastName) AS customerName,
  c.country,
  c.city,
  c.subscriptionDate,
  EXTRACT(month FROM c.subscriptionDate) AS subscriptionMonth,
  EXTRACT(year FROM c.subscriptionDate) AS subscriptionYear
FROM `<proyecto>.p2_cohortes.customer` AS c
  WHERE 
    EXTRACT(year FROM c.subscriptionDate) = (SELECT msymmc.subscriptionYear FROM max_subscriptions_by_month_year_max_country AS msymmc) AND
    EXTRACT(month FROM c.subscriptionDate) = (SELECT msymmc.subscriptionMonthNumber FROM max_subscriptions_by_month_year_max_country AS msymmc) AND
    c.country = (SELECT msymmc.country FROM max_subscriptions_by_month_year_max_country AS msymmc)
ORDER BY EXTRACT(day FROM c.subscriptionDate) ASC

/* Del año y mes con mayor número de suscripciones la relación entre clientes registrados y con interacciones (reviews) */
WITH customer_country_count AS (
    SELECT DISTINCT
      COUNT(c.customerID) OVER (PARTITION BY c.country) AS conteo,
      c.country
    FROM `<proyecto>.p2_cohortes.customer` AS c
),
max_country_customer_count AS (
    SELECT 
        ccc.conteo,
        ccc.country
    FROM customer_country_count AS ccc
    ORDER BY ccc.conteo DESC
    LIMIT 1
),
suscriptions_by_year_max_country AS (
  SELECT DISTINCT
    c.country,
    EXTRACT(year FROM c.subscriptionDate) AS subscriptionYear,
    COUNT(c.customerID) OVER (PARTITION BY EXTRACT(year FROM c.subscriptionDate) ORDER BY EXTRACT(year FROM c.subscriptionDate)) AS customerCount
  FROM `<proyecto>.p2_cohortes.customer` AS c
  WHERE
    c.country = (SELECT mccc.country FROM max_country_customer_count AS mccc)
),
max_subscription_by_year_max_country AS (
    SELECT
      symc.country,
      symc.subscriptionYear,
      symc.customerCount
    FROM suscriptions_by_year_max_country AS symc
    ORDER BY symc.customerCount DESC
    LIMIT 1
  ),
subscriptions_by_month_year_max_country AS (
  SELECT DISTINCT
    symc.country,
    symc.subscriptionYear,
    symc.customerCount,
    EXTRACT(month FROM c.subscriptionDate) AS subscriptionMonthNumber,
    CASE EXTRACT(month FROM c.subscriptionDate)
      WHEN 1 THEN "Enero"
      WHEN 2 THEN "Febrero"
      WHEN 3 THEN "Marzo"
      WHEN 4 THEN "Abril"
      WHEN 5 THEN "Mayo"
      WHEN 6 THEN "Junio"
      WHEN 7 THEN "Julio"
      WHEN 8 THEN "Agosto"
      WHEN 9 THEN "Septiembre"
      WHEN 10 THEN "Octubre"
      WHEN 11 THEN "Noviembre"
      ELSE "Diciembre"
    END
    AS subscriptionMonth,
    COUNT(c.customerID) OVER (PARTITION BY FORMAT_DATE('%b-%Y', c.subscriptionDate)) AS customerCountByMonth
  FROM suscriptions_by_year_max_country AS symc
  INNER JOIN `<proyecto>.p2_cohortes.customer` as c
  ON EXTRACT(year from c.subscriptionDate) = symc.subscriptionYear
  WHERE
    c.country = symc.country AND
    EXTRACT(year FROM c.subscriptionDate) = (
      SELECT msymc.subscriptionYear FROM max_subscription_by_year_max_country AS msymc
    )
  ORDER BY symc.subscriptionYear, subscriptionMonthNumber ASC
),
max_subscriptions_by_month_year_max_country AS (
  SELECT 
    smymc.country,
    smymc.subscriptionYear,
    smymc.customerCount,
    smymc.subscriptionMonthNumber,
    smymc.subscriptionMonth,
    smymc.customerCountByMonth
  FROM subscriptions_by_month_year_max_country AS smymc
  ORDER BY customerCountByMonth DESC
  LIMIT 1
)

SELECT
  c.customerID,
  cr.reviewerID,
  CONCAT(c.firstName, ' ', c.lastName) AS customerName,
  c.country,
  c.city,
  c.subscriptionDate
FROM `<proyecto>.p2_cohortes.customer` AS c
INNER JOIN `<proyecto>.p2_cohortes.customer_reviewer` AS cr
ON cr.customerID = c.customerID 
  WHERE 
    EXTRACT(year FROM c.subscriptionDate) = (SELECT msymmc.subscriptionYear FROM max_subscriptions_by_month_year_max_country AS msymmc) AND
    EXTRACT(month FROM c.subscriptionDate) = (SELECT msymmc.subscriptionMonthNumber FROM max_subscriptions_by_month_year_max_country AS msymmc) AND
    c.country = (SELECT msymmc.country FROM max_subscriptions_by_month_year_max_country AS msymmc)
ORDER BY EXTRACT(day FROM c.subscriptionDate) ASC

/* Seleccionar una muestra pequeña y en base a sus reviews obtener las principales categorías reseñadas por individuo (género musical, formato) */
WITH customer_country_count AS (
    SELECT DISTINCT
      COUNT(c.customerID) OVER (PARTITION BY c.country) AS conteo,
      c.country
    FROM `<proyecto>.p2_cohortes.customer` AS c
),
max_country_customer_count AS (
    SELECT 
        ccc.conteo,
        ccc.country
    FROM customer_country_count AS ccc
    ORDER BY ccc.conteo DESC
    LIMIT 1
),
suscriptions_by_year_max_country AS (
  SELECT DISTINCT
    c.country,
    EXTRACT(year FROM c.subscriptionDate) AS subscriptionYear,
    COUNT(c.customerID) OVER (PARTITION BY EXTRACT(year FROM c.subscriptionDate) ORDER BY EXTRACT(year FROM c.subscriptionDate)) AS customerCount
  FROM `<proyecto>.p2_cohortes.customer` AS c
  WHERE
    c.country = (SELECT mccc.country FROM max_country_customer_count AS mccc)
),
max_subscription_by_year_max_country AS (
    SELECT
      symc.country,
      symc.subscriptionYear,
      symc.customerCount
    FROM suscriptions_by_year_max_country AS symc
    ORDER BY symc.customerCount DESC
    LIMIT 1
  ),
subscriptions_by_month_year_max_country AS (
  SELECT DISTINCT
    symc.country,
    symc.subscriptionYear,
    symc.customerCount,
    EXTRACT(month FROM c.subscriptionDate) AS subscriptionMonthNumber,
    CASE EXTRACT(month FROM c.subscriptionDate)
      WHEN 1 THEN "Enero"
      WHEN 2 THEN "Febrero"
      WHEN 3 THEN "Marzo"
      WHEN 4 THEN "Abril"
      WHEN 5 THEN "Mayo"
      WHEN 6 THEN "Junio"
      WHEN 7 THEN "Julio"
      WHEN 8 THEN "Agosto"
      WHEN 9 THEN "Septiembre"
      WHEN 10 THEN "Octubre"
      WHEN 11 THEN "Noviembre"
      ELSE "Diciembre"
    END
    AS subscriptionMonth,
    COUNT(c.customerID) OVER (PARTITION BY FORMAT_DATE('%b-%Y', c.subscriptionDate)) AS customerCountByMonth
  FROM suscriptions_by_year_max_country AS symc
  INNER JOIN `<proyecto>.p2_cohortes.customer` as c
  ON EXTRACT(year from c.subscriptionDate) = symc.subscriptionYear
  WHERE
    c.country = symc.country AND
    EXTRACT(year FROM c.subscriptionDate) = (
      SELECT msymc.subscriptionYear FROM max_subscription_by_year_max_country AS msymc
    )
  ORDER BY symc.subscriptionYear, subscriptionMonthNumber ASC
),
max_subscriptions_by_month_year_max_country AS (
  SELECT 
    smymc.country,
    smymc.subscriptionYear,
    smymc.customerCount,
    smymc.subscriptionMonthNumber,
    smymc.subscriptionMonth,
    smymc.customerCountByMonth
  FROM subscriptions_by_month_year_max_country AS smymc
  ORDER BY customerCountByMonth DESC
  LIMIT 1
),
detail_customers_by_year_month_max_country AS (
  SELECT
    c.customerID,
    CONCAT(c.firstName, ' ', c.lastName) AS customerName,
    c.country,
    c.city,
    c.subscriptionDate
  FROM `<proyecto>.p2_cohortes.customer` AS c
    WHERE 
      EXTRACT(year FROM c.subscriptionDate) = (SELECT msymmc.subscriptionYear FROM max_subscriptions_by_month_year_max_country AS msymmc) AND
      EXTRACT(month FROM c.subscriptionDate) = (SELECT msymmc.subscriptionMonthNumber FROM max_subscriptions_by_month_year_max_country AS msymmc) AND
      c.country = (SELECT msymmc.country FROM max_subscriptions_by_month_year_max_country AS msymmc)
  ORDER BY EXTRACT(day FROM c.subscriptionDate) ASC
),
detail_reviewers_by_year_month_max_country AS (
  SELECT
      c.customerID,
      cr.reviewerID,
      CONCAT(c.firstName, ' ', c.lastName) AS customerName,
      c.country,
      c.city,
      c.subscriptionDate
    FROM `<proyecto>.p2_cohortes.customer` AS c
    INNER JOIN `<proyecto>.p2_cohortes.customer_reviewer` AS cr
    ON cr.customerID = c.customerID 
      WHERE 
        EXTRACT(year FROM c.subscriptionDate) = (SELECT msymmc.subscriptionYear FROM max_subscriptions_by_month_year_max_country AS msymmc) AND
        EXTRACT(month FROM c.subscriptionDate) = (SELECT msymmc.subscriptionMonthNumber FROM max_subscriptions_by_month_year_max_country AS msymmc) AND
        c.country = (SELECT msymmc.country FROM max_subscriptions_by_month_year_max_country AS msymmc)
    ORDER BY EXTRACT(day FROM c.subscriptionDate) ASC
),
detail_reviews_by_year_month_max_country AS (
    SELECT 
      drymmc.customerID,
      drymmc.reviewerID,
      drymmc.customerName,
      drymmc.country,
      drymmc.city,
      drymmc.subscriptionDate,
      rdm.asin AS productID,
      rdm.reviewText,
      rdm.overall AS score,
      mdm.title,
      mdm.description,
      mdm.categories
    FROM detail_reviewers_by_year_month_max_country AS drymmc
    INNER JOIN `<proyecto>.p2_cohortes.review_digital_music` AS rdm
    ON rdm.reviewerID = drymmc.reviewerID
    INNER JOIN `<proyecto>.p2_cohortes.meta_digital_music` AS mdm
    ON mdm.asin = rdm.asin
)

SELECT DISTINCT
  category,
  COUNT(1) OVER (PARTITION BY category ORDER BY category) AS countByCategory
FROM detail_reviews_by_year_month_max_country AS drymmc,
UNNEST(drymmc.categories) AS category

/* se crea un reporte */
WITH customer_country_count AS (
    SELECT DISTINCT
      COUNT(c.customerID) OVER (PARTITION BY c.country) AS conteo,
      c.country
    FROM `<proyecto>.p2_cohortes.customer` AS c
),
max_country_customer_count AS (
    SELECT 
        ccc.conteo,
        ccc.country
    FROM customer_country_count AS ccc
    ORDER BY ccc.conteo DESC
    LIMIT 1
),
suscriptions_by_year_max_country AS (
  SELECT DISTINCT
    c.country,
    EXTRACT(year FROM c.subscriptionDate) AS subscriptionYear,
    COUNT(c.customerID) OVER (PARTITION BY EXTRACT(year FROM c.subscriptionDate) ORDER BY EXTRACT(year FROM c.subscriptionDate)) AS customerCount
  FROM `<proyecto>.p2_cohortes.customer` AS c
  WHERE
    c.country = (SELECT mccc.country FROM max_country_customer_count AS mccc)
),
max_subscription_by_year_max_country AS (
    SELECT
      symc.country,
      symc.subscriptionYear,
      symc.customerCount
    FROM suscriptions_by_year_max_country AS symc
    ORDER BY symc.customerCount DESC
    LIMIT 1
  ),
subscriptions_by_month_year_max_country AS (
  SELECT DISTINCT
    symc.country,
    symc.subscriptionYear,
    symc.customerCount,
    EXTRACT(month FROM c.subscriptionDate) AS subscriptionMonthNumber,
    CASE EXTRACT(month FROM c.subscriptionDate)
      WHEN 1 THEN "Enero"
      WHEN 2 THEN "Febrero"
      WHEN 3 THEN "Marzo"
      WHEN 4 THEN "Abril"
      WHEN 5 THEN "Mayo"
      WHEN 6 THEN "Junio"
      WHEN 7 THEN "Julio"
      WHEN 8 THEN "Agosto"
      WHEN 9 THEN "Septiembre"
      WHEN 10 THEN "Octubre"
      WHEN 11 THEN "Noviembre"
      ELSE "Diciembre"
    END
    AS subscriptionMonth,
    COUNT(c.customerID) OVER (PARTITION BY FORMAT_DATE('%b-%Y', c.subscriptionDate)) AS customerCountByMonth
  FROM suscriptions_by_year_max_country AS symc
  INNER JOIN `<proyecto>.p2_cohortes.customer` as c
  ON EXTRACT(year from c.subscriptionDate) = symc.subscriptionYear
  WHERE
    c.country = symc.country AND
    EXTRACT(year FROM c.subscriptionDate) = (
      SELECT msymc.subscriptionYear FROM max_subscription_by_year_max_country AS msymc
    )
  ORDER BY symc.subscriptionYear, subscriptionMonthNumber ASC
),
max_subscriptions_by_month_year_max_country AS (
  SELECT 
    smymc.country,
    smymc.subscriptionYear,
    smymc.customerCount,
    smymc.subscriptionMonthNumber,
    smymc.subscriptionMonth,
    smymc.customerCountByMonth
  FROM subscriptions_by_month_year_max_country AS smymc
  ORDER BY customerCountByMonth DESC
  LIMIT 1
),
detail_customers_by_year_month_max_country AS (
  SELECT
    c.customerID,
    CONCAT(c.firstName, ' ', c.lastName) AS customerName,
    c.country,
    c.city,
    c.subscriptionDate
  FROM `<proyecto>.p2_cohortes.customer` AS c
    WHERE 
      EXTRACT(year FROM c.subscriptionDate) = (SELECT msymmc.subscriptionYear FROM max_subscriptions_by_month_year_max_country AS msymmc) AND
      EXTRACT(month FROM c.subscriptionDate) = (SELECT msymmc.subscriptionMonthNumber FROM max_subscriptions_by_month_year_max_country AS msymmc) AND
      c.country = (SELECT msymmc.country FROM max_subscriptions_by_month_year_max_country AS msymmc)
  ORDER BY EXTRACT(day FROM c.subscriptionDate) ASC
),
detail_reviewers_by_year_month_max_country AS (
  SELECT
      c.customerID,
      cr.reviewerID,
      CONCAT(c.firstName, ' ', c.lastName) AS customerName,
      c.country,
      c.city,
      c.subscriptionDate
    FROM `<proyecto>.p2_cohortes.customer` AS c
    INNER JOIN `<proyecto>.p2_cohortes.customer_reviewer` AS cr
    ON cr.customerID = c.customerID 
      WHERE 
        EXTRACT(year FROM c.subscriptionDate) = (SELECT msymmc.subscriptionYear FROM max_subscriptions_by_month_year_max_country AS msymmc) AND
        EXTRACT(month FROM c.subscriptionDate) = (SELECT msymmc.subscriptionMonthNumber FROM max_subscriptions_by_month_year_max_country AS msymmc) AND
        c.country = (SELECT msymmc.country FROM max_subscriptions_by_month_year_max_country AS msymmc)
    ORDER BY EXTRACT(day FROM c.subscriptionDate) ASC
),
detail_reviews_by_year_month_max_country AS (
    SELECT 
      drymmc.customerID,
      drymmc.reviewerID,
      drymmc.customerName,
      drymmc.country,
      drymmc.city,
      drymmc.subscriptionDate,
      rdm.asin AS productID,
      rdm.reviewText,
      rdm.overall AS score,
      mdm.title,
      mdm.description,
      mdm.categories
    FROM detail_reviewers_by_year_month_max_country AS drymmc
    INNER JOIN `<proyecto>.p2_cohortes.review_digital_music` AS rdm
    ON rdm.reviewerID = drymmc.reviewerID
    INNER JOIN `<proyecto>.p2_cohortes.meta_digital_music` AS mdm
    ON mdm.asin = rdm.asin
),
count_categories_by_max_year_month_country AS (
    SELECT DISTINCT
        category,
        COUNT(1) OVER (PARTITION BY category ORDER BY category) AS countByCategory
    FROM detail_reviews_by_year_month_max_country AS drymmc,
    UNNEST(drymmc.categories) AS category
),
report AS (
  SELECT 
    "Country Name" AS name, 
    msymmc.country AS value, 
    1 AS sortby 
  FROM max_subscriptions_by_month_year_max_country AS msymmc
  UNION ALL
  SELECT 
    "Year with max customer subscription" AS name, 
    CAST(msymmc.subscriptionYear AS string) AS value, 
    2 AS sortby 
  FROM max_subscriptions_by_month_year_max_country AS msymmc
  UNION ALL
  SELECT DISTINCT
    "Total customer subscription in year" AS name, 
    CAST(smymc.customerCount AS string) AS value, 
    3 AS sortby 
  FROM subscriptions_by_month_year_max_country AS smymc
  UNION ALL
  SELECT DISTINCT
    "Month with max customer subscription" AS name, 
    msmymc.subscriptionMonth AS value, 
    4 AS sortby 
  FROM max_subscriptions_by_month_year_max_country AS msmymc
  UNION ALL
  SELECT 
    "Total customers in month" AS name, 
    CAST(COUNT(dcymmc.customerID) AS string) AS value, 
    5 AS sortby 
  FROM detail_customers_by_year_month_max_country AS dcymmc
  UNION ALL
  SELECT 
    "Total customers with reviews in month" AS name, 
    CAST(COUNT(drymmc.customerID) AS string) AS value, 
    6 AS sortby 
  FROM detail_reviewers_by_year_month_max_country AS drymmc
  UNION ALL
  SELECT 
    "Retention percentage" AS name, 
    CAST(
      (
        (SELECT COUNT(drymmc.customerID) FROM detail_reviewers_by_year_month_max_country AS drymmc) * 100 /
        (SELECT COUNT(dcymmc.customerID) FROM detail_customers_by_year_month_max_country AS dcymmc) 
      ) AS string
    ) AS value, 
    7 AS sortby
  UNION ALL
  (SELECT 
    ccmymc.category AS name, 
    CAST(ccmymc.countByCategory AS string) AS value,
    8 AS sortby,
  FROM count_categories_by_max_year_month_country AS ccmymc
  ORDER BY ccmymc.countByCategory DESC)
  
  ORDER BY sortby
)

SELECT
    name,
    value
FROM report
ORDER BY report.sortby

/* se crea una tabla con los resultados del reporte previo */
CREATE OR REPLACE TABLE `<proyecto>.p2_cohortes.report_segmentation` AS (
    WITH customer_country_count AS (
        SELECT DISTINCT
        COUNT(c.customerID) OVER (PARTITION BY c.country) AS conteo,
        c.country
        FROM `<proyecto>.p2_cohortes.customer` AS c
    ),
    max_country_customer_count AS (
        SELECT 
            ccc.conteo,
            ccc.country
        FROM customer_country_count AS ccc
        ORDER BY ccc.conteo DESC
        LIMIT 1
    ),
    suscriptions_by_year_max_country AS (
    SELECT DISTINCT
        c.country,
        EXTRACT(year FROM c.subscriptionDate) AS subscriptionYear,
        COUNT(c.customerID) OVER (PARTITION BY EXTRACT(year FROM c.subscriptionDate) ORDER BY EXTRACT(year FROM c.subscriptionDate)) AS customerCount
    FROM `<proyecto>.p2_cohortes.customer` AS c
    WHERE
        c.country = (SELECT mccc.country FROM max_country_customer_count AS mccc)
    ),
    max_subscription_by_year_max_country AS (
        SELECT
        symc.country,
        symc.subscriptionYear,
        symc.customerCount
        FROM suscriptions_by_year_max_country AS symc
        ORDER BY symc.customerCount DESC
        LIMIT 1
    ),
    subscriptions_by_month_year_max_country AS (
    SELECT DISTINCT
        symc.country,
        symc.subscriptionYear,
        symc.customerCount,
        EXTRACT(month FROM c.subscriptionDate) AS subscriptionMonthNumber,
        CASE EXTRACT(month FROM c.subscriptionDate)
        WHEN 1 THEN "Enero"
        WHEN 2 THEN "Febrero"
        WHEN 3 THEN "Marzo"
        WHEN 4 THEN "Abril"
        WHEN 5 THEN "Mayo"
        WHEN 6 THEN "Junio"
        WHEN 7 THEN "Julio"
        WHEN 8 THEN "Agosto"
        WHEN 9 THEN "Septiembre"
        WHEN 10 THEN "Octubre"
        WHEN 11 THEN "Noviembre"
        ELSE "Diciembre"
        END
        AS subscriptionMonth,
        COUNT(c.customerID) OVER (PARTITION BY FORMAT_DATE('%b-%Y', c.subscriptionDate)) AS customerCountByMonth
    FROM suscriptions_by_year_max_country AS symc
    INNER JOIN `<proyecto>.p2_cohortes.customer` as c
    ON EXTRACT(year from c.subscriptionDate) = symc.subscriptionYear
    WHERE
        c.country = symc.country AND
        EXTRACT(year FROM c.subscriptionDate) = (
        SELECT msymc.subscriptionYear FROM max_subscription_by_year_max_country AS msymc
        )
    ORDER BY symc.subscriptionYear, subscriptionMonthNumber ASC
    ),
    max_subscriptions_by_month_year_max_country AS (
    SELECT 
        smymc.country,
        smymc.subscriptionYear,
        smymc.customerCount,
        smymc.subscriptionMonthNumber,
        smymc.subscriptionMonth,
        smymc.customerCountByMonth
    FROM subscriptions_by_month_year_max_country AS smymc
    ORDER BY customerCountByMonth DESC
    LIMIT 1
    ),
    detail_customers_by_year_month_max_country AS (
    SELECT
        c.customerID,
        CONCAT(c.firstName, ' ', c.lastName) AS customerName,
        c.country,
        c.city,
        c.subscriptionDate
    FROM `<proyecto>.p2_cohortes.customer` AS c
        WHERE 
        EXTRACT(year FROM c.subscriptionDate) = (SELECT msymmc.subscriptionYear FROM max_subscriptions_by_month_year_max_country AS msymmc) AND
        EXTRACT(month FROM c.subscriptionDate) = (SELECT msymmc.subscriptionMonthNumber FROM max_subscriptions_by_month_year_max_country AS msymmc) AND
        c.country = (SELECT msymmc.country FROM max_subscriptions_by_month_year_max_country AS msymmc)
    ORDER BY EXTRACT(day FROM c.subscriptionDate) ASC
    ),
    detail_reviewers_by_year_month_max_country AS (
    SELECT
        c.customerID,
        cr.reviewerID,
        CONCAT(c.firstName, ' ', c.lastName) AS customerName,
        c.country,
        c.city,
        c.subscriptionDate
        FROM `<proyecto>.p2_cohortes.customer` AS c
        INNER JOIN `<proyecto>.p2_cohortes.customer_reviewer` AS cr
        ON cr.customerID = c.customerID 
        WHERE 
            EXTRACT(year FROM c.subscriptionDate) = (SELECT msymmc.subscriptionYear FROM max_subscriptions_by_month_year_max_country AS msymmc) AND
            EXTRACT(month FROM c.subscriptionDate) = (SELECT msymmc.subscriptionMonthNumber FROM max_subscriptions_by_month_year_max_country AS msymmc) AND
            c.country = (SELECT msymmc.country FROM max_subscriptions_by_month_year_max_country AS msymmc)
        ORDER BY EXTRACT(day FROM c.subscriptionDate) ASC
    ),
    detail_reviews_by_year_month_max_country AS (
        SELECT 
        drymmc.customerID,
        drymmc.reviewerID,
        drymmc.customerName,
        drymmc.country,
        drymmc.city,
        drymmc.subscriptionDate,
        rdm.asin AS productID,
        rdm.reviewText,
        rdm.overall AS score,
        mdm.title,
        mdm.description,
        mdm.categories
        FROM detail_reviewers_by_year_month_max_country AS drymmc
        INNER JOIN `<proyecto>.p2_cohortes.review_digital_music` AS rdm
        ON rdm.reviewerID = drymmc.reviewerID
        INNER JOIN `<proyecto>.p2_cohortes.meta_digital_music` AS mdm
        ON mdm.asin = rdm.asin
    ),
    count_categories_by_max_year_month_country AS (
        SELECT DISTINCT
            category,
            COUNT(1) OVER (PARTITION BY category ORDER BY category) AS countByCategory
        FROM detail_reviews_by_year_month_max_country AS drymmc,
        UNNEST(drymmc.categories) AS category
    ),
    report AS (
    SELECT 
        "Country Name" AS name, 
        msymmc.country AS value, 
        1 AS sortby 
    FROM max_subscriptions_by_month_year_max_country AS msymmc
    UNION ALL
    SELECT 
        "Year with max customer subscription" AS name, 
        CAST(msymmc.subscriptionYear AS string) AS value, 
        2 AS sortby 
    FROM max_subscriptions_by_month_year_max_country AS msymmc
    UNION ALL
    SELECT DISTINCT
        "Total customer subscription in year" AS name, 
        CAST(smymc.customerCount AS string) AS value, 
        3 AS sortby 
    FROM subscriptions_by_month_year_max_country AS smymc
    UNION ALL
    SELECT DISTINCT
        "Month with max customer subscription" AS name, 
        msmymc.subscriptionMonth AS value, 
        4 AS sortby 
    FROM max_subscriptions_by_month_year_max_country AS msmymc
    UNION ALL
    SELECT 
        "Total customers in month" AS name, 
        CAST(COUNT(dcymmc.customerID) AS string) AS value, 
        5 AS sortby 
    FROM detail_customers_by_year_month_max_country AS dcymmc
    UNION ALL
    SELECT 
        "Total customers with reviews in month" AS name, 
        CAST(COUNT(drymmc.customerID) AS string) AS value, 
        6 AS sortby 
    FROM detail_reviewers_by_year_month_max_country AS drymmc
    UNION ALL
    SELECT 
        "Retention percentage" AS name, 
        CAST(
        (
            (SELECT COUNT(drymmc.customerID) FROM detail_reviewers_by_year_month_max_country AS drymmc) * 100 /
            (SELECT COUNT(dcymmc.customerID) FROM detail_customers_by_year_month_max_country AS dcymmc) 
        ) AS string
        ) AS value, 
        7 AS sortby
    UNION ALL
    (SELECT 
        ccmymc.category AS name, 
        CAST(ccmymc.countByCategory AS string) AS value,
        8 AS sortby,
    FROM count_categories_by_max_year_month_country AS ccmymc
    ORDER BY ccmymc.countByCategory DESC)
    
    ORDER BY sortby
    )

    SELECT
        name,
        value
    FROM report
    ORDER BY report.sortby
)