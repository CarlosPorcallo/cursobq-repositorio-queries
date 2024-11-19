CREATE MATERIALIZED VIEW `<proyecto>.p5_optimizacion.materialized_views_all_sessions_chile` AS (
  SELECT 
    all_sessions.fullVisitorId,
    all_sessions.channelGrouping,
    all_sessions.country,
    all_sessions.city,
    all_sessions.timeOnSite,
    all_sessions.pageviews,
    all_sessions.visitDate,
    all_sessions.visitId
  FROM `<proyecto>.p5_optimizacion.particionamiento_clustering_all_sessions` AS all_sessions
  WHERE 
    all_sessions.country = 'Chile'
);

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
WHERE 
  wa.geoNetwork.country = "Chile" AND
  DATE(CAST(SUBSTR(wa.date, 0, 4) AS INT64), CAST(SUBSTR(wa.date, 5 , 2) AS INT64), CAST(SUBSTR(all_sessions.date, 7, 2) AS INT64)) BETWEEN "2016-09-01" AND "2016-09-16";

SELECT 
  all_sessions.fullVisitorId,
  all_sessions.channelGrouping,
  all_sessions.country,
  all_sessions.city,
  all_sessions.timeOnSite,
  all_sessions.pageviews,
  all_sessions.visitDate,
  all_sessions.visitId
FROM `<proyecto>.p5_optimizacion.materialized_views_all_sessions_chile` AS all_sessions
WHERE
  all_sessions.country = 'Chile' AND
  all_sessions.visitDate BETWEEN "2016-09-01" AND "2016-09-16";
-- comparando el performance de mis queries