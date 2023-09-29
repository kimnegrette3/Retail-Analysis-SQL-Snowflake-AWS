-- Check all tables one by one

---------- TABLE CANAL_VENTA ------------

SELECT * FROM canal_venta; -- looks good


----------- TABLE CLIENTE -----------------

SELECT * FROM cliente; 
DESCRIBE TABLE cliente;

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
ADD CategoriaEdad VARCHAR(50);

UPDATE cliente -- 3407 rows affected
SET CategoriaEdad =
  CASE
    WHEN edad < 18 THEN 'Menor de 18'
    WHEN edad BETWEEN 19 AND 29 THEN 'Entre 19 y 29'
    WHEN edad BETWEEN 30 AND 39 THEN 'Entre 30 y 39'
    WHEN edad BETWEEN 40 AND 49 THEN 'Entre 40 y 49'
    WHEN edad BETWEEN 50 AND 59 THEN 'Entre 50 y 59'
    ELSE 'Mayor de 60'
  END;

SELECT DISTINCT Localidad
FROM cliente
WHERE Localidad LIKE '%Buenos%';

UPDATE cliente -- 458 rows updated
SET localidad = 'Ciudad de Buenos Aires'
WHERE localidad = 'Ciudad De Buenos Aires';    

-- Check format for LONGITUD y LATITUD, turn into decimal
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

-- Fill missing values in categorical columns
UPDATE cliente -- 31 rows updated
SET provincia = COALESCE(provincia, 'Sin Dato')
WHERE provincia IS NULL;

UPDATE cliente -- 46 rows updated
SET NombreApellido  = COALESCE(NombreApellido, 'Sin Dato')
WHERE NombreApellido IS NULL;

UPDATE cliente -- 48 rows updated
SET direccion = COALESCE(direccion, 'Sin Dato')
WHERE direccion IS NULL;

UPDATE cliente -- 32 rows updated
SET localidad = COALESCE(localidad, 'Sin Dato')
WHERE localidad IS NULL;


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
                    'Capital Federal', 'Cdad de Buenos Aires', 'Ciudad De Buenos Aires');

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
WHERE TRIM(provincia) IN ('C deBuenos Aires', 'Ciudad de Buenos Aires', 'Ciudad De Buenos Aires');

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
        
-- Fill missing values in categorical columns
UPDATE sucursal -- 0 rows updated
SET  provincia = COALESCE(provincia, 'Sin Dato')
WHERE provincia IS NULL;

UPDATE sucursal -- 0 rows updated
SET sucursal  = COALESCE(sucursal, 'Sin Dato')
WHERE sucursal IS NULL;

UPDATE sucursal -- 0 rows updated
SET direccion = COALESCE(direccion, 'Sin Dato')
WHERE direccion IS NULL;

UPDATE sucursal -- 0 rows updated
SET localidad = COALESCE(localidad, 'Sin Dato')
WHERE localidad IS NULL;


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

-- Fill mising values in categorical columns
UPDATE empleado --  0 rows updated
SET nombre = COALESCE(nombre, 'Sin Dato')
WHERE nombre IS NULL;

UPDATE empleado --  0 rows updated
SET apellido = COALESCE(apellido, 'Sin Dato')
WHERE apellido IS NULL;

UPDATE empleado -- 0  rows updated
SET sucursal  = COALESCE(sucursal, 'Sin Dato')
WHERE sucursal IS NULL;

UPDATE empleado -- 0  rows updated
SET sector = COALESCE(sector, 'Sin Dato')
WHERE sector IS NULL;

UPDATE empleado -- 0  rows updated
SET cargo = COALESCE(cargo, 'Sin Dato')
WHERE cargo IS NULL;

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

-- Fill missing values in categorical columns
UPDATE producto -- 0 rows affected
SET producto = COALESCE(producto, 'Sin Dato')
WHERE producto IS NULL;

UPDATE producto -- 12 rows affected
SET TipoProducto = COALESCE(TipoProducto, 'Sin Dato')
WHERE TipoProducto IS NULL;


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

-- Rename ciudad for localidad and drop column localidad
ALTER TABLE proveedor
DROP COLUMN localidad;

ALTER TABLE proveedor
RENAME COLUMN ciudad TO localidad;

-- Fill missing values in categorical columns
UPDATE proveedor -- 2 rows updated
SET proveedor = COALESCE(proveedor, 'Sin Dato')
WHERE proveedor IS NULL;

UPDATE proveedor -- 0 rows updated
SET direccion = COALESCE(direccion, 'Sin Dato')
WHERE direccion IS NULL;

UPDATE proveedor -- 0 rows updated
SET provincia = COALESCE(provincia, 'Sin Dato')
WHERE provincia IS NULL;

UPDATE proveedor -- 0 rows updated
SET pais = COALESCE(pais, 'Sin Dato')
WHERE pais IS NULL;

UPDATE proveedor -- 0 rows updated
SET localidad = COALESCE(localidad, 'Sin Dato')
WHERE localidad IS NULL;


------- TABLE TIPO_GASTO -----------

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

------- CALENDAR TABLE --------------

CREATE OR REPLACE TABLE TablaCalendario AS
  SELECT 
    DATEADD(DAY, seq4(), '2015-01-01')::DATE AS Fecha,
    DATE_PART(YEAR, DATEADD(DAY, seq4(), '2015-01-01')) AS Anio,
    DATE_PART(QUARTER, DATEADD(DAY, seq4(), '2015-01-01')) AS Trimestre,
    DATE_PART(MONTH, DATEADD(DAY, seq4(), '2015-01-01')) AS Mes,
    DATE_PART(DAYOFWEEK, DATEADD(DAY, seq4(), '2015-01-01')) AS DiaSemana,
    DATE_PART(DAY, DATEADD(DAY, seq4(), '2015-01-01')) AS DiaMes
  FROM TABLE(GENERATOR(ROWCOUNT => 3000));

-- Verificar la tabla calendario
SELECT * FROM TablaCalendario order by fecha desc limit 4;

-- Normalize dimension tables

-- Table empleado: Make dimensions for sector, cargo, drop column sucursal

CREATE OR REPLACE TABLE cargo(
IdCargo INT AUTOINCREMENT PRIMARY KEY,
Cargo VARCHAR(50) NOT NULL
);

INSERT INTO cargo(Cargo) -- 5 rows inserted
SELECT DISTINCT TRIM(Cargo) -- There are lead or trail spaces in this field in table Empleado
FROM empleado
ORDER BY 1;

ALTER TABLE empleado 
ADD IdCargo INT NOT NULL DEFAULT 0; 

UPDATE empleado e -- 267 rows updated
SET e.IdCargo = c.IdCargo
FROM cargo c
WHERE TRIM(e.Cargo) = c.Cargo;


CREATE OR REPLACE TABLE sector(
IdSector INT AUTOINCREMENT PRIMARY KEY,
Sector VARCHAR(50) NOT NULL
);

INSERT INTO sector(Sector) -- 6 rows inserted
SELECT DISTINCT TRIM(Sector)
FROM empleado
ORDER BY 1;

ALTER TABLE empleado 
ADD IdSector INT NOT NULL DEFAULT 0;

UPDATE empleado e --  267 rows updated
SET e.IdSector = s.IdSector
FROM sector s
WHERE TRIM(e.Sector) = s.Sector;

ALTER TABLE empleado
DROP COLUMN cargo, sector, sucursal;


-- Table producto: Make dimension for TipoProducto

CREATE OR REPLACE TABLE tipo_producto(
IdTipoProducto INT AUTOINCREMENT PRIMARY KEY,
TipoProducto VARCHAR(50) NOT NULL
);

INSERT INTO tipo_producto(TipoProducto) -- 11 rows inserted
SELECT DISTINCT TRIM(TipoProducto)
FROM producto
ORDER BY 1;

ALTER TABLE producto
ADD IdTipoProducto INT NOT NULL DEFAULT 0;

UPDATE producto p -- 291 rows updated
SET p.IdTipoProducto = tp.IdTipoProducto
FROM tipo_producto tp
WHERE TRIM(p.TipoProducto) = tp.TipoProducto;

ALTER TABLE producto
DROP COLUMN TipoProducto;

-- Table proveedor: Check if possible to make dimensions for provincia, localidad, pais
-- Table sucursal: Check if possible to make dimensions for provincia and localidad

CREATE OR REPLACE TABLE localidad(
IdLocalidad INT AUTOINCREMENT PRIMARY KEY,
Localidad VARCHAR(250) NOT NULL,
Provincia VARCHAR(250) NOT NULL,
IdProvincia INT NOT NULL DEFAULT 0
);

INSERT INTO localidad(Localidad, Provincia) -- 594 rows inserted 
SELECT DISTINCT Localidad, Provincia
FROM cliente
UNION 
SELECT DISTINCT Localidad, Provincia
FROM proveedor
UNION
SELECT DISTINCT Localidad,Provincia
FROM sucursal
ORDER BY 2,1;

SELECT * FROM localidad;

--Check for duplicates
SELECT Localidad, COUNT(*)
FROM localidad
GROUP BY Localidad
HAVING COUNT(*)>1; -- There are 13 localidades with two provincias, may be real according to Argentine geography

SELECT * 
FROM localidad
WHERE Localidad = 'Ciudad de Buenos Aires'; -- delete idlocalidad 69 and 341 because they have C. Buenos Aires as provincia

SELECT * 
FROM localidad
WHERE Localidad = 'Sin Dato'; -- delete idlocalidad 584 as it is Sin dato - Tucuman

DELETE FROM localidad -- 3 rows deleted
WHERE IdLocalidad = 69 OR IdLocalidad = 584 OR IdLocalidad = 341;

SELECT DISTINCT Provincia
FROM localidad;-- Correct mispelling

UPDATE localidad
    SET provincia =
        CASE
            WHEN provincia = 'Rio Negro' THEN 'Río Negro'
            WHEN provincia = 'Tucuman' THEN 'Tucumán'
            ELSE provincia
        END;


CREATE OR REPLACE TABLE provincia(
IdProvincia INT AUTOINCREMENT PRIMARY KEY,
Provincia VARCHAR(50) NOT NULL
);

INSERT INTO provincia(Provincia) -- 10 rows inserted
SELECT DISTINCT Provincia
FROM localidad
ORDER BY 1;

SELECT * FROM provincia;

UPDATE localidad l -- 591 rows updated
SET l.IdProvincia = p.IdProvincia
FROM provincia p
WHERE l.provincia = p.provincia;

ALTER TABLE localidad
DROP COLUMN Provincia;

-- Add columns for IdLocalidad  and drop old columns of localidad in cliente, sucursal, proveedor
ALTER TABLE cliente
ADD IdLocalidad INT NOT NULL DEFAULT 0;

UPDATE cliente c -- 3407 rows updated
SET c.IdLocalidad = l.IdLocalidad
FROM localidad l
WHERE c.Localidad = l.Localidad;

ALTER TABLE cliente
DROP COLUMN Provincia, Localidad;

ALTER TABLE sucursal
ADD IdLocalidad INT NOT NULL DEFAULT 0;

UPDATE sucursal s -- 31 rows updated
SET s.IdLocalidad = l.IdLocalidad
FROM localidad l
WHERE s.Localidad = l.Localidad;

ALTER TABLE sucursal
DROP COLUMN Provincia, Localidad;

ALTER TABLE proveedor
ADD IdLocalidad INT NOT NULL DEFAULT 0;

UPDATE proveedor p -- 14 rows updated
SET p.IdLocalidad = l.IdLocalidad
FROM localidad l
WHERE p.Localidad = l.Localidad;

ALTER TABLE proveedor
DROP COLUMN Provincia, Localidad, Pais;


-- Create primary and foreign keys to fact and dim tables
-- Create PRIMARY KEYS for all the tables
ALTER TABLE canal_venta ADD CONSTRAINT pk_canal_venta 
PRIMARY KEY (IdCanal);

ALTER TABLE cargo ADD CONSTRAINT pk_canal_venta 
PRIMARY KEY (IdCargo);

ALTER TABLE cliente add constraint pk_cliente 
PRIMARY KEY (IdCliente);

ALTER TABLE compra add constraint pk_compra 
PRIMARY KEY (IdCompra);

ALTER TABLE empleado add constraint pk_empleado 
PRIMARY KEY (IdEmpleado);

ALTER TABLE gasto add constraint pk_gasto 
PRIMARY KEY (IdGasto);

ALTER TABLE  localidad add constraint pk_localidad 
PRIMARY KEY (IdLocalidad);

ALTER TABLE producto add constraint pk_producto 
PRIMARY KEY (IdProducto);

ALTER TABLE proveedor add constraint pk_proveedor 
PRIMARY KEY (IdProveedor);

ALTER TABLE provincia add constraint pk_provincia 
PRIMARY KEY (IdProvincia);

ALTER TABLE sector add constraint pk_sector 
PRIMARY KEY (IdSector);

ALTER TABLE sucursal add constraint pk_sucursal 
PRIMARY KEY (IdSucursal);

ALTER TABLE TablaCalendario add constraint pk_calendario 
PRIMARY KEY (Fecha);

ALTER TABLE tipo_gasto add constraint pk_tipo_gasto 
PRIMARY KEY (IdTipoGasto);

ALTER TABLE tipo_producto add constraint pk_tipo_producto 
PRIMARY KEY (IdTipoProducto);

ALTER TABLE venta add constraint pk_venta 
PRIMARY KEY (IdVenta);


-- Create FOREIGN KEYS for all the tables

-- Table Cliente 

ALTER TABLE cliente ADD CONSTRAINT fk_cliente_localidad 
FOREIGN KEY (IdLocalidad) REFERENCES localidad(IdLocalidad);


-- Table Compra
ALTER TABLE compra ADD CONSTRAINT fk_compra_producto 
FOREIGN KEY (IdProducto) REFERENCES producto(IdProducto);

ALTER TABLE compra ADD CONSTRAINT fk_compra_proveedor 
FOREIGN KEY (IdProveedor) REFERENCES proveedor(IdProveedor);


-- Empleado
ALTER TABLE empleado ADD CONSTRAINT fk_empleado_sucursal F
OREIGN KEY (IdSucursal) REFERENCES sucursal(IdSucursal);

ALTER TABLE empleado ADD CONSTRAINT fk_empleado_cargo 
FOREIGN KEY(IdCargo) REFERENCES cargo(IdCargo);

ALTER TABLE empleado ADD CONSTRAINT fk_empleado_sector 
FOREIGN KEY(IdSector) REFERENCES sector(IdSector);


-- Table Gasto
ALTER TABLE gasto ADD CONSTRAINT fk_gasto_sucursal 
FOREIGN KEY (IdSucursal) REFERENCES sucursal(IdSucursal); 

ALTER TABLE gasto ADD CONSTRAINT fk_gasto_tipo_gasto 
FOREIGN KEY (IdTipoGasto) REFERENCES tipo_gasto(IdTipoGasto);


-- Table Localidad
ALTER TABLE localidad ADD CONSTRAINT fk_localidad_provincia 
FOREIGN KEY (IdProvincia) REFERENCES provincia(IdProvincia);


-- Table Producto
ALTER TABLE producto ADD CONSTRAINT fk_producto_tipo_producto 
FOREIGN KEY (IdTipoProducto) REFERENCES tipo_producto(IdTipoProducto);


-- Table Proveedor
ALTER TABLE proveedor ADD CONSTRAINT fk_proveedor_localidad 
FOREIGN KEY (IdLocalidad) REFERENCES localidad(IdLocalidad);


-- Table Sucursal
ALTER TABLE sucursal ADD CONSTRAINT fk_sucursal_localidad 
FOREIGN KEY (IdLocalidad) REFERENCES localidad(IdLocalidad);



-- Table Venta 
ALTER TABLE venta ADD CONSTRAINT fk_venta_canal_venta 
FOREIGN KEY (IdCanal) REFERENCES canal_venta(IdCanal);

ALTER TABLE venta ADD CONSTRAINT fk_venta_cliente 
FOREIGN KEY (IdCliente) REFERENCES cliente(IdCliente);

ALTER TABLE venta ADD CONSTRAINT fk_venta_sucursal 
FOREIGN KEY (IdSucursal) REFERENCES sucursal(IdSucursal);

ALTER TABLE venta ADD CONSTRAINT fk_venta_empleado 
FOREIGN KEY (IdEmpleado) REFERENCES empleado(IdEmpleado);

ALTER TABLE venta ADD CONSTRAINT fk_venta_producto 
FOREIGN KEY (IdProducto) REFERENCES producto(IdProducto);

ALTER TABLE venta ADD CONSTRAINT fk_venta_calendario 
FOREIGN KEY (Fecha) REFERENCES TablaCalendario(Fecha);