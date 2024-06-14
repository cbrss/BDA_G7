/*
		BASE DE DATOS APLICADA
		GRUPO: 07
		COMISION: 5600
		INTEGRANTES:
			Cristian Raul Berrios Lima		42875289
			Lautaro Da silva				42816815
			Abigail Karina Pe�afiel Huayta	41913506

		FECHA DE ENTREGA: 14/6/2024
*/



/*
	Los turnos para atenci�n m�dica tienen como estado inicial disponible, seg�n el m�dico, la 
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
