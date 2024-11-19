-- creando tabla particionada sin especificar el tipo de particionamiento
DROP TABLE `<proyecto>.p5_optimizacion.particionamiento_all_sessions`;
CREATE TABLE `<proyecto>.p5_optimizacion.particionamiento_all_sessions`
PARTITION BY
  visitDate
  OPTIONS (
    require_partition_filter = TRUE -- para cada query se debe especificar el campo de filtrado usado por la partición
  )
AS (
  SELECT
    wa.fullVisitorId,
    wa.channelGrouping,
    wa.geoNetwork.country,
    wa.geoNetwork.city,
    wa.totals.timeOnSite,
    wa.totals.pageviews,
    DATE(CAST(SUBSTR(wa.date, 0, 4) AS INT64), CAST(SUBSTR(wa.date, 5 , 2) AS INT64), CAST(SUBSTR(wa.date, 7, 2) AS INT64)) AS visitDate,
    wa.visitId
  FROM
    `<proyecto>.p4_machine_learning.web_analytics` AS all_sessions
);
-- creando tabla particionada sin especificar el tipo de particionamiento

-- creando tabla particionada especificando el tipo de particionamiento
DROP TABLE `<proyecto>.p5_optimizacion.particionamiento_all_sessions`;
CREATE TABLE `<proyecto>.p5_optimizacion.particionamiento_all_sessions`
PARTITION BY
  DATE_TRUNC(visitDate, MONTH)
  OPTIONS (
  --  partition_expiration_days = 30, -- el tiempo que BigQuery conservará la data en una partición
    require_partition_filter = TRUE -- para cada query se debe especificar el campo de filtrado usado por la partición
  )
AS (
  SELECT
    wa.fullVisitorId,
    wa.channelGrouping,
    wa.geoNetwork.country,
    wa.geoNetwork.city,
    wa.totals.timeOnSite,
    wa.totals.pageviews,
    DATE(CAST(SUBSTR(wa.date, 0, 4) AS INT64), CAST(SUBSTR(wa.date, 5 , 2) AS INT64), CAST(SUBSTR(wa.date, 7, 2) AS INT64)) AS visitDate,
    wa.visitId
  FROM
    `<proyecto>.p4_machine_learning.web_analytics` AS all_sessions
);
-- creando tabla particionada especificando el tipo de particionamiento

-- comparando el performance de mis queries
SELECT
  wa.fullVisitorId,
  wa.channelGrouping,
  wa.geoNetwork.country,
  wa.geoNetwork.city,
  wa.totals.timeOnSite,
  wa.totals.pageviews,
  DATE(CAST(SUBSTR(wa.date, 0, 4) AS INT64), CAST(SUBSTR(wa.date, 5 , 2) AS INT64), CAST(SUBSTR(wa.date, 7, 2) AS INT64)) AS visitDate,
  wa.visitId
FROM
  `<proyecto>.p4_machine_learning.web_analytics` AS wa
WHERE DATE(CAST(SUBSTR(all_sessions.date, 0, 4) AS INT64), CAST(SUBSTR(all_sessions.date, 5 , 2) AS INT64), CAST(SUBSTR(all_sessions.date, 7, 2) AS INT64)) BETWEEN "2017-01-01" AND "2017-12-31";

SELECT 
  all_sessions.fullVisitorId,
  all_sessions.channelGrouping,
  all_sessions.geoNetwork.country,
  all_sessions.geoNetwork.city,
  all_sessions.totals.timeOnSite,
  all_sessions.totals.pageviews,
  all_sessions.visitDate,
  all_sessions.visitId
FROM `<proyecto>.p5_optimizacion.particionamiento_all_sessions` AS all_sessions
WHERE visitDate BETWEEN "2017-01-01" AND "2017-12-31";
-- comparando el performance de mis queries