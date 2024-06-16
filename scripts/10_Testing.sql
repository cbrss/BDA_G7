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

EXEC gestion_turno.usp_InsertarReservaTurno
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
EXEC gestion_paciente.usp_AutorizarEstudio 
	@p_id_estudio		= 41365,
	@p_dni_paciente		= 4268398306,
	@p_plan_prestador	=  'Jovenes',	
	@p_ruta				= '../lote_de_pruebas/lote_de_prueba_autorizar.json',	
	@p_respuesta		= '';

/*
Importaciones de los archivos, la ruta de los casos de prueba debe estar en la carpeta "lote_de_pruebas"
*/
EXEC gestion_paciente.usp_ImportarPacientes
	@p_ruta	= '../lote_de_pruebas/lote_de_prueba_paciente.csv'

EXEC  gestion_paciente.usp_ImportarPrestadores
	@p_ruta = '../lote_de_pruebas/lote_de_prueba_prestador.csv'

EXEC gestion_sede.usp_ImportarSede
	@p_ruta = '../lote_de_pruebas/lote_de_prueba_sede.csv'

EXEC gestion_sede.usp_ImportarMedico
	@p_ruta = '../lote_de_pruebas/lote_de_prueba_medico.csv'


-- LOTE TIPO TURNO

EXEC gestion_turno.InsertarTipoTurno 10, 'Presencial';
go
EXEC gestion_turno.InsertarTipoTurno 11, 'Virtual';
go

-- id_tipo_turno ya existe
EXEC gestion_turno.InsertarTipoTurno 11, 'repetido';
go
-- tipo_turno ya existe
EXEC gestion_turno.InsertarTipoTurno 8, 'Presencial';
go

-- No debe haber otro tipo de turno
EXEC gestion_turno.InsertarTipoTurno 11, 'a distancia';
go
-- No debe haber numeros
EXEC gestion_turno.InsertarTipoTurno 11, 'asitencia45';
go

-- LOTE ESTADO TURNO

EXEC gestion_turno.InsertarEstadoTurno 1, 'Disponible';
go
EXEC gestion_turno.InsertarEstadoTurno 2, 'Cancelado';
go
EXEC gestion_turno.InsertarEstadoTurno 3, 'Ausente';
go
EXEC gestion_turno.InsertarEstadoTurno 4, 'Atendido';
go

-- id_estado ya existe
EXEC gestion_turno.InsertarEstadoTurno 3, 'espera';
go
-- estado ya existe
EXEC gestion_turno.InsertarEstadoTurno 8, 'Ausente';
go
-- No admite numeros
EXEC gestion_turno.InsertarEstadoTurno 7, '678ahu';
go


-- LOTE RESERVA TURNO

EXEC gestion_turno.InsertarReservaTurno 77, '2024-05-18', '9:45', 1500, 1, 11;
go
EXEC gestion_turno.InsertarReservaTurno 78, '2024-03-10', '20:15', 1556, 1, 10;
go
-- Cambia estado a Cancelado, podrá crearse otra con id 78
EXEC gestion_turno.ActualizarReservaTurno 78, NULL, NULL, NULL, 2, NULL;
go


EXEC gestion_turno.InsertarReservaTurno 80, '2024-03-02', '12:15', 2135, 1, 10;
go
EXEC gestion_turno.InsertarReservaTurno 80, '2024-04-06', '13:00', 4890, 3, 10;
go
-- Nueva reserva con fecha hora y estado del que se canceló
EXEC gestion_turno.InsertarReservaTurno 81, '2024-03-10', '20:15', 3440, 1, 10;
go


-- El paciente ya tiene turno en esa fecha y hora
EXEC gestion_turno.InsertarReservaTurno 82, '2024-03-02', '12:15', 2135, 1, 10;
go

-- id_sede (desde 100 en adelante)
-- id_medico (desde 500 hasta 599)
-- id_especialidad (600 en adelante)
-- id_paciente (desde 1500 hasta 5000)
	
-- El paciente no existe
EXEC gestion_turno.InsertarReservaTurno 83, '2024-03-02', '12:30', 1300, 1, 10;
go
-- id ya existe
EXEC gestion_turno.InsertarReservaTurno 78, '2024-03-06', '9:00', 1500, 1, 11;
go
-- id_estado no existe
EXEC gestion_turno.InsertarReservaTurno 84, '2024-03-06', '9:15', 1500, 5, 11;
go
-- id_tipo_turno no existe
EXEC gestion_turno.InsertarReservaTurno 85, '2024-03-06', '10:00', 1500, 1, 49;
go
-- fecha formato incorrecto?
EXEC gestion_turno.InsertarReservaTurno 86, '18-05-2024', '10:30', 1500, 1, 11;
go

