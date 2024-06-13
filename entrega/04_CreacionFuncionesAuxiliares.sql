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

CREATE OR ALTER Function gestion_turno.existeTurno (@p_id_turno int)
RETURNS BIT
BEGIN
	IF EXISTS (
		Select 'a'
		from gestion_turno.Turno
		where id = @p_id_turno
		)
		return 0
	ELSE
		return 1
END

CREATE OR ALTER Function gestion_turno.existeTipoTurno (@p_id_tipo_turno int)
RETURNS BIT
BEGIN
	IF EXISTS (
		Select 'a'
		from gestion_turno.Tipo
		where id = @p_id_tipo_turno
		)
		return 0
	ELSE
		return 1
END

CREATE OR ALTER Function gestion_paciente.existeElPaciente (@p_id_paciente int)
RETURNS BIT
BEGIN
	IF EXISTS (
		Select 'a'
		from gestion_paciente.Paciente
		where id = @p_id_paciente
		)
		return 0
	ELSE
		return 1
END

-- PARA ESTE NECESITO QUE Medico TENGA id_especialidad COMO ATRIVUTO, POR FAVOR !!!
CREATE OR ALTER Function gestion_sede.hayMedicoConEsaEspecialidad (@p_id_medico int, @p_id_especialidad int)
RETURNS BIT
BEGIN
	IF EXISTS ( -- Hay un Medico con esa Especialidad
		Select 'a'
		from gestion_sede.Medico
		where id = @p_id_medico and id_especialidad = @p_id_especialidad	
		)
		return 0
	ELSE
		return 1
END

CREATE OR ALTER Function gestion_sede.medicoTrabajaEnSede (@p_id_medico int, @p_id_sede int)
RETURNS BIT
BEGIN
	IF EXISTS ( -- Medico trabaja en esa Sede
		Select 'a'
		from gestion_sede.DiasXSede join gestion_sede.Sede on id_sede = id
		where id_medico = @p_id_medico and id = @p_id_sede
		)
		return 0
	ELSE
		return 1
END

CREATE OR ALTER Function gestion_sede.medicoTrabajaEseDiaHora(@p_id_medico int, @p_fecha date, @p_hora time)
RETURNS BIT
BEGIN
	IF EXISTS ( -- Medico trabaja en ese dia por ese horario
			Select 'a'
			from gestion_sede.DiasXSede
			where id_medico = @p_id_medico
				and fecha = @p_fecha and hora_inicio >= @p_hora
		)
		return 0
	ELSE
		return 1
END

CREATE OR ALTER Function gestion_sede.medicoDiaHorarioOcupado(@p_id_medico int, @p_fecha date, @p_hora time)
RETURNS BIT
BEGIN
	IF EXISTS (	-- Ya hay un Turno con ese Medico, fecha y hora
		Select 'a'
		from gestion_turno.Turno
		where id_medico = @p_id_medico
			and fecha = @p_fecha and hora = @p_hora
		)
		return 0
	ELSE
		return 1
END
