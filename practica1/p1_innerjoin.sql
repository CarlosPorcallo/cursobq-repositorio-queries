/* Reviews de usuarios de las compañías de una lista */​

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
    `<proyecto>.p1_carga_transformacion.customer` AS c​
INNER JOIN `sandbox-433907.sesion_1_transformacion_datos.customer_reviewer` AS cr​
ON cr.customerID = c.customerID​
INNER JOIN `<proyecto>.p1_carga_transformacion.review_digital_music` as rdm​
ON rdm.reviewerID = cr.reviewerID​
INNER JOIN `<proyecto>.p1_carga_transformacion.meta_digital_music` as mdm​
ON mdm.asin = rdm.asin​
WHERE​
    c.company IN (<company-list>) AND​
    mdm.title is not NULL​

/* Reviews de usuarios de las compañías de una lista */​

