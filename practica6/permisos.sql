-- roles y permisos
GRANT `roles/bigquery.dataEditor`
ON TABLE `<proyecto>.p1_reviews_amazon.customer`
TO "user:<user>@gmail.com";

GRANT `roles/bigquery.dataEditor`
ON SCHEMA `<proyecto>.p1_reviews_amazon`
TO "user:<user>@gmail.com";

REVOKE `roles/bigquery.dataEditor`
ON SCHEMA `<proyecto>.p1_reviews_amazon`
FROM "user:<user>@gmail.com";
-- roles y permisos

-- probando activación de los roles
UPDATE `<proyecto>.p1_reviews_amazon.customer` SET firstName = 'Carlos' WHERE customerID = '7E2d50A61DA07Ba';

SELECT 
  index
  customerID,
  firstName,
  lastName,
  company,
  city,
  country,
  phone1,
  phone2,
  email,
  subscriptionDate,
  website
FROM `<proyecto>.p1_reviews_amazon.customer`
WHERE customerID = '7E2d50A61DA07Ba';

UPDATE `<proyecto>.p1_reviews_amazon.meta_digital_music` SET brand = 'EMI Music' WHERE asin = 'B000MM1FSW';

SELECT 
  asin,
  brand
FROM `<proyecto>.p1_reviews_amazon.meta_digital_music`
WHERE asin = 'B000MM1FSW';
-- probando activación de los roles