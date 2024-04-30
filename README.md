# RH DATA ANALYSIS - SQL SERVER / POWER BI
Este proyecto profundiza en el ámbito del análisis de datos utilizando SQL y Power BI para descubrir importantes conocimientos sobre recursos humanos que pueden beneficiar enormemente a la empresa.
Los paneles de control llamativos ofrecen métricas de recursos humanos cruciales, como la rotación de empleados, la diversidad, la eficacia de la contratación y las evaluaciones 
de desempeño. Estos ayudan a los profesionales de recursos humanos a tomar decisiones informadas y planificar estratégicamente la fuerza laboral.

## Datos fuente:
Los datos de origen contiene 22000 registros de Recursos Humanos correspondientes a los años de 2000 a 2020. Esto se incluye en el repositorio.

## Limpieza y análisis de datos:
Por medio de SQL Server se realizo:
- Carga e inspección de datos.
- Manejo de valores faltantes
- Limpieza y análisis de datos.

## Visualización de datos:
Reporte de datos por medio de Power Bi.
En un entorno corporativo, los resultados se pueden compartir en línea en www.powerbi.com

![powerbi-1](https://github.com/JohaOrtiz99/Proyecto-SQL-Power-Bi/blob/main/Diapositiva2.JPG)

![powerbi-1](https://github.com/JohaOrtiz99/Proyecto-SQL-Power-Bi/blob/main/Diapositiva3.JPG)


## Análisis exploratorio de datos
### Preguntas:
1) ¿Cuál es la distribución por edades en la empresa?
2) ¿Cuál es la distribución por género en la empresa?
3) ¿Cómo varía el género entre departamentos y puestos de trabajo?
4) ¿Cuál es la distribución racial en la empresa?
5) ¿Cuál es la duración media del empleo en la empresa?
6) ¿Qué departamento tiene la tasa de rotación más alta?
7) ¿Cuál es la distribución de la tenencia para cada departamento?
8) ¿Cuántos empleados trabajan de forma remota para cada departamento?
9) ¿Cuál es la distribución de empleados en los diferentes estados?
10) ¿Cómo se distribuyen los puestos de trabajo en la empresa?
11) ¿Cómo ha variado el número de contrataciones de empleados a lo largo del tiempo?


### Hallazgos:
1) Hay más empleados hombres que mujeres o empleados no conformes.
2) Los géneros están distribuidos de manera bastante uniforme entre los departamentos. En general, hay un poco más de empleados varones.
3) Los empleados de entre 21 y 30 años son los menos de la empresa. La mayoría de los empleados tienen entre 31 y 50 años. Sorprendentemente, el grupo de edad de 50 años o más tiene el mayor número de empleados en la empresa.
4) Los empleados caucásicos son la mayoría en la empresa, seguidos por los mestizos, negros, asiáticos, hispanos y nativos americanos.
5) La duración media del empleo es de 7 años.
6) Auditoría tiene la tasa de rotación más alta, seguida de Legal, Investigación y Desarrollo y Capacitación. Desarrollo de Negocios y Marketing tienen las tasas de rotación más bajas.
7) Los empleados tienden a permanecer en la empresa entre 6 y 8 años. La tenencia se distribuye de manera bastante uniforme entre los departamentos.
8) Alrededor del 25% de los empleados trabajan de forma remota.
9) La mayoría de los empleados están en Ohio (14.788), seguidos de lejos por Pensilvania (930) e Illinois (730), Indiana (572), Michigan (569), Kentucky (375) y Wisconsin (321).
10) Hay 182 puestos de trabajo en la empresa, siendo Asistente de investigación II la mayoría de los empleados (634) y Profesor asistente, Gerente de marketing, Asistente de oficina IV, Profesor asociado y Vicepresidente de capacitación y desarrollo con solo 1 empleado cada uno.
11) El número de contrataciones de empleados ha aumentado a lo largo de los años.

### 1) Crear Base de Datos
``` SQL
CREATE DATABASE Recursos_Humanos;
```
### 2) Importar datos a SQL Server
- Haga clic derecho en Recursos_humanos > Tareas > Importar datos
- Utilice el asistente de importación para importar rh_Data.csv a la tabla de recursos humanos. 
- Verificar que la importación funcionó:

``` SQL
use rh;
```
``` SQL
SELECT *
FROM rh_data;
```

### 3) LIMPIEZA DE DATOS
La fecha se importó como un dato nvarchar(50). Esta columna contiene fechas de terminación, por lo que es necesario convertirla al formato de fecha.

####	Actualizar fecha/hora hasta la fecha
![format-termdate-1](https://github.com/kahethu/data/assets/27964625/463e86e0-8b1a-47c8-943e-f125bad98706)

 Actualizar la fecha/hora del término hasta la fecha
- 1) Convertir fechas a AAAA-MM-DD
- 2) Crear una nueva columna new_FechaT
- 3) Copiar los valores de tiempo convertidos de FECHA_TERMINACION a new_FechaT

- convertir fechas a AAAA-MM-DD

``` SQL
UPDATE rh_data
SET FECHA_TERMINACION = FORMAT(CONVERT(DATETIME, LEFT(FECHA_TERMINACION, 19), 120), 'yyyy-MM-dd');
```

- crear nueva columna new_FechaT
``` SQL

ALTER TABLE rh_data
ADD new_FechaT DATE;
```

- copiar los valores de tiempo convertidos de FECHA_TERMINACION a new_FechaT

``` SQL
UPDATE rh_data
SET new_FechaT = CASE
    WHEN FECHA_TERMINACION IS NOT NULL AND ISDATE(FECHA_TERMINACION) = 1
        THEN CAST(FECHA_TERMINACION AS DATETIME)
        ELSE NULL
    END;
```
- Comprobar resultados

``` SQL
SELECT new_FechaT
FROM rh_data;
```

#### Crear nueva columna "Edad"
``` SQL
ALTER TABLE rh_data
ADD Edad nvarchar(50)
```

#### Rellenar nueva columna con edad
``` SQL
UPDATE rh_data
SET Edad = DATEDIFF(YEAR, FECHA_NACIMIENTO, GETDATE());
```

## PREGUNTAS A RESPONDER A PARTIR DE LOS DATOS

#### 1) ¿Cuál es la distribución por edades en la empresa?

- Distribución de edad

``` SQL
SELECT 
 MIN(edad) AS Joven, 
 MAX(edad) AS Antiguo
FROM rh_data;
```

- Distribución de la edad por grupos

``` SQL
SELECT
  grupos_edad,
  COUNT(*) AS count
FROM (
  SELECT
    CASE
      WHEN Edad <= 21 AND edad <= 30 THEN '21 a 30'
      WHEN edad <= 31 AND edad <= 40 THEN '31 a 40'
      WHEN edad <= 41 AND edad <= 50 THEN '41-50'
      ELSE '50+'
    END AS grupos_edad
  FROM rh_data
  WHERE new_FechaT IS NULL
) AS Subconsulta
GROUP BY grupos_edad
ORDER BY grupos_edad;
```

- Grupos de Edad por sexo

``` SQL
SELECT
  Grupos_edad, Genero,
  COUNT(*) AS Conteo
FROM (
  SELECT
    CASE
      WHEN Edad <= 21 AND edad <= 30 THEN '21 a 30'
      WHEN edad <= 31 AND edad <= 40 THEN '31 a 40'
      WHEN edad <= 41 AND edad <= 50 THEN '41-50'
      ELSE '50+'
    END AS Grupos_edad, Genero
  FROM rh_data
  WHERE new_FechaT IS NULL
) as Subconsulta
GROUP BY grupos_edad, genero
ORDER BY grupos_edad, genero;
```
#### 2) ¿Cuál es la distribución por género en la empresa?

``` SQL
SELECT
 Genero,
 COUNT(Genero) AS Conteo
FROM rh_data
WHERE new_FechaT IS NULL
GROUP BY Genero
ORDER BY Genero ASC;
```

#### 3) ¿Cómo varía el género entre departamentos y puestos de trabajo?
- Departamentos
``` SQL
SELECT Seccion, Genero, count(*) as conteo
FROM rh_data
WHERE new_fechat IS NULL
GROUP BY Seccion, genero
ORDER BY Seccion,genero ASC;
```
- Puestos de Trabajo

``` SQL
SELECT 
Seccion, Puesto_trabajo,Genero,
count(genero) AS Conteo
FROM rh_data
WHERE new_fechat IS NULL
GROUP BY Seccion, Puesto_trabajo,Genero
ORDER BY Seccion, Puesto_trabajo,Genero ASC;
```

#### 4)¿Cuál es la distribución racial en la empresa?

``` SQL
SELECT raza,
 COUNT(*) AS conteo
FROM rh_data
WHERE new_fechat IS NULL
GROUP BY raza
ORDER BY conteo DESC;
```

#### 5) ¿Cuál es la duración media del empleo en la empresa?

``` SQL
SELECT
 AVG(DATEDIFF(year, fecha_contratacion, new_fechat)) AS Permanencia
 FROM rh_data
 WHERE new_fechat IS NOT NULL AND new_fechat <= GETDATE();

```

#### 6) Qué departamento tiene la tasa de rotación más alta?
- obtener el recuento total
- obtener el conteo terminado
- recuento terminado/recuento total

``` SQL
SELECT
 Seccion,recuento_total,conteo_terminado,
 round(CAST(conteo_terminado AS FLOAT)/recuento_total, 2) AS Tasa_facturacion
FROM 
   (SELECT
   Seccion,
   count(*) AS Recuento_total,
   SUM(CASE
        WHEN new_fechat IS NOT NULL AND new_fechat <= getdate()
		THEN 1 ELSE 0
		END
   ) AS conteo_terminado
  FROM rh_data
  GROUP BY Seccion
  ) AS Subquery
ORDER BY tasa_facturacion DESC;

```

#### 7) Cuál es la distribución de la permanencia para cada seccion?

``` SQL
SELECT Seccion,
    AVG(DATEDIFF(year, fecha_contratacion, new_fechat)) AS Permanencia
FROM rh_data
WHERE 
    new_FechaT IS NOT NULL 
    AND new_fechat <= GETDATE()
GROUP BY seccion;
```


#### 8) Cuántos empleados trabajan de forma remota para cada departamento?

``` SQL
SELECT Lugar,
 count(*) AS Conteo
 FROM rh_data
 WHERE new_fechat IS NULL
 GROUP BY lugar;
```

#### 9) Cuál es la distribución de empleados en los diferentes estados?

``` SQL
SELECT Estado,
count(*) AS Conteo
FROM rh_data
WHERE new_fechat IS NULL
GROUP BY estado
ORDER BY conteo DESC;
```

#### 10)Cómo se distribuyen los puestos de trabajo en la empresa?

``` SQL
SELECT Puesto_Trabajo,
 count(*) AS Cantidad
FROM rh_data
WHERE new_fechat IS NULL
GROUP BY Puesto_trabajo
ORDER BY cantidad DESC;
```

#### 11)¿Cómo han variado los recuentos de contratación de empleados a lo largo del tiempo?
- calcular contrataciones
- calcular terminaciones
- (contrataciones-despidos)/contrataciones cambio porcentual de contratación
  
``` SQL
SELECT año_contr,Contratacion,Terminacion,
    (contratacion - terminacion) AS Cambio,
    (round(CAST(contratacion - terminacion AS FLOAT) / NULLIF(contratacion, 0), 2)) *100 AS Porcentaje_cambio_contratación
FROM  
    (SELECT
        YEAR(fecha_contratacion) AS Año_contr,
  count(*) as contratacion,
  SUM(CASE WHEN new_fechat IS NOT NULL AND new_fechat <= GETDATE() THEN 1 ELSE 0 END) terminacion
  FROM rh_data
  GROUP BY year(fecha_contratacion)
  ) AS Subconsulta
ORDER BY porcentaje_cambio_contratación ASC;
```
