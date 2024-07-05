/*
		BASE DE DATOS APLICADA
		GRUPO: 07
		COMISION: 5600
		INTEGRANTES:
			Cristian Raul Berrios Lima		42875289
			Lautaro Da silva				42816815
			Abigail Karina Peñafiel Huayta	41913506

		FECHA DE ENTREGA: 5/7/2024
*/


USE Com5600G07
GO

--- CREACION DE PROCEDIMIENTOS DE IMPORTACION

-- IMPORTAR PACIENTE Y DOMICILIO

CREATE OR ALTER PROCEDURE gestion_paciente.ImportarPacientes
	@p_ruta				VARCHAR(max)
AS
BEGIN
	set nocount on

	CREATE TABLE #CsvPaciente (
		nombre			VARCHAR(30),
		apellido		VARCHAR(30),
		fecha_nac		VARCHAR(10),
		tipo_doc		CHAR(5),
		nro_doc			INT,
		sexo			VARCHAR(11),
		genero			VARCHAR(9),
		telefono		VARCHAR(15),
		nacionalidad	VARCHAR(30),
		mail			VARCHAR(30),
		calle_y_nro		VARCHAR(50),
		localidad		VARCHAR(50),
		provincia		VARCHAR(50)
	)
	CREATE TABLE #CsvId (
		id_paciente		INT, 
		nro				INT IDENTITY(1,1)
	)
	BEGIN TRY
	DECLARE @consulta_sql NVARCHAR(max) = 'BULK INSERT #CsvPaciente 
											FROM ''' + @p_ruta + ''' 
											WITH (
												FIELDTERMINATOR = '';'',
												ROWTERMINATOR = ''\n'',
												CODEPAGE = ''65001'',
												FIRSTROW = 2
											);'
	EXEC sp_executesql @consulta_sql
	END TRY
	BEGIN CATCH
		IF ERROR_NUMBER() = 4861
			PRINT 'La ruta del archivo ingresado no existe'
	END CATCH
	ALTER TABLE #CsvPaciente ADD nro INT IDENTITY(1,1)

	--	IMPORTAR PACIENTE

	INSERT INTO gestion_paciente.Paciente(
					nombre, 
					apellido, 
					apellido_materno, 
					fecha_nac, 
					tipo_doc, 
					num_doc, 
					sexo, 
					genero, 
					nacionalidad, 
					tel_fijo, 
					mail, 
					fecha_actualizacion, 
					usr_actualizacion
				)
	OUTPUT INSERTED.ID INTO #CsvId
	SELECT C.nombre, 
		C.apellido, 
		gestion_paciente.LimpiarApellidoMaterno(c.apellido), 
		TRY_CONVERT(DATE, c.fecha_nac, 103), 
		C.tipo_doc, 
		C.nro_doc, 
		C.sexo, 
		C.genero, 
		C.nacionalidad, 
		C.telefono, 
		C.mail, 
		GETDATE(), 
		ORIGINAL_LOGIN()
	FROM #CsvPaciente C
	WHERE NOT EXISTS(
		SELECT 1 
		FROM gestion_paciente.Paciente P
		WHERE nombre			= c.nombre
			AND	apellido		= c.apellido
			AND tipo_doc		= c.tipo_doc
			AND num_doc			= c.nro_doc
			AND nacionalidad	= c.nacionalidad
	)

	-- IMPORTAR DOMICILIO
	
	INSERT INTO gestion_paciente.Domicilio(
					calle, 
					numero, 
					provincia, 
					localidad, 
					id_paciente
				)
	SELECT P.calle, 
		P.numero, 
		C.provincia, 
		C.localidad, 
		T.id_paciente
	FROM #CsvPaciente C
	CROSS APPLY gestion_paciente.ParsearDomicilio(c.calle_y_nro) P
	JOIN #CsvId T on T.nro = C.nro
	WHERE NOT EXISTS(
		SELECT 1
		FROM gestion_paciente.Domicilio D
		WHERE D.calle = P.calle
			AND	D.numero		= P.numero
			AND D.localidad		= C.localidad
			AND D.id_paciente	= T.id_paciente
	)
END
GO


-- IMPORTAR PRESTADOR

CREATE OR ALTER PROCEDURE gestion_paciente.ImportarPrestadores
	@p_ruta		VARCHAR(max)
AS
BEGIN
	set nocount on
	CREATE TABLE #CsvPrestador (
		nombre			VARCHAR(30),
		[plan]			VARCHAR(30),
		basura			VARCHAR(10)
	)
	DECLARE @consulta_sql NVARCHAR(max) = 'BULK INSERT #CsvPrestador 
											FROM ''' + @p_ruta + ''' 
											WITH (
												FIELDTERMINATOR = '';'',
												ROWTERMINATOR = ''\n'',
												CODEPAGE = ''65001'',
												FIRSTROW = 2
											);'
	EXEC sp_executesql @consulta_sql

	INSERT INTO gestion_paciente.Prestador(
					nombre, 
					[plan]
				)
	SELECT C.nombre, 
		C.[plan]
	FROM #CsvPrestador C
	WHERE NOT EXISTS(
		SELECT 1 
		FROM gestion_paciente.Prestador
		WHERE nombre			= C.nombre
			AND	[plan]			= C.[plan]
	)
END
GO


--IMPORTAR SEDE

CREATE OR ALTER PROCEDURE gestion_sede.ImportarSede
	@p_ruta		VARCHAR(max)
AS
BEGIN
	set nocount on
	CREATE TABLE #CsvSede (
	    nombre		VARCHAR(30),
	    direccion	VARCHAR(30),
		localidad	VARCHAR(30),
		provincia	VARCHAR(30)
	)
	DECLARE @consulta_sql NVARCHAR(max) = 'BULK INSERT #CsvSede 
											FROM ''' + @p_ruta + ''' 
											WITH (
												FIELDTERMINATOR = '';'',
												ROWTERMINATOR = ''\n'',
												CODEPAGE = ''65001'',
												FIRSTROW = 2
											);'
	EXEC sp_executesql @consulta_sql



	INSERT INTO gestion_sede.Sede(
					nombre, 
					direccion,
					localidad,
					provincia
				)
	SELECT C.nombre, 
		C.direccion,
		C.localidad,
		C.provincia
	FROM #CsvSede C
	WHERE NOT EXISTS(
		SELECT 1 
		FROM gestion_sede.Sede
		WHERE nombre			= C.nombre
			AND	direccion			= C.direccion
			AND	localidad			= C.localidad
			AND provincia			= C.provincia
	)
	
END
GO


--IMPORTAR MEDICO

CREATE OR ALTER PROCEDURE gestion_sede.ImportarMedico
	@p_ruta		VARCHAR(max)
AS
BEGIN
	set nocount on
	CREATE TABLE #CsvMedico (
	    apellido		VARCHAR(30),
		nombre			VARCHAR(30),
		especialidad	VARCHAR(30),
		matricula		INT

	)
	DECLARE @consulta_sql NVARCHAR(max) = 'BULK INSERT #CsvMedico 
											FROM ''' + @p_ruta + ''' 
											WITH (
												FIELDTERMINATOR = '';'',
												ROWTERMINATOR = ''\n'',
												CODEPAGE = ''65001'',
												FIRSTROW = 2
											);'
	EXEC sp_executesql @consulta_sql

	INSERT INTO gestion_sede.Especialidad(
					nombre
				)
	SELECT DISTINCT C.especialidad
	FROM #CsvMedico C
	WHERE NOT EXISTS(
		SELECT 1 
		FROM gestion_sede.Especialidad
		WHERE nombre = C.especialidad
	)

	INSERT INTO gestion_sede.Medico(
					nombre, 
					apellido,
					id_especialidad,
					matricula
				)
				
	SELECT C.nombre,
		gestion_sede.LimpiarApellidoMedico(C.apellido), 
		gestion_sede.BuscarIdEspecialidad(C.especialidad),
		C.matricula
	FROM #CsvMedico C
	WHERE NOT EXISTS(
		SELECT 1 
		FROM gestion_sede.Medico
		WHERE nombre			= C.nombre
			AND	apellido			= C.apellido
			AND	matricula			= C.matricula
	)
	
END
GO
