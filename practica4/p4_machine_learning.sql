/*
  Pasos a seguir:
  - Exploramos un poco nuestro dataset
  - vemos que datos podemos obtener, tales como:
    - total de visitantes
    - total de visitantes que han realizado compras en mi sitio
    - total de visitantes que han realizado compras en su primer visita contra aquellos que compraron hasta visitas posteriores
  - Creamos un modelo de clasificación que nos permita determinar bajos ciertos parámetros que compra corresponde a uno de los dos casos que detectamos previamente
*/

-- exploración del dataset

/* paso 1 (taza conversión) */
WITH visitors AS(
  SELECT
  COUNT(DISTINCT fullVisitorId) AS total_visitors
  FROM `<proyecto>.p4_machine_learning.web_analytics`
),
purchasers AS(
SELECT
  COUNT(DISTINCT fullVisitorId) AS total_purchasers
  FROM `<proyecto>.p4_machine_learning.web_analytics`
  WHERE totals.transactions IS NOT NULL
)

SELECT
  total_visitors,
  total_purchasers,
  (total_purchasers / total_visitors) * 100 AS conversion_rate
FROM visitors, purchasers
/* paso 1 */

/*. paso 2 (5 productos más vendidos) */
SELECT
  p.productSKU AS productSKU,
  p.v2ProductName AS productName,
  p.v2ProductCategory AS productCategory,
  SUM(p.productQuantity) AS units_sold,
  ROUND(SUM(p.localProductRevenue),2) AS revenue -- ganancias
FROM `<proyecto>.p4_machine_learning.web_analytics`,
UNNEST(hits) AS h,
UNNEST(h.product) AS p
WHERE 
  p.productQuantity IS NOT NULL AND
  p.localProductRevenue IS NOT NULL AND
  h.eCommerceAction.action_type = "6" -- compra concretada
GROUP BY productSKU, productName, productCategory
ORDER BY revenue DESC
LIMIT 5;

-- detalle de la query de productos
SELECT 
  p.productSKU,
  p.V2ProductName,
  p.localProductRevenue,
  p.productQuantity
FROM `<proyecto>.p4_machine_learning.web_analytics` AS wa,
UNNEST(wa.hits) AS h,
UNNEST(h.product) AS p
WHERE p.productSKU = "GGOENEBJ079499" AND
  p.productQuantity IS NOT NULL AND
  p.localProductRevenue IS NOT NULL AND
  h.eCommerceAction.action_type = "6" -- compra concretada
LIMIT 1000

/* paso 2 (5 productos más vendidos) */

/* paso 3 (total de visitantes que volveran contra aquellos que no) */
-- detalle visitantes
SELECT
  wa.fullVisitorId,
  wa.totals.transactions,
  wa.totals.newVisits
FROM `<proyecto>.p4_machine_learning.web_analytics` AS wa
LIMIT 1000

-- estadísticos
WITH all_visitor_stats AS (
  SELECT
    wa.fullVisitorId,
    IF(COUNTIF(wa.totals.transactions > 0 AND wa.totals.newVisits IS NULL) > 0, 0, 1) AS willBuyOnReturnVisit
  FROM `<proyecto>.p4_machine_learning.web_analytics` AS wa,
  UNNEST(wa.hits) AS h
  WHERE 
    h.eCommerceAction.action_type = "6" -- compra concretada
  GROUP BY wa.fullVisitorId
),
count_all_visitor_stats AS (
  SELECT
    COUNT(DISTINCT avs.fullVisitorId) AS totalVisitors,
    avs.willBuyOnReturnVisit
  FROM all_visitor_stats AS avs
  GROUP BY avs.willBuyOnReturnVisit
),
count_users_willBuyOnReturnVisit AS (
  SELECT 
    cavs.totalVisitors
  FROM count_all_visitor_stats AS cavs
  WHERE cavs.willBuyOnReturnVisit = 0
),
count_users_will_buy_on_first_visit AS (
  SELECT 
    cavs.totalVisitors
  FROM count_all_visitor_stats AS cavs
  WHERE cavs.willBuyOnReturnVisit = 1
),
report AS (
  SELECT 
    CASE cavs.willBuyOnReturnVisit
      WHEN 1 THEN "Clientes que compraron en su primer visita"
      WHEN 0 THEN "Clientes que compraron hasta su próxima visita"
    END
    AS name,
    cavs.totalVisitors AS value,
    1 AS sortby
  FROM count_all_visitor_stats AS cavs
)

SELECT
  r.name,
  r.value
FROM report AS r
ORDER BY
  r.sortby
/* paso 3 (total de visitantes que volveran contra aquellos que no) */

-- exploración del dataset

-- paso 4.- crear un modelo de clasificación
-- mas detalle tabla web_analytics 
SELECT
  wa.fullVisitorId,
  wa.totals.transactions,
  wa.totals.newVisits,
  wa.totals.bounces,
  wa.totals.timeOnSite
FROM `<proyecto>.p4_machine_learning.web_analytics` AS wa
LIMIT 1000

-- conjunto de datos de entrenamiento
WITH all_visitor_stats AS (
  SELECT
    wa.fullVisitorId,
    IF(COUNTIF(totals.transactions > 0 AND totals.newVisits IS NULL) > 0, 0, 1) AS willBuyOnReturnVisit
  FROM `<proyecto>.p4_machine_learning.web_analytics` AS wa,
  UNNEST(wa.hits) AS h
  WHERE 
    h.eCommerceAction.action_type = "6" -- compra concretada
  GROUP BY wa.fullVisitorId
)

SELECT
  * EXCEPT(fullVisitorId)
FROM (
    SELECT
    fullVisitorId,
    IFNULL(totals.bounces, 0) AS bounces,
    IFNULL(totals.timeOnSite, 0) AS timeOnSite
  FROM
    `<proyecto>.p4_machine_learning.web_analytics`
  WHERE
    totals.newVisits = 1
  )
  JOIN all_visitor_stats USING(fullVisitorId)
ORDER BY timeOnSite DESC
LIMIT 1000000;

-- crear un modelo de clasificación
CREATE OR REPLACE MODEL `p4_machine_learning.classification_model`
OPTIONS
  (model_type='logistic_reg', labels = ['willBuyOnReturnVisit']) AS
  WITH all_visitor_stats AS (
    SELECT
      wa.fullVisitorId,
      IF(COUNTIF(totals.transactions > 0 AND totals.newVisits IS NULL) > 0, 0, 1) AS willBuyOnReturnVisit
    FROM `<proyecto>.p4_machine_learning.web_analytics` AS wa,
    UNNEST(wa.hits) AS h
    WHERE 
      h.eCommerceAction.action_type = "6" -- compra concretada
    GROUP BY wa.fullVisitorId
  )
  
  SELECT
    * EXCEPT(fullVisitorId)
  FROM (
    SELECT
    fullVisitorId,
    IFNULL(totals.bounces, 0) AS bounces,
    IFNULL(totals.timeOnSite, 0) AS timeOnSite
  FROM
    `<proyecto>.p4_machine_learning.web_analytics`
  WHERE
    totals.newVisits = 1
    AND date BETWEEN '20160101' AND '20161231'
  )
  JOIN all_visitor_stats USING(fullVisitorId);

-- evaluación y rendimiento del modelo
SELECT
  roc_auc,
  CASE
    WHEN roc_auc > .9 THEN 'bueno'
    WHEN roc_auc > .8 THEN 'regular'
    WHEN roc_auc > .7 THEN 'decente'
    WHEN roc_auc > .6 THEN 'no tan mal'
  ELSE 'malo' 
  END 
  AS model_quality
FROM
  ML.EVALUATE(
    MODEL p4_machine_learning.classification_model,  
    (
      WITH all_visitor_stats AS (
        SELECT
            wa.fullVisitorId,
            IF(COUNTIF(totals.transactions > 0 AND totals.newVisits IS NULL) > 0, 0, 1) AS willBuyOnReturnVisit
          FROM `<proyecto>.p4_machine_learning.web_analytics` AS wa,
          UNNEST(wa.hits) AS h
          WHERE 
            h.eCommerceAction.action_type = "6" -- compra concretada
          GROUP BY wa.fullVisitorId
        )

      SELECT
        * EXCEPT(fullVisitorId)
      FROM
        (
          SELECT
          fullVisitorId,
          IFNULL(totals.bounces, 0) AS bounces,
          IFNULL(totals.timeOnSite, 0) AS timeOnSite
        FROM
          `<proyecto>.p4_machine_learning.web_analytics`
        WHERE
          AND date BETWEEN '20170101' AND '20170228'
        )
        JOIN all_visitor_stats USING(fullVisitorId)
    )
  );

-- evaluar y mejorar el rendimiento del modelo
-- detalles nuevos campos para entrenar modelo
SELECT
  wa1.fullVisitorId,
  wa1.visitId,
  h.eCommerceAction.action_type,
  wa1.totals.bounces,
  wa1.totals.timeOnSite,
  wa1.totals.pageviews,
  wa1.trafficSource.source,
  wa1.trafficSource.medium,
  wa1.channelGrouping,
  wa1.device.deviceCategory,
  wa1.geoNetwork.country
FROM `<proyecto>.p4_machine_learning.web_analytics` AS wa1,
UNNEST(wa1.hits) AS h
LIMIT 10

-- se reentrena al modelo
CREATE OR REPLACE MODEL `p4_machine_learning.classification_model`
OPTIONS
  (model_type='logistic_reg', labels = ['willBuyOnReturnVisit']) AS

  WITH all_visitor_stats AS (
      SELECT
      wa.fullVisitorId,
      IF(COUNTIF(totals.transactions > 0 AND totals.newVisits IS NULL) > 0, 0, 1) AS willBuyOnReturnVisit
    FROM `<proyecto>.p4_machine_learning.web_analytics` AS wa,
    UNNEST(wa.hits) AS h
    WHERE 
      h.eCommerceAction.action_type = "6" -- compra concretada
    GROUP BY wa.fullVisitorId
    )

    -- nuevas caracteristicas
    SELECT
      fullVisitorId,
      IFNULL(totals.bounces, 0) AS bounces,
      IFNULL(totals.timeOnSite, 0) AS timeOnSite,
      IFNULL(totals.pageviews, 0) AS pageviews,
      trafficSource.source,
      trafficSource.medium,
      channelGrouping,
      device.deviceCategory,
      IFNULL(geoNetwork.country, "") AS country
    FROM
      `<proyecto>.p4_machine_learning.web_analytics`
    WHERE
      date BETWEEN '20160101' AND '20161231'

  -- se evalua nuevamente el modelo
  SELECT
  roc_auc,
  CASE
    WHEN roc_auc > .9 THEN 'bueno'
    WHEN roc_auc > .8 THEN 'regular'
    WHEN roc_auc > .7 THEN 'decente'
    WHEN roc_auc > .6 THEN 'no tan mal'
  ELSE 'malo' 
  END
  AS model_quality
FROM
  ML.EVALUATE(MODEL p4_machine_learning.classification_model_2,  (

  WITH all_visitor_stats AS (
    SELECT
        wa.fullVisitorId,
        IF(COUNTIF(totals.transactions > 0 AND totals.newVisits IS NULL) > 0, 0, 1) AS willBuyOnReturnVisit
      FROM `<proyecto>.p4_machine_learning.web_analytics` AS wa,
      UNNEST(wa.hits) AS h
      WHERE 
        h.eCommerceAction.action_type = "6" -- compra concretada
      GROUP BY wa.fullVisitorId
    )

    # nuevas caracteristicas para las muestras
    SELECT
      fullVisitorId,
      IFNULL(totals.bounces, 0) AS bounces,
      IFNULL(totals.timeOnSite, 0) AS timeOnSite,
      IFNULL(totals.pageviews, 0) AS pageviews,
      trafficSource.source,
      trafficSource.medium,
      channelGrouping,
      device.deviceCategory,
      IFNULL(geoNetwork.country, "") AS country
    FROM
      `<proyecto>.p4_machine_learning.web_analytics`
    WHERE
      date BETWEEN '20170401' AND '20170530'
));

-- paso 5.- predecir y clasificar la probabilidad de que un visitante realice una compra
SELECT
*
FROM
  ml.PREDICT(MODEL `p4_machine_learning.classification_model`, (
    SELECT
      fullVisitorId,
      IFNULL(totals.bounces, 0) AS bounces,
      IFNULL(totals.timeOnSite, 0) AS timeOnSite,
      IFNULL(totals.pageviews, 0) AS pageviews,
      trafficSource.source,
      trafficSource.medium,
      channelGrouping,
      device.deviceCategory,
      IFNULL(geoNetwork.country, "") AS country
    FROM
      `<proyecto>.p4_machine_learning.web_analytics`
    WHERE
      date BETWEEN '20170401' AND '20170530'
  )
)

ORDER BY
  predicted_willBuyOnReturnVisit DESC;
