-- Check all tables one by one

---------- TABLE CANAL_VENTA ------------

SELECT * FROM canal_venta; -- looks good


----------- TABLE CLIENTE -----------------

SELECT * FROM cliente; 
-- Provincia y Localidad, standardize names 

SELECT DISTINCT Provincia -- Looks good
FROM cliente;

SELECT DISTINCT Localidad -- Looks good
FROM cliente
ORDER BY 1;

-- Update the "NOMBREAPELLIDO" column to capitalize its contents. -- 3407 rows affected
UPDATE cliente
SET NombreApellido = INITCAP(NombreApellido);

-- Capitalize Direccion -- 3407 rows affected
UPDATE cliente
SET direccion = INITCAP(direccion);

--Capitalize LOCALIDAD --3407 rows affected
UPDATE cliente
    SET localidad = INITCAP(localidad);

-- Categorize Edad
-- Create a new column "AgeCategory" based on the "EDAD" column.
ALTER TABLE cliente
ADD AgeCategory VARCHAR(50);

UPDATE cliente -- 3407 rows affected
SET AgeCategory =
  CASE
    WHEN edad < 18 THEN 'Less than 18'
    WHEN edad BETWEEN 19 AND 29 THEN 'Between 19 and 29'
    WHEN edad BETWEEN 30 AND 39 THEN 'Between 30 and 39'
    WHEN edad BETWEEN 40 AND 49 THEN 'Between 40 and 49'
    WHEN edad BETWEEN 50 AND 59 THEN 'Between 50 and 59'
    ELSE '60 and older'
  END;

-- Check format for LONGITUD y LATITUD, turn into decimal
-- Check the data types of "LONGITUD" and "LATITUD" columns.
DESCRIBE TABLE cliente; 
-- latitud and longitus are varchar and have nulls 

-- Convert columns to decimal
UPDATE cliente -- 3407 rows affected
SET
    longitud = CAST(REPLACE(longitud, ',', '.') AS DECIMAL(18,2)),
    latitud = CAST(REPLACE(latitud, ',', '.') AS DECIMAL(18,2));

-- Remove column COL10
ALTER TABLE cliente
DROP COLUMN col10;

-- Check for duplicates in id
SELECT IdCliente, COUNT(*)
FROM cliente
GROUP BY IdCliente
HAVING COUNT(*) > 1; -- no duplicates


----------- TABLE SUCURSAL -- -----------

SELECT * FROM sucursal; 

-- Check SUCURSAL names
SELECT DISTINCT sucursal
FROM sucursal
ORDER BY sucursal; 

-- Change Palermo 1 for Palermo1 and MDQ1 and MDQ2 for Mar del Plata1 and Mar del Plata2

UPDATE sucursal -- 31 rows affected
SET sucursal =
    CASE
        WHEN sucursal = 'Palermo 1' THEN 'Palermo1'
        WHEN sucursal = 'Palermo 2' THEN 'Palermo2'
        WHEN sucursal = 'MDQ1' THEN 'Mar del Plata1'
        WHEN sucursal = 'MDQ2' THEN 'Mar del Plata2'
        ELSE sucursal
    END;
        
-- Standardize LOCALIDAD y PROVINCIA
SELECT DISTINCT localidad
FROM sucursal
ORDER BY localidad;

UPDATE sucursal -- 8 rows affected
SET localidad = 'Ciudad de Buenos Aires'
WHERE TRIM(localidad) IN ('CABA', 'Cap. Federal','Cap.   Federal', 'Cap. Fed.', 'CapFed', 'Capital',
                    'Capital Federal', 'Cdad de Buenos Aires');

UPDATE sucursal  -- 2 rows affected
SET localidad = 'Córdoba'
WHERE TRIM(localidad) IN ('Coroba', 'Cordoba');

SELECT DISTINCT provincia
FROM sucursal
ORDER BY provincia;

UPDATE sucursal -- 8 rows updated
SET provincia = 'Buenos Aires'
WHERE TRIM(provincia) IN ('B. Aires', 'B.Aires', 'Bs As', 'Bs.As.', 'Pcia Bs AS', 
                    'Prov de Bs As.', 'Provincia de Buenos Aires');
UPDATE sucursal  -- 4 rows updates
SET provincia = 'CABA'
WHERE TRIM(provincia) IN ('C deBuenos Aires', 'Ciudad de Buenos Aires');

UPDATE sucursal  -- 1 row updated
SET provincia = 'Córdoba'
WHERE TRIM(provincia) = 'Cordoba';


-- Check LATITUD y LONGITUD, change positions and turn into decimal
UPDATE sucursal -- 31 rows updated
    SET latitud = CAST(REPLACE(latitud, ',', '.') AS DECIMAL(18,2)),
        longitud = CAST(REPLACE(longitud, ',', '.') AS DECIMAL(18,2));

-- Change positions, first longitud and the latitud. 
-- Because there are no REORDER command, I create a new column that it's added at the end
ALTER TABLE sucursal
ADD latitud_ DECIMAL(18,2);

UPDATE sucursal --31 rows affected
    SET latitud_ = latitud;

ALTER TABLE sucursal
DROP COLUMN latitud;

ALTER TABLE sucursal
RENAME COLUMN latitud_ TO latitud;
        

---------- TABLE EMPLEADO ------------

SELECT * FROM empleado; 
-- Check Sucursal, estandardize names

SELECT DISTINCT sucursal
FROM empleado
ORDER BY 1;

UPDATE empleado -- 267 rows updated
SET sucursal =
    CASE
        WHEN sucursal = 'Palermo 1' THEN 'Palermo1'
        WHEN sucursal = 'Palermo 2' THEN 'Palermo2'
        WHEN sucursal = 'Mendoza 1' THEN 'Mendoza1'
        WHEN sucursal = 'Mendoza 2' THEN 'Mendoza2'
        WHEN sucursal = 'MDQ1' THEN 'Mar del Plata1'
        WHEN sucursal = 'MDQ2' THEN 'Mar del Plata2'
        WHEN sucursal = 'Cordoba Quiroz' THEN 'Córdoba Quiroz'
        ELSE sucursal
    END;

-- Check Salario, turn into decimal
DESCRIBE TABLE empleado; -- Salario is varchar

UPDATE empleado -- 267 rows updated
    SET salario = CAST(REPLACE(salario, ',', '.') AS DECIMAL(8,2));

-- Check for duplicates in ID
SELECT IdEmpleado, count(*)
FROM empleado
GROUP BY IdEmpleado
HAVING count(*) > 1; -- There are multiple id with duplicates, some have 3

-- Create a new unique id combining with sucursal id
-- Check if the join works ok
SELECT e.*, s.IdSucursal
FROM empleado e JOIN sucursal s
    ON (e.sucursal = s.sucursal);

-- Check if there are inconsistencies in the sucursal name between tables
SELECT DISTINCT sucursal from empleado
WHERE sucursal NOT IN (SELECT sucursal from sucursal); -- looks good

-- Add a column with sucursal id
ALTER TABLE empleado
ADD IdSucursal INT NULL DEFAULT 0;

UPDATE empleado e -- 267 rows updated
    SET e.IdSucursal = s.IdSucursal
    FROM sucursal s    
    WHERE e.sucursal = s.sucursal;

-- Create a unique id multiplying the sucursal id and adding the empleado id number
ALTER TABLE empleado
ADD CodigoEmpleado INT NULL DEFAULT 0;

UPDATE empleado
    SET CodigoEmpleado = IdEmpleado;

UPDATE empleado
    SET IdEmpleado = (IdSucursal*100000) + CodigoEmpleado;


---------- TABLE PRODUCTO -------------
    
SELECT * FROM producto; 

-- Check for duplicates and nulls in ID
DESCRIBE TABLE producto;

SELECT IdProducto, COUNT(*)
FROM producto
GROUP BY IdProducto
HAVING COUNT(*) > 1; -- No duplicates in id

-- Capitalize TIPOPRODUCTO
UPDATE producto -- 291 rows updated
    SET TipoProducto = INITCAP(TipoProducto);

-- Check PRECIO, turn into decimal
UPDATE producto -- 291 rows updated
    SET precio = CAST(REPLACE(precio, ',', '.') AS DECIMAL(12,2));


-------- TABLE PROVEEDOR --------------

SELECT * FROM proveedor; 
-- Check for nulls in proveedor
-- Capiatlize DIRECCION, CIUDAD, PROVINCIA, PAIS, LOCALIDAD
UPDATE proveedor
    SET direccion = INITCAP(TRIM(direccion)),
        ciudad = INITCAP(TRIM(ciudad)),
        provincia = INITCAP(TRIM(provincia)),
        pais = INITCAP(TRIM(pais)),
        localidad = INITCAP(TRIM(localidad));

-- Check for mispellings, standardise locations
UPDATE  proveedor
    SET ciudad = 'Ciudad de Buenos Aires'
    WHERE TRIM(ciudad) = 'Boca De Atencion Monte Castro';

UPDATE proveedor
    SET ciudad = 'Córdoba'
    WHERE TRIM(ciudad) = 'Cordoba';

UPDATE proveedor
    SET provincia = 'CABA'
    WHERE provincia = 'Caba';

UPDATE proveedor
    SET provincia = 'Córdoba'
    WHERE provincia = 'Cordoba';

------- TABLE GASTO -----------

SELECT * FROM tipo_gasto; -- Check MONTO, what is it supposed to mean in this table?

--------- TABLE COMPRA ------------

SELECT * FROM compra; -- Looks good, check for data types and duplicates
DESCRIBE TABLE compra;

SELECT IdCompra, COUNT(*)
FROM compra
GROUP BY IdCompra
HAVING COUNT(*)>1; -- no duplicates in id

--------- TABLE GASTO ---------------

SELECT * FROM gasto; -- Looks good, check for data types and duplicates
DESCRIBE TABLE gasto;

SELECT IdGasto, COUNT(*)
FROM gasto
GROUP BY IdGasto
HAVING COUNT(*)>1; -- no duplicates in id

---------- TABLE VENTA --------------

SELECT * FROM venta;
DESCRIBE TABLE venta;

-- Update the IdEmpleado column for the unique id created before in table Empleado
UPDATE venta v -- 46645 rows updated
SET v.IdEmpleado = e.IdEmpleado
FROM empleado e
WHERE v.IdEmpleado = e.CodigoEmpleado;

-- Create calendar table



-- Normalize dimension tables
