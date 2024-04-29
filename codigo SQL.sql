/*
Este proyecto profundiza en el ámbito del análisis de datos utilizando SQL y Power BI para descubrir importantes conocimientos 
sobre recursos humanos que pueden beneficiar enormemente a la empresa.
Author: Johanna Ortiz
*/

-- crear base de datos
CREATE DATABASE Recursos_Humanos


-- explorar los datos cargados en rh_data
SELECT * FROM rh_data;


-- explorar la estructura de la tabla
SELECT COLUMN_NAME, DATA_TYPE, CHARACTER_MAXIMUM_LENGTH
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME = 'rh_data';


-- Se corrigió el formato de la columna "FECHA_TERMINACION"
--formato FECHA_TERMINACION ES fecha/hora valores UTC
-- Actualizar fecha/hora hasta la fecha

select FECHA_TERMINACION from rh_data
order by FECHA_TERMINACION desc;

UPDATE rh_data
SET FECHA_TERMINACION = FORMAT(CONVERT(DATETIME, LEFT(FECHA_TERMINACION, 19), 120), 'yyyy-MM-dd');


-- Actualización de nvachar hasta la fecha
-- Primero, agregue una nueva columna de fecha
ALTER TABLE rh_data
ADD New_FechaT DATE;

-- Actualice la nueva columna de fecha con los valores convertidos

UPDATE rh_data
SET new_FechaT = CASE
    WHEN FECHA_TERMINACION IS NOT NULL AND ISDATE(FECHA_TERMINACION) = 1
        THEN CAST(FECHA_TERMINACION AS DATETIME)
        ELSE NULL
    END;


SELECT new_FechaT
FROM rH_data
ORDER BY new_FechaT desc;

-- Crear nueva columna "Edad"
ALTER TABLE rh_data
ADD Edad nvarchar(50)


-- llenar con datos la columna Edad
UPDATE rh_data
SET Edad = DATEDIFF(YEAR, FECHA_NACIMIENTO, GETDATE());

SELECT FECHA_NACIMIENTO, Edad
FROM rh_data
ORDER BY edad;

-- Edades minimas y Maximas 
SELECT 
 MIN(edad) AS min_edad, 
 MAX(edad) AS max_edad
FROM rh_data;

-- PREGUNTAS A RESPONDER A PARTIR DE LOS DATOS

-- 1) ¿Cuál es la distribución por edades en la empresa?

-- Distribución de edad
SELECT 
 MIN(edad) AS Joven, 
 MAX(edad) AS Antiguo
FROM rh_data;

--Distribución del grupo de edad

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

-- grupo de edad por sexo

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


-- 2) ¿Cuál es el desglose por género en la empresa?

SELECT
 Genero,
 COUNT(Genero) AS Conteo
FROM rh_data
WHERE new_FechaT IS NULL
GROUP BY Genero
ORDER BY Genero ASC;

-- 3) ¿Cómo varía el género entre seccion y puestos de trabajo?

-- sección
SELECT Seccion, Genero, count(*) as conteo
FROM rh_data
WHERE new_fechat IS NULL
GROUP BY Seccion, genero
ORDER BY Seccion;


-- puestos de trabajo
SELECT 
Seccion, Puesto_trabajo,Genero,
count(genero) AS Conteo
FROM rh_data
WHERE new_fechat IS NULL
GROUP BY Seccion, Puesto_trabajo,Genero
ORDER BY Seccion, Puesto_trabajo,Genero ASC;


-- 4) ¿Cuál es la distribución racial en la empresa?
SELECT raza,
 COUNT(*) AS conteo
FROM rh_data
WHERE new_fechat IS NULL
GROUP BY raza
ORDER BY conteo DESC;


-- 5) ¿Cuál es la duración media del empleo en la empresa?
SELECT
 AVG(DATEDIFF(year, fecha_contratacion, new_fechat)) AS Permanencia
 FROM rh_data
 WHERE new_fechat IS NOT NULL AND new_fechat <= GETDATE();

-- 6) ¿Qué departamento tiene la tasa de rotación más alta?
--obtener el recuento total
---obtener el conteo terminado
-- recuento terminado/recuento total

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




-- 7) ¿Cuál es la distribución de la permanencia para cada seccion?
--opcion 1
SELECT Seccion,
    AVG(DATEDIFF(year, fecha_contratacion, new_fechat)) AS Permanencia
FROM rh_data
WHERE 
    new_FechaT IS NOT NULL 
    AND new_fechat <= GETDATE()
GROUP BY seccion;


-- 8)¿Cuántos empleados trabajan de forma remota para cada departamento?
SELECT Lugar,
 count(*) AS Conteo
 FROM rh_data
 WHERE new_fechat IS NULL
 GROUP BY lugar;


-- 9)¿Cuál es la distribución de empleados en los diferentes estados?
SELECT Estado,
count(*) AS Conteo
FROM rh_data
WHERE new_fechat IS NULL
GROUP BY estado
ORDER BY conteo DESC;


-- 10) ¿Cómo se distribuyen los puestos de trabajo en la empresa?
SELECT Puesto_Trabajo,
 count(*) AS Cantidad
FROM rh_data
WHERE new_fechat IS NULL
GROUP BY Puesto_trabajo
ORDER BY cantidad DESC;



-- 11) ¿Cómo han variado los recuentos de contratación de empleados a lo largo del tiempo?

SELECT
año_contr,Contratacion,Terminacion,
(contratacion - terminacion) AS Cambio,
(contratacion - terminacion)/contratacion AS porcentaje_cambio_contratación
FROM  
  (SELECT
  YEAR(fecha_contratacion) AS Año_contr,
  count(*) as contratacion,
  SUM(CASE WHEN new_fechat IS NOT NULL AND new_fechat <= GETDATE() THEN 1 ELSE 0 END) terminacion
  FROM rh_data
  GROUP BY year(fecha_contratacion)
  ) AS Subconsulta
ORDER BY porcentaje_cambio_contratación ASC;

-- corrige valores cero de la consulta anterior

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

