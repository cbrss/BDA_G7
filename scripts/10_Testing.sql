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
Select * from gestion_turno.EstadoTurno
go


