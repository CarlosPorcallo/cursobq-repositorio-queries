WITH cities AS (​
/* Del país mejor ranqueado obtener su conteo de ciudades el año 2020 */​
SELECT​
    COUNT(1) as conteo,​
    c.country,​
    c.city​
FROM​
    `<proyecto>.<dataset>.customer` as c​
WHERE ​
    c.country = 'Korea' AND​
    c.subscriptionDate BETWEEN DATE("2020-01-01") AND DATE("2020-12-12")​
GROUP BY c.city, c.country​
ORDER BY conteo desc​
LIMIT 5​
/* Del país mejor ranqueado obtener su conteo de ciudades el año 2020 */​
)​


/* De las 5 primeras ciudades obtener su listado de compañías */​

SELECT​
    COUNT(1) as conteo,​
    c.country,​
    c.city,​
    c.company​
FROM​
    `<proyecto>.<dataset>.customer` as c​
WHERE ​
    c.country = '<country>' AND​
    c.city IN (​
        SELECT city FROM cities ​
    ) AND​
    c.subscriptionDate BETWEEN DATE("2020-01-01") AND DATE("2020-12-12")​
GROUP BY c.city, c.country, c.company​
ORDER BY conteo desc, c.city DESC;​
/* De las 5 primeras ciudades obtener su listado de compañías */​
