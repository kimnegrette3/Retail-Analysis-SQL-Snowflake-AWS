-- Create database and warehouse
CREATE OR REPLACE DATABASE RETAIL_SNOWFLAKE_AWS;
CREATE OR REPLACE WAREHOUSE RETAIL_WH;

USE DATABASE RETAIL_SNOWFLAKE_AWS;

-- Create the stage from AWS s3 bucket
CREATE OR REPLACE STAGE retail_s3_stage
URL = 's3://de-adventurework-snowflake-raw/data'
CREDENTIALS = (
  AWS_KEY_ID = ''
  AWS_SECRET_KEY = ''
);

-- Check the connection
LIST @retail_s3_stage;

-- Create the tables 
CREATE OR REPLACE TABLE tipo_gasto(
IdTipoGasto int,
Descripcion varchar(50),
Monto int
);

CREATE OR REPLACE TABLE sucursal(
IdSucursal int,
Sucursal varchar(50),
Direccion varchar(250),
Localidad varchar(250),
Provincia varchar(250),
Latitud varchar(250),
Longitud varchar(250)
);

CREATE OR REPLACE TABLE proveedor(
IdProveedor int,
Proveedor varchar(50),
Direccion varchar(250),
Ciudad varchar(250),
Provincia varchar(250),
Pais varchar(50),
Localidad varchar(250)
);

CREATE OR REPLACE TABLE canal_venta(
IdCanal int, 
Canal varchar(50)
);

CREATE OR REPLACE TABLE cliente(
IdCliente int,
Provincia varchar(250),
NombreApellido varchar(250),
Direccion varchar(250),
Telefono varchar(50),
Edad varchar(50),
Localidad varchar(250),
Longitud varchar(50),
Latitud varchar(50),
Fecha_Alta varchar(50),
Usuario_Alta varchar(50),
Fecha_Ultima_Modificacion varchar(50),
Usuario_Ultima_Modificacion varchar(50),
Marca_Baja varchar(50),
col10 int
);

CREATE OR REPLACE TABLE empleado(
IdEmpleado int,
Apellido varchar(50),
Nombre varchar(50),
Sucursal varchar(50),
Sector varchar(50),
Cargo varchar(50),
Salario varchar(50)
);

CREATE OR REPLACE TABLE producto(
IdProducto int,
Producto varchar(250),
TipoProducto varchar(50),
Precio varchar(50)
);

CREATE OR REPLACE TABLE venta(
IdVenta int,
Fecha date,
Fecha_Entrega date,
IdCanal int,
IdCliente int,
IdSucursal int,
IdEmpleado int,
IdProducto int,
Precio decimal(10,2),
Cantidad int
);

CREATE OR REPLACE TABLE compra(
IdCompra int,
Fecha date,
IdProducto int,
Cantidad int,
Precio decimal(10,2),
IdProveedor int
);

CREATE OR REPLACE TABLE gasto(
IdGasto int,
IdSucursal int,
IdTipoGasto int,
Fecha date,
Monto decimal(10,2)
);

-- Copy files from bucket into tables
COPY INTO tipo_gasto
FROM @retail_s3_stage/TiposDeGasto.csv
FILE_FORMAT = (
    TYPE = CSV 
    SKIP_HEADER = 1); -- Skip the first row (header) in the CSV file.

SELECT * FROM tipo_gasto;

COPY INTO sucursal
FROM @retail_s3_stage/Sucursales.csv
FILE_FORMAT = (
    TYPE = CSV 
    FIELD_DELIMITER = ';'
    SKIP_HEADER = 1);

SELECT * FROM sucursal;

COPY INTO proveedor
FROM @retail_s3_stage/Proveedores.csv
FILE_FORMAT = (
    TYPE = CSV 
    FIELD_DELIMITER = ';'
    SKIP_HEADER = 1);

SELECT * FROM proveedor;

COPY INTO canal_venta
FROM @retail_s3_stage/Canalventa.csv
FILE_FORMAT = (
    TYPE = CSV 
    FIELD_DELIMITER = ';'
    SKIP_HEADER = 1
    ERROR_ON_COLUMN_COUNT_MISMATCH = FALSE);

SELECT * FROM canal_venta;


COPY INTO cliente
FROM @retail_s3_stage/Clientes.csv
FILE_FORMAT = (
    TYPE = CSV 
    FIELD_DELIMITER = ';'
    SKIP_HEADER = 1);

SELECT * FROM cliente;

COPY INTO empleado
FROM @retail_s3_stage/Empleados.csv
FILE_FORMAT = (
    TYPE = CSV
    FIELD_DELIMITER = ';'
    SKIP_HEADER = 1);

SELECT * FROM empleado;

COPY INTO producto
FROM @retail_s3_stage/Productos.csv
FILE_FORMAT = (
    TYPE = CSV
    FIELD_DELIMITER = ';'
    SKIP_HEADER = 1
    ERROR_ON_COLUMN_COUNT_MISMATCH = FALSE);

SELECT * FROM producto;

COPY INTO venta
FROM @retail_s3_stage/Venta.csv
FILE_FORMAT = (
    TYPE = CSV
    FIELD_DELIMITER = ','
    SKIP_HEADER = 1);

SELECT * FROM venta;

COPY INTO compra
FROM @retail_s3_stage/Compra.csv
FILE_FORMAT =(
    TYPE = CSV
    FIELD_DELIMITER = ','
    SKIP_HEADER = 1);

SELECT * FROM compra;

COPY INTO gasto
FROM @retail_s3_stage/Gasto.csv
FILE_FORMAT = (
    TYPE = CSV
    FIELD_DELIMITER = ','
    SKIP_HEADER = 1);

SELECT * FROM gasto;
