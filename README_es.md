<img src="src/mike-petrucci-open-unsplash.jpg" height="400" width="1000">

![Static Badge](https://img.shields.io/badge/Snowflake-gray?style=flat&logo=snowflake)
![Static Badge](https://img.shields.io/badge/SQL-gray?style=flat&logo=SQL)
![Static Badge](https://img.shields.io/badge/AWS--S3-gray?style=flat&logo=aws)
![Static Badge](https://img.shields.io/badge/PowerBI-gray?style=flat&logo=powerbi)


# Construyendo un Ecosistema de Datos con Snowflake y AWS-S3 <br> Análisis de una Empresa de Retail

For the english version, click [here](README.md)

## Resumen del Proyecto

En este proyecto integral de ingeniería de datos, construimos meticulosamente un poderoso ecosistema de datos utilizando AWS-S3 como datalake y Snowflake como data warehouse. Nuestro objetivo principal fue integrar y transformar diversos conjuntos de datos de una tienda de retail de equipos electrónicos, abarcando ventas, información del cliente, detalles del proveedor y datos del producto. A través de procesos de ETL meticulosos y transformaciones SQL, normalizamos los datos, asegurando su integridad y coherencia.

## Datasets

Nuestro conjunto de datos comprendía diez tablas distintas, que abarcan tanto formatos CSV como XLSX. Cada tabla encapsulaba aspectos vitales del negocio, desde canales de ventas y perfiles de clientes hasta registros detallados de compras e información del proveedor.

### Tablas Clave:

- **Canal Venta**: Información sobre diversos canales de ventas.
- **Clientes**: Perfiles completos de los clientes.
- **Compra**: Registros detallados de transacciones, incluyendo datos específicos de las sucursales.
- **Empleados**: Datos de los empleados, incluyendo roles y responsabilidades.
- **Gasto**: Registros de gastos fijos incurridos por las sucursales.
- **Productos**: Catálogo completo de productos.
- **Proveedores**: Detalles del proveedor asociados con los productos de la tienda.
- **Sucursales**: Información sobre las sucursales de la tienda.
- **Tipos de Gasto**: Categorización de diferentes tipos de gastos.
- **Venta**: Datos transaccionales relacionados con ventas realizadas en las sucursales.

## Proceso ETL: Ingestión y Transformación de Datos

![snowflake](src/captura-snowflake.PNG)

Nuestro proceso ETL (Extraer, Transformar, Cargar) fue meticuloso y sistemático, asegurando la calidad, consistencia y coherencia de los datos. Las principales transformaciones realizadas en Snowflake incluyeron:

### Ingestión de Datos desde CSV a AWS S3

1. **Subida de Archivos CSV**: El primer paso implicó subir los archivos CSV a un bucket en AWS-S3. Esto se hizo usando la Consola de Administración de AWS, AWS CLI o cualquier otro método preferido para cargar archivos en S3. Los pasos detallados se encuentran en el script [loading_aws.sh](loading_aws.sh).

   ```bash
   aws s3 cp local_file_path s3://bucket_name/
   ```

2. **Configuración del bucket en AWS S3**: Asegurar configuraciones adecuadas del bucket, incluyendo permisos y control de acceso, fue crucial para asegurar los datos y permitir una ingesta sin problemas.

### Staging de Datos en Snowflake

1. **Creación de Stage en Snowflake**: En Snowflake, se creó un stage para apuntar al bucket S3 específico y la carpeta donde se almacenaban los archivos CSV. Este stage actuaba como una ubicación intermedia para la transferencia de datos.

   ```sql
   CREATE STAGE my_stage
   URL='s3://bucket_name/folder/'
   CREDENTIALS = (AWS_KEY_ID='mi_aws_key_id' AWS_SECRET_KEY='mi_aws_secret_key')
   FILE_FORMAT = (TYPE=CSV FIELD_OPTIONALLY_ENCLOSED_BY='"');
   ```

2. **Copia de Datos desde es Stage a las Tablas de Snowflake**: Utilizando el comando `COPY INTO` de Snowflake, los datos de los archivos en el stage fueron copiados a las tablas de Snowflake.

   ```sql
   COPY INTO target_table
   FROM @my_stage/file_name.csv
   FILE_FORMAT = (TYPE=CSV FIELD_OPTIONALLY_ENCLOSED_BY='"')
   ON_ERROR = 'CONTINUE';
   ```
    Los detalles de la creación de la base de datos y las tablas se encuentran en el archivo [snowflake_db_creation.sql](snowflake_db_creation.sql).

3. **Transformación de Datos en Snowflake**: Después de la ingestión, se realizaron varias transformaciones, como limpieza de datos, normalización de esquemas y conversión de tipos de columnas, directamente en Snowflake usando consultas SQL. Estas transformaciones aseguraron que los datos cumplieran con los estándares requeridos de calidad y estructura. Algunas de las transformaciones realizadas fueron:

- **Estandarización de Canales de Ventas**: Garantizando consistencia al eliminar columnas innecesarias y renombrar campos.
  
- **Refinamiento de Datos de Clientes**: Formateo de coordenadas geográficas, renombrado de identificadores de clientes y creación de tablas de dimensiones para localidad y provincia.
  
- **Normalización de Cargos de Empleados**: Creación de una tabla de dimensiones completa para títulos o cargos de trabajo.
  
- **Optimización de Compras**: Establecimiento de conexiones con proveedores y productos, mejorando la integridad de los datos.
  
- **Enriquecimiento de Datos de Empleados**: Creación de un código de empleado autoincremental para evitar duplicados de IdEmpleado. Estandarización de nombres de sucursales para coincidencias precisas.
  
- **Mejora de Gastos**: Creación de una tabla de dimensiones detallada para tipos de gastos.
  
- **Refinamiento de Datos Espaciales**: Estandarización de valores de latitud y longitud y creación de una tabla de dimensiones completa para sucursales.
  
- **Creación de Dimensión Temporal**: Implementación de un procedimiento personalizado para construir una tabla de calendario robusta que abarca varios años.

    Los detalles se encuentran en el archivo [snowflake_transformation.sql](snowflake_transformation.sql). 

## Arquitectura

Decidimos crear un esquema de copo de nieve o Snowflake. El Esquema Snowflake extiende el Esquema Estrella al normalizar aún más las tablas de dimensión. En este esquema, las tablas de dimensión se organizan en múltiples tablas relacionadas, creando una forma de copo de nieve cuando se diagrama. Cada nivel de normalización reduce la redundancia a expensas de la complejidad aumentada.
Entre sus ventajas podemos destacar:
- Eficiencia Espacial: Reduce la redundancia, ahorrando espacio de almacenamiento, lo cual puede ser significativo para conjuntos de datos grandes.
- Integridad de Datos: La normalización asegura la integridad de los datos y reduce las posibilidades de anomalías de actualización.

Este esquema es ideal para situaciones donde la optimización del almacenamiento es crucial y donde hay necesidad de mantener la integridad de los datos incluso a expensas de una complejidad ligeramente aumentada en las consultas.

### Arquitectura Final:
![Arquitectura Final](src/data_model_snowflake.PNG)

## Visualizaciones: Empoderando la Toma de Decisiones con PowerBI

El dashboard de PowerBI, conectado perfectamente a la base de datos de Snowflake, proporciona visualizaciones efectivas de patrones y tendencias clave de ventas. Las visualizaciones destacan tendencias esenciales, permitiendo a las partes interesadas obtener información práctica y a la mano para tomar decisiones estratégicas. El informe interactivo está disponible [aquí](https://www.novypro.com/project/aws-s3-snowflake-power-bi-retail-sales-analysis).

![dashboard](src/dashboard.jpeg)

## Conclusión

En este proyecto, no solo hemos construido con éxito un ecosistema de datos, sino que también hemos proporcionado una base para la toma de decisiones basada en datos. La integración efectiva de diversos conjuntos de datos, las transformaciones meticulosas y la visualización efectiva en PowerBI muestran la profundidad y amplitud de nuestros esfuerzos en tareas relacionadas con la ingeniería de datos.