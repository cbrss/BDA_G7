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

--- CREACION DE PROCEDIMIENTOS DE IMPORTACION

-- IMPORTAR PACIENTE

CREATE OR ALTER PROCEDURE gestion_paciente.ImportarPacientes
	@p_ruta				VARCHAR(max)
AS
BEGIN
	set nocount on
	CREATE TABLE #Csv (
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
		provincia		VARCHAR(50),
	)
	CREATE TABLE #Domicilio(
		calle		VARCHAR(30),
		numero		INT,
		provincia	VARCHAR(30),
		localidad	VARCHAR(50)
	)

	DECLARE @consulta_sql NVARCHAR(max) = 'BULK INSERT #Csv 
											FROM ''' + @p_ruta + ''' 
											WITH (
												FIELDTERMINATOR = '';'',
												ROWTERMINATOR = ''\n'',
												CODEPAGE = ''65001'',
												FIRSTROW = 2
											);'
	EXEC sp_executesql @consulta_sql
	
	INSERT INTO #Domicilio (calle, numero, provincia, localidad)
	SELECT p.calle, p.numero, c.provincia, c.localidad
	FROM #Csv c
	CROSS APPLY gestion_paciente.ParsearDomicilio(c.calle_y_nro) p

	--INSERT INTO gestion_paciente.Domicilio( calle, numero)

	--SET @apellido_materno = gestion_paciente.LimpiarApellidoMaterno (@apellido)
	
END
GO

-- para testear:
/*

delete from gestion_paciente.Domicilio
delete from gestion_paciente.Paciente
DECLARE @p_ruta VARCHAR(max) = 'C:\Users\Cristian B\Desktop\Datasets---Informacion-necesaria\Dataset\Pacientes.csv'; 

EXEC gestion_paciente.ImportarPacientes 
		@p_ruta = @p_ruta
GO

SELECT * from gestion_paciente.Paciente
SELECT * from gestion_paciente.Domicilio

*/

-- IMPORTAR PRESTADOR

CREATE OR ALTER PROCEDURE gestion_paciente.ImportarPrestadores
	@p_ruta		VARCHAR(max)
AS
BEGIN
	set nocount on
	CREATE TABLE #csv_TT (
		nombre			VARCHAR(30),
		[plan]			VARCHAR(30),
		basura			CHAR(1)
	)
	DECLARE @consulta_sql VARCHAR(max) = 'BULK INSERT #csv_TT 
											FROM ''' + @p_ruta + ''' 
											WITH (
												FIELDTERMINATOR = '';'',
												ROWTERMINATOR = ''\n'',
												CODEPAGE = ''65001'',
												FIRSTROW = 2
											);'
	EXEC sp_executesql @consulta_sql

	DECLARE 
		@nombre VARCHAR(30),
		@plan	VARCHAR(30)

	DECLARE cursor_prestadores CURSOR FOR 
    SELECT nombre, [plan]
    FROM #csv_TT;

	OPEN cursor_prestadores

	FETCH NEXT FROM cursor_prestadores INTO @nombre, @plan;

	WHILE @@FETCH_STATUS = 0	
	BEGIN
		
		EXEC gestion_paciente.InsertarPrestador
			@p_nombre		= @nombre,
			@p_plan			= @plan
			
	
		FETCH NEXT FROM cursor_prestadores INTO @nombre, @plan;
	END
	CLOSE cursor_prestadores
	DEALLOCATE cursor_prestadores	
	
END
GO
-- para testear:
/*
DECLARE @p_ruta VARCHAR(max) = 'C:\Users\Cristian B\Desktop\Datasets---Informacion-necesaria\Dataset\Prestador.csv'; 

EXEC gestion_paciente.ImportarPrestadores 
		@p_ruta = @p_ruta
GO

select * from gestion_paciente.Prestador
*/

--IMPORTAR SEDE

CREATE OR ALTER PROCEDURE gestion_sede.ImportarSede
	@p_ruta		VARCHAR(max)
AS
BEGIN
	set nocount on
	CREATE TABLE #csv_TT (
	    nombre		VARCHAR(30),
	    direccion	VARCHAR(30),
		localidad	VARCHAR(30),
		provincia	VARCHAR(30)
	)
	DECLARE @consulta_sql VARCHAR(max) = 'BULK INSERT #csv_TT 
											FROM ''' + @p_ruta + ''' 
											WITH (
												FIELDTERMINATOR = '';'',
												ROWTERMINATOR = ''\n'',
												CODEPAGE = ''65001'',
												FIRSTROW = 2
											);'
	EXEC sp_executesql @consulta_sql

	DECLARE 
		@nombre		VARCHAR(30),
		@direccion	VARCHAR(30),
		@localidad	VARCHAR(30),
		@provincia	VARCHAR(30)

	DECLARE cursor_sedes CURSOR FOR 
    SELECT nombre, direccion, localidad, provincia
    FROM #csv_TT;

	OPEN cursor_sedes

	FETCH NEXT FROM cursor_sedes INTO @nombre, @direccion, @localidad, @provincia;

	WHILE @@FETCH_STATUS = 0	
	BEGIN
		
		EXEC gestion_sede.InsertarSede
			@p_nombre		= @nombre,
			@p_direccion	= @direccion,
			@p_localidad	= @localidad,
			@p_provincia	= @provincia

			
		FETCH NEXT FROM cursor_sedes INTO @nombre, @direccion, @localidad, @provincia;
	END
	CLOSE cursor_sedes
	DEALLOCATE cursor_sedes	
	
END
GO

/*
-- para testear

EXEC gestion_sede.ImportarSede
	@p_ruta = 'C:\Users\Cristian B\Desktop\Datasets---Informacion-necesaria\Dataset\Sedes.csv'

select * from gestion_sede.Sede
*/


--IMPORTAR MEDICO

CREATE OR ALTER PROCEDURE gestion_sede.ImportarMedico
	@p_ruta		VARCHAR(max)
AS
BEGIN
	set nocount on
	CREATE TABLE #csv_TT (
	    apellido		VARCHAR(30),
		nombre			VARCHAR(30),
		especialidad	VARCHAR(20),
		matricula		INT

	)
	DECLARE @consulta_sql VARCHAR(max) = 'BULK INSERT #csv_TT 
											FROM ''' + @p_ruta + ''' 
											WITH (
												FIELDTERMINATOR = '';'',
												ROWTERMINATOR = ''\n'',
												CODEPAGE = ''65001'',
												FIRSTROW = 2
											);'
	EXEC sp_executesql @consulta_sql

	DECLARE 
		@apellido			VARCHAR(30),
		@nombre				VARCHAR(30),
		@especialidad		VARCHAR(30),
		@matricula			INT,
		@id_especialidad	INT


	DECLARE cursor_medicos CURSOR FOR 
    SELECT nombre, apellido, especialidad, matricula
    FROM #csv_TT;

	OPEN cursor_medicos

	FETCH NEXT FROM cursor_medicos INTO @nombre, @apellido, @especialidad, @matricula

	WHILE @@FETCH_STATUS = 0	
	BEGIN
		

		EXEC gestion_sede.InsertarEspecialidad
			@p_nombre = @especialidad

		SELECT @id_especialidad = id FROM gestion_sede.Especialidad WHERE nombre = @especialidad

		SET @apellido = gestion_sede.LimpiarApellidoMedico(@apellido)

		EXEC gestion_sede.InsertarMedico
			@p_nombre		= @nombre,
			@p_apellido		= @apellido,
			@p_matricula	= @matricula,
			@p_id_especialidad	= @id_especialidad

		FETCH NEXT FROM cursor_medicos INTO @nombre, @apellido, @especialidad, @matricula;
	END
	CLOSE cursor_medicos
	DEALLOCATE cursor_medicos	
	
END
GO

/*
-- para testear

EXEC gestion_sede.ImportarMedico
	@p_ruta = 'C:\Users\Cristian B\Desktop\Datasets---Informacion-necesaria\Dataset\Medicos.csv'

	select * from gestion_sede.Especialidad
	select * from gestion_sede.Medico

	delete from gestion_sede.Especialidad
	delete from gestion_sede.Medico

	
*/