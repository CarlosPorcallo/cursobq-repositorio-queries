/* Población de clientes por país */​

SELECT​
    COUNT(1) as conteo,​
    country​
FROM​
    `<proyecto>.p1_carga_transformacion.customer`​
GROUP BY country​

/* Población de clientes por país */​



/* De nuestra población de clientes, interesa conocer por país cuantos de ellos se suscribieron por país en el año 2020 */​

SELECT​
    COUNT(1) as conteo,​
    c.country​
FROM​
    `<proyecto>.p1_carga_transformacion.customer` as c​
WHERE ​
    c.subscriptionDate BETWEEN DATE("2020-01-01") AND DATE("2020-12-12")​
GROUP BY c.country​
ORDER BY conteo desc;​

/* De nuestra población de clientes, interesa conocer por país cuantos de ellos se suscribieron por país en el año 2020 */

/* Del país mejor rankeado obtener su conteo de ciudades el año 2020 */​

SELECT​
    COUNT(1) as conteo,​
    c.country,​
    c.city​
FROM​
    `<proyecto>.p1_carga_transformacion.customer` as c​
WHERE ​
    c.country = '<country>' AND​
    c.subscriptionDate BETWEEN DATE("2020-01-01") AND DATE("2020-12-12")​
GROUP BY c.city, c.country​
ORDER BY conteo desc;​

/* Del país mejor ranqueado obtener su conteo de ciudades el año 2020 */

/* De las 5 primeras ciudades obtener su listado de compañías */​

SELECT​
    COUNT(1) as conteo,​
    c.country,​
    c.city,​
    c.company​
FROM​
    `<proyecto>.p1_carga_transformacion.customer` as c​
WHERE ​
    c.country = '<country>' AND​
    c.city IN (<cities_list>) AND​
    c.subscriptionDate BETWEEN DATE("2020-01-01") AND DATE("2020-12-12")​
GROUP BY c.city, c.country, c.company​
ORDER BY conteo desc, c.city DESC;​

/* De las 5 primeras ciudades obtener su listado de compañías */​

​/* De las ciudades que tengan un nombre de celebridad en el nombre de su compañía, obtener el listado de compañías */​

SELECT​
    COUNT(1) as conteo,​
    c.country,​
    c.city,​
    c.company​
FROM​
    `<proyecto>.p1_carga_transformacion.customer` as c​
WHERE ​
    c.country = '<country>' AND​
    c.city LIKE '%<name>%' AND​
    c.subscriptionDate BETWEEN DATE("2020-01-01") AND DATE("2020-12-12")​
GROUP BY c.city, c.country, c.company​
ORDER BY conteo desc, c.city DESC;​

/* De las ciudades que tengan un nombre de celebridad en el nombre de su compañía, obtener el listado de compañías */​

/* Del listado de compañías, elegir una y ver su conteo de suscripciones por mes */​

SELECT​
    c.subscriptionDate,​
    c.country,​
    c.city,​
    c.company​
FROM​
    `<proyecto>.p1_carga_transformacion.customer` as c​
WHERE ​
    c.country = '<>country' AND​
    c.company IN (<company-list>) AND​
    c.subscriptionDate BETWEEN DATE("2020-01-01") AND DATE("2020-12-12")​
ORDER BY c.city DESC;​

/* Del listado de compañías, elegir una y ver su conteo de suscripciones por mes */​

/* Del listado de compañías, elegir una y ver su conteo de suscripciones por mes */​

SELECT​
    c.subscriptionDate,​
    CASE​
        WHEN c.subscriptionDate BETWEEN DATE("2020-01-01") AND DATE("2020-01-31") THEN "Enero"​
        WHEN c.subscriptionDate BETWEEN DATE("2020-02-01") AND DATE("2020-02-28") THEN "Febrero"​
        WHEN c.subscriptionDate BETWEEN DATE("2020-03-01") AND DATE("2020-03-31") THEN "Marzo"​
        WHEN c.subscriptionDate BETWEEN DATE("2020-04-01") AND DATE("2020-04-30") THEN "Abril"​
        WHEN c.subscriptionDate BETWEEN DATE("2020-05-01") AND DATE("2020-05-31") THEN "Mayo"​
        WHEN c.subscriptionDate BETWEEN DATE("2020-06-01") AND DATE("2020-06-30") THEN "Junio"​
        WHEN c.subscriptionDate BETWEEN DATE("2020-07-01") AND DATE("2020-07-31") THEN "Julio"​
        WHEN c.subscriptionDate BETWEEN DATE("2020-08-01") AND DATE("2020-08-31") THEN "Agosto"​
        WHEN c.subscriptionDate BETWEEN DATE("2020-09-01") AND DATE("2020-09-30") THEN "Septiembre"​
        WHEN c.subscriptionDate BETWEEN DATE("2020-10-01") AND DATE("2020-10-31") THEN "Octubre"​
        WHEN c.subscriptionDate BETWEEN DATE("2020-11-01") AND DATE("2020-11-30") THEN "Noviembre"​
        ELSE "Diciembre"​
    END​
    AS subscription_month,​
    c.country,​
    c.city,​
    c.company​
FROM​
    `<proyecto>.p1_carga_transformacion.customer` as c​
WHERE ​
    c.country = '<country>' AND​
    c.company IN (<company-list>) AND​
    c.subscriptionDate BETWEEN DATE("2020-01-01") AND DATE("2020-12-12")​
ORDER BY c.city DESC;​

/* Del listado de compañías, elegir una y ver su conteo de suscripciones por mes */​