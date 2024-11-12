-- Listado de años y su conteo de reviews. 

SELECT DISTINCT
  EXTRACT(year FROM DATE(CAST(SUBSTR(rdm.reviewTime, -4) AS INT64), CAST(SUBSTR(rdm.reviewTime, 0 , 2) AS INT64), CAST(SUBSTR(rdm.reviewTime, -8, 2) AS INT64))) AS reviewYear,
  COUNT(rdm.reviewerID) OVER (PARTITION BY 
    EXTRACT(year FROM DATE(CAST(SUBSTR(rdm.reviewTime, -4) AS INT64), CAST(SUBSTR(rdm.reviewTime, 0 , 2) AS INT64), CAST(SUBSTR(rdm.reviewTime, -8, 2) AS INT64)))
  ) AS reviewsCount
FROM
  `<proyecto>.<dataset>.review_digital_music` AS rdm
ORDER BY reviewsCount DESC

-- Del año con mayor número de reviews obtener el conteo de categorías.

WITH count_years_reviews AS (
  /* conteo de reviews por año */
  SELECT DISTINCT
    EXTRACT(year FROM DATE(CAST(SUBSTR(rdm.reviewTime, -4) AS INT64), CAST(SUBSTR(rdm.reviewTime, 0 , 2) AS INT64), CAST(SUBSTR(rdm.reviewTime, -8, 2) AS INT64))) AS reviewYear,
    COUNT(rdm.reviewerID) OVER (PARTITION BY 
      EXTRACT(year FROM DATE(CAST(SUBSTR(rdm.reviewTime, -4) AS INT64), CAST(SUBSTR(rdm.reviewTime, 0 , 2) AS INT64), CAST(SUBSTR(rdm.reviewTime, -8, 2) AS INT64)))
    ) AS reviewsCount
  FROM
    `<proyecto>.<dataset>.review_digital_music` AS rdm
  ORDER BY reviewsCount DESC
)

SELECT
    cyr.reviewYear,
    cyr.reviewsCount
FROM count_years_reviews AS cyr
LIMIT 1

-- conteos del último año como CTE:
max_count_years AS (
  SELECT
      cyr.reviewYear,
      cyr.reviewsCount
  FROM count_years_reviews AS cyr
  LIMIT 1
),

SELECT 
  EXTRACT(year FROM DATE(CAST(SUBSTR(rdm.reviewTime, -4) AS INT64), CAST(SUBSTR(rdm.reviewTime, 0 , 2) AS INT64), CAST(SUBSTR(rdm.reviewTime, -8, 2) AS INT64))) AS reviewYear,
  mdm.categories
FROM `<proyecto>.<dataset>.review_digital_music` AS rdm
INNER JOIN `<proyecto>.<dataset>.meta_digital_music` AS mdm
ON mdm.asin = rdm.asin
WHERE 
  EXTRACT(year FROM DATE(CAST(SUBSTR(rdm.reviewTime, -4) AS INT64), CAST(SUBSTR(rdm.reviewTime, 0 , 2) AS INT64), CAST(SUBSTR(rdm.reviewTime, -8, 2) AS INT64))) = (
    SELECT mcy.reviewYear FROM max_count_years AS mcy
)

-- categorías como CTE:

categories_by_year AS (
  SELECT 
    EXTRACT(year FROM DATE(CAST(SUBSTR(rdm.reviewTime, -4) AS INT64), CAST(SUBSTR(rdm.reviewTime, 0 , 2) AS INT64), CAST(SUBSTR(rdm.reviewTime, -8, 2) AS INT64))) AS reviewYear,
    mdm.categories
  FROM `<proyecto>.<dataset>.review_digital_music` AS rdm
  INNER JOIN `<proyecto>.<dataset>.meta_digital_music` AS mdm
  ON mdm.asin = rdm.asin
  WHERE 
    EXTRACT(year FROM DATE(CAST(SUBSTR(rdm.reviewTime, -4) AS INT64), CAST(SUBSTR(rdm.reviewTime, 0 , 2) AS INT64), CAST(SUBSTR(rdm.reviewTime, -8, 2) AS INT64))) = (
      SELECT mcy.reviewYear FROM max_count_years AS mcy
    )
)

SELECT DISTINCT
  cy.reviewYear,
  category,
  COUNT(1) OVER (PARTITION BY category) AS countByCategory
FROM categories_by_year AS cy,
UNNEST(cy.categories) AS category

-- categoría más alta
count_categories_by_max_year AS (
  SELECT DISTINCT
    cy.reviewYear,
    category,
    COUNT(1) OVER (PARTITION BY category) AS countByCategory
  FROM categories_by_year AS cy,
  UNNEST(cy.categories) AS category
)

SELECT
  ccmy.reviewYear,
  ccmy.category,
  ccmy.countByCategory
FROM count_categories_by_max_year AS ccmy
ORDER BY ccmy.countByCategory DESC
LIMIT 1

-- conteo por mes para la categoría más alta
max_count_categories_by_max_year AS (
  SELECT
    ccmy.reviewYear,
    ccmy.category,
    ccmy.countByCategory
  FROM count_categories_by_max_year AS ccmy
  ORDER BY ccmy.countByCategory DESC
  LIMIT 1
)

SELECT 
  EXTRACT(year FROM DATE(CAST(SUBSTR(rdm.reviewTime, -4) AS INT64), CAST(SUBSTR(rdm.reviewTime, 0 , 2) AS INT64), CAST(SUBSTR(rdm.reviewTime, -8, 2) AS INT64))) AS reviewYear,
  EXTRACT(month FROM DATE(CAST(SUBSTR(rdm.reviewTime, -4) AS INT64), CAST(SUBSTR(rdm.reviewTime, 0 , 2) AS INT64), CAST(SUBSTR(rdm.reviewTime, -8, 2) AS INT64))) AS reviewMonthNumber,
  CASE EXTRACT(month FROM DATE(CAST(SUBSTR(rdm.reviewTime, -4) AS INT64), CAST(SUBSTR(rdm.reviewTime, 0 , 2) AS INT64), CAST(SUBSTR(rdm.reviewTime, -8, 2) AS INT64)))
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
  AS reviewmonth,
  mdm.categories
FROM `<proyecto>.<dataset>.review_digital_music` AS rdm
INNER JOIN `<proyecto>.<dataset>.meta_digital_music` AS mdm
ON mdm.asin = rdm.asin
WHERE 
  EXTRACT(year FROM DATE(CAST(SUBSTR(rdm.reviewTime, -4) AS INT64), CAST(SUBSTR(rdm.reviewTime, 0 , 2) AS INT64), CAST(SUBSTR(rdm.reviewTime, -8, 2) AS INT64))) = (
    SELECT mcy.reviewYear FROM max_count_years AS mcy
  )

-- robusteciendo el listado:
categories_by_month_max_year AS (
  SELECT 
    EXTRACT(year FROM DATE(CAST(SUBSTR(rdm.reviewTime, -4) AS INT64), CAST(SUBSTR(rdm.reviewTime, 0 , 2) AS INT64), CAST(SUBSTR(rdm.reviewTime, -8, 2) AS INT64))) AS reviewYear,
    EXTRACT(month FROM DATE(CAST(SUBSTR(rdm.reviewTime, -4) AS INT64), CAST(SUBSTR(rdm.reviewTime, 0 , 2) AS INT64), CAST(SUBSTR(rdm.reviewTime, -8, 2) AS INT64))) AS reviewMonthNumber,
    CASE EXTRACT(month FROM DATE(CAST(SUBSTR(rdm.reviewTime, -4) AS INT64), CAST(SUBSTR(rdm.reviewTime, 0 , 2) AS INT64), CAST(SUBSTR(rdm.reviewTime, -8, 2) AS INT64)))
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
    AS reviewmonth,
    mdm.categories
  FROM `<proyecto>.<dataset>.review_digital_music` AS rdm
  INNER JOIN `<proyecto>.<dataset>.meta_digital_music` AS mdm
  ON mdm.asin = rdm.asin
  WHERE 
    EXTRACT(year FROM DATE(CAST(SUBSTR(rdm.reviewTime, -4) AS INT64), CAST(SUBSTR(rdm.reviewTime, 0 , 2) AS INT64), CAST(SUBSTR(rdm.reviewTime, -8, 2) AS INT64))) = (
      SELECT mcy.reviewYear FROM max_count_years AS mcy
    )
)

SELECT DISTINCT
    cmmy.reviewYear,
    cmmy.reviewMonthNumber,
    cmmy.reviewMonth,
    category,
    COUNT(category) AS countReviews
  FROM categories_by_month_max_year AS cmmy,
  UNNEST(cmmy.categories) AS category
  GROUP BY category, reviewMonthNumber, reviewMonth, reviewYear
  ORDER BY cmmy.reviewMonthNumber, category

-- listado final:

count_categories_by_month_max_year AS (
  SELECT DISTINCT
    cmmy.reviewYear,
    cmmy.reviewMonthNumber,
    cmmy.reviewMonth,
    category,
    COUNT(category) AS countReviews
  FROM categories_by_month_max_year AS cmmy,
  UNNEST(cmmy.categories) AS category
  GROUP BY category, reviewMonthNumber, reviewMonth, reviewYear
  ORDER BY cmmy.reviewMonthNumber, category
)

SELECT 
  ccmmy.reviewYear,
  ccmmy.reviewMonth,
  ccmmy.category,
  ccmmy.countReviews,
  ROW_NUMBER() OVER (ORDER BY ccmmy.countReviews) AS orderCountReviews,
  LAG(ccmmy.countReviews) OVER (ORDER BY ccmmy.reviewYear) AS lagCountReviews,
  LEAD(ccmmy.countReviews) OVER (ORDER BY ccmmy.reviewYear) AS leadCountReviews
FROM count_categories_by_month_max_year AS ccmmy 
WHERE 
  ccmmy.category IN (
    SELECT
      mccmy.category
    FROM max_count_categories_by_max_year AS mccmy
  )
ORDER BY ccmmy.reviewMonthNumber

--

WITH count_years_reviews AS (
  /* conteo de reviews por año */
  SELECT DISTINCT
    EXTRACT(year FROM DATE(CAST(SUBSTR(rdm.reviewTime, -4) AS INT64), CAST(SUBSTR(rdm.reviewTime, 0 , 2) AS INT64), CAST(SUBSTR(rdm.reviewTime, -8, 2) AS INT64))) AS reviewYear,
    COUNT(rdm.reviewerID) OVER (PARTITION BY 
      EXTRACT(year FROM DATE(CAST(SUBSTR(rdm.reviewTime, -4) AS INT64), CAST(SUBSTR(rdm.reviewTime, 0 , 2) AS INT64), CAST(SUBSTR(rdm.reviewTime, -8, 2) AS INT64)))
    ) AS reviewsCount
  FROM
    `<proyecto>.<dataset>.review_digital_music` AS rdm
  ORDER BY reviewsCount DESC
),
max_count_years AS (
  SELECT
      cyr.reviewYear,
      cyr.reviewsCount
  FROM count_years_reviews AS cyr
  LIMIT 1
),
categories_by_year AS (
  SELECT 
    EXTRACT(year FROM DATE(CAST(SUBSTR(rdm.reviewTime, -4) AS INT64), CAST(SUBSTR(rdm.reviewTime, 0 , 2) AS INT64), CAST(SUBSTR(rdm.reviewTime, -8, 2) AS INT64))) AS reviewYear,
    mdm.categories
  FROM `<proyecto>.<dataset>.review_digital_music` AS rdm
  INNER JOIN `<proyecto>.<dataset>.meta_digital_music` AS mdm
  ON mdm.asin = rdm.asin
  WHERE 
    EXTRACT(year FROM DATE(CAST(SUBSTR(rdm.reviewTime, -4) AS INT64), CAST(SUBSTR(rdm.reviewTime, 0 , 2) AS INT64), CAST(SUBSTR(rdm.reviewTime, -8, 2) AS INT64))) = (
      SELECT mcy.reviewYear FROM max_count_years AS mcy
    )
),count_categories_by_max_year AS (
  SELECT DISTINCT
    cy.reviewYear,
    category,
    COUNT(1) OVER (PARTITION BY category) AS countByCategory
  FROM categories_by_year AS cy,
  UNNEST(cy.categories) AS category
),max_count_categories_by_max_year AS (
  SELECT
    ccmy.reviewYear,
    ccmy.category,
    ccmy.countByCategory
  FROM count_categories_by_max_year AS ccmy
  ORDER BY ccmy.countByCategory DESC
  LIMIT 1
),categories_by_month_max_year AS (
  SELECT 
    EXTRACT(year FROM DATE(CAST(SUBSTR(rdm.reviewTime, -4) AS INT64), CAST(SUBSTR(rdm.reviewTime, 0 , 2) AS INT64), CAST(SUBSTR(rdm.reviewTime, -8, 2) AS INT64))) AS reviewYear,
    EXTRACT(month FROM DATE(CAST(SUBSTR(rdm.reviewTime, -4) AS INT64), CAST(SUBSTR(rdm.reviewTime, 0 , 2) AS INT64), CAST(SUBSTR(rdm.reviewTime, -8, 2) AS INT64))) AS reviewMonthNumber,
    CASE EXTRACT(month FROM DATE(CAST(SUBSTR(rdm.reviewTime, -4) AS INT64), CAST(SUBSTR(rdm.reviewTime, 0 , 2) AS INT64), CAST(SUBSTR(rdm.reviewTime, -8, 2) AS INT64)))
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
    AS reviewmonth,
    mdm.categories
  FROM `<proyecto>.<dataset>.review_digital_music` AS rdm
  INNER JOIN `<proyecto>.<dataset>.meta_digital_music` AS mdm
  ON mdm.asin = rdm.asin
  WHERE 
    EXTRACT(year FROM DATE(CAST(SUBSTR(rdm.reviewTime, -4) AS INT64), CAST(SUBSTR(rdm.reviewTime, 0 , 2) AS INT64), CAST(SUBSTR(rdm.reviewTime, -8, 2) AS INT64))) = (
      SELECT mcy.reviewYear FROM max_count_years AS mcy
    )
),
count_categories_by_month_max_year AS (
  SELECT DISTINCT
    cmmy.reviewYear,
    cmmy.reviewMonthNumber,
    cmmy.reviewMonth,
    category,
    COUNT(category) AS countReviews
  FROM categories_by_month_max_year AS cmmy,
  UNNEST(cmmy.categories) AS category
  GROUP BY category, reviewMonthNumber, reviewMonth, reviewYear
  ORDER BY cmmy.reviewMonthNumber, category
)

SELECT 
  ccmmy.reviewYear,
  ccmmy.reviewMonth,
  ccmmy.category,
  ccmmy.countReviews,
  ROW_NUMBER() OVER (ORDER BY ccmmy.countReviews) AS orderCountReviews,
  LAG(ccmmy.countReviews) OVER (ORDER BY ccmmy.reviewYear) AS lagCountReviews,
  LEAD(ccmmy.countReviews) OVER (ORDER BY ccmmy.reviewYear) AS leadCountReviews
FROM count_categories_by_month_max_year AS ccmmy 
WHERE 
  ccmmy.category IN (
    SELECT
      mccmy.category
    FROM max_count_categories_by_max_year AS mccmy
  )
ORDER BY ccmmy.reviewMonthNumber