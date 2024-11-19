-- cifrado irreversible (farm_fingerprint)
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
  website,
  FARM_FINGERPRINT(CONCAT(customerID, firstName, lastName)) AS keyhash
FROM `<proyecto>.p1_carga_transformacion.customer`
LIMIT 10;
-- cifrado irreversible (farm_fingerprint)


-- cifrado reversible (AEAD.ENCRYPT)
-- se crea la tabla de keysets de los primeros 10 usuarios
CREATE OR REPLACE TABLE `<proyecto>.p6_aead_functions.customerKeysets` AS (
  SELECT
    customerID,
    CAST(country AS BYTES) as bytesCountry,
    KEYS.NEW_KEYSET('AEAD_AES_GCM_256') AS keyset
    FROM `<proyecto>.p1_carga_transformacion.customer`
  LIMIT 10
);

-- se encriptan los registros de los primeros 10 usuarios
CREATE OR REPLACE TABLE `<proyecto>.p6_aead_functions.customerEncriptedData` AS (
  SELECT 
    ck.customerID,
    AEAD.ENCRYPT(ck.keyset, CAST(firstName AS BYTES), ck.bytesCountry) AS encryptedFirstName,
    AEAD.ENCRYPT(ck.keyset, CAST(lastName AS BYTES), ck.bytesCountry) AS encryptedLastName,
    AEAD.ENCRYPT(ck.keyset, CAST(company AS BYTES), ck.bytesCountry) AS encryptedCompany,
    AEAD.ENCRYPT(ck.keyset, CAST(city AS BYTES), ck.bytesCountry) AS encryptedCity,
    AEAD.ENCRYPT(ck.keyset, CAST(country AS BYTES), ck.bytesCountry) AS encryptedCountry,
    AEAD.ENCRYPT(ck.keyset, CAST(phone1 AS BYTES), ck.bytesCountry) AS encryptedPhone1,
    AEAD.ENCRYPT(ck.keyset, CAST(phone2 AS BYTES), ck.bytesCountry) AS encryptedPhone2,
    AEAD.ENCRYPT(ck.keyset, CAST(email AS BYTES), ck.bytesCountry) AS encryptedEmail,
    AEAD.ENCRYPT(ck.keyset, CAST(CAST(subscriptionDate AS string) AS BYTES), ck.bytesCountry) AS encryptedSubscriptionDate,
    AEAD.ENCRYPT(ck.keyset, CAST(website AS BYTES), ck.bytesCountry) AS encryptedWebsite,
  FROM `<proyecto>.p6_aead_functions.customerKeysets` AS ck
  INNER JOIN `<proyecto>.p1_carga_transformacion.customer` AS c
  ON ck.customerID = c.customerID
);

-- se desencriptan los datos de la tabla
SELECT 
  ced.customerID,
  AEAD.DECRYPT_STRING(ck.keyset, ced.encryptedFirstName, CAST(ck.bytesCountry AS string)) AS FirstName,
  AEAD.DECRYPT_STRING(ck.keyset, ced.encryptedLastName, CAST(ck.bytesCountry AS string)) AS LastName,
  AEAD.DECRYPT_STRING(ck.keyset, ced.encryptedCompany, CAST(ck.bytesCountry AS string)) AS Company,
  AEAD.DECRYPT_STRING(ck.keyset, ced.encryptedCity, CAST(ck.bytesCountry AS string)) AS City,
  AEAD.DECRYPT_STRING(ck.keyset, ced.encryptedCountry, CAST(ck.bytesCountry AS string)) AS Country,
  AEAD.DECRYPT_STRING(ck.keyset, ced.encryptedPhone1, CAST(ck.bytesCountry AS string)) AS Phone1,
  AEAD.DECRYPT_STRING(ck.keyset, ced.encryptedPhone2, CAST(ck.bytesCountry AS string)) AS Phone2,
  AEAD.DECRYPT_STRING(ck.keyset, ced.encryptedEmail, CAST(ck.bytesCountry AS string)) AS Email,
  AEAD.DECRYPT_STRING(ck.keyset, ced.encryptedSubscriptionDate, CAST(ck.bytesCountry AS string)) AS SubscriptionDate,
  AEAD.DECRYPT_STRING(ck.keyset, ced.encryptedWebsite, CAST(ck.bytesCountry AS string)) AS Website,
FROM `<proyecto>.p6_aead_functions.customerEncriptedData` AS ced
INNER JOIN `<proyecto>.p6_aead_functions.customerKeysets` AS ck
ON ced.customerID = ck.customerID
-- cifrado reversible (AEAD.ENCRYPT)