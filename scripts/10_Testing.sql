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
	Los turnos para atención médica tienen como estado inicial disponible, según el médico, la 
	especialidad y la sede.
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
VALUES (1000, 'testTi')


DECLARE @p_id INT = 10000;
DECLARE @p_fecha DATE = '2024-06-15';
DECLARE @p_hora TIME = '10:00:00';
DECLARE @p_id_paciente INT = @id_paciente; 
DECLARE @p_id_medico INT = @id_medico; 
DECLARE @p_id_especialidad INT = @id_especialidad; 
DECLARE @p_id_sede_atencion INT = @id_sede; 
DECLARE @p_id_tipo_turno INT = 1000; 

EXEC gestion_turno.InsertarReservaTurno
	@p_id = @p_id,
	@p_fecha = @p_fecha,
	@p_hora = @p_hora,
	@p_id_paciente = @p_id_paciente,
	@p_id_medico = @p_id_medico,
	@p_id_especialidad = @p_id_especialidad,
	@p_id_sede_atencion = @p_id_sede_atencion,
	@p_id_tipo_turno = @p_id_tipo_turno;

select * from gestion_turno.ReservaTurno

delete from gestion_turno.ReservaTurno where id = 10000
delete from gestion_paciente.Paciente where nombre = 'testPaciente'
delete from gestion_sede.Medico where nombre = 'testMedico'
delete from gestion_sede.Especialidad where nombre = 'testEspecialidad'
delete from gestion_sede.Sede where nombre = 'testSede'
delete from gestion_turno.EstadoTurno where id = 100 or id = 101
delete from gestion_turno.TipoTurno where id = 1000

/*
Los estudios clínicos deben ser autorizados, e indicar si se cubre el costo completo del mismo o solo 
un porcentaje. El sistema de Cure se comunica con el servicio de la prestadora, se le envía el código 
del estudio, el dni del paciente y el plan; el sistema de la prestadora informa si está autorizado o no y 
el importe a facturarle al paciente.
*/
EXEC gestion_paciente.AutorizarEstudio 
	@p_id_estudio		= 41365,
	@p_dni_paciente		= 4268398306,
	@p_plan_prestador	=  'Jovenes',	
	@p_ruta				= '../casos_de_prueba/lote_de_prueba_autorizar.json',	
	@p_respuesta		= '';

/*
Importaciones de los archivos, la ruta de los casos de prueba debe estar en la carpeta "lote_de_pruebas"
*/
EXEC gestion_paciente.ImportarPacientes
	@p_ruta	= '../casos_de_prueba/Pacientes.csv'

EXEC  gestion_paciente.ImportarPrestadores
	@p_ruta = '../casos_de_prueba/Prestador.csv'

EXEC gestion_sede.ImportarSede
	@p_ruta = '../casos_de_prueba/Sedes.csv'

EXEC gestion_sede.ImportarMedico
	@p_ruta = '../casos_de_prueba/Medicos.csv'


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
go -- Instrucción UPDATE en conflicto con la restricción FOREIGN KEY 'FK_tipoID'.
--	El conflicto ha aparecido en la base de datos 'Com5600G07', tabla 'gestion_turno.TipoTurno', column 'id'.

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
