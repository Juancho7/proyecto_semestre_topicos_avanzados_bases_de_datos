----------------------------------
-- INTEGRANTES:
-- CRISTIAN CAMILO SANTIAGO SANCHEZ
-- JUAN FERNANDO ORDOÑEZ MARTINEZ
-- LUIS EDUARDO TORRES
----------------------------------

------------------------------
-- TRIGGERS
------------------------------

------------------------------
-- TRIGGER 1
------------------------------
-- Función del trigger
-- Cuando se inserta un pago de tipo 'inscripcion', si el estudiante está en estado 'Inactivo',
-- automáticamente se cambia a 'Activo'.
CREATE OR REPLACE FUNCTION trg_activar_estudiante_por_inscripcion_fn()
RETURNS TRIGGER AS $$
BEGIN
    -- Solo si el pago es de tipo 'inscripcion'
    IF NEW.tipo = 'inscripcion' THEN
        -- Actualizamos el estado del estudiante a 'Activo' si estaba inactivo
        UPDATE estudiante
        SET estado = 'Activo'
        WHERE id_estudiante = NEW.id_estudiante
          AND estado = 'Inactivo';
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Trigger asociado
CREATE TRIGGER trg_activar_estudiante_por_inscripcion
    AFTER INSERT ON pago
    FOR EACH ROW
    EXECUTE FUNCTION trg_activar_estudiante_por_inscripcion_fn();

-- INSERTAR PARA VERIFICAR QUE EL TRIGGER FUNCIONA
INSERT INTO pago (id_estudiante, tipo, monto, fecha, metodo_pago, estado, id_plan)
VALUES (2, 'inscripcion', 50000.00, '2024-02-05', 'Efectivo', 'completado', 1);

-- OBTENER DATOS PARA VERIFICAR QUE EL TRIGGER FUNCIONÓ CORRECTAMENTE
SELECT id_estudiante, estado FROM estudiante WHERE id_estudiante = 2;

------------------------------
-- TRIGGER 2
------------------------------
-- Función del trigger
-- Antes de insertar una nueva clase, verificar que el estudiante no haya superado el
-- límite mensual de clases permitidas por su plan de clases.
CREATE OR REPLACE FUNCTION trg_control_clases_por_plan_fn()
RETURNS TRIGGER AS $$
DECLARE
    total_clases_mes INT;
    limite_clases INT;
BEGIN
    -- Obtener el límite de clases del plan del estudiante
    SELECT p.numero_de_clases_mes INTO limite_clases
    FROM plan_de_clases p
    JOIN estudiante e ON p.id_plan = e.id_plan
    WHERE e.id_estudiante = NEW.id_estudiante;

    -- Contar cuántas clases ya ha tenido este estudiante en el mes actual
    SELECT COUNT(*) INTO total_clases_mes
    FROM clase
    WHERE id_estudiante = NEW.id_estudiante
      AND EXTRACT(YEAR FROM fecha_hora) = EXTRACT(YEAR FROM NEW.fecha_hora)
      AND EXTRACT(MONTH FROM fecha_hora) = EXTRACT(MONTH FROM NEW.fecha_hora);

    -- Verificar si excede el límite
    IF total_clases_mes >= limite_clases THEN
        RAISE EXCEPTION 'El estudiante con ID % ya ha alcanzado el límite de % clases este mes.', NEW.id_estudiante, limite_clases;
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Trigger asociado
CREATE TRIGGER trg_control_clases_por_plan
    BEFORE INSERT ON clase
    FOR EACH ROW
    EXECUTE FUNCTION trg_control_clases_por_plan_fn();

-- CONSULTA PARA VERIFICAR ANTES DE TRATAR DE HACER INSERCIÓN
-- Verificar el número de clases actuales del estudiante 1 en noviembre de 2023
-- (Debería mostrar 4 clases, según las inserciones que ya tenemos)
SELECT COUNT(*) FROM clase
WHERE id_estudiante = 1
AND EXTRACT(YEAR FROM fecha_hora) = 2023
AND EXTRACT(MONTH FROM fecha_hora) = 11;

-- Esta inserción intentará añadir una quinta clase para el estudiante 1
-- en noviembre de 2023, lo que debería activar el trigger y fallar.
INSERT INTO clase (nombre, fecha_hora, contador_clase, id_plan, id_estudiante)
VALUES ('Clase Extra', '2023-11-25 10:00:00', 5, 1, 1);

SELECT * 
FROM clase c 
JOIN estudiante e 
  ON c.id_estudiante = e.id_estudiante 
WHERE c.id_estudiante = 1;

------------------------------
-- TRIGGER 3
------------------------------
-- Función del trigger
-- No permitir que un estudiante tenga más de un pago de tipo 'mensualidad' en el mismo mes.
CREATE OR REPLACE FUNCTION trg_no_duplicar_mensualidad_fn()
RETURNS TRIGGER AS $$
DECLARE
    total_mensualidades INT;
BEGIN
    -- Solo aplica si el tipo es 'mensualidad'
    IF NEW.tipo = 'mensualidad' THEN
        -- Contar pagos de mensualidad en el mismo mes y año
        SELECT COUNT(*) INTO total_mensualidades
        FROM pago
        WHERE id_estudiante = NEW.id_estudiante
          AND tipo = 'mensualidad'
          AND EXTRACT(YEAR FROM fecha) = EXTRACT(YEAR FROM NEW.fecha)
          AND EXTRACT(MONTH FROM fecha) = EXTRACT(MONTH FROM NEW.fecha);

        -- Si ya existe uno, rechazamos la inserción
        IF total_mensualidades > 0 THEN
            RAISE EXCEPTION 'El estudiante con ID % ya tiene un pago de mensualidad registrado para %-%.', 
                            NEW.id_estudiante, EXTRACT(YEAR FROM NEW.fecha), EXTRACT(MONTH FROM NEW.fecha);
        END IF;
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Trigger asociado
CREATE TRIGGER trg_no_duplicar_mensualidad
    BEFORE INSERT ON pago
    FOR EACH ROW
    EXECUTE FUNCTION trg_no_duplicar_mensualidad_fn();

-- Paso 1: Primer pago del mes (válido).
-- Este pago se insertará sin problemas.
INSERT INTO pago (id_estudiante, tipo, monto, fecha, metodo_pago, estado, id_plan)
VALUES (1, 'mensualidad', 200000.00, '2024-02-10', 'Transferencia', 'completado', 2);

-- Paso 2: Segundo pago en el mismo mes (inválido).
-- Esta inserción debería fallar, ya que el trigger se activará.
INSERT INTO pago (id_estudiante, tipo, monto, fecha, metodo_pago, estado, id_plan)
VALUES (1, 'mensualidad', 200000.00, '2024-02-20', 'Efectivo', 'pendiente', 2);

SELECT COUNT(*) FROM pago
WHERE id_estudiante = 1
AND tipo = 'mensualidad'
AND EXTRACT(YEAR FROM fecha) = 2024
AND EXTRACT(MONTH FROM fecha) = 2;

------------------------------
-- PROCEDIMIENTOS
------------------------------

------------------------------
-- PRROCEDIMIENTO 1
------------------------------
-- Función que devuelve un conjunto (mejor que procedimiento para SELECT)
-- Procedimiento almacenado
CREATE OR REPLACE PROCEDURE sp_reactivar_estudiante(
    p_id_estudiante INT,
    p_id_plan INT,
    p_monto_inscripcion DECIMAL,
    p_fecha_pago DATE
)
AS $$
BEGIN
    -- Verificar que el estudiante exista y esté inactivo
    IF NOT EXISTS (
        SELECT 1 FROM estudiante 
        WHERE id_estudiante = p_id_estudiante AND estado = 'Inactivo'
    ) THEN
        RAISE EXCEPTION 'El estudiante con ID % no existe o ya está activo.', p_id_estudiante;
    END IF;

    -- Verificar que el plan exista
    IF NOT EXISTS (
        SELECT 1 FROM plan_de_clases WHERE id_plan = p_id_plan
    ) THEN
        RAISE EXCEPTION 'El plan con ID % no existe.', p_id_plan;
    END IF;

    -- Actualizar estudiante: nuevo plan y estado Activo
    UPDATE estudiante
    SET id_plan = p_id_plan,
        estado = 'Activo'
    WHERE id_estudiante = p_id_estudiante;

    -- Registrar el pago de inscripción
    INSERT INTO pago (id_estudiante, tipo, monto, fecha, estado, id_plan)
    VALUES (p_id_estudiante, 'inscripcion', p_monto_inscripcion, p_fecha_pago, 'completado', p_id_plan);

    -- Commit implícito en procedimientos (si no estás en transacción manual)
END;
$$ LANGUAGE plpgsql;

-- Llamada al procedimiento para reactivar al estudiante con ID 5
-- (Ricardo Pérez), que se encuentra 'Inactivo' en la base de datos.
CALL sp_reactivar_estudiante(
    p_id_estudiante => 5,
    p_id_plan => 3,
    p_monto_inscripcion => 10000.00,
    p_fecha_pago => '2024-03-01'
);

-- Verificar que el estudiante 5 ha sido actualizado y reactivado
SELECT * FROM estudiante WHERE id_estudiante = 5;

-- Verificar que se ha registrado el nuevo pago de inscripción
SELECT * FROM pago
WHERE id_estudiante = 5
AND tipo = 'inscripcion'
ORDER BY fecha DESC;

------------------------------
-- PRROCEDIMIENTO 2
------------------------------
-- Muestra un resumen de los pagos de un estudiante para un mes y año específicos.
-- Función que devuelve un conjunto (mejor que procedimiento para SELECT)
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
        p.id_pago,
        p.tipo,
        p.monto,
        p.fecha,
        p.estado,
        p.metodo_pago
    FROM pago p
    WHERE p.id_estudiante = p_id_estudiante
      AND EXTRACT(MONTH FROM p.fecha) = p_mes
      AND EXTRACT(YEAR FROM p.fecha) = p_anio
    ORDER BY p.fecha;
END;
$$ LANGUAGE plpgsql;

-- Consulta para obtener un resumen de todos los pagos del estudiante 1 en noviembre de 2023
SELECT * FROM sp_resumen_pagos_mensuales(
    p_id_estudiante => 1,
    p_mes => 11,
    p_anio => 2023
);