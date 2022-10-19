
/*----------------------------------------------------------------
DROP DE TABLAS
*/

DROP TABLE mercado;
DROP TABLE espacios;
DROP TABLE zonas_comerciales;
DROP TABLE instalacion_auxiliar;
DROP TABLE instalacion_complementaria;
DROP TABLE puesto;
DROP TABLE establecimiento;
DROP TABLE faltas;
DROP TABLE concesion;
DROP TABLE transmision;
DROP TABLE titular;
DROP TABLE persona_juridica;
DROP DOMAIN gestion_mer;
DROP DOMAIN estado_esp;
DROP DOMAIN fin_zonacom;
DROP DOMAIN tipo_instaux;
DROP DOMAIN fin_pue;
DROP DOMAIN gestion_inscom;
DROP DOMAIN fin_inscom;
DROP DOMAIN tipo_venta_est;
DROP DOMAIN tipo_falta;
DROP DOMAIN motivo_trans;
DROP DOMAIN tipo_con;
DROP DOMAIN causa_con;

/*
Creamos los dominios
*/

CREATE DOMAIN gestion_mer AS VARCHAR(25)
CHECK (VALUE IN ('directa', 'indirecta','asociacion comerciantes'));

CREATE DOMAIN estado_esp AS VARCHAR(10)
CHECK (VALUE IN ('abierto','cerrado','obra')); 

CREATE DOMAIN fin_zonacom AS VARCHAR(20)
CHECK (VALUE IN ('genero temporada','exposicion productos','actividades'));

CREATE DOMAIN tipo_instaux AS VARCHAR(15)
CHECK (VALUE IN ('almacen','frigorifico'));

CREATE DOMAIN fin_pue AS VARCHAR(15)
CHECK (VALUE IN ('alimentacion','artesania','moda'));

CREATE DOMAIN gestion_inscom AS VARCHAR(25)
CHECK (VALUE IN ('directa','indirecta','asociacion comerciantes'));

CREATE DOMAIN fin_inscom AS VARCHAR(25)
CHECK (VALUE IN ('publicidad','informacion','servicios complementarios'));

CREATE DOMAIN tipo_venta_est AS VARCHAR(25)
CHECK (VALUE IN ('pescaderia','carniceria','fruteria','charcuteria'));

CREATE DOMAIN tipo_falta AS VARCHAR(10)
CHECK (VALUE IN ('leve','grave','muy grave'));

CREATE DOMAIN tipo_con AS VARCHAR(10)
CHECK (VALUE IN ('fija','especial','temporal'));

CREATE DOMAIN causa_con AS VARCHAR(25)
CHECK (VALUE IN ('subasta','concurso','adjudicacion directa'));

CREATE DOMAIN motivo_trans AS VARCHAR(15)
CHECK (VALUE IN ('mortiscausa','intervivos')); 


/*----------------------------------------------------------------
DEFINICIÓN DE TABLAS
*/

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

        id_esp INTEGER SERIAL ,

        espacio_esp INTEGER NOT NULL ,
        estado estado_esp NOT NULL,
        anualidad_esp DOUBLE PRECISION NOT NULL ,


        CONSTRAINT espacios__clave
        PRIMARY KEY (id_esp),

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


        /*---------------------------------------------------------------- 
        atributos propios de zonas comerciales
        */

        fin fin_zonacom NOT NULL,


        CONSTRAINT zonas_comerciales__clave
        PRIMARY KEY (id_esp),

        CONSTRAINT zonas_comerciales_extends_espacios
        FOREIGN KEY (id_esp)
        REFERENCES espacios (id_esp)

);

CREATE TABLE instalacion_auxiliar(
        
        /*
        Clave foranea hacia espacio
        */
        id_esp INTEGER ,


        /*
        Clave foranea hacia puesto
        */
        id_esp_puesto INTEGER,

        /*---------------------------------------------------------------- 
        atributos propios de instalacion auxiliar
        */

        tipo tipo_instaux NOT NULL ,
        gestion gestion_inscom NOT NULL ,

        CONSTRAINT instalacion_auxiliar__unique
        UNIQUE (id_esp,id_esp_puesto),

        CONSTRAINT instalacion_auxiliar__clave
        PRIMARY KEY (id_esp),

        CONSTRAINT instalacion_auxiliar_extends_espacios
        FOREIGN KEY (id_esp)
        REFERENCES espacios (id_esp),


        CONSTRAINT instalacion_auxiliar__puesto
        FOREIGN KEY (id_esp_puesto)
        REFERENCES puesto(id_esp)

);

CREATE TABLE puesto(
        
        /*
        Clave foranea hacia espacio
        */
        id_esp INTEGER ,



        /*---------------------------------------------------------------- 
        atributos propios de puesto
        */

        fecha_obra_pue DATE  ,
        fin fin_pue NOT NULL ,


        CONSTRAINT puesto__clave
        PRIMARY KEY (id_esp),

        CONSTRAINT puesto_extends_espacios
        FOREIGN KEY (id_esp)
        REFERENCES espacios (id_esp) ,

        CONSTRAINT fecha_obra_pue__correcta
        CHECK ( 
                CASE WHEN fecha_obra_pue IS NOT NULL
                    THEN
                        fecha_obra_pue <= CURRENT_TIMESTAMP
                END
        )
    
);

CREATE TABLE instalacion_complementaria(
        
        /*
        Clave foranea hacia espacio
        */
        id_esp INTEGER ,


        /*---------------------------------------------------------------- 
        atributos propios de instalacion complementaria
        */

        gestion gestion_inscom NOT NULL,
        fin fin_inscom NOT NULL ,


        CONSTRAINT instalacion_complementaria__clave
        PRIMARY KEY (id_esp),

        CONSTRAINT instalacion_complementaria_extends_espacios
        FOREIGN KEY (id_esp)
        REFERENCES espacios (id_esp)


);

CREATE TABLE establecimiento(

        /*---------------------------------------------------------------- 
        atributos propios de establecimiento
        */

        id_est INTEGER SERIAL ,

        nombre_est VARCHAR(255) NOT NULL,
        tipo tipo_venta_est NOT NULL ,

        CONSTRAINT establecimiento__clave
        PRIMARY KEY (id_est)

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

        id_falta INTEGER SERIAL ,

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
        
        CONSTRAINT faltas__establecimiento
        FOREIGN KEY (id_est)
        REFERENCES establecimiento (id_est),

        CONSTRAINT falta_tipo_leve
        CHECK ( 
                CASE WHEN tipo IS 'leve' 
                    THEN  sancion_economica_falta <= 50000
                END
        ),

         CONSTRAINT falta_tipo_grave
        CHECK ( 
                CASE WHEN tipo IS 'grave' 
                    THEN  sancion_economica_falta <= 150000 AND DATEDIFF(day,fecha_fin_falta,fecha_ini_falta) <= 60
                END
        ),

        CONSTRAINT falta_tipo_muy_grave
        CHECK ( 
                CASE WHEN tipo IS 'muy grave' 
                    THEN  sancion_economica_falta <= 300000 AND DATEDIFF(day,fecha_fin_falta,fecha_ini_falta) <= 90 
                END
        )

);

CREATE TABLE concesion(

        /*
        Clave foranea hacia espacios
        */
        id_esp INTEGER ,

        /*
        Clave foranea hacia titular
        */
        id_dni VARCHAR(10) ,

        /*---------------------------------------------------------------- 
        atributos propios de concesion
        */

        id_concesion INTEGER SERIAL ,

        fianza_con DOUBLE PRECISION NOT NULL ,
        fecha_ini_con DATE NOT NULL
        fecha_fin_con DATE NOT NULL
        tipo tipo_con NOT NULL , 
        contador_prorrogas_con INTEGER NOT NULL ,
        causa causa_con NOT NULL,

        CONSTRAINT concesion__unique
        UNIQUE (id_esp,id_concesion,id_dni),

        CONSTRAINT concesion__clave
        PRIMARY KEY (id_concesion),

        CONSTRAINT concesion__espacios
        FOREIGN KEY (id_esp)
        REFERENCES espacios (id_esp) ,

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
                CASE WHEN tipo IS 'temporal' AND contador_prorrogas_con IS 0
                    THEN DATEDIFF(month,fecha_fin_con,fecha_ini_con) <= 1
                        
                END
        ),

        CONSTRAINT concesion_tipo_temporal_con_prorrogas
        CHECK ( 
                CASE WHEN tipo IS 'temporal' AND contador_prorrogas_con IS > 0
                    THEN DATEDIFF(month,fecha_fin_con,fecha_ini_con) <= 12
                        
                END
        ),

        CONSTRAINT concesion_tipo_fija
        CHECK ( 
                CASE WHEN tipo IS 'fija'
                    THEN DATEDIFF(day,fecha_fin_con,fecha_ini_con) > 365
                    AND 
                        
                END
        ),

        CONSTRAINT concesion_tipo_especial_sin_prorrogas
        CHECK ( 
                CASE WHEN tipo IS 'especial' AND contador_prorrogas_con IS 0
                    THEN  DATEDIFF(year,fecha_fin_con,fecha_ini_con) <= 5
                END
        ),

        CONSTRAINT concesion_tipo_especial_con_prorrogas
        CHECK ( 
                CASE WHEN tipo IS 'especial' AND contador_prorrogas_con IS > 0
                    THEN  DATEDIFF(year,fecha_fin_con,fecha_ini_con) <= 10
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

CREATE TABLE titular(

         /*---------------------------------------------------------------- 
        atributos propios de titular
        */

        id_dni VARCHAR(10) ,

        nombre_tit VARCHAR(255) NOT NULL ,
        telefono_tit INTEGER NOT NULL ,
        domicilio_tit VARCHAR(255) NOT NULL ,
        sancionado_tit BIT NOT NULL

        CONSTRAINT titular__clave
        PRIMARY KEY (id_dni),

        CONSTRAINT telefono_tit__correcto
        CHECK (telefono_tit >= 0 AND LEN(telefono_tit) == 9)

        CONSTRAINT id_dni__bien
        CHECK (id_dni LIKE '[0-9](8)%(1)' OR '%(1)[0-9](7)%(1)')

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

/* Poblacion de las tablas */

/*
Insercion de mercados
*/

INSERT INTO mercado (id_dni,nombre_mer,renta_mer,cuota_mer,beneficio_mer,gastos_mer,gestion)VALUE
('78909456P','Mercado 1',2000.045,1000.99,500,250,'directa')

INSERT INTO mercado (id_dni,nombre_mer,renta_mer,cuota_mer,beneficio_mer,gastos_mer,gestion)VALUE
('72909456P','Mercado 2',10000,400,1000.75,2250.33,'asociacion comerciantes')

/*
Insercion de espacios
*/

INSERT INTO espacios(id_esp,id_dni,nombre_mer,id_est,espacio_esp,estado,anualidad_esp)VALUE
(1,'78909456Q','Mercado 1',1,1,'abierto',10000)

INSERT INTO espacios(id_esp,id_dni,nombre_mer,id_est,espacio_esp,estado,anualidad_esp)VALUE
(1,'78909456Q','Mercado 2',1,1,'cerrado',20000)

INSERT INTO espacios(id_esp,id_dni,nombre_mer,id_est,espacio_esp,estado,anualidad_esp)VALUE
(2,'78919456Q','Mercado 1',2,2,'obra',15000)

INSERT INTO espacios(id_esp,id_dni,nombre_mer,id_est,espacio_esp,estado,anualidad_esp)VALUE
(2,'78919456Q','Mercado 2',2,2,'abierto',2000)

/*
Insercion de zonas comerciales
*/

INSERT INTO espacios(id_esp,id_dni,nombre_mer,id_est,espacio_esp,estado,anualidad_esp)VALUE
(3,'78909456Q','Mercado 1',3,3,'abierto',11000)
INSERT INTO zonas_comerciales(id_esp,fin)VALUE
(3,'genero temporada')

INSERT INTO espacios(id_esp,id_dni,nombre_mer,id_est,espacio_esp,estado,anualidad_esp)VALUE
(3,'78919456Q','Mercado 2',3,3,'abierto',1000)
INSERT INTO zonas_comerciales(id_esp,fin)VALUE
(3,'exposicion productos')

/*
Insercion de instalacion auxiliar
*/

INSERT INTO espacios(id_esp,id_dni,nombre_mer,id_est,espacio_esp,estado,anualidad_esp)VALUE
(4,'78909456Q','Mercado 1',4,4,'abierto',1200.66)
INSERT INTO instalacion_auxiliar(id_esp,id_esp_puesto,tipo,gestion)VALUE
(4,5,'almacen','directa')

INSERT INTO espacios(id_esp,id_dni,nombre_mer,id_est,espacio_esp,estado,anualidad_esp)VALUE
(4,'78919456Q','Mercado 2',4,4,'abierto',30000)
INSERT INTO instalacion_auxiliar(id_esp,id_esp_puesto,tipo,gestion)VALUE
(4,5,'frigorifico','indirecta')

/*
Insercion de puesto
*/

INSERT INTO espacios(id_esp,id_dni,nombre_mer,id_est,espacio_esp,estado,anualidad_esp)VALUE
(5,'78909456Q','Mercado 1',5,5,'abierto',120)
INSERT INTO puesto(id_esp,fecha_obra_pue,fin)VALUE
(5,'2007-03-05','alimentacion')


INSERT INTO espacios(id_esp,id_dni,nombre_mer,id_est,espacio_esp,estado,anualidad_esp)VALUE
(5,'78919456Q','Mercado 2',10,5,'abierto',8000)
INSERT INTO puesto(id_esp,fecha_obra_pue)VALUE
(5,'2013-09-11','artesania')

/*
Insercion de instalacion complementaria
*/

INSERT INTO espacios(id_esp,id_dni,nombre_mer,id_est,espacio_esp,estado,anualidad_esp)VALUE
(6,'78909456Q','Mercado 1',6,6,'abierto',20)
INSERT INTO instalacion_complementaria(id_esp,gestion,fin)VALUE
(6,'directa','publicidad')

INSERT INTO espacios(id_esp,id_dni,nombre_mer,id_est,espacio_esp,estado,anualidad_esp)VALUE
(6,'78919456Q','Mercado 2',6,6,'abierto',20)
INSERT INTO instalacion_complementaria(id_esp,gestion,fin)VALUE
(6,'indirecta','informacion')

/*
Insercion de establecimiento
*/

INSERT INTO establecimiento (id_est,tipo,nombre_est)VALUE
(5,'fruteria','Fruterias Paqui')

INSERT INTO establecimiento (id_est,tipo,nombre_est)VALUE
(10,'pescaderia','Pescaderia Alfonsin')

/*
Insercion de faltas
*/

INSERT INTO faltas(id_falta,id_est,id_dni,tipo,motivo_falta,sancion_economica_falta,fecha_ini_falta,fecha_fin_falta)VALUE
(1,5,'78909456Q','leve','Cambio domicilio no comunicado',200,'2021-12-04',NULL)


INSERT INTO faltas(id_falta,id_est,id_dni,tipo,motivo_falta,sancion_economica_falta,fecha_ini_falta,fecha_fin_falta)VALUE
(2,10,'78919456Q','muy grave','Subarriendo local',2000,'2021-12-04','2023-12-04')

/*
Insercion de concesion
*/

INSERT INTO concesion(id_concesion,id_esp,id_dni,causa,tipo,fianza_con,contador_prorrogas_con,fecha_ini_con,fecha_fin_con)VALUE
(1,1,1,'subasta','fija',3000,0,'2007-10-05','2009-10-05')

INSERT INTO concesion(id_concesion,id_esp,id_dni,causa,tipo,fianza_con,contador_prorrogas_con,fecha_ini_con,fecha_fin_con)VALUE
(2,2,2,'concurso','especial',22000,2,'2005-10-05','2012-10-05')

/*
Insercion de transmision
*/

INSERT INTO transmision(id_concesion,motivo,fecha_trans,precio_trans)VALUE
(1,'mortiscausa','2008-11-03',200)

INSERT INTO transmision(id_concesion,motivo,fecha_trans,precio_trans)VALUE
(2,'intervivos','2008-11-03',2000)

/*
Insercion de titular
*/
INSERT INTO titular(id_dni,nombre_tit,telefono_tit,domicilio_tit,sancionado_tit)VALUE
('78909456P','David',634765898,'Calle Uno /nº 1',FALSE)

INSERT INTO titular(id_dni,nombre_tit,telefono_tit,domicilio_tit,sancionado_tit)VALUE
('72909456P','Adolfo',624765898,'Calle Dos /nº 2',FALSE)

INSERT INTO titular(id_dni,nombre_tit,telefono_tit,domicilio_tit,sancionado_tit)VALUE
('78909456Q','Daniel',634769898,'Calle Tres /nº 3',FALSE)

INSERT INTO titular(id_dni,nombre_tit,telefono_tit,domicilio_tit,sancionado_tit)VALUE
('78919456Q','Julian',634165898,'Calle Cuatro /nº 4',TRUE)


/*
Insercion de persona juridica
*/

INSERT INTO persona_juridica(id_dni,nombre_sociedad_perj)VALUE
(3,'Sociedad 1')

INSERT INTO persona_juridica(id_dni,nombre_sociedad_perj)VALUE
(4,'Sociedad 2')





