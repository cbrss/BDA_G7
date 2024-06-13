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
CREATE OR ALTER PROCEDURE gestion_turno.InsertarEstado
	@p_id		INT,
	@p_nombre	VARCHAR(11)
AS
BEGIN
	IF NOT EXISTS (
		SELECT 'a'
		FROM gestion_turno.Estado
		WHERE id = @p_id AND nombre = @p_nombre
	)
	INSERT INTO gestion_turno.Estado(id, nombre) VALUES (@p_id, @p_nombre);
END

CREATE OR ALTER PROCEDURE gestion_turno.EliminarEstado
	@p_id		INT
AS
BEGIN
	IF EXISTS (
		SELECT 'a'
		FROM gestion_turno.Estado
		WHERE id = @p_id
	)
	DELETE gestion_turno.Estado
	WHERE id = @p_id
END

-- CREACION DE SP Tipo de turno

CREATE OR ALTER PROCEDURE gestion_turno.InsertarTipoTurno
	@p_id		INT,
	@p_nombre	VARCHAR(20)
AS
BEGIN
	IF NOT EXISTS (
		SELECT 'a'
		FROM gestion_turno.Tipo
		WHERE id = @p_id AND nombre = @p_nombre
	)
	INSERT INTO gestion_turno.Tipo(id, nombre) VALUES (@p_id, @p_nombre);
END

CREATE OR ALTER PROCEDURE gestion_turno.EliminarTipoTurno
	@p_id		INT
AS
BEGIN
	IF EXISTS (
		SELECT 'a'
		FROM gestion_turno.Turno
		WHERE id = @p_id
	)
	DELETE gestion_turno.Turno
	WHERE id = @p_id
END

-- CREACION DE SP Turno

CREATE OR ALTER PROCEDURE gestion_turno.InsertarTurno
	@p_id						INT,
	@p_fecha					DATE,
	@p_hora						TIME,
	@p_id_paciente				INT,
	@p_id_medico				INT,
	@p_id_especialidad			INT,
	@p_id_direccion_atencion	INT,-- gestion_sede.Sede.direccion
	@p_id_tipo_turno			INT
AS
BEGIN
/*	IF NOT EXISTS ( -- No existe un Turno con ese ID
		SELECT 'a'
		FROM gestion_turno.Turno
		WHERE id = @p_id
	)
	AND EXISTS ( -- Existe el tipo_turno
		SELECT 'a'
		FROM gestion_turno.Tipo
		WHERE id = @p_id_tipo_turno
	)
	AND EXISTS ( -- Existe el Paciente
		SELECT 'a'
		FROM gestion_paciente.Paciente
		WHERE id = @p_id_paciente
	)
	AND EXISTS ( -- Hay un Medico con esa Especialidad
		SELECT 'a'
		FROM gestion_sede.Medico
		WHERE id = @p_id_medico AND id_especialidad = @p_id_especialidad	
	)
	AND EXISTS ( -- Medico trabaja en esa Sede
		SELECT 'a'
		FROM gestion_sede.DiasXSede JOIN gestion_sede.Sede
		ON id_sede = id
		WHERE id_medico = @p_id_medico AND id = @p_id_direccion_atencion
	)
	AND EXISTS ( -- Medico trabaja en ese dia por ese horario
			SELECT 'a'
			FROM gestion_sede.DiasXSede
			WHERE id_medico = @p_id_medico
				AND fecha = @p_fecha AND hora_inicio >= @p_hora
	)*/
	DECLARE @hayTurno BIT, @hayTipoTurno BIT, @hayPaciente BIT, @hayMedicoConEsaEsp BIT,
		@medicoTrabajaEnSede BIT, @medicoTrabajaEseDiaHora BIT
	SELECT
		@hayTurno = gestion_turno.existeTurno (@p_id),
		@hayTipoTurno = gestion_turno.existeTipoTurno (@p_id_tipo_turno),
		@hayPaciente = gestion_paciente.existeElPaciente (@p_id_paciente),
		@hayMedicoConEsaEsp = gestion_sede.hayMedicoConEsaEspecialidad (@p_id_medico, @p_id_especialidad),
		@medicoTrabajaEnSede = gestion_sede.medicoTrabajaEnSede (@p_id_medico, @p_id_direccion_atencion),
		@medicoTrabajaEseDiaHora = gestion_sede.medicoTrabajaEseDiaHora(@p_id_medico, @p_fecha, @p_hora)
	
	IF @hayTurno = 1 -- No existe el turno, existe...
		AND @hayTipoTurno = 0 AND @hayPaciente = 0 AND @hayMedicoConEsaEsp = 0
		AND @medicoTrabajaEnSede = 0 AND @medicoTrabajaEseDiaHora = 0
	BEGIN
		DECLARE @id_estado INT, @medicoReservado BIT
		SET @medicoReservado = gestion_sede.medicoDiaHorarioOcupado(@p_id_medico, @p_fecha, @p_hora)

		IF @medicoReservado = 1		-- No hay un Turno con ese Medico, fecha y hora
		BEGIN
			SET @id_estado = (
				SELECT id
				FROM gestion_turno.Estado
				WHERE nombre = 'Disponible'
			)
			INSERT INTO gestion_turno.Turno (
				id,
				fecha,
				hora,
				id_paciente,
				id_medico,
				id_especialidad,
				id_direccion_atencion,
				id_estado_turno,
				id_tipo_turno
			)		
			VALUES (
				@p_id,
				@p_fecha,
				@p_hora,
				@p_id_paciente,
				@p_id_medico,
				@p_id_especialidad,
				@p_id_direccion_atencion,
				@id_estado,
				@p_id_tipo_turno
			)
		END
	END
END

-- BORRADO LOGICO

CREATE OR ALTER PROCEDURE gestion_turno.eliminarTurno
	@p_id	INT
AS
BEGIN
	UPDATE gestion_turno.Turno
	SET borrado_logico = 1
	WHERE id = @p_id
END

-- MODIFICACION

CREATE OR ALTER gestion_turno.ModificarFechaHora
	@p_id		INT,
	@p_fecha	DATE,
	@p_hora		TIME,
	@p_id_medico	INT,
AS
BEGIN
	DECLARE @medicoReservado BIT
	SET @medicoReservado = gestion_sede.medicoDiaHorarioOcupado(@p_id_medico, @p_fecha, @p_hora)
	
	IF @medicoReservado = 1
		UPDATE gestion_turno.Turno
		SET fecha = @p_fecha, hora = @p_hora
		WHERE id = @p_id
END
