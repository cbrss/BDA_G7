/*
		BASE DE DATOS APLICADA
		GRUPO: 07
		COMISION: 5600
		INTEGRANTES:
			Cristian Raul Berrios Lima		42875289
			Lautaro Da silva				42816815
			Abigail Karina Peñafiel Huayta	41913506

		FECHA DE ENTREGA: 14/6/2024
*/

USE Com5600G07
GO



/*
Importaciones de los archivos, la ruta de los casos de prueba debe estar en la carpeta "casos_de_prueba"
y para testear con las distintas rutas, solo hay que reemplazar "@p_ruta" con la ruta del caso de prueba
*/

-- ====================== Importacion validos ======================

EXEC gestion_paciente.ImportarPacientes
	@p_ruta	= '../casos_de_prueba/Pacientes.csv'
SELECT * from gestion_paciente.Paciente
SELECT * from gestion_paciente.Domicilio
DELETE from gestion_paciente.Domicilio
DELETE from gestion_paciente.Paciente

EXEC  gestion_paciente.ImportarPrestadores
	@p_ruta = '../casos_de_prueba/Prestador.csv'
SELECT * from gestion_paciente.Prestador
DELETE from gestion_paciente.Prestador

EXEC gestion_sede.ImportarSede
	@p_ruta = '../casos_de_prueba/Sedes.csv'
SELECT * from gestion_sede.Sede
DELETE from gestion_sede.Sede

EXEC gestion_sede.ImportarMedico
	@p_ruta = '../casos_de_prueba/Medicos.csv'
SELECT * from gestion_sede.Especialidad
SELECT * from gestion_sede.Medico
DELETE from gestion_sede.Especialidad
DELETE from gestion_sede.Medico

-- ====================== Importacion con errores ======================

EXEC gestion_paciente.ImportarPacientes
	@p_ruta = '../casos_de_prueba/PacientesErrores.csv'

EXEC gestion_paciente.ImportarPrestadores
	@p_ruta = '../casos_de_prueba/PrestadorErrores.csv'

EXEC gestion_sede.ImportarSede
	@p_ruta = '../casos_de_prueba/SedesErrores.csv'

EXEC gestion_sede.ImportarMedico
	@p_ruta = '../casos_de_prueba/MedicosErrores.csv'

/*
	EXPORTACION ARCHIVO XML
	ejecutar la insercion de datos hasta el comentario ========= V1 =========
	para limpiar los datos, ejecutar los delete del comentario -- ========= V2 =========
*/
-- Paciente
INSERT INTO gestion_paciente.Paciente (nombre, apellido, num_doc, fecha_nac, tipo_doc, sexo, genero, nacionalidad, mail, tel_fijo, tel_alt, tel_laboral, fecha_registro, fecha_actualizacion, usr_actualizacion, borrado_logico)
VALUES ('Juan', 'Perez', 12345678, '1990-01-01', 'DNI', 'Masculino', 'Hombre', 'Argentina', 'juan.perez@example.com', '(011) 1234-5678', '(011) 8765-4321', '(011) 5555-5555', '2024-06-01', '2024-06-01', 'admin', 0);
GO
DECLARE @id_paciente int
SET @id_paciente= (SELECT SCOPE_IDENTITY())

-- Cobertura
INSERT INTO gestion_paciente.Cobertura (id, id_paciente, imagen_credencial, nro_socio, fecha_registro)
VALUES (1, @id_paciente, 'credencial.jpg', 123456, '2024-06-01');

-- Prestador
INSERT INTO gestion_paciente.Prestador (id_cobertura, nombre, [plan])
VALUES (1, 'OSDE', 'Plan 210');

-- EstadoTurno
INSERT INTO gestion_turno.EstadoTurno (id, nombre)
VALUES (1, 'Atendido');
-- TipoTurno
INSERT INTO gestion_turno.TipoTurno(id, nombre)
VALUES (1, 'Presencial')

-- ReservaTurno
INSERT INTO gestion_turno.ReservaTurno (id, fecha, hora, id_paciente, id_estado_turno, id_tipo_turno, borrado_logico)
VALUES (1, '2024-06-15', '10:00:00', @id_paciente, 1, 1, 0);

-- Medico y especialidad
INSERT INTO gestion_sede.Especialidad (nombre)
VALUES ('Cardiología');
DECLARE @id_especialidad int
SET @id_especialidad= (SELECT SCOPE_IDENTITY())

INSERT INTO gestion_sede.Medico (nombre, apellido, matricula, id_especialidad)
VALUES ('Carlos', 'Gomez', 12345, @id_especialidad);
DECLARE @id_medico int
SET @id_medico= (SELECT SCOPE_IDENTITY())
-- Sede
INSERT INTO gestion_sede.Sede(nombre)
VALUES ('Cruz roja')
DECLARE @id_sede int
SET @id_sede= (SELECT SCOPE_IDENTITY())
-- DiasXSede
INSERT INTO gestion_sede.DiasXSede (id, id_sede, id_medico, id_reserva_turno, dia, hora_inicio)
VALUES (1, @id_sede, @id_medico, 1, '2024-06-15', '10:00:00');
GO

-- ========= V1 =========

-- CASO DE TURNO DENTRO DEL RANGO DE FECHAS
EXEC gestion_turno.ExportarTurnos 'OSDE', '2024-06-01', '2024-06-30';
-- CASO DE TURNO FUERA DEL RANGO DE FECHAS
EXEC gestion_turno.ExportarTurnos 'OSDE', '2024-07-01', '2024-07-30';

-- ========= V2 =========
DELETE FROM gestion_sede.DiasXSede;
DELETE FROM gestion_sede.Medico;
DELETE FROM gestion_sede.Especialidad;
DELETE FROM gestion_turno.ReservaTurno;
DELETE FROM gestion_turno.EstadoTurno;
DELETE FROM gestion_turno.TipoTurno
DELETE FROM gestion_paciente.Prestador;
DELETE FROM gestion_paciente.Cobertura;
DELETE FROM gestion_paciente.Paciente;
-- ========= V2 =========

/*
	Los turnos para atención médica tienen como estado inicial disponible, según el médico, la 
	especialidad y la sede.
	Para testear este caso de prueba, es necesario ejecutar hasta el comentario ===== V1 =====
	y despues ejecutar el borrado de los datos de prueba, el cual esta en el comentario ===== V2 =====

*/

INSERT INTO gestion_paciente.Paciente(nombre, apellido, fecha_nac, tipo_doc, num_doc, sexo, genero, nacionalidad, mail)
VALUES ('testPaciente', 'Perez', '1980-01-01', 'DNI', 12345678, 'Masculino', 'Masculino', 'Argentina', 'pepe@hotmial.com');
GO

DECLARE @id_paciente int
SET @id_paciente= (SELECT SCOPE_IDENTITY())

INSERT INTO gestion_sede.Especialidad(nombre)
VALUES ('testEspecialidad');


DECLARE @id_especialidad int
SET @id_especialidad= (SELECT SCOPE_IDENTITY())

INSERT INTO gestion_sede.Medico(nombre, apellido, matricula, id_especialidad)
VALUES ('testMedico', 'Gomez', 1234, @id_especialidad); 

DECLARE @id_medico int
SET @id_medico= (SELECT SCOPE_IDENTITY())

INSERT INTO gestion_sede.Sede(nombre, direccion, localidad, provincia)
VALUES ('testSede', 'Calle falsa 123', 'Bsas', 'Bsas');
DECLARE @id_sede int
SET @id_sede= (SELECT SCOPE_IDENTITY())

INSERT INTO gestion_turno.EstadoTurno(id, nombre)
VALUES (100,'Disponible');
INSERT INTO gestion_turno.EstadoTurno(id, nombre)
VALUES (101,'Pendiente');

INSERT INTO gestion_turno.TipoTurno(id, nombre)
VALUES (1000, 'Presencial')


DECLARE @p_id INT = 10000;
DECLARE @p_fecha DATE = '2024-06-15';
DECLARE @p_hora TIME = '10:00:00';
DECLARE @p_id_paciente INT = @id_paciente; 
DECLARE @p_id_medico INT = @id_medico; 
DECLARE @p_id_especialidad INT = @id_especialidad; 
DECLARE @p_id_sede_atencion INT = @id_sede; 
DECLARE @p_id_tipo_turno INT = 1000; 
DECLARE @p_id_estado_turno INT = 101;

EXEC gestion_turno.InsertarReservaTurno
	@p_id = @p_id,
	@p_fecha = @p_fecha,
	@p_hora = @p_hora,
	@p_id_paciente = @p_id_paciente,
	@p_id_medico = @p_id_medico,
	@p_id_especialidad = @p_id_especialidad,
	@p_id_sede_atencion = @p_id_sede_atencion,
	@p_id_tipo_turno = @p_id_tipo_turno,
	@p_id_estado_turno = @p_id_estado_turno;
GO

SELECT * from gestion_turno.ReservaTurno
/* ====================== HASTA V1 =================*/

delete from gestion_turno.ReservaTurno where id = 10000
delete from gestion_paciente.Paciente where nombre = 'testPaciente'
delete from gestion_sede.Medico where nombre = 'testMedico'
delete from gestion_sede.Especialidad where nombre = 'testEspecialidad'
delete from gestion_sede.Sede where nombre = 'testSede'
delete from gestion_turno.EstadoTurno where id = 100 or id = 101
delete from gestion_turno.TipoTurno where id = 1000
/* ====================== HASTA V2 =================*/
/*
Los estudios clínicos deben ser autorizados, e indicar si se cubre el costo completo del mismo o solo 
un porcentaje. El sistema de Cure se comunica con el servicio de la prestadora, se le envía el código 
del estudio, el dni del paciente y el plan; el sistema de la prestadora informa si está autorizado o no y 
el importe a facturarle al paciente.

para testear el procedimiento, se debe ejecutar hasta el comentario -- ======== V1 =======
y para borrar las inserciones ejecutar hasta el comentario -- ======== V2 =======
*/

INSERT INTO gestion_paciente.Paciente(nombre, apellido, fecha_nac, tipo_doc, num_doc, sexo, genero, nacionalidad, mail)
VALUES ('testPaciente', 'Perez', '1980-01-01', 'DNI', 12345678, 'Masculino', 'Masculino', 'Argentina', 'pepe@hotmial.com');
GO

DECLARE @id_paciente int
SET @id_paciente= (SELECT SCOPE_IDENTITY())

insert into gestion_paciente.Estudio(id, id_paciente, autorizado, nombre)
values (1, @id_paciente, 1, 'ECOCARDIOGRAMA CON STRESS CON RESERVA DE FLUJO CORONARIO')

DECLARE @p_respuesta varchar(100)

EXEC gestion_paciente.AutorizarEstudio 
	@p_id_estudio		= 1,
	@p_dni_paciente		= 12345678,
	@p_plan_prestador	=  'Plan 800 OSPOCE Integral',	
	@p_ruta				= 'D:\BDA_TALLER\BDA_tp\casos_de_prueba\Centro_Autorizaciones.Estudios clinicos.json',	
	@p_respuesta		= @p_respuesta OUTPUT;

print (@p_respuesta)
-- ======== V1 =======

delete from gestion_paciente.Estudio
delete from gestion_paciente.Paciente
-- ======== V2 =======

-- ====================== LOTE TIPO TURNO ======================

EXEC gestion_turno.InsertarTipoTurno 10, 'Presencial'
go
Select * from gestion_turno.TipoTurno where id = 10
go
EXEC gestion_turno.InsertarTipoTurno 11, 'virtual'
Select * from gestion_turno.TipoTurno where id = 11
go

-- id_tipo_turno ya existe -> INFRACCION DE RESTRICCION PK_tipoID
EXEC gestion_turno.InsertarTipoTurno 11, 'repetido'
go

-- tipo_turno ya existe
EXEC gestion_turno.InsertarTipoTurno 8, 'Presencial'
go

-- No debe haber otro tipo de turno -> INFRACCION DE RESTRICCION PK_tipoID
EXEC gestion_turno.InsertarTipoTurno 11, 'a distancia'
go
-- No debe haber numeros -> Instrucción INSERT en conflicto con la restricción CHECK 'Ck_TipoTurno', column 'nombre'
EXEC gestion_turno.InsertarTipoTurno 12, 'asitencia45'
go

-- Error en el campo: Nombre del tipo de turno invalido. Debe ser "Presencial" o "Virtual".
EXEC gestion_turno.ActualizarTipoTurno 10, 'vir980'
go
-- Error: El tipo de turno no existe
EXEC gestion_turno.ActualizarTipoTurno 12, 'vir980'
go
EXEC gestion_turno.ActualizarTipoTurno 11, 'Virtual'
go
Select * from gestion_turno.TipoTurno where id = 11
go

-- ====================== LOTE ESTADO TURNO ======================

EXEC gestion_turno.InsertarEstadoTurno 600, 'Disponible'
go
Select * from gestion_turno.EstadoTurno where id = 600
go
EXEC gestion_turno.InsertarEstadoTurno 601, 'cancelado'
go
Select * from gestion_turno.EstadoTurno where id = 601
go
EXEC gestion_turno.InsertarEstadoTurno 602, 'Ausente'
go
Select * from gestion_turno.EstadoTurno where id = 602
go
EXEC gestion_turno.InsertarEstadoTurno 603, 'Atendido'
go
Select * from gestion_turno.EstadoTurno where id = 603
go

Select * from gestion_turno.EstadoTurno
go

-- id_estado ya existe -> Error en el campo: Error no identificado
EXEC gestion_turno.InsertarEstadoTurno 603, 'espera';
go
-- Error: El estado de turno ya existe
EXEC gestion_turno.InsertarEstadoTurno 608, 'Ausente';
go
-- No admite numeros -> Error en el campo: Nombre del estado de turno invalido
EXEC gestion_turno.InsertarEstadoTurno 607, '678ahu';
go

-- Estado NO existe
EXEC gestion_turno.ActualizarEstadoTurno 604, 'Pendiente'
go
-- Excede el largo del nombre -> NO LO DETECTA!!!
EXEC gestion_turno.ActualizarEstadoTurno 601, 'disponibleeesssaaa'
go
-- Error en el campo: Nombre del estado de turno invalido
EXEC gestion_turno.ActualizarEstadoTurno 601, 'CANCE89ADO'
go
EXEC gestion_turno.ActualizarEstadoTurno 601, 'Cancelado'
go
EXEC gestion_turno.InsertarEstadoTurno 604, 'Pendiente'
go
Select * from gestion_turno.EstadoTurno
go

-- ====================== LOTE RESERVA TURNO ======================

-- Requiero datos correctos cargados en ciertas tablas

Insert into gestion_sede.Sede (nombre) values -- IDs 1 a 5
('El Palomar'), ('Ramos Mejía'), ('San Justo'), ('La Noria'), ('Morón')
go
Select * from gestion_sede.Sede -- OK
go

Insert into gestion_sede.Especialidad (nombre) values -- IDs 1 a 5
('Pediatría'), ('Oncología'), ('Kinesiología'), ('Diagnosta'), ('Ginecología')
go
Select * from gestion_sede.Especialidad -- OK
go

Insert into gestion_sede.Medico (nombre, apellido, matricula, id_especialidad) values -- IDs 12 a 17
('Ricardo', 'Sendra', 2500, 2), ('Evangeline', 'Sánz', 1800, 3), ('Emeth', 'Marx', 3490, 5),
('Gerardo', 'Ruiz', 1687, 4), ('Elena', 'De La Vega', 4300, 5), ('Sebastián', 'Esquivel', 5980, 4)
go
Select * from gestion_sede.Medico -- OK
go

Insert into gestion_paciente.Paciente(nombre, apellido, apellido_materno) values -- IDs 1 a 6
('Laura', 'López', 'Ramirez'),
('Ezequiel', 'Baez', 'Peña') ,
('José', 'Ibarola', 'Zarratea') ,
('Evelin', 'Benítez', 'Heredia'), 
('Santiago Emmanuel', 'Vallesteros', ''),
('Ignacio', 'Francisco', 'Paz')
go
Select * from gestion_paciente.Paciente -- OK
go

/*	gestion_turno.InsertarReservaTurno
	@p_id	@p_fecha	@p_hora		@p_id_paciente		@p_id_medico	@p_id_especialidad		@p_id_sede_atencion
	@p_id_estado_turno	@p_id_tipo_turno
*/

-- Por convencion lo dejara Disponible (600) o Pendiente (604)
-- ESTO DEBERIA CAMBIAR CON EL ARCHIVO DE DISPONIBILIDAD cuando cambie CONSULTAR DISPONIBILIDAD
-- TODO
EXEC gestion_turno.InsertarReservaTurno 77, '2024-05-18', '9:45', 4, 15, 4, 3, 600, 11
go
Select * from gestion_turno.ReservaTurno where id = 77
go

EXEC gestion_turno.InsertarReservaTurno 78, '2024-03-10', '20:15', 2, 12, 2, 1, 600, 10
go
Select * from gestion_turno.ReservaTurno where id = 78
go

Select * from gestion_turno.ReservaTurno
go

-- Cambia estado a Cancelado
EXEC gestion_turno.ActualizarReservaTurno @p_id = 78, @p_id_estado_turno = 601
go
Select * from gestion_turno.ReservaTurno where id = 78
go


EXEC gestion_turno.InsertarReservaTurno 79, '2024-03-02', '12:15', 3, 14, 5, 4, 600, 10
go
Select * from gestion_turno.ReservaTurno where id = 79
go
EXEC gestion_turno.InsertarReservaTurno 80, '2024-04-06', '13:00', 5, 13, 3, 2, 600, 10
go
Select * from gestion_turno.ReservaTurno where id = 80
go
/*EXEC gestion_turno.ModificarEstadoReserva 80, 602 -- Estado Ausente
go*/
EXEC gestion_turno.ActualizarReservaTurno @p_id = 80, @p_id_estado_turno = 602 -- Estado Ausente
go
Select * from gestion_turno.ReservaTurno where id = 80
go

-- Nueva reserva con fecha hora y estado del que se canceló (se insertó como Pendiente -604- en sede 1)
EXEC gestion_turno.InsertarReservaTurno 81, '2024-03-10', '20:15', 1, 12, 2, 1, 600, 10
go
Select * from gestion_turno.ReservaTurno where id = 81
go

-- El paciente ya tiene turno a esa fecha y hora (si es en otra sede y/o con otro medico, NO SE ACLARARÁ)-> OK
EXEC gestion_turno.InsertarReservaTurno 82, '2024-03-02', '12:15', 3, 14, 5, 4, 600, 10
go

-- El paciente tenía turno Pendiente a esa fecha y hora en sede 1, se anulará y creará nuevo turno en sede 5 -> OK
EXEC gestion_turno.InsertarReservaTurno 82, '2024-03-10', '20:15', 1, 17, 4, 5, 600, 10
go
Select * from gestion_turno.ReservaTurno where id = 81 -- Se borró -> OK
go
Select * from gestion_turno.ReservaTurno where id = 82 -- Nuevo turno -> estado Pendiente
go

-- El paciente no existe (IDs 1 a 5) -> OK
EXEC gestion_turno.InsertarReservaTurno 83, '2024-03-02', '12:30', 9, 14, 5, 4, 600, 10
go
-- id ya existe -> El ID de la reserva ya existe. Se borró
EXEC gestion_turno.InsertarReservaTurno 78, '2024-03-06', '9:00', 1, 17, 4, 5, 600, 11
go
Select * from gestion_turno.ReservaTurno where id = 78
go
-- El estado no existe -> OK
EXEC gestion_turno.InsertarReservaTurno 84, '2024-03-06', '9:15', 1, 17, 4, 5, 605, 11
go
-- El tipo de turno no existe -> OK
EXEC gestion_turno.InsertarReservaTurno 85, '2024-03-06', '10:00', 1, 17, 4, 5, 600, 49
go

-- Estas validaciones son INDISPENSABLES para cargar DiasXSede, las puse para probar que va al SP auxiliar como debe

-- El medico no existe (IDs 12 a 17) -> OK
EXEC gestion_turno.InsertarReservaTurno 84, '2024-03-06', '9:15', 1, 60, 4, 5, 600, 11
go
-- La especialidad no existe (IDs 1 a 5) -> OK
EXEC gestion_turno.InsertarReservaTurno 84, '2024-03-06', '9:15', 1, 17, 39, 5, 600, 11
go
-- La sede no existe (IDs 1 a 5) -> OK
EXEC gestion_turno.InsertarReservaTurno 84, '2024-03-06', '9:15', 1, 17, 4, 1200, 600, 11
go

-- =============================== ACTUALIZAR ===============================

-- Solo se debería poder actualizar fecha, hora, estado y quizá tipo de turno
-- (Para fecha y hora no se está controlando la disponibilidad horaria del medico)

Select * from gestion_turno.ReservaTurno

-- Cambia reserva 79 a Atendido (603)
EXEC gestion_turno.ModificarEstadoReserva 79, 603
go
Select * from gestion_turno.ReservaTurno where id = 79
go
-- Cambia reserva 81 Pendiente a Disponible (600)
EXEC gestion_turno.ActualizarReservaTurno @p_id = 81, @p_id_estado_turno = 600
go
Select * from gestion_turno.ReservaTurno where id = 81
go

-- La reserva no existe -> OK
EXEC gestion_turno.ModificarEstadoReserva 84, 601
go
EXEC gestion_turno.ActualizarReservaTurno @p_id = 84, @p_id_estado_turno = 601
go

-- El estado no existe (IDs 600 a 603)
EXEC gestion_turno.ModificarEstadoReserva 77, 1809 --> OK
go
EXEC gestion_turno.ActualizarReservaTurno @p_id = 77, @p_id_estado_turno = 1809
go --> Instrucción UPDATE en conflicto con la restricción FOREIGN KEY 'FK_estadoID'.
--	El conflicto ha aparecido en la base de datos 'Com5600G07', tabla 'gestion_turno.EstadoTurno', column 'id'.

-- El tipo de turno no existe (IDs 10 y 11)
EXEC gestion_turno.ActualizarReservaTurno @p_id = 79, @p_id_estado_turno = 601, @p_id_tipo_turno = 15
go 

-- =============================== ELIMINAR ===============================

EXEC gestion_turno.BorrarReservaTurno 77 --> OK
go
Select * from gestion_turno.ReservaTurno where id = 77
go
-- La reserva no existe -> OK
EXEC gestion_turno.BorrarReservaTurno 266
go
Select * from gestion_turno.ReservaTurno --> Antes de vaciar la tabla ReservaTurno
go

-- Para vaciar la tabla ReservaTurno, debo vaciar Sede, Medico y Especialidad

Delete gestion_sede.Sede where id = 1
go
Delete gestion_sede.Sede where id = 2
go
Delete gestion_sede.Sede where id = 3
go
Delete gestion_sede.Sede where id = 4
go
Delete gestion_sede.Sede where id = 5
go
Select * from gestion_sede.Sede
go

Delete gestion_sede.Medico where id = 12
go
Delete gestion_sede.Medico where id = 13
go
Delete gestion_sede.Medico where id = 14
go
Delete gestion_sede.Medico where id = 15
go	
Delete gestion_sede.Medico where id = 16
go
Delete gestion_sede.Medico where id = 17
go
Select * from gestion_sede.Medico
go

Delete gestion_sede.Especialidad where id = 1
go
Delete gestion_sede.Especialidad where id = 2
go
Delete gestion_sede.Especialidad where id = 3
go
Delete gestion_sede.Especialidad where id = 4
go
Delete gestion_sede.Especialidad where id = 5
go
Select * from gestion_sede.Especialidad
go

-- BorrarReservaTurno

EXEC gestion_turno.BorrarReservaTurno 77
go
Select * from gestion_turno.ReservaTurno -- 77 borrado logico en 1 -> OK
go
EXEC gestion_turno.BorrarReservaTurno 86 -- No existe la reserva -> OK
go

-- Vaciar tabla ReservaTurno

Delete gestion_turno.ReservaTurno where id = 77
go
Delete gestion_turno.ReservaTurno where id = 78
go
Delete gestion_turno.ReservaTurno where id = 79
go
Delete gestion_turno.ReservaTurno where id = 80
go
Delete gestion_turno.ReservaTurno where id = 81
go
Delete gestion_turno.ReservaTurno where id = 82
go
Select * from gestion_turno.ReservaTurno
go

-- Ahora puedo vaciar las tablas TipoTurno y EstadoTurno (borrado fisico)

EXEC gestion_turno.EliminarTipoTurno 10 --> OK
go
EXEC gestion_turno.EliminarTipoTurno 11 --> OK
go
Select * from gestion_turno.TipoTurno
go
EXEC gestion_turno.EliminarTipoTurno 9 -- No existe el tipo turno -> OK
go


EXEC gestion_turno.BorrarEstadoTurno 600 -- Disponible
go
EXEC gestion_turno.BorrarEstadoTurno 602 -- Ausente
go
Select * from gestion_turno.EstadoTurno -- 600 y 602 ya no están
go
EXEC gestion_turno.BorrarEstadoTurno 600 -- Ya no existe el estado Disponible -> OK
go
EXEC gestion_turno.BorrarEstadoTurno 560 -- No existe el estado 560 -> OK
go
EXEC gestion_turno.BorrarEstadoTurno 601 -- Cancelado
go
EXEC gestion_turno.BorrarEstadoTurno 603 -- Atendido
go
EXEC gestion_turno.BorrarEstadoTurno 604 -- Pendiente
go
Select * from gestion_turno.EstadoTurno -- Vacía -> OK
go

-- Ahora puedo vaciar tabla Paciente
/*
Delete gestion_paciente.Paciente where id = 1
go
Delete gestion_paciente.Paciente where id = 2
go
Delete gestion_paciente.Paciente where id = 3
go
Delete gestion_paciente.Paciente where id = 4
go
Delete gestion_paciente.Paciente where id = 5
go
Delete gestion_paciente.Paciente where id = 6
go
Select * from gestion_paciente.Paciente
go
*/
-- ====================== LOTE PACIENTE ======================

/* gestion_paciente.InsertarPaciente
	@p_id					INT				= NULL,
	@p_nombre				VARCHAR(30),
	@p_apellido				VARCHAR(30),
	@p_apellido_materno		VARCHAR(30), --> Esta debería poder ser NULL
	@p_fecha_nac			DATE,
	@p_tipo_doc				CHAR(5),
	@p_num_doc				INT,
	@p_sexo					VARCHAR(11),
	@p_genero				VARCHAR(9),
	@p_nacionalidad			VARCHAR(20),
	@p_foto_perfil			VARCHAR(max)	= NULL,
	@p_mail					VARCHAR(30),
	@p_tel_fijo				VARCHAR(15),
	@p_tel_alt				VARCHAR(15)		= NULL,
	@p_tel_laboral			VARCHAR(15)		= NULL,
	@p_id_identity			INT				= NULL OUTPUT 
*/
-- Datos válidos

-- Todos los campos (menos perfil)
EXEC gestion_paciente.InsertarPaciente
	@p_id					= 3,
	@p_nombre				= 'José',
	@p_apellido				= 'Ibarola',
	@p_apellido_materno		= 'Zarratea',
	@p_fecha_nac			= '1996-02-06',
	@p_tipo_doc				= 'DNI',
	@p_num_doc				= 30152136, --No debería ser BIGINT?
	@p_sexo					= 'Masculino',
	@p_genero				= 'Masculino',
	@p_nacionalidad			= 'Brasil',
	@p_mail					= 'zarrateajose@gmail.com',
	@p_tel_fijo				= '04008956',
	@p_tel_alt				= '1148199526',
	@p_tel_laboral			= '16162320',
	@p_id_identity			= NULL
go
Select * from gestion_paciente.Paciente where id = 3
go

-- Sin Tel laboral
EXEC gestion_paciente.InsertarPaciente
	@p_id					= 1,
	@p_nombre				= 'Laura',
	@p_apellido				= 'López',
	@p_apellido_materno		= 'Ramirez',
	@p_fecha_nac			= '1995-08-03',
	@p_tipo_doc				= 'DNI',
	@p_num_doc				= 49560012,
	@p_sexo					= 'Femenino',
	@p_genero				= 'Femenino',
	@p_nacionalidad			= 'Argentina',
	@p_mail					= 'ramirezlauraestela@gmail.com',
	@p_tel_fijo				= '04001616',
	@p_tel_alt				= '1123354626',
--	@p_tel_laboral			= '19162320',
	@p_id_identity			= NULL
go
Select * from gestion_paciente.Paciente where id = 1
go

-- Sin Tel alt
EXEC gestion_paciente.InsertarPaciente
	@p_id					= 2,
	@p_nombre				= 'Ezequiel',
	@p_apellido				= 'Báez',
	@p_apellido_materno		= 'Peña',
	@p_fecha_nac			= '1996-01-15',
	@p_tipo_doc				= 'DNI',
	@p_num_doc				= 32692136,
	@p_sexo					= 'Masculino',
	@p_genero				= 'Masculino',
	@p_nacionalidad			= 'Perú',
	@p_mail					= 'baezezequiel52@gmail.com',
	@p_tel_fijo				= '04007987',
--	@p_tel_alt				= '1123562160',
	@p_tel_laboral			= '44789960',
	@p_id_identity			= NULL
go
Select * from gestion_paciente.Paciente where id = 2
go

-- Sin apellido materno
EXEC gestion_paciente.InsertarPaciente
	@p_id					= 5,
	@p_nombre				= 'Santiago',
	@p_apellido				= 'Vallesteros',
	@p_apellido_materno		= '',
	@p_fecha_nac			= '1997-05-20',
	@p_tipo_doc				= 'DNI',
	@p_num_doc				= 30152136,
	@p_sexo					= 'Masculino',
	@p_genero				= 'Masculino',
	@p_nacionalidad			= 'Guyana',
	@p_mail					= 'vallesterosChampion@gmail.com',
	@p_tel_fijo				= '08006644',
	@p_tel_alt				= '1165601222',
	@p_tel_laboral			= '16162320',
	@p_id_identity			= NULL
go
Select * from gestion_paciente.Paciente where id = 5
go

-- Paciente existe (cambia tel fijo)
EXEC gestion_paciente.InsertarPaciente
	@p_id					= 3,
	@p_nombre				= 'José',
	@p_apellido				= 'Ibarola',
	@p_apellido_materno		= 'Zarratea',
	@p_fecha_nac			= '1996-02-06',
	@p_tipo_doc				= 'DNI',
	@p_num_doc				= 30152136,
	@p_sexo					= 'Masculino',
	@p_genero				= 'Masculino',
	@p_nacionalidad			= 'Brasil',
	@p_mail					= 'zarrateajose@gmail.com',
	@p_tel_fijo				= '04005020',
	@p_tel_alt				= '1148199526',
	@p_tel_laboral			= '16162320'
go
Select * from gestion_paciente.Paciente where id = 3
go

-- DATOS INVALIDOS

-- Nombre inválido
EXEC gestion_paciente.InsertarPaciente
	@p_id					= 4,
	@p_nombre				= 'Evel45896',
	@p_apellido				= 'Benítez',
	@p_apellido_materno		= 'Heredia',
	@p_fecha_nac			= '1996-09-25',
	@p_tipo_doc				= 'DNI',
	@p_num_doc				= 41235656,
	@p_sexo					= 'Femenino',
	@p_genero				= 'Femenino',
	@p_nacionalidad			= 'Colombia',
	@p_mail					= 'benitezEve@gmail.com',
	@p_tel_fijo				= '08004455',
	@p_tel_alt				= '1139605959',
	@p_tel_laboral			= '40708520',
	@p_id_identity			= NULL
go
Select * from gestion_paciente.Paciente where id = 4
go

-- Apellido inválido
EXEC gestion_paciente.InsertarPaciente
	@p_id					= 4,
	@p_nombre				= 'Evelin',
	@p_apellido				= 'Benítez4444',
	@p_apellido_materno		= 'Heredia',
	@p_fecha_nac			= '1996-09-25',
	@p_tipo_doc				= 'DNI',
	@p_num_doc				= 41235656,
	@p_sexo					= 'Femenino',
	@p_genero				= 'Femenino',
	@p_nacionalidad			= 'Colombia',
	@p_mail					= 'benitezEve@gmail.com',
	@p_tel_fijo				= '08004455',
	@p_tel_alt				= '1139605959',
	@p_tel_laboral			= '40708520',
	@p_id_identity			= NULL
go
Select * from gestion_paciente.Paciente where id = 4
go

-- Apellido materno inaválido
EXEC gestion_paciente.InsertarPaciente
	@p_id					= 4,
	@p_nombre				= 'Evelin',
	@p_apellido				= 'Benítez',
	@p_apellido_materno		= 'Here999dia',
	@p_fecha_nac			= '1996-09-25',
	@p_tipo_doc				= 'DNI',
	@p_num_doc				= 41235656,
	@p_sexo					= 'Femenino',
	@p_genero				= 'Femenino',
	@p_nacionalidad			= 'Colombia',
	@p_mail					= 'benitezEve@gmail.com',
	@p_tel_fijo				= '08004455',
	@p_tel_alt				= '1139605959',
	@p_tel_laboral			= '40708520',
	@p_id_identity			= NULL
go
Select * from gestion_paciente.Paciente where id = 4
go

-- Tipo doc inválido
EXEC gestion_paciente.InsertarPaciente
	@p_id					= 4,
	@p_nombre				= 'Evelin',
	@p_apellido				= 'Benítez',
	@p_apellido_materno		= 'Heredia',
	@p_fecha_nac			= '1996-09-25',
	@p_tipo_doc				= 'DN45898I',
	@p_num_doc				= 41235656,
	@p_sexo					= 'Femenino',
	@p_genero				= 'Femenino',
	@p_nacionalidad			= 'Colombia',
	@p_mail					= 'benitezEve@gmail.com',
	@p_tel_fijo				= '08004455',
	@p_tel_alt				= '1139605959',
	@p_tel_laboral			= '40708520',
	@p_id_identity			= NULL
go
Select * from gestion_paciente.Paciente where id = 4
go


-- Sexo inválido
EXEC gestion_paciente.InsertarPaciente
	@p_id					= 4,
	@p_nombre				= 'Evelin',
	@p_apellido				= 'Benítez',
	@p_apellido_materno		= 'Heredia',
	@p_fecha_nac			= '1996-09-25',
	@p_tipo_doc				= 'DNI',
	@p_num_doc				= 41235656,
	@p_sexo					= 'F49595nino',
	@p_genero				= 'Femenino',
	@p_nacionalidad			= 'Colombia',
	@p_mail					= 'benitezEve@gmail.com',
	@p_tel_fijo				= '08004455',
	@p_tel_alt				= '1139605959',
	@p_tel_laboral			= '40708520',
	@p_id_identity			= NULL
go
Select * from gestion_paciente.Paciente where id = 4
go

-- Genero inválido
EXEC gestion_paciente.InsertarPaciente
	@p_id					= 4,
	@p_nombre				= 'Evelin',
	@p_apellido				= 'Benítez',
	@p_apellido_materno		= 'Heredia',
	@p_fecha_nac			= '1996-09-25',
	@p_tipo_doc				= 'DNI',
	@p_num_doc				= 41235656,
	@p_sexo					= 'Femenino',
	@p_genero				= 'FEM49852',
	@p_nacionalidad			= 'Colombia',
	@p_mail					= 'benitezEve@gmail.com',
	@p_tel_fijo				= '08004455',
	@p_tel_alt				= '1139605959',
	@p_tel_laboral			= '40708520',
	@p_id_identity			= NULL
go
Select * from gestion_paciente.Paciente where id = 4
go

-- Nacionalidad inválida
EXEC gestion_paciente.InsertarPaciente
	@p_id					= 4,
	@p_nombre				= 'Evelin',
	@p_apellido				= 'Benítez',
	@p_apellido_materno		= 'Heredia',
	@p_fecha_nac			= '1996-09-25',
	@p_tipo_doc				= 'DNI',
	@p_num_doc				= 41235656,
	@p_sexo					= 'Femenino',
	@p_genero				= 'Femenino',
	@p_nacionalidad			= 'Colombia49',
	@p_mail					= 'benitezEve@gmail.com',
	@p_tel_fijo				= '08004455',
	@p_tel_alt				= '1139605959',
	@p_tel_laboral			= '40708520',
	@p_id_identity			= NULL
go
Select * from gestion_paciente.Paciente where id = 4
go

-- Ingreso correcto de Evelin
EXEC gestion_paciente.InsertarPaciente
	@p_id					= 4,
	@p_nombre				= 'Evelin',
	@p_apellido				= 'Benítez',
	@p_apellido_materno		= 'Heredia',
	@p_fecha_nac			= '1996-09-25',
	@p_tipo_doc				= 'DNI',
	@p_num_doc				= 41235656,
	@p_sexo					= 'Femenino',
	@p_genero				= 'Femenino',
	@p_nacionalidad			= 'Colombia',
	@p_mail					= 'benitezEve@gmail.com',
	@p_tel_fijo				= '08004455',
	@p_tel_alt				= '1139605959',
	@p_tel_laboral			= '40708520',
	@p_id_identity			= NULL
go
Select * from gestion_paciente.Paciente where id = 4
go

-- Mail inválido (falta @)
EXEC gestion_paciente.InsertarPaciente
	@p_id					= 6,
	@p_nombre				= 'Ignacio',
	@p_apellido				= 'Francisco',
	@p_apellido_materno		= 'Paz',
	@p_fecha_nac			= '2000-05-25',
	@p_tipo_doc				= 'DNI',
	@p_num_doc				= 46945212,
	@p_sexo					= 'Masculino',
	@p_genero				= 'Masculino',
	@p_nacionalidad			= 'Chile',
	@p_mail					= 'ignacio48.gmail.com',
	@p_tel_fijo				= '08004455',
	@p_tel_alt				= '1139605959',
	@p_tel_laboral			= '40708520',
	@p_id_identity			= NULL
go
Select * from gestion_paciente.Paciente where id = 6
go

-- Mail inválido (falta .)
EXEC gestion_paciente.InsertarPaciente
	@p_id					= 6,
	@p_nombre				= 'Ignacio',
	@p_apellido				= 'Francisco',
	@p_apellido_materno		= 'Paz',
	@p_fecha_nac			= '2000-05-25',
	@p_tipo_doc				= 'DNI',
	@p_num_doc				= 4694521220,
	@p_sexo					= 'Masculino',
	@p_genero				= 'Masculino',
	@p_nacionalidad			= 'Chile',
	@p_mail					= 'ignacio48@gmailCom',
	@p_tel_fijo				= '08004455',
	@p_tel_alt				= '1139605959',
	@p_tel_laboral			= '40708520',
	@p_id_identity			= NULL
go
Select * from gestion_paciente.Paciente where id = 6
go

-- Tel fijo inválido
EXEC gestion_paciente.InsertarPaciente
	@p_id					= 6,
	@p_nombre				= 'Ignacio',
	@p_apellido				= 'Francisco',
	@p_apellido_materno		= 'Paz',
	@p_fecha_nac			= '2000-05-25',
	@p_tipo_doc				= 'DNI',
	@p_num_doc				= 4694521220,
	@p_sexo					= 'Masculino',
	@p_genero				= 'Masculino',
	@p_nacionalidad			= 'Chile',
	@p_mail					= 'ignacio48.gmail.com',
	@p_tel_fijo				= '0800aca4455',
	@p_tel_alt				= '1139605959',
	@p_tel_laboral			= '40708520',
	@p_id_identity			= NULL
go
Select * from gestion_paciente.Paciente where id = 6
go

-- Tel alternativo inválido
EXEC gestion_paciente.InsertarPaciente
	@p_id					= 6,
	@p_nombre				= 'Ignacio',
	@p_apellido				= 'Francisco',
	@p_apellido_materno		= 'Paz',
	@p_fecha_nac			= '2000-05-25',
	@p_tipo_doc				= 'DNI',
	@p_num_doc				= 4694521220,
	@p_sexo					= 'Masculino',
	@p_genero				= 'Masculino',
	@p_nacionalidad			= 'Chile',
	@p_mail					= 'ignacio48@gmail.com',
	@p_tel_fijo				= '08004455',
	@p_tel_alt				= 'GUI05959',
	@p_tel_laboral			= '40708520',
	@p_id_identity			= NULL
go
Select * from gestion_paciente.Paciente where id = 6
go

-- Tel laboral inválido
EXEC gestion_paciente.InsertarPaciente
	@p_id					= 6,
	@p_nombre				= 'Ignacio',
	@p_apellido				= 'Francisco',
	@p_apellido_materno		= 'Paz',
	@p_fecha_nac			= '2000-05-25',
	@p_tipo_doc				= 'DNI',
	@p_num_doc				= 4694521220,
	@p_sexo					= 'Masculino',
	@p_genero				= 'Masculino',
	@p_nacionalidad			= 'Chile',
	@p_mail					= 'ignacio48@gmail.com',
	@p_tel_fijo				= '08004455',
	@p_tel_alt				= '1139605959',
	@p_tel_laboral			= '407CISCO',
	@p_id_identity			= NULL
go
Select * from gestion_paciente.Paciente where id = 6
go

-- Ingreso correcto de Ignacio
EXEC gestion_paciente.InsertarPaciente
	@p_id					= 6,
	@p_nombre				= 'Ignacio',
	@p_apellido				= 'Francisco',
	@p_apellido_materno		= 'Paz',
	@p_fecha_nac			= '2000-05-25',
	@p_tipo_doc				= 'DNI',
	@p_num_doc				= 4694521220,
	@p_sexo					= 'Masculino',
	@p_genero				= 'Masculino',
	@p_nacionalidad			= 'Chile',
	@p_mail					= 'ignacio48@gmail.com',
	@p_tel_fijo				= '08004455',
	@p_tel_alt				= '1139605959',
	@p_tel_laboral			= '40708520',
	@p_id_identity			= NULL
go
Select * from gestion_paciente.Paciente where id = 6
go

Select * from gestion_paciente.Paciente
go

-- ====================== LOTE USUARIO ======================

-- gestion_paciente.InsertarUsuario @p_id,	@p_id_paciente,	@p_contrasena

EXEC gestion_paciente.InsertarUsuario 20, 1, 'LauraLopezRamirez87'
go
Select * from gestion_paciente.Usuario where id = 20
go

-- Usuario ya existe
EXEC gestion_paciente.InsertarUsuario 20, 1, 'LauraLopezRamirez87'
go
-- Paciente NO existe
EXEC gestion_paciente.InsertarUsuario 20, 15, 'LauraLopezRamirez87'
go
-- Contraseña excede el largo maximo VARCHAR(30) SEGURO NO LO DETECTA
EXEC gestion_paciente.InsertarUsuario 21, 2, 'EzequielBaezPenia5ezequielBaezPenia'
go

Select * from gestion_paciente.Usuario
go

-- ====================== LOTE DOMICILIO ======================

/* gestion_paciente.InsertarDomicilio
    @p_id			INT		=	NULL,
    @p_id_paciente	INT,
    @p_calle		VARCHAR(30),
    @p_numero		INT,
    @p_piso			INT		=	NULL,
    @p_departamento INT		=	NULL,
    @p_cod_postal	INT		=	NULL,
    @p_pais			VARCHAR(30),
    @p_provincia	VARCHAR(30),
    @p_localidad	VARCHAR(50)
*/

-- Con todos los campos
EXEC gestion_paciente.InsertarDomicilio 800, 1, 'Yerua', 4300, 2, 50, 1766, 'Argentina', 'Buenos Aires', 'La Tablada'
go
Select * from gestion_paciente.Domicilio where id = 800
go
-- Sin piso ni departamento
EXEC gestion_paciente.InsertarDomicilio
	@p_id = 801,
	@p_id_paciente = 5,
	@p_calle = 'Gascón', @p_numero = 1260,
	@p_cod_postal = 1766,
	@p_pais = 'Argentina', @p_provincia = 'Buenos Aires', @p_localidad = 'La Tablada'
go
Select * from gestion_paciente.Domicilio where id = 800
go
-- En el departamento está su casa
EXEC gestion_paciente.InsertarDomicilio
	@p_id = 802,
	@p_id_paciente = 3,
	@p_calle = 'Perdriel', @p_numero = 6422,
	@p_departamento = 346,
	@p_cod_postal = 1766,
	@p_pais = 'Argentina', @p_provincia = 'Buenos Aires', @p_localidad = 'La Tablada'
go
Select * from gestion_paciente.Domicilio where id = 800
go
-- Sin codigo postal
EXEC gestion_paciente.InsertarDomicilio
	@p_id = 803,
	@p_id_paciente = 4,
	@p_calle = 'Altolaguirre', @p_numero = 4300,
	@p_piso = 8, @p_departamento = 29,
	@p_pais = 'Argentina', @p_provincia = 'Buenos Aires', @p_localidad = 'Tapiales'
go
Select * from gestion_paciente.Domicilio where id = 803
go

-- ID Domicilio ya existe
EXEC gestion_paciente.InsertarDomicilio 800, 2, 'Ignacio Arieta', 3000, 2, 50, 1754, 'Argentina', 'Buenos Aires', 'San Justo'
go
Select * from gestion_paciente.Usuario where id = 800
go
-- Paciente NO existe
EXEC gestion_paciente.InsertarDomicilio 899, 44, 'Ignacio Arieta', 3000, 2, 50, 1754, 'Argentina', 'Buenos Aires', 'San Justo'
go
Select * from gestion_paciente.Usuario where id = 899
go
Select * from gestion_paciente.Paciente where id = 44
go
-- Calle excedio su largo de 30
EXEC gestion_paciente.InsertarDomicilio 900, 2, 'Ignacio Arieta Yrigoyen y Mendoza', 3000, 2, 50, 1754, 'Argentina', 'Buenos Aires', 'San Justo'
go
-- Localidad excedio su largo de 50
EXEC gestion_paciente.InsertarDomicilio 901, 6, 'Zepeda', 6900, 2, 50, 1754, 'Argentina', 'Buenos Aires',
									'Villa Luzuriaga de Almafuerte y Nuestra señora de Luján y el Sagrado Corazón'
go
-- Pais invalido
EXEC gestion_paciente.InsertarDomicilio 902, 6, 'Zepeda', 6900, 2, 50, 1754, 'Argentina485', 'Buenos Aires', 'Villa Luzuriaga'
go
-- Provincia invalida
EXEC gestion_paciente.InsertarDomicilio 903, 4, 'Almafuerte', 4200, 2, 50, 7118, 'Argentina', 'Buenos Aires74', 'San Justo'
go

Select * from gestion_paciente.Domicilio
go

-- ====================== LOTE SEDE ======================

-- Direccion excedio
EXEC gestion_sede.insertarSede 
	@p_nombre = 'Avellaneda', 
	@p_direccion = 'Av. San Salvador de los Andalos 1248132123123123', 
	@p_localidad = 'Avellaneda', 
	@p_provincia = 'Buenos Aires'

-- Localidad excedio
EXEC gestion_sede.insertarSede 
	@p_nombre = 'Once', 
	@p_direccion = 'Mitre 1233', 
	@p_localidad = 'Teniente Primero Juan Jose -San Martin1123123123', 
	@p_provincia = 'Buenos Aires'

-- Provincia invalida
EXEC gestion_sede.insertarSede 
	@p_nombre = 'Avellaneda', 
	@p_direccion = 'Av. Mitre 749', 
	@p_localidad = 'Avellaneda', 
	@p_provincia = 'Bu3nos A1res'


-- ====================== LOTE ESPECIALIDAD ======================

-- Nombre excedido
EXEC gestion_sede.insertarEspecialidad 
	@p_nombre = 'Otorrinonaringologo infantoadolescente'
	
-- Nombre invalido
EXEC gestion_sede.insertarEspecialidad 
	@p_nombre = 'Medico famili44r'

-- ====================== LOTE MEDICO ======================

-- Apellido invalido
EXEC gestion_sede.insertarMedico 
	@p_apellido = 'Dr. 9', 
	@p_nombre = 'Paula', 
	@p_matricula = 119925,
	@p_id_especialidad = 1

-- Apellido excedido
EXEC gestion_sede.insertarMedico 
	@p_apellido = 'Dr. De La Rosa Villalba Fernandez123123123', 
	@p_nombre = 'Paula', 
	@p_matricula = 119925, 
	@p_id_especialidad = 1

-- Nombre invalido
EXEC gestion_sede.insertarMedico 
	@p_apellido = 'Dr. Zapaton',
	@p_nombre = 't41', 
	@p_matricula = 119955, 
	@p_id_especialidad = 1

-- Nombre excedido
EXEC gestion_sede.insertarMedico 
	@p_apellido = 'Dr. Hibbert', 
	@p_nombre = 'Ignacio Nicolas Augustino Segundo5',
	@p_matricula = 119943, 
	@p_id_especialidad = 1

-- Especialidad inexistente
EXEC gestion_sede.insertarMedico 
	@p_apellido = 'Dr Riviera', 
	@p_nombre = 'Nick', 
	@p_matricula = 184968, 
	@p_id_especialidad = 6

