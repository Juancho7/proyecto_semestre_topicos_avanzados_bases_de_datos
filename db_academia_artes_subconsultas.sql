----------------------------------
-- INTEGRANTES:
-- CRISTIAN CAMILO SANTIAGO SANCHEZ
-- JUAN FERNANDO ORDOÑEZ MARTINEZ
-- LUIS EDUARDO TORRES
----------------------------------

----------------------------------
-- SUBCONSULTAS
----------------------------------

-- 1. Estudiantes que han comprado un bastidor de más de 100 cm de largo
SELECT nombre, apellido
FROM estudiante
WHERE id_estudiante IN (
    SELECT id_estudiante
    FROM estudiante_bastidor
    WHERE id_bastidor IN (
        SELECT id_bastidor
        FROM bastidor
        WHERE medidas LIKE '%100%' OR medidas LIKE '%120%' OR medidas LIKE '%150%'
    )
);

-- 2. Estudiantes que han asistido a todas las clases de su plan
SELECT e.nombre, e.apellido
FROM estudiante e
JOIN plan_de_clases p ON e.id_plan = p.id_plan
WHERE (
    SELECT COUNT(*)
    FROM asistencia a
    WHERE a.id_estudiante = e.id_estudiante AND a.asistio = TRUE
) = p.numero_de_clases_mes;

-- 3. Planes de clases que tienen al menos un estudiante inactivo
SELECT DISTINCT nombre
FROM plan_de_clases
WHERE id_plan IN (
    SELECT id_plan
    FROM estudiante
    WHERE estado = 'Inactivo'
);

-- 4. Pagos de estudiantes que también han redimido una clase
SELECT *
FROM pago
WHERE id_estudiante IN (
    SELECT DISTINCT id_estudiante
    FROM redencion_de_clase_no_asistida
);

-- 5. Estudiantes que han pagado la mensualidad pero no han asistido a ninguna clase
SELECT nombre, apellido
FROM estudiante
WHERE id_estudiante IN (
    SELECT id_estudiante
    FROM pago
    WHERE tipo = 'mensualidad'
) AND id_estudiante NOT IN (
    SELECT id_estudiante
    FROM asistencia
    WHERE asistio = TRUE
);

-- 6. Estudiantes que han pagado un bastidor con un precio de 15000.00
SELECT nombre, apellido
FROM estudiante
WHERE id_estudiante IN (
    SELECT id_estudiante
    FROM pago
    WHERE tipo = 'bastidor' AND monto = 15000.00
);

-- 7. Estudiantes que han pagado por un bastidor que no está asociado a su perfil
SELECT e.nombre, e.apellido
FROM estudiante e
JOIN pago p ON e.id_estudiante = p.id_estudiante
WHERE p.tipo = 'bastidor' AND p.id_bastidor NOT IN (
    SELECT id_bastidor
    FROM estudiante_bastidor
    WHERE id_estudiante = e.id_estudiante
);

-- 8. Planes de clases que tienen estudiantes que han redimido una clase con un estado 'aprobado'
SELECT DISTINCT nombre
FROM plan_de_clases
WHERE id_plan IN (
    SELECT id_plan
    FROM estudiante
    WHERE id_estudiante IN (
        SELECT DISTINCT id_estudiante
        FROM redencion_de_clase_no_asistida
        WHERE estado_redencion = 'aprobada'
    )
);

-- 9. Estudiantes que han tenido una redención de clase rechazada con el motivo 'Falta de notificación previa'
SELECT nombre, apellido
FROM estudiante
WHERE id_estudiante IN (
    SELECT id_estudiante
    FROM redencion_de_clase_no_asistida
    WHERE estado_redencion = 'rechazada' AND motivo = 'Falta de notificación previa'

);
