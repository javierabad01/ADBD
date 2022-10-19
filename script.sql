
/*----------------------------------------------------------------
DROP DE TABLAS
*/
DROP TABLE IF EXISTS titular CASCADE;
DROP TABLE IF EXISTS persona_juridica CASCADE;
DROP TABLE IF EXISTS establecimiento CASCADE;
DROP TABLE IF EXISTS mercado CASCADE;
DROP TABLE IF EXISTS espacios CASCADE;
DROP TABLE IF EXISTS zonas_comerciales CASCADE;
DROP TABLE IF EXISTS puesto CASCADE;
DROP TABLE IF EXISTS instalacion_auxiliar CASCADE;
DROP TABLE IF EXISTS instalacion_complementaria CASCADE;
DROP TABLE IF EXISTS faltas CASCADE;
DROP TABLE IF EXISTS concesion CASCADE;
DROP TABLE IF EXISTS transmision CASCADE;

DROP DOMAIN IF EXISTS gestion_mer;
DROP DOMAIN IF EXISTS estado_esp;
DROP DOMAIN IF EXISTS fin_zonacom;
DROP DOMAIN IF EXISTS tipo_instaux;
DROP DOMAIN IF EXISTS fin_pue;
DROP DOMAIN IF EXISTS gestion_inscom;
DROP DOMAIN IF EXISTS fin_inscom;
DROP DOMAIN IF EXISTS tipo_venta_est;
DROP DOMAIN IF EXISTS tipo_falta;
DROP DOMAIN IF EXISTS motivo_trans;
DROP DOMAIN IF EXISTS tipo_con;
DROP DOMAIN IF EXISTS causa_con;

/*
Creamos los dominios
*/

CREATE DOMAIN gestion_mer AS VARCHAR(25)
CHECK ( VALUE IN ('directa', 'indirecta','asociacion comerciantes'));

CREATE DOMAIN estado_esp AS VARCHAR(10)
CHECK ( VALUE IN ('abierto','cerrado','obra')); 

CREATE DOMAIN fin_zonacom AS VARCHAR(20)
CHECK ( VALUE IN ('genero temporada','exposicion productos','actividades'));

CREATE DOMAIN tipo_instaux AS VARCHAR(15)
CHECK ( VALUE IN ('almacen','frigorifico'));

CREATE DOMAIN fin_pue AS VARCHAR(15)
CHECK ( VALUE IN ('alimentacion','artesania','moda'));

CREATE DOMAIN gestion_inscom AS VARCHAR(25)
CHECK ( VALUE IN ('directa','indirecta','asociacion comerciantes'));

CREATE DOMAIN fin_inscom AS VARCHAR(25)
CHECK ( VALUE IN ('publicidad','informacion','servicios complementarios'));

CREATE DOMAIN tipo_venta_est AS VARCHAR(25)
CHECK ( VALUE IN ('pescaderia','carniceria','fruteria','charcuteria'));

CREATE DOMAIN tipo_falta AS VARCHAR(10)
CHECK ( VALUE IN ('leve','grave','muy grave'));

CREATE DOMAIN tipo_con AS VARCHAR(10)
CHECK ( VALUE IN ('fija','especial','temporal'));

CREATE DOMAIN causa_con AS VARCHAR(25)
CHECK ( VALUE IN ('subasta','concurso','adjudicacion directa'));

CREATE DOMAIN motivo_trans AS VARCHAR(15)
CHECK ( VALUE IN ('mortiscausa','intervivos')); 


/*----------------------------------------------------------------
DEFINICIÓN DE TABLAS
*/

CREATE TABLE titular(

         /*---------------------------------------------------------------- 
        atributos propios de titular
        */

        id_dni VARCHAR(10) ,

        nombre_tit VARCHAR(255) NOT NULL ,
        telefono_tit INTEGER NOT NULL ,
        domicilio_tit VARCHAR(255) NOT NULL ,
        sancionado_tit BIT NOT NULL,

        CONSTRAINT titular__clave
        PRIMARY KEY (id_dni)
/*
        CONSTRAINT telefono_tit__correcto
        CHECK (telefono_tit >= 0 AND LEN(telefono_tit) == 9),

        CONSTRAINT id_dni__bien
        CHECK (id_dni LIKE '[0-9](8)%(1)' OR '%(1)[0-9](7)%(1)')
        */

);



CREATE TABLE persona_juridica(
        /*
        Clave foranea hacia titular
        */
        id_dni VARCHAR(10) ,

        /*---------------------------------------------------------------- 
        atributos propios de persona juridica
        */


        nombre_sociedad_perj VARCHAR(255) NOT NULL ,
        
        CONSTRAINT persona_juridica__clave
        PRIMARY KEY (id_dni,nombre_sociedad_perj),

        CONSTRAINT persona_juridica_extends_titular
        FOREIGN KEY(id_dni)
        REFERENCES titular (id_dni)

);

CREATE TABLE establecimiento(

        /*---------------------------------------------------------------- 
        atributos propios de establecimiento
        */

        id_est INTEGER   ,

        nombre_est VARCHAR(255) NOT NULL,
        tipo tipo_venta_est NOT NULL ,

        CONSTRAINT establecimiento__clave
        PRIMARY KEY (id_est)

);

CREATE TABLE mercado(

        /*
        Clave foranea hacia titular
        */
        id_dni VARCHAR(10) ,

        /*----------------------------------------------------------------
        atributos propios de mercado
        */

        nombre_mer  VARCHAR(255)  ,

        renta_mer DOUBLE PRECISION NOT NULL ,
        cuota_mer DOUBLE PRECISION NOT NULL ,
        beneficio_mer DOUBLE PRECISION NOT NULL ,
        gastos_mer DOUBLE PRECISION NOT NULL ,
        gestion gestion_mer NOT NULL,


        CONSTRAINT mercado__clave 
        PRIMARY KEY (nombre_mer) ,

        CONSTRAINT mercado__titular
        FOREIGN KEY (id_dni)
        REFERENCES titular (id_dni),

        CONSTRAINT renta_mer__positiva
        CHECK ( renta_mer >= 0),

        CONSTRAINT cuota_mer__positiva
        CHECK ( cuota_mer >= 0),

        CONSTRAINT beneficio_mer__positivo
        CHECK ( beneficio_mer >= 0),

        CONSTRAINT gastos_mer__positiva
        CHECK ( gastos_mer >= 0)
        
);

CREATE TABLE espacios(

        /*
        Clave foranea hacia mercado
        */
        nombre_mer VARCHAR(255) ,

        /*
        Clave foranea hacia establecimiento
        */
        id_est INTEGER ,

        /*
        Clave foranea hacia titular
        */
        id_dni VARCHAR(10) ,

        /*---------------------------------------------------------------- 
        atributos propios de espacios 
        */

        id_esp INTEGER   ,

        espacio_esp INTEGER NOT NULL ,
        estado estado_esp NOT NULL,
        anualidad_esp DOUBLE PRECISION NOT NULL ,


        CONSTRAINT espacios__clave
        PRIMARY KEY (id_esp,nombre_mer),

        CONSTRAINT espacios__titular
        FOREIGN KEY (id_dni)
        REFERENCES titular (id_dni) ,

        CONSTRAINT espacios__mercado
        FOREIGN KEY (nombre_mer)
        REFERENCES mercado (nombre_mer) ,

        CONSTRAINT espacios__establecimiento
        FOREIGN KEY (id_est)
        REFERENCES establecimiento (id_est) ,

        CONSTRAINT espacio_esp__positivo
        CHECK ( espacio_esp >= 0),

        CONSTRAINT anualidad_esp__positivo
        CHECK (anualidad_esp >= 0)

);

CREATE TABLE zonas_comerciales(
        
        /*
        Clave foranea hacia espacio
        */
        id_esp INTEGER ,

        /*
        Clave foranea de mercado hacia espacio
        */
        nombre_mer VARCHAR(255) ,


        /*---------------------------------------------------------------- 
        atributos propios de zonas comerciales
        */

        fin fin_zonacom NOT NULL,


        CONSTRAINT zonas_comerciales__clave
        PRIMARY KEY (id_esp,nombre_mer),

        CONSTRAINT zonas_comerciales_extends_espacios
        FOREIGN KEY (id_esp,nombre_mer)
        REFERENCES espacios (id_esp,nombre_mer)

);


CREATE TABLE puesto(
        
        /*
        Clave foranea hacia espacio
        */
        id_esp INTEGER ,

        /*
        Clave foranea de mercado hacia espacio
        */
        nombre_mer VARCHAR(255) ,

        /*---------------------------------------------------------------- 
        atributos propios de puesto
        */

        fecha_obra_pue DATE  ,
        fin fin_pue NOT NULL ,


        CONSTRAINT puesto__clave
        PRIMARY KEY (id_esp,nombre_mer),

        CONSTRAINT puesto_extends_espacios
        FOREIGN KEY (id_esp,nombre_mer)
        REFERENCES espacios (id_esp,nombre_mer) ,

        CONSTRAINT fecha_obra_pue__correcta
        CHECK ( 
                CASE WHEN fecha_obra_pue IS NOT NULL
                    THEN
                        fecha_obra_pue <= CURRENT_TIMESTAMP
                END
        )
    
);

CREATE TABLE instalacion_auxiliar(
        
        /*
        Clave foranea hacia espacio
        */
        id_esp INTEGER ,
        /*
        Clave foranea de mercado hacia espacio
        */
        nombre_mer VARCHAR(255) ,

        /*
        Clave foranea hacia puesto
        */
        id_esp_puesto INTEGER,

        /*
        Clave foranea de mercado hacia puesto
        */
        id_nombre_mer_puesto VARCHAR(255),

        /*---------------------------------------------------------------- 
        atributos propios de instalacion auxiliar
        */

        tipo tipo_instaux NOT NULL ,
        gestion gestion_inscom NOT NULL ,

        CONSTRAINT instalacion_auxiliar__unique
        UNIQUE (id_esp,nombre_mer,id_esp_puesto,id_nombre_mer_puesto),  
        CONSTRAINT instalacion_auxiliar__clave
        PRIMARY KEY (id_esp,nombre_mer),

        CONSTRAINT instalacion_auxiliar_extends_espacios
        FOREIGN KEY (id_esp,nombre_mer)
        REFERENCES espacios (id_esp,nombre_mer),


        CONSTRAINT instalacion_auxiliar__puesto
        FOREIGN KEY (id_esp_puesto,id_nombre_mer_puesto)
        REFERENCES puesto(id_esp,nombre_mer)


);



CREATE TABLE instalacion_complementaria(
        
        /*
        Clave foranea hacia espacio
        */
        id_esp INTEGER ,

        /*
        Clave foranea de mercado hacia espacio
        */
        nombre_mer VARCHAR(255) ,

        /*---------------------------------------------------------------- 
        atributos propios de instalacion complementaria
        */

        gestion gestion_inscom NOT NULL,
        fin fin_inscom NOT NULL ,


        CONSTRAINT instalacion_complementaria__clave
        PRIMARY KEY (id_esp,nombre_mer),

        CONSTRAINT instalacion_complementaria_extends_espacios
        FOREIGN KEY (id_esp,nombre_mer)
        REFERENCES espacios (id_esp,nombre_mer)


);



CREATE TABLE faltas(

        /*
        Clave foranea hacia titular
        */
        id_dni VARCHAR(10) ,

        /*
        Clave foranea hacia establecimiento
        */
        id_est INTEGER ,

        /*---------------------------------------------------------------- 
        atributos propios de faltas
        */

        id_falta INTEGER   ,

        motivo_falta VARCHAR(255) NOT NULL ,
        fecha_ini_falta DATE NOT NULL ,
        fecha_fin_falta DATE  ,
        sancion_economica_falta DOUBLE PRECISION NOT NULL ,
        tipo tipo_falta NOT NULL,

        CONSTRAINT faltas__unique
        UNIQUE(id_dni,id_est,id_falta,fecha_ini_falta),

        CONSTRAINT faltas__clave
        PRIMARY KEY (id_falta,id_est,id_dni),

        CONSTRAINT faltas__titular
        FOREIGN KEY(id_dni)
        REFERENCES titular (id_dni) ,

        CONSTRAINT faltas__establecimiento
        FOREIGN KEY (id_est)
        REFERENCES establecimiento (id_est),

        CONSTRAINT sancion_economica_falta__positiva
        CHECK ( sancion_economica_falta >= 0 ),


        CONSTRAINT fecha_ini_falta__correcta
        CHECK (fecha_ini_falta <= CURRENT_TIMESTAMP),

        CONSTRAINT fecha_fin_falta__correctas
        CHECK (
            CASE WHEN fecha_fin_falta IS NOT NULL
                THEN
                    fecha_fin_falta >= CURRENT_TIMESTAMP AND fecha_fin_falta <> fecha_ini_falta
                END
        ),       

        CONSTRAINT falta_tipo_leve
        CHECK ( 
                CASE WHEN tipo = 'leve' 
                    THEN  sancion_economica_falta <= 50000
                END
        ),

        CONSTRAINT falta_tipo_grave
        CHECK ( 
                CASE WHEN tipo = 'grave' 
                    THEN  sancion_economica_falta <= 150000 AND (extract(day from fecha_fin_falta)-extract(day from fecha_ini_falta))<=60
                END
        ),

        CONSTRAINT falta_tipo_muy_grave
        CHECK ( 
                CASE WHEN tipo = 'muy grave' 
                    THEN  sancion_economica_falta <= 300000 AND  (extract(day from fecha_fin_falta)-extract(day from fecha_ini_falta))<=90
                END
        )

);

CREATE TABLE concesion(

        /*
        Clave foranea hacia espacios
        */
        id_esp INTEGER ,

        /*
        Clave foranea de mercado hacia espacio
        */
        nombre_mer VARCHAR(255) ,

        /*
        Clave foranea hacia titular
        */
        id_dni VARCHAR(10) ,

        /*---------------------------------------------------------------- 
        atributos propios de concesion
        */

        id_concesion INTEGER ,

        fianza_con DOUBLE PRECISION NOT NULL ,
        fecha_ini_con DATE NOT NULL,
        fecha_fin_con DATE NOT NULL,
        tipo tipo_con NOT NULL , 
        contador_prorrogas_con INTEGER NOT NULL ,
        causa causa_con NOT NULL,

        CONSTRAINT concesion__unique
        UNIQUE (id_esp,nombre_mer,id_concesion,id_dni),

        CONSTRAINT concesion__clave
        PRIMARY KEY (id_concesion),

        CONSTRAINT concesion__espacios
        FOREIGN KEY (id_esp,nombre_mer)
        REFERENCES espacios (id_esp,nombre_mer) ,

        CONSTRAINT concesion__titular
        FOREIGN KEY (id_dni)
        REFERENCES titular (id_dni) ,

        CONSTRAINT fianza_con__positiva
        CHECK ( fianza_con >= 0),

        CONSTRAINT contador_prorrogas_con__postivo
        CHECK ( contador_prorrogas_con >= 0) ,

        CONSTRAINT fecha_ini_con_y_fecha_fin_con__correctas
        CHECK ( fecha_ini_con <= CURRENT_TIMESTAMP AND fecha_fin_con >= CURRENT_TIMESTAMP AND fecha_fin_con <> fecha_ini_con),

        CONSTRAINT concesion_tipo_temporal_sin_prorrogas
        CHECK ( 
                CASE WHEN tipo = 'temporal' AND contador_prorrogas_con = 0 THEN
                (extract(month from fecha_fin_con)-extract(month from fecha_ini_con))<=1                       
                END
        ),

        CONSTRAINT concesion_tipo_temporal_con_prorrogas
        CHECK ( 
                CASE WHEN tipo = 'temporal' AND contador_prorrogas_con > 0
                    THEN (extract(month from fecha_fin_con)-extract(month from fecha_ini_con))<=12
                        
                END
        ),

        CONSTRAINT concesion_tipo_fija
        CHECK ( 
                CASE WHEN tipo = 'fija'
                    THEN (extract(year from fecha_fin_con)-extract(year from fecha_ini_con))>1
                END
        ),

        CONSTRAINT concesion_tipo_especial_sin_prorrogas
        CHECK ( 
                CASE WHEN tipo = 'especial' AND contador_prorrogas_con = 0
                    THEN  (extract(year from fecha_fin_con)-extract(year from fecha_ini_con))<=5
                END
        ),

        CONSTRAINT concesion_tipo_especial_con_prorrogas
        CHECK ( 
                CASE WHEN tipo = 'especial' AND contador_prorrogas_con  > 0
                    THEN  (extract(year from fecha_fin_con)-extract(year from fecha_ini_con))<=10
                END
        )
);

CREATE TABLE transmision(

        /*
        Clave foranea hacia concesion
        */
        id_concesion INTEGER ,

         /*---------------------------------------------------------------- 
        atributos propios de transmision
        */

        fecha_trans DATE ,

        motivo motivo_trans NOT NULL ,
        precio_trans DOUBLE PRECISION NOT NULL ,

        CONSTRAINT transmision__clave
        PRIMARY KEY (id_concesion,fecha_trans),

        CONSTRAINT transmision__concesion
        FOREIGN KEY (id_concesion)
        REFERENCES concesion (id_concesion) ,

        CONSTRAINT precio_trans__positivo
        CHECK ( precio_trans >= 0 ),

        CONSTRAINT fecha_trans__correcta
        CHECK ( fecha_trans <= CURRENT_TIMESTAMP)

);


/* Poblacion de las tablas */

/*
Insercion de titular
*/
INSERT INTO titular(id_dni,nombre_tit,telefono_tit,domicilio_tit,sancionado_tit) VALUES
('78909456P','David',634765898,'Calle Uno /nº 1',B'0');

INSERT INTO titular(id_dni,nombre_tit,telefono_tit,domicilio_tit,sancionado_tit)  VALUES
('72909456P','Adolfo',624765898,'Calle Dos /nº 2',B'0');

INSERT INTO titular(id_dni,nombre_tit,telefono_tit,domicilio_tit,sancionado_tit)  VALUES
('78909456Q','Daniel',634769898,'Calle Tres /nº 3',B'1');

INSERT INTO titular(id_dni,nombre_tit,telefono_tit,domicilio_tit,sancionado_tit)  VALUES
('78919456Q','Julian',634165898,'Calle Cuatro /nº 4',B'1');


/*
Insercion de persona juridica
*/

INSERT INTO persona_juridica(id_dni,nombre_sociedad_perj)  VALUES
('78909456Q','Sociedad 1');

INSERT INTO persona_juridica(id_dni,nombre_sociedad_perj)  VALUES
('78919456Q','Sociedad 2');


/*
Insercion de establecimiento
*/
INSERT INTO establecimiento (id_est,tipo,nombre_est)  VALUES
(1,'fruteria','Fruterias Paqui 1');

INSERT INTO establecimiento (id_est,tipo,nombre_est)  VALUES
(2,'fruteria','Fruterias Paqui 2');

INSERT INTO establecimiento (id_est,tipo,nombre_est)  VALUES
(3,'fruteria','Fruterias Paqui 3');

INSERT INTO establecimiento (id_est,tipo,nombre_est)  VALUES
(4,'fruteria','Fruterias Paqui 4');

INSERT INTO establecimiento (id_est,tipo,nombre_est)  VALUES
(5,'fruteria','Fruterias Paqui 5');

INSERT INTO establecimiento (id_est,tipo,nombre_est)  VALUES
(6,'fruteria','Fruterias Paqui 6');

INSERT INTO establecimiento (id_est,tipo,nombre_est)  VALUES
(10,'pescaderia','Pescaderia Alfonsin');


/*
Insercion de mercados
*/

INSERT INTO mercado (id_dni,nombre_mer,renta_mer,cuota_mer,beneficio_mer,gastos_mer,gestion)  VALUES
('78909456P','Mercado 1',2000.045,1000.99,500,250,'directa');

INSERT INTO mercado (id_dni,nombre_mer,renta_mer,cuota_mer,beneficio_mer,gastos_mer,gestion)  VALUES
('72909456P','Mercado 2',10000,400,1000.75,2250.33,'asociacion comerciantes');

/*
Insercion de espacios
*/

INSERT INTO espacios(id_esp,id_dni,nombre_mer,id_est,espacio_esp,estado,anualidad_esp)  VALUES
(1,'78909456Q','Mercado 1',1,1,'abierto',10000);

INSERT INTO espacios(id_esp,id_dni,nombre_mer,id_est,espacio_esp,estado,anualidad_esp)  VALUES
(10,'78909456Q','Mercado 2',1,1,'cerrado',20000);

INSERT INTO espacios(id_esp,id_dni,nombre_mer,id_est,espacio_esp,estado,anualidad_esp)  VALUES
(2,'78919456Q','Mercado 1',2,2,'obra',15000);

INSERT INTO espacios(id_esp,id_dni,nombre_mer,id_est,espacio_esp,estado,anualidad_esp)  VALUES
(20,'78919456Q','Mercado 2',2,2,'abierto',2000);

/*
Insercion de zonas comerciales
*/

INSERT INTO espacios(id_esp,id_dni,nombre_mer,id_est,espacio_esp,estado,anualidad_esp)  VALUES
(3,'78909456Q','Mercado 1',3,3,'abierto',11000);
INSERT INTO zonas_comerciales(id_esp,nombre_mer,fin)  VALUES
(3,'Mercado 1','genero temporada');

INSERT INTO espacios(id_esp,id_dni,nombre_mer,id_est,espacio_esp,estado,anualidad_esp)  VALUES
(30,'78919456Q','Mercado 2',3,3,'abierto',1000);
INSERT INTO zonas_comerciales(id_esp,nombre_mer,fin)  VALUES
(30,'Mercado 2','exposicion productos');

/*
Insercion de puesto
*/

INSERT INTO espacios(id_esp,id_dni,nombre_mer,id_est,espacio_esp,estado,anualidad_esp)  VALUES
(5,'78909456Q','Mercado 1',5,5,'abierto',120);
INSERT INTO puesto(id_esp,nombre_mer,fecha_obra_pue,fin)  VALUES
(5,'Mercado 1','2007-03-05','alimentacion');


INSERT INTO espacios(id_esp,id_dni,nombre_mer,id_est,espacio_esp,estado,anualidad_esp)  VALUES
(50,'78919456Q','Mercado 2',10,5,'abierto',8000);
INSERT INTO puesto(id_esp,nombre_mer,fecha_obra_pue,fin)  VALUES
(50,'Mercado 2','2013-09-11','artesania');


/*
Insercion de instalacion auxiliar
*/

INSERT INTO espacios(id_esp,id_dni,nombre_mer,id_est,espacio_esp,estado,anualidad_esp)  VALUES
(4,'78909456Q','Mercado 1',4,4,'abierto',1200.66);
INSERT INTO instalacion_auxiliar(id_esp,nombre_mer,id_esp_puesto,id_nombre_mer_puesto,tipo,gestion)  VALUES
(4,'Mercado 1',5,'Mercado 1','almacen','directa');

INSERT INTO espacios(id_esp,id_dni,nombre_mer,id_est,espacio_esp,estado,anualidad_esp)  VALUES
(40,'78919456Q','Mercado 2',4,4,'abierto',30000);
INSERT INTO instalacion_auxiliar(id_esp,nombre_mer,id_esp_puesto,id_nombre_mer_puesto,tipo,gestion)  VALUES
(40,'Mercado 2',50,'Mercado 2','frigorifico','indirecta');



/*
Insercion de instalacion complementaria
*/

INSERT INTO espacios(id_esp,id_dni,nombre_mer,id_est,espacio_esp,estado,anualidad_esp)  VALUES
(6,'78909456Q','Mercado 1',6,6,'abierto',20);
INSERT INTO instalacion_complementaria(id_esp,nombre_mer,gestion,fin)  VALUES
(6,'Mercado 1','directa','publicidad');

INSERT INTO espacios(id_esp,id_dni,nombre_mer,id_est,espacio_esp,estado,anualidad_esp)  VALUES
(60,'78919456Q','Mercado 2',6,6,'abierto',20);
INSERT INTO instalacion_complementaria(id_esp,nombre_mer,gestion,fin)  VALUES
(60,'Mercado 2','indirecta','informacion');



/*
Insercion de faltas
*/

INSERT INTO faltas(id_falta,id_est,id_dni,tipo,motivo_falta,sancion_economica_falta,fecha_ini_falta,fecha_fin_falta)  VALUES
(1,5,'78909456Q','leve','Cambio domicilio no comunicado',200,'2021-12-04',NULL);


INSERT INTO faltas(id_falta,id_est,id_dni,tipo,motivo_falta,sancion_economica_falta,fecha_ini_falta,fecha_fin_falta)  VALUES
(2,10,'78919456Q','muy grave','Subarriendo local',2000,'2021-12-04','2023-12-04');

/*
Insercion de concesion
*/

INSERT INTO concesion(id_concesion,id_esp,nombre_mer,id_dni,causa,tipo,fianza_con,contador_prorrogas_con,fecha_ini_con,fecha_fin_con)  VALUES
(1,1,'Mercado 1','78909456Q','subasta','fija',3000,0,'2021-10-05','2023-3-05');

INSERT INTO concesion(id_concesion,id_esp,nombre_mer,id_dni,causa,tipo,fianza_con,contador_prorrogas_con,fecha_ini_con,fecha_fin_con)  VALUES
(2,2,'Mercado 1','78919456Q','concurso','especial',22000,2,'2015-10-05','2022-10-05');

/*
Insercion de transmision
*/

INSERT INTO transmision(id_concesion,motivo,fecha_trans,precio_trans)  VALUES
(1,'mortiscausa','2008-11-03',200);

INSERT INTO transmision(id_concesion,motivo,fecha_trans,precio_trans)  VALUES
(2,'intervivos','2008-11-03',2000);


/*
CONSULTAS
*/

/*
Consulta 1: Todas las concesiones en el tiempo de un determinado espacio
 */
SELECT DISTINCT E.id_esp,C.id_dni,C.fecha_ini_con,C.fecha_fin_con
FROM espacios E NATURAL JOIN concesion C
WHERE E.id_esp = 2
ORDER BY C.fecha_ini_con ASC;


/*
Consulta 2: Espacios que han cambiado de titular pero luego han tenido otra vez el mismo
 */

SELECT DISTINCT
    c1.id_dni,
    c1.id_esp,
    c1.nombre_mer
FROM
    concesion c1,
    concesion c2
WHERE
    c1.id_dni = c2.id_dni AND
    c1.fecha_ini_con <> c2.fecha_ini_con AND
    c1.id_esp = c2.id_esp AND c1.nombre_mer=c2.nombre_mer;


/*
Consulta 3: Titulares con más de cuatro concesiones vigentes
 */

SELECT 
    t.id_dni,
    t.nombre_tit,
    COUNT(*) as nconcesiones
FROM
    concesion c,
    titular t
WHERE
    c.fecha_fin_con >= CURRENT_TIMESTAMP AND
    c.id_dni = t.id_dni

GROUP BY t.id_dni
HAVING COUNT(*)>4;


/*
Consulta 4: Espacio que ha tenido mayor numero de concesiones en los ultimos 5 años
 */

WITH NConcesiones AS (SELECT c.id_esp,c.nombre_mer,COUNT(*) as nconcesiones
FROM concesion c
WHERE (extract(year from CURRENT_TIMESTAMP)-extract(year from fecha_ini_con))<= 5 
GROUP BY c.id_esp,c.nombre_mer
)
SELECT NC.id_esp,NC.nombre_mer,NC.nconcesiones
FROM NConcesiones NC
WHERE NC.nconcesiones>=ALL (SELECT NC2.nconcesiones FROM NConcesiones NC2);

/*
Consulta 5: Titulares sin ninguna falta
 */

WITH sancionesTitular AS(
    SELECT f.id_dni, COUNT(*) AS numSanciones
    FROM faltas f
    GROUP BY f.id_dni
)

SELECT T.id_dni,T.nombre_tit
FROM titular T
WHERE T.id_dni NOT IN (SELECT ST.id_dni
                       FROM sancionesTitular ST);






