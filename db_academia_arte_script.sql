----------------------------------
-- INTEGRANTES:
-- CRISTIAN CAMILO SANTIAGO SANCHEZ
-- JUAN FERNANDO ORDOÑEZ MARTINEZ
-- LUIS EDUARDO TORRES
----------------------------------

-- -- Script completo para la configuración y carga de la base de datos de la escuela de arte
-- Propósito: Crear la base de datos completa desde cero. -- Las sentencias DROP permiten ejecutar este script varias veces sin errores.
-- Borrar triggers, funciones y procedimientos
DROP TRIGGER IF EXISTS trg_activar_estudiante_por_inscripcion ON pago;
DROP TRIGGER IF EXISTS trg_control_clases_por_plan ON clase;
DROP TRIGGER IF EXISTS trg_no_duplicar_mensualidad ON pago;
DROP FUNCTION IF EXISTS trg_activar_estudiante_por_inscripcion_fn();
DROP FUNCTION IF EXISTS trg_control_clases_por_plan_fn();
DROP FUNCTION IF EXISTS trg_no_duplicar_mensualidad_fn();
DROP PROCEDURE IF EXISTS sp_reactivar_estudiante(INT, INT, DECIMAL, DATE);
DROP FUNCTION IF EXISTS sp_resumen_pagos_mensuales(INT, INT, INT);

-- Borrar tablas
-- El orden es importante para evitar errores de dependencia.
DROP TABLE IF EXISTS redencion_de_clase_no_asistida;
DROP TABLE IF EXISTS asistencia;
DROP TABLE IF EXISTS estudiante_bastidor;
DROP TABLE IF EXISTS clase;
DROP TABLE IF EXISTS pago;
DROP TABLE IF EXISTS estudiante;
DROP TABLE IF EXISTS bastidor;
DROP TABLE IF EXISTS plan_de_clases;
DROP TABLE IF EXISTS usuario;
DROP TABLE IF EXISTS rol_implementacion;

-- CREACIÓN DE TABLAS
CREATE TABLE rol_implementacion (
rol_id SERIAL PRIMARY KEY,
nombre_rol VARCHAR(100) NOT NULL
);

CREATE TABLE usuario (
id_usuario SERIAL PRIMARY KEY,
nombre VARCHAR(50) NOT NULL,
apellido VARCHAR(50) NOT NULL,
correo_electronico VARCHAR(100) NOT NULL UNIQUE,
contrasena VARCHAR(255) NOT NULL,
rol_id INT REFERENCES rol_implementacion(rol_id)
);

CREATE TABLE plan_de_clases (
id_plan SERIAL PRIMARY KEY,
nombre VARCHAR(100) NOT NULL,
descripcion TEXT,
numero_de_clases_mes INT NOT NULL,
precio_mensualidad DECIMAL(10,2) NOT NULL
);

CREATE TABLE estudiante (
id_estudiante SERIAL PRIMARY KEY,
nombre VARCHAR(50) NOT NULL,
apellido VARCHAR(50) NOT NULL,
fecha_nacimiento DATE,
telefono VARCHAR(20) NOT NULL,
correo_electronico VARCHAR(100) NOT NULL,
estado VARCHAR(10) CHECK (estado IN ('Activo', 'Inactivo')) DEFAULT 'Inactivo',
fecha_inscripcion DATE NOT NULL,
id_plan INT REFERENCES plan_de_clases(id_plan)
);

CREATE TABLE clase (
id_clase SERIAL PRIMARY KEY,
nombre VARCHAR(100) NOT NULL,
fecha_hora TIMESTAMP NOT NULL,
contador_clase INT NOT NULL,
id_plan INT REFERENCES plan_de_clases(id_plan),
id_estudiante INT REFERENCES estudiante(id_estudiante)
);

CREATE TABLE bastidor (
id_bastidor SERIAL PRIMARY KEY,
medidas VARCHAR(50) NOT NULL,
precio DECIMAL(10,2) NOT NULL
);

CREATE TABLE estudiante_bastidor (
id_registro_eb SERIAL PRIMARY KEY,
id_estudiante INT NOT NULL REFERENCES estudiante(id_estudiante),
id_bastidor INT NOT NULL REFERENCES bastidor(id_bastidor),
UNIQUE (id_estudiante, id_bastidor)
);

CREATE TABLE pago (
id_pago SERIAL PRIMARY KEY,
id_estudiante INT REFERENCES estudiante(id_estudiante),
tipo VARCHAR(20) CHECK (tipo IN ('inscripcion', 'mensualidad', 'bastidor')) NOT NULL,
monto DECIMAL(10,2) NOT NULL,
fecha DATE NOT NULL,
metodo_pago VARCHAR(50),
estado VARCHAR(20) CHECK (estado IN ('pendiente', 'completado', 'fallido')) DEFAULT 'pendiente',
id_bastidor INT REFERENCES bastidor(id_bastidor),
id_plan INT REFERENCES plan_de_clases(id_plan)
);

CREATE TABLE asistencia (
id_asistencia SERIAL PRIMARY KEY,
id_estudiante INT REFERENCES estudiante(id_estudiante),
id_clase INT REFERENCES clase(id_clase),
asistio BOOLEAN NOT NULL DEFAULT FALSE,
jornada VARCHAR(10) CHECK (jornada IN ('mañana', 'tarde', 'noche')) NOT NULL,
fecha DATE NOT NULL
);

CREATE TABLE redencion_de_clase_no_asistida (
id_redencion SERIAL PRIMARY KEY,
id_estudiante INT REFERENCES estudiante(id_estudiante),
id_clase_original INT REFERENCES clase(id_clase),
fecha DATE NOT NULL,
estado_redencion VARCHAR(20) CHECK (estado_redencion IN ('pendiente', 'aprobada', 'rechazada')) DEFAULT 'pendiente',
motivo TEXT
);

-- INSERCIONES DE DATOS
INSERT INTO rol_implementacion (nombre_rol) VALUES
('Administrador'),
('Docente');

INSERT INTO plan_de_clases (nombre, descripcion, numero_de_clases_mes, precio_mensualidad) VALUES
('Plan Básico', '4 clases al mes.', 4, 110000.00),
('Plan Intermedio', '8 clases al mes.', 8, 200000.00),
('Plan Avanzado', '16 clases al mes.', 16, 300000.00);

INSERT INTO bastidor (medidas, precio) VALUES
('20x30 cm', 15000.00),
('30x40 cm', 25000.00),
('40x50 cm', 35000.00),
('50x60 cm', 45000.00),
('60x80 cm', 60000.00),
('70x90 cm', 75000.00),
('80x100 cm', 90000.00),
('100x120 cm', 120000.00),
('120x150 cm', 150000.00),
('15x15 cm (mini)', 10000.00),
('25x35 cm', 20000.00),
('45x55 cm', 40000.00),
('55x75 cm', 55000.00),
('90x110 cm', 105000.00),
('110x130 cm', 135000.00);

INSERT INTO usuario (nombre, apellido, correo_electronico, contrasena, rol_id) VALUES
('Juan', 'Pérez', 'juan.perez@email.com', 'pass123', 1),
('Ana', 'Gómez', 'ana.gomez@email.com', 'pass123', 2);

INSERT INTO estudiante (nombre, apellido, fecha_nacimiento, telefono, correo_electronico, estado, fecha_inscripcion, id_plan) VALUES
('Alejandro', 'Castro', '1995-05-10', '1234567890', 'alejo.c@email.com', 'Activo', '2023-01-15', 1),
('Daniela', 'García', '2000-08-22', '0987654321', 'dani.g@email.com', 'Inactivo', '2023-02-20', 2),
('Javier', 'Hernández', '1998-11-03', '5551234567', 'javi.h@email.com', 'Activo', '2023-03-01', 3),
('Carolina', 'Mora', '1997-04-18', '6662345678', 'caro.m@email.com', 'Activo', '2023-03-10', 1),
('Ricardo', 'Pérez', '1996-09-25', '7773456789', 'ricardo.p@email.com', 'Inactivo', '2023-04-05', 1),
('Valeria', 'Rojas', '2001-02-12', '8884567890', 'vale.r@email.com', 'Activo', '2023-05-11', 1),
('Gustavo', 'López', '1994-07-07', '9995678901', 'gustavo.l@email.com', 'Activo', '2023-06-01', 2),
('Isabel', 'Ramírez', '1999-10-30', '1116789012', 'isa.r@email.com', 'Inactivo', '2023-06-18', 3),
('Sebastián', 'Vargas', '2002-01-20', '2227890123', 'sebas.v@email.com', 'Activo', '2023-07-09', 1),
('Fernanda', 'Díaz', '1993-06-15', '3338901234', 'fer.d@email.com', 'Activo', '2023-08-05', 1),
('Jorge', 'Gómez', '1990-12-01', '4449012345', 'jorge.g@email.com', 'Activo', '2023-08-22', 2),
('Lucía', 'Paz', '1998-03-28', '5550123456', 'lucia.p@email.com', 'Inactivo', '2023-09-01', 3),
('Martín', 'Soto', '1997-09-09', '6661234567', 'martin.s@email.com', 'Activo', '2023-09-15', 1),
('Natalia', 'Ortega', '2003-04-04', '7772345678', 'nat.o@email.com', 'Activo', '2023-10-10', 1),
('Óscar', 'Reyes', '1992-07-17', '8883456789', 'oscar.r@email.com', 'Activo', '2023-11-03', 2),
('Paula', 'Zambrano', '1996-02-28', '9994567890', 'paula.z@email.com', 'Activo', '2023-11-20', 1);

INSERT INTO clase (nombre, fecha_hora, contador_clase, id_plan, id_estudiante) VALUES
('Pintura al Óleo - Clase 1', '2023-11-01 10:00:00', 1, 1, 1),
('Dibujo Básico - Clase 1', '2023-11-02 15:00:00', 1, 2, 3),
('Acrílicos - Clase 1', '2023-11-03 18:00:00', 1, 3, 4),
('Escultura en Arcilla - Clase 1', '2023-11-04 10:00:00', 1, 1, 6),
('Pintura al Óleo - Clase 2', '2023-11-08 10:00:00', 2, 1, 1),
('Dibujo Básico - Clase 2', '2023-11-09 15:00:00', 2, 2, 3),
('Acrílicos - Clase 2', '2023-11-10 18:00:00', 2, 3, 4),
('Escultura en Arcilla - Clase 2', '2023-11-11 10:00:00', 2, 1, 6),
('Pintura al Óleo - Clase 3', '2023-11-15 10:00:00', 3, 1, 1),
('Dibujo Básico - Clase 3', '2023-11-16 15:00:00', 3, 2, 3),
('Acrílicos - Clase 3', '2023-11-17 18:00:00', 3, 3, 4),
('Escultura en Arcilla - Clase 3', '2023-11-18 10:00:00', 3, 1, 6),
('Pintura al Óleo - Clase 4', '2023-11-22 10:00:00', 4, 1, 1),
('Dibujo Básico - Clase 4', '2023-11-23 15:00:00', 4, 2, 3),
('Acrílicos - Clase 4', '2023-11-24 18:00:00', 4, 3, 4),
('Pintura al Óleo - Clase 1', '2023-11-05 10:00:00', 1, 1, 10),
('Dibujo Básico - Clase 1', '2023-11-06 15:00:00', 1, 2, 11),
('Acrílicos - Clase 1', '2023-11-07 18:00:00', 1, 3, 12),
('Dibujo Avanzado - Clase 1', '2023-11-20 17:00:00', 1, 1, 16);

INSERT INTO estudiante_bastidor (id_estudiante, id_bastidor) VALUES
(1, 2), (3, 4), (4, 1), (6, 3), (7, 5), (9, 6), (10, 7), (11, 8), (12, 9), (13, 10),
(14, 11), (15, 12), (16, 13), (1, 14), (3, 15), (4, 5);

DELETE FROM pago;
INSERT INTO pago (id_estudiante, tipo, monto, fecha, metodo_pago, estado, id_bastidor, id_plan) VALUES
(1, 'mensualidad', 110000.00, '2023-11-01', 'Nequi', 'completado', NULL, 1),
(3, 'mensualidad', 300000.00, '2023-11-02', 'Nequi', 'completado', NULL, 3),
(4, 'inscripcion', 10000.00, '2023-11-03', 'Efectivo', 'completado', NULL, 1),
(6, 'mensualidad', 110000.00, '2023-11-04', 'Efectivo', 'completado', NULL, 1),
(1, 'bastidor', 25000.00, '2023-11-05', 'Efectivo', 'completado', 2, NULL),
(7, 'mensualidad', 200000.00, '2023-11-06', 'Nequi', 'completado', NULL, 2),
(9, 'mensualidad', 110000.00, '2023-11-07', 'Nequi', 'pendiente', NULL, 1),
(10, 'mensualidad', 25000.00, '2023-11-08', 'Efectivo', 'completado', NULL, 1),
(11, 'mensualidad', 200000.00, '2023-11-09', 'Efectivo', 'completado', NULL, 2),
(12, 'mensualidad', 300000.00, '2023-11-10', 'Nequi', 'completado', NULL, 3),
(13, 'mensualidad', 110000.00, '2023-11-11', 'Efectivo', 'completado', NULL, 1),
(14, 'mensualidad', 25000.00, '2023-11-12', 'Nequi', 'completado', NULL, 1),
(15, 'mensualidad', 200000.00, '2023-11-13', 'Efectivo', 'completado', NULL, 2),
(16, 'mensualidad', 110000.00, '2023-11-14', 'Nequi', 'completado', NULL, 1),
(1, 'bastidor', 35000.00, '2023-11-15', 'Nequi', 'completado', 4, NULL),
(3, 'bastidor', 15000.00, '2023-11-16', 'Efectivo', 'completado', 1, NULL);

INSERT INTO asistencia (id_estudiante, id_clase, asistio, jornada, fecha) VALUES
(1, 1, TRUE, 'mañana', '2023-11-01'), (3, 2, TRUE, 'tarde', '2023-11-02'), (4, 3, TRUE, 'noche', '2023-11-03'),
(6, 4, TRUE, 'mañana', '2023-11-04'), (1, 5, TRUE, 'mañana', '2023-11-08'), (3, 6, FALSE, 'tarde', '2023-11-09'),
(4, 7, TRUE, 'noche', '2023-11-10'), (6, 8, TRUE, 'mañana', '2023-11-11'), (1, 9, FALSE, 'mañana', '2023-11-15'),
(3, 10, TRUE, 'tarde', '2023-11-16'), (4, 11, TRUE, 'noche', '2023-11-17'), (6, 12, TRUE, 'mañana', '2023-11-18'),
(1, 13, TRUE, 'mañana', '2023-11-22'), (3, 14, TRUE, 'tarde', '2023-11-23'), (4, 15, FALSE, 'noche', '2023-11-24'),
(10, 16, TRUE, 'mañana', '2023-11-05'), (16, 17, FALSE, 'tarde', '2023-11-20');

INSERT INTO redencion_de_clase_no_asistida (id_estudiante, id_clase_original, fecha, estado_redencion, motivo) VALUES
(3, 6, '2023-11-15', 'aprobada', 'Viaje de negocios'), (1, 9, '2023-11-18', 'pendiente', 'Problema médico'),
(4, 15, '2023-11-28', 'rechazada', 'Falta de notificación previa'), (2, 6, '2023-12-01', 'aprobada', 'Examen universitario'),
(5, 7, '2023-12-05', 'pendiente', 'Motivos personales'), (8, 8, '2023-12-10', 'aprobada', 'Clima'),
(12, 11, '2023-12-15', 'pendiente', 'Compromiso laboral'), (15, 12, '2023-12-20', 'aprobada', 'Fuerza mayor'),
(1, 1, '2023-11-02', 'aprobada', 'Clase no usada'), (3, 2, '2023-11-05', 'pendiente', 'Clase no usada'),
(4, 3, '2023-11-08', 'rechazada', 'Clase no usada'), (6, 4, '2023-11-10', 'aprobada', 'Clase no usada'),
(1, 5, '2023-11-12', 'aprobada', 'Clase no usada'), (3, 6, '2023-11-15', 'pendiente', 'Clase no usada'),
(4, 7, '2023-11-19', 'rechazada', 'Clase no usada'), (6, 8, '2023-11-22', 'aprobada', 'Clase no usada'),
(1, 9, '2023-11-25', 'aprobada', 'Clase no usada'), (16, 17, '2023-12-06', 'rechazada', 'Vencido el plazo de 15 días para redimir');

-- TRIGGERS Y PROCEDIMIENTOS
-- INTEGRANTES:
-- CRISTIAN CAMILO SANTIAGO SANCHEZ
-- JUAN FERNANDO ORDOÑEZ MARTINEZ
-- LUIS EDUARDO TORRES

-- TRIGGER 1: Activa a un estudiante al registrar su pago de inscripción.
CREATE OR REPLACE FUNCTION trg_activar_estudiante_por_inscripcion_fn()
RETURNS TRIGGER AS $$
BEGIN
IF NEW.tipo = 'inscripcion' THEN
UPDATE estudiante
SET estado = 'Activo'
WHERE id_estudiante = NEW.id_estudiante
AND estado = 'Inactivo';
END IF;
RETURN NEW;
END;
$$ LANGUAGE plpgsql;
CREATE TRIGGER trg_activar_estudiante_por_inscripcion
AFTER INSERT ON pago
FOR EACH ROW
EXECUTE FUNCTION trg_activar_estudiante_por_inscripcion_fn();

-- TRIGGER 2: No permite insertar más clases de las permitidas por el plan.
CREATE OR REPLACE FUNCTION trg_control_clases_por_plan_fn()
RETURNS TRIGGER AS $$
DECLARE
total_clases_mes INT;
limite_clases INT;
BEGIN
SELECT p.numero_de_clases_mes INTO limite_clases
FROM plan_de_clases p
JOIN estudiante e ON p.id_plan = e.id_plan
WHERE e.id_estudiante = NEW.id_estudiante;
SELECT COUNT(*) INTO total_clases_mes
FROM clase
WHERE id_estudiante = NEW.id_estudiante
AND EXTRACT(YEAR FROM fecha_hora) = EXTRACT(YEAR FROM NEW.fecha_hora)
AND EXTRACT(MONTH FROM fecha_hora) = EXTRACT(MONTH FROM NEW.fecha_hora);
IF total_clases_mes >= limite_clases THEN
RAISE EXCEPTION 'El estudiante con ID % ya ha alcanzado el límite de % clases este mes.', NEW.id_estudiante, limite_clases;
END IF;
RETURN NEW;
END;
$$ LANGUAGE plpgsql;
CREATE TRIGGER trg_control_clases_por_plan
BEFORE INSERT ON clase
FOR EACH ROW
EXECUTE FUNCTION trg_control_clases_por_plan_fn();

-- TRIGGER 3: No permite pagos duplicados de mensualidad en el mismo mes.
CREATE OR REPLACE FUNCTION trg_no_duplicar_mensualidad_fn()
RETURNS TRIGGER AS $$
DECLARE
total_mensualidades INT;
BEGIN
IF NEW.tipo = 'mensualidad' THEN
SELECT COUNT(*) INTO total_mensualidades
FROM pago
WHERE id_estudiante = NEW.id_estudiante
AND tipo = 'mensualidad'
AND EXTRACT(YEAR FROM fecha) = EXTRACT(YEAR FROM NEW.fecha)
AND EXTRACT(MONTH FROM fecha) = EXTRACT(MONTH FROM NEW.fecha);
IF total_mensualidades > 0 THEN
RAISE EXCEPTION 'El estudiante con ID % ya tiene un pago de mensualidad registrado para %-%.',
NEW.id_estudiante, EXTRACT(YEAR FROM NEW.fecha), EXTRACT(MONTH FROM NEW.fecha);
END IF;
END IF;
RETURN NEW;
END;
$$ LANGUAGE plpgsql;
CREATE TRIGGER trg_no_duplicar_mensualidad
BEFORE INSERT ON pago
FOR EACH ROW
EXECUTE FUNCTION trg_no_duplicar_mensualidad_fn();

-- PROCEDIMIENTO 1: Reactiva un estudiante inactivo.
CREATE OR REPLACE PROCEDURE sp_reactivar_estudiante(
p_id_estudiante INT,
p_id_plan INT,
p_monto_inscripcion DECIMAL,
p_fecha_pago DATE
)
AS $$
BEGIN
IF NOT EXISTS (
SELECT 1 FROM estudiante
WHERE id_estudiante = p_id_estudiante AND estado = 'Inactivo'
) THEN
RAISE EXCEPTION 'El estudiante con ID % no existe o ya está activo.', p_id_estudiante;
END IF;
IF NOT EXISTS (
SELECT 1 FROM plan_de_clases WHERE id_plan = p_id_plan
) THEN
RAISE EXCEPTION 'El plan con ID % no existe.', p_id_plan;
END IF;
UPDATE estudiante
SET id_plan = p_id_plan,
estado = 'Activo'
WHERE id_estudiante = p_id_estudiante;
INSERT INTO pago (id_estudiante, tipo, monto, fecha, estado, id_plan)
VALUES (p_id_estudiante, 'inscripcion', p_monto_inscripcion, p_fecha_pago, 'completado', p_id_plan);
END;
$$ LANGUAGE plpgsql;

-- PROCEDIMIENTO 2: Muestra un resumen de los pagos mensuales de un estudiante.
CREATE OR REPLACE FUNCTION sp_resumen_pagos_mensuales(
p_id_estudiante INT,
p_mes INT,
p_anio INT
)
RETURNS TABLE (
id_pago INT,
tipo VARCHAR,
monto DECIMAL,
fecha DATE,
estado VARCHAR,
metodo_pago VARCHAR
) AS $$
BEGIN
RETURN QUERY
SELECT
p.id_pago, p.tipo, p.monto, p.fecha, p.estado, p.metodo_pago
FROM pago p
WHERE p.id_estudiante = p_id_estudiante
AND EXTRACT(MONTH FROM p.fecha) = p_mes
AND EXTRACT(YEAR FROM p.fecha) = p_anio
ORDER BY p.fecha;
END;
$$ LANGUAGE plpgsql;