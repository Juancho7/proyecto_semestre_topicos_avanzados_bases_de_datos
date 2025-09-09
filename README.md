# TÓPICOS AVANZADOS EN BASES DE DATOS

## ACADEMIA DE ARTES

**INTEGRANTES:**

* CRISTIAN CAMILO SANTIAGO SANCHEZ

* JUAN FERNANDO ORDOÑEZ MARTINEZ

* LUIS EDUARDO TORRES

---

### **Tabla: `rol_implementacion`**

| Campo | Tipo de Dato | Restricciones | Descripción | 
| :--- | :--- | :--- | :--- | 
| `rol_id` | `SERIAL` (`INT`) | PK, NOT NULL | Identificador único del rol | 
| `nombre_rol` | `VARCHAR(100)` | NOT NULL | Nombre o etiqueta del rol | 

---

### **Tabla: `usuario`**

| Campo | Tipo de Dato | Restricciones | Descripción | 
| :--- | :--- | :--- | :--- | 
| `id_usuario` | `SERIAL` (`INT`) | PK, NOT NULL | Identificador único del usuario | 
| `nombre` | `VARCHAR(50)` | NOT NULL | Nombre del usuario | 
| `apellido` | `VARCHAR(50)` | NOT NULL | Apellido del usuario | 
| `correo_electronico` | `VARCHAR(100)` | NOT NULL, UNIQUE | Correo electrónico del usuario | 
| `contrasena` | `VARCHAR(255)` | NOT NULL | Contraseña encriptada del usuario | 
| `rol_id` | `INT` | FK → `rol_implementacion(rol_id)` | Rol asignado al usuario | 

---

### **Tabla: `plan_de_clases`**

| Campo | Tipo de Dato | Restricciones | Descripción | 
| :--- | :--- | :--- | :--- | 
| `id_plan` | `SERIAL` (`INT`) | PK, NOT NULL | Identificador único del plan | 
| `nombre` | `VARCHAR(100)` | NOT NULL | Nombre del plan de clases | 
| `descripcion` | `TEXT` | NULL | Descripción del plan | 
| `numero_de_clases_mes` | `INT` | NOT NULL | Número de clases incluidas al mes | 
| `precio_mensualidad` | `DECIMAL(10,2)` | NOT NULL | Costo mensual del plan | 

---

### **Tabla: `estudiante`**

| Campo | Tipo de Dato | Restricciones | Descripción | 
| :--- | :--- | :--- | :--- | 
| `id_estudiante` | `SERIAL` (`INT`) | PK, NOT NULL | Identificador único del estudiante | 
| `nombre` | `VARCHAR(50)` | NOT NULL | Nombre del estudiante | 
| `apellido` | `VARCHAR(50)` | NOT NULL | Apellido del estudiante | 
| `fecha_nacimiento` | `DATE` | NULL | Fecha de nacimiento | 
| `telefono` | `VARCHAR(20)` | NOT NULL | Teléfono de contacto | 
| `correo_electronico` | `VARCHAR(100)` | NOT NULL | Correo electrónico del estudiante | 
| `estado` | `VARCHAR(10)` | CHECK (‘Activo’, ‘Inactivo’), DEFAULT ‘Inactivo’ | Estado del estudiante | 
| `fecha_inscripcion` | `DATE` | NOT NULL | Fecha de inscripción | 
| `id_plan` | `INT` | FK → `plan_de_clases(id_plan)` | Plan de clases contratado | 

---

### **Tabla: `clase`**

| Campo | Tipo de Dato | Restricciones | Descripción | 
| :--- | :--- | :--- | :--- | 
| `id_clase` | `SERIAL` (`INT`) | PK, NOT NULL | Identificador único de la clase | 
| `nombre` | `VARCHAR(100)` | NOT NULL | Nombre de la clase | 
| `fecha_hora` | `TIMESTAMP` | NOT NULL | Fecha y hora de la clase | 
| `contador_clase` | `INT` | NOT NULL | Número de la clase en el plan | 
| `id_plan` | `INT` | FK → `plan_de_clases(id_plan)` | Plan al que pertenece la clase | 
| `id_estudiante` | `INT` | FK → `estudiante(id_estudiante)` | Estudiante asignado | 

---

### **Tabla: `bastidor`**

| Campo | Tipo de Dato | Restricciones | Descripción | 
| :--- | :--- | :--- | :--- | 
| `id_bastidor` | `SERIAL` (`INT`) | PK, NOT NULL | Identificador único del bastidor | 
| `medidas` | `VARCHAR(50)` | NOT NULL | Dimensiones del bastidor | 
| `precio` | `DECIMAL(10,2)` | NOT NULL | Precio del bastidor | 

---

### **Tabla: `estudiante_bastidor`**

| Campo | Tipo de Dato | Restricciones | Descripción | 
| :--- | :--- | :--- | :--- | 
| `id_registro_eb` | `SERIAL` (`INT`) | PK, NOT NULL | Identificador único del registro | 
| `id_estudiante` | `INT` | FK → `estudiante(id_estudiante)` | Estudiante asociado | 
| `id_bastidor` | `INT` | FK → `bastidor(id_bastidor)` | Bastidor asignado | 

---

### **Tabla: `pago`**

| Campo | Tipo de Dato | Restricciones | Descripción | 
| :--- | :--- | :--- | :--- | 
| `id_pago` | `SERIAL` (`INT`) | PK, NOT NULL | Identificador del pago | 
| `id_estudiante` | `INT` | FK → `estudiante(id_estudiante)` | Estudiante que realiza el pago | 
| `tipo` | `VARCHAR(20)` | CHECK (‘inscripcion’, ‘mensualidad’, ‘bastidor’) | Tipo de pago realizado | 
| `monto` | `DECIMAL(10,2)` | NOT NULL | Valor del pago | 
| `fecha` | `DATE` | NOT NULL | Fecha en que se realizó el pago | 
| `metodo_pago` | `VARCHAR(50)` | NULL | Método de pago utilizado | 
| `estado` | `VARCHAR(20)` | CHECK (‘pendiente’, ‘completado’, ‘fallido’) | Estado del pago | 
| `id_bastidor` | `INT` | FK → `bastidor(id_bastidor)` | Bastidor relacionado | 
| `id_plan` | `INT` | FK → `plan_de_clases(id_plan)` | Plan relacionado | 

---

### **Tabla: `asistencia`**

| Campo | Tipo de Dato | Restricciones | Descripción | 
| :--- | :--- | :--- | :--- | 
| `id_asistencia` | `SERIAL` (`INT`) | PK, NOT NULL | Identificador de la asistencia | 
| `id_estudiante` | `INT` | FK → `estudiante(id_estudiante)` | Estudiante asociado | 
| `id_clase` | `INT` | FK → `clase(id_clase)` | Clase asistida | 
| `asistio` | `BOOLEAN` | NOT NULL, DEFAULT FALSE | Indicador de asistencia | 
| `jornada` | `VARCHAR(10)` | CHECK (‘mañana’, ‘tarde’, ‘noche’) | Jornada de la clase | 
| `fecha` | `DATE` | NOT NULL | Fecha de la clase | 

---

### **Tabla: `redencion_de_clase_no_asistida`**

| Campo | Tipo de Dato | Restricciones | Descripción | 
| :--- | :--- | :--- | :--- | 
| `id_redencion` | `SERIAL` (`INT`) | PK, NOT NULL | Identificador de la redención | 
| `id_estudiante` | `INT` | FK → `estudiante(id_estudiante)` | Estudiante que solicita la redención | 
| `id_clase_original` | `INT` | FK → `clase(id_clase)` | Clase original no asistida | 
| `fecha` | `DATE` | NOT NULL | Fecha de la solicitud | 
| `estado_redencion` | `VARCHAR(20)` | CHECK (‘pendiente’, ‘aprobada’, ‘rechazada’) | Estado del trámite | 
| `motivo` | `TEXT` | NULL | Motivo de la solicitud |