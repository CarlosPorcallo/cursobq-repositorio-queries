/* Población de clientes por país (funciones de agregación) */​

SELECT​
    COUNT(c.customerID) as conteo,​
    country​
FROM​
    `<proyecto>.p1_carga_transformacion.customer` AS c​
GROUP BY country​
ORDER BY conteo desc​
LIMIT 100;​

/* Población de clientes por país (funciones de agregación) */​

/* over */​

/* Población de clientes por país (funciones analíticas) */​

SELECT DISTINCT​
    c.country,​
    COUNT(c.customerID) OVER(PARTITION BY c.country) AS cuenta​
FROM​
    `<proyecto>.p1_carga_transformacion.customer` AS c​
ORDER BY cuenta​
LIMIT 100;​

SELECT DISTINCT​
    c.country,​
    COUNT(c.customerID) OVER(PARTITION BY c.country ORDER BY c.country) AS cuenta​
FROM​
    `<proyecto>.p1_carga_transformacion.customer` AS c​
LIMIT 100;​

/* Población de clientes por país (funciones analíticas) */​
