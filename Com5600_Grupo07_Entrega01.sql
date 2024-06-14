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

---- CREACION BASE DE DATOS

IF NOT EXISTS (
	SELECT 1
	FROM sys.databases
	WHERE name = 'Com5600G07'
)
BEGIN
	CREATE DATABASE Com5600G07
	COLLATE SQL_Latin1_General_CP1_CI_AS;
END
go

USE Com5600G07
GO
---- CREACION ESQUEMAS


IF NOT EXISTS (
	SELECT 1
	FROM sys.schemas
	WHERE name = 'gestion_paciente'
)
BEGIN
	EXEC ('create schema gestion_paciente');
END;
GO

IF NOT EXISTS (
	SELECT 1
	FROM sys.schemas
	WHERE name = 'gestion_turno'
)
BEGIN
	EXEC ('create schema gestion_turno');
END;
GO

IF NOT EXISTS (
	SELECT 1
	FROM sys.schemas
	WHERE name = 'gestion_sede'
)
BEGIN
	EXEC ('create schema gestion_sede');
END;
GO


--- CREACION DE TABLAS DEL ESQUEMA GESTION_PACIENTE

--	CREACION TABLA PACIENTE

IF NOT EXISTS (
    SELECT 1
    FROM sys.tables
    WHERE name = 'Paciente'
    AND schema_id = SCHEMA_ID('gestion_paciente')
)
BEGIN
    CREATE TABLE gestion_paciente.Paciente
	(
		id					INT IDENTITY(1,1),
		nombre				VARCHAR(30),
		apellido			VARCHAR(30),
		apellido_materno	VARCHAR(30),
		fecha_nac			DATE,
		tipo_doc			CHAR(5),
		num_doc				INT,
		sexo				VARCHAR(11),
		genero				VARCHAR(9),
		nacionalidad		VARCHAR(20),
		foto_perfil			VARCHAR(max),
		mail				VARCHAR(30),
		tel_fijo			VARCHAR(15),
		tel_alt				VARCHAR(15),
		tel_laboral			VARCHAR(15),
		fecha_registro		DATE,
		fecha_actualizacion	DATE,
		usr_actualizacion	VARCHAR(20),
		borrado_logico		BIT DEFAULT 0,

		CONSTRAINT Ck_PacientNomb		CHECK(PATINDEX('%[^A-Za-zÁÉÍÓÚáéíóú ]%', nombre) = 0),
		CONSTRAINT Ck_PacientApell		CHECK(PATINDEX('%[^A-Za-zÁÉÍÓÚáéíóú ]%', apellido) = 0),
		CONSTRAINT Ck_PacientApellMat	CHECK(PATINDEX('%[^A-Za-zÁÉÍÓÚáéíóú ]%', apellido_materno) = 0),
		CONSTRAINT Ck_PacientTipoDoc	CHECK(PATINDEX('%[^A-Za-zÁÉÍÓÚáéíóú ]%', tipo_doc) = 0),
		CONSTRAINT Ck_PacientSexo		CHECK(PATINDEX('%[^A-Za-zÁÉÍÓÚáéíóú ]%', sexo) = 0),
		CONSTRAINT Ck_PacientGenero		CHECK(PATINDEX('%[^A-Za-zÁÉÍÓÚáéíóú ]%', genero) = 0),
		CONSTRAINT Ck_PacientNacion		CHECK(PATINDEX('%[^A-Za-zÁÉÍÓÚáéíóú ]%', nacionalidad) = 0),
		CONSTRAINT PK_PacienteID PRIMARY KEY (id)
	);
END;
GO


-- CREACION TABLA ESTUDIO

IF NOT EXISTS (
    SELECT 1
    FROM sys.tables
    WHERE name = 'Estudio'
    AND schema_id = SCHEMA_ID('gestion_paciente')
)
BEGIN
    CREATE TABLE gestion_paciente.Estudio
	(
		id					INT,
		id_paciente			INT,
		fecha				DATE,
		nombre_estudio		VARCHAR(50),
		autorizado			BIT DEFAULT 0,
		doc_resultado		VARCHAR(max),
		img_resultado		VARCHAR(max),
		borrado_logico		BIT DEFAULT 0,

		CONSTRAINT PK_EstudioID PRIMARY KEY(id),
		CONSTRAINT FK_Estudio_PacienteID FOREIGN KEY(id_paciente) REFERENCES gestion_paciente.Paciente(id)
	);
END;
GO


-- CREACION TABLA USUARIO

IF NOT EXISTS (
    SELECT 1
    FROM sys.tables
    WHERE name = 'Usuario'
    AND schema_id = SCHEMA_ID('gestion_paciente')
)
BEGIN
    CREATE TABLE gestion_paciente.Usuario
	(
		id					INT,
		id_paciente			INT UNIQUE,
		contrasena			VARCHAR(30),
		fecha_creacion		DATE,

		CONSTRAINT PK_UsuarioID PRIMARY KEY(id),
		CONSTRAINT FK_Usuario_PacienteID FOREIGN KEY(id_paciente) REFERENCES gestion_paciente.Paciente(id)
	);
END;
GO

-- CREACION TABLA DOMICILIO

IF NOT EXISTS (
    SELECT 1
    FROM sys.tables
    WHERE name = 'Domicilio'
    AND schema_id = SCHEMA_ID('gestion_paciente')
)
BEGIN
    CREATE TABLE gestion_paciente.Domicilio
	(
		id					INT IDENTITY(1,1),
		id_paciente			INT	UNIQUE,
		calle				VARCHAR(30),
		numero				INT,
		piso				INT,
		departamento		INT,
		cod_postal			INT,
		pais				VARCHAR(30),
		provincia			VARCHAR(30),
		localidad			VARCHAR(30),
		
		CONSTRAINT Ck_DomicCalle CHECK(PATINDEX('%[^A-Za-zÁÉÍÓÚáéíóú ]%', calle) = 0),
		CONSTRAINT Ck_DomicPais CHECK(PATINDEX('%[^A-Za-zÁÉÍÓÚáéíóú ]%', pais) = 0),
		CONSTRAINT Ck_DomicProv CHECK(PATINDEX('%[^A-Za-zÁÉÍÓÚáéíóú ]%', provincia) = 0),
		CONSTRAINT Ck_DomicLocalidad CHECK(PATINDEX('%[^A-Za-zÁÉÍÓÚáéíóú ]%', localidad) = 0),
		CONSTRAINT PK_DomicilioID PRIMARY KEY (id),
		CONSTRAINT FK_Domicilio_PacienteID FOREIGN KEY (id_paciente) REFERENCES gestion_paciente.Paciente(id)
	);
END;
GO


-- CREACION TABLA COBERTURA

IF NOT EXISTS (
    SELECT 1
    FROM sys.tables
    WHERE name = 'Cobertura'
    AND schema_id = SCHEMA_ID('gestion_paciente')
)
BEGIN
    CREATE TABLE gestion_paciente.Cobertura
	(
		id					INT,
		id_paciente			INT	UNIQUE,
		imagen_credencial	VARCHAR(max),
		nro_socio			INT,
		fecha_registro		DATE,

		CONSTRAINT PK_CoberturaID PRIMARY KEY (id),
		CONSTRAINT FK_Cobertura_PacienteID FOREIGN KEY (id_paciente) REFERENCES gestion_paciente.Paciente(id)
	);
END;
GO


-- CREACION TABLA PRESTADOR

IF NOT EXISTS (
    SELECT 1
    FROM sys.tables
    WHERE name = 'Prestador'
    AND schema_id = SCHEMA_ID('gestion_paciente')
)
BEGIN
    CREATE TABLE gestion_paciente.Prestador
	(
		id					INT IDENTITY (1,1),
		id_cobertura		INT	UNIQUE,
		nombre				VARCHAR(30),
		[plan]				VARCHAR(30),

		CONSTRAINT Ck_Prestanomb CHECK(PATINDEX('%[^A-Za-zÁÉÍÓÚáéíóú ]%', nombre) = 0),
		CONSTRAINT PK_PrestadorID PRIMARY KEY (id),
		CONSTRAINT FK_Prestador_CoberturaID FOREIGN KEY (id_cobertura) REFERENCES gestion_paciente.Cobertura(id)
	);
END;
GO

--- CREACION TABLAS DE ESQUEMA GESTION_TURNO

-- CREACION TABLA ESTADO turno

IF NOT EXISTS (
    SELECT 1
    FROM sys.tables
    WHERE name = 'EstadoTurno'
    AND schema_id = SCHEMA_ID('gestion_turno')
)
BEGIN
	CREATE TABLE gestion_turno.EstadoTurno
	(
		id		INT,
		nombre	VARCHAR(11),-- Disponible, Atendido Ausente Cancelado

		CONSTRAINT Ck_EstadoTurnoNombre CHECK(PATINDEX('%[^A-Za-zÁÉÍÓÚáéíóú ]%', nombre) = 0),
		CONSTRAINT PK_estadoID PRIMARY KEY(id)
	)
END
GO

-- CREACION TABLA TIPO TURNO

IF NOT EXISTS (
    SELECT 1
    FROM sys.tables
    WHERE name = 'TipoTurno'
    AND schema_id = SCHEMA_ID('gestion_turno')
)
BEGIN
	CREATE TABLE gestion_turno.TipoTurno
	(
		id		INT,
		nombre	VARCHAR(11), -- Presencial Virtual
		CONSTRAINT PK_tipoID PRIMARY KEY(id)
	)
END
GO

-- CREACION TABLA RESERVA TURNO

IF NOT EXISTS (
    SELECT 1
    FROM sys.tables
    WHERE name = 'ReservaTurno'
    AND schema_id = SCHEMA_ID('gestion_turno')
)
BEGIN
	CREATE TABLE gestion_turno.ReservaTurno
	(
		id						INT,
		fecha					DATE,
		hora					TIME,
		id_paciente				INT,
		id_estado_turno			INT,
		id_tipo_turno			INT,
		borrado_logico			BIT DEFAULT 0,

		CONSTRAINT PK_turnoID			PRIMARY KEY(id),
		CONSTRAINT FK_pacienteID		FOREIGN KEY(id_paciente)		REFERENCES gestion_paciente.Paciente(id),
		CONSTRAINT FK_estadoID			FOREIGN KEY(id_estado_turno)	REFERENCES gestion_turno.EstadoTurno(id),
		CONSTRAINT FK_tipoID			FOREIGN KEY(id_tipo_turno)		REFERENCES gestion_turno.TipoTurno(id)		
	)
END
GO





--- CREACION DE TABLAS DEL ESQUEMA GESTION_SEDE

-- CREACION TABLA SEDE

IF NOT EXISTS (
    SELECT 1
    FROM sys.tables
    WHERE name = 'Sede'
    AND schema_id = SCHEMA_ID('gestion_sede')
)
BEGIN
	 CREATE TABLE gestion_sede.Sede (
		 id					INT IDENTITY(1,1),
		 nombre				VARCHAR(30),
		 direccion			VARCHAR(30),
		 localidad			VARCHAR(30),
		 provincia			VARCHAR(30),

		CONSTRAINT Ck_Sedenomb CHECK(PATINDEX('%[^A-Za-zÁÉÍÓÚáéíóú ]%', nombre) = 0),
		CONSTRAINT Ck_Sedeprov CHECK(PATINDEX('%[^A-Za-zÁÉÍÓÚáéíóú ]%', provincia) = 0),
		CONSTRAINT PK_SedeID PRIMARY KEY (id)
	 )
END
GO

-- CREACION TABLA ESPECIALIDAD

IF NOT EXISTS (
    SELECT 1
    FROM sys.tables
    WHERE name = 'Especialidad'
    AND schema_id = SCHEMA_ID('gestion_sede')
)
BEGIN
	 CREATE TABLE gestion_sede.Especialidad(
		id			INT	IDENTITY(1,1),
		nombre		VARCHAR(30),

		CONSTRAINT Ck_Espnombre CHECK(PATINDEX('%[^A-Za-zÁÉÍÓÚáéíóú ]%', nombre) = 0),
		CONSTRAINT PK_EspecialidadID PRIMARY KEY (id)
	 );
END;
GO


-- CREACION TABLA MEDICO

IF NOT EXISTS (
    SELECT 1
    FROM sys.tables
    WHERE name = 'Medico'
    AND schema_id = SCHEMA_ID('gestion_sede')
)
BEGIN
	 CREATE TABLE gestion_sede.Medico(
		id					INT IDENTITY(1,1),
		nombre				VARCHAR(30),
		apellido			VARCHAR(30),
		matricula			INT UNIQUE,
		id_especialidad		INT,

		CONSTRAINT CK_MedicoNombre CHECK(PATINDEX('%[^A-Za-zÁÉÍÓÚáéíóú ]%', nombre) = 0),
		CONSTRAINT Ck_MedicoApellido CHECK(PATINDEX('%[^A-Za-zÁÉÍÓÚáéíóú ]%', apellido) = 0),
		CONSTRAINT PK_MedicoID			PRIMARY KEY (id),
		CONSTRAINT FK_EspecialidadID	FOREIGN KEY (id_especialidad) REFERENCES gestion_sede.Especialidad(id)
	 );
END;
GO

-- CREACION TABLA DIASXSEDE

IF NOT EXISTS (
    SELECT 1
    FROM sys.tables
    WHERE name = 'DiasXSede'
    AND schema_id = SCHEMA_ID('gestion_sede')
)
BEGIN
	 CREATE TABLE gestion_sede.DiasXSede (
		 id					INT,
		 id_sede			INT,
		 id_medico			INT,
		 id_reserva_turno	INT UNIQUE,
		 dia				DATE,
		 hora_inicio		TIME,

	 CONSTRAINT PK_DiasxsedeID		PRIMARY KEY (id),
	 CONSTRAINT FK_SedeID			FOREIGN KEY (id_sede)			REFERENCES gestion_sede.Sede (id),
	 CONSTRAINT FK_MedicoID			FOREIGN KEY (id_medico)			REFERENCES gestion_sede.Medico (id),
	 CONSTRAINT FK_ReservaTurnoID	FOREIGN KEY (id_reserva_turno)	REFERENCES gestion_turno.ReservaTurno (id)
	 );
END;
GO


---- CREACION FUNCIONES AUXILIARES PARA LOS STORE PROCEDURES

--- FUNCIONES Y PROCEDIMIENTOS AUXILIARES PARA LA INSERCION DE RESERVAS DE TURNOS

CREATE OR ALTER PROCEDURE gestion_turno.ConsultarDisponibilidad (
	@p_id_medico			INT, 
	@p_id_especialidad		INT,
	@p_id_sede_atencion		INT,
	@r_disponiblidad		INT OUTPUT
)
AS
BEGIN
    SET @r_disponiblidad = CAST(RAND() + 0.5 AS INT)
END
GO

--- FUNCIONES Y PROCEDIMIENTOS AUXILIARES PARA LA INSERCION DE PACIENTES

CREATE OR ALTER FUNCTION gestion_paciente.ExistePaciente(
	@p_nombre				VARCHAR(30),
	@p_apellido				VARCHAR(30),
	@p_fecha_nac			DATE,
	@p_tipo_doc				CHAR(5),
	@p_num_doc				INT,
	@p_sexo					VARCHAR(11),
	@p_genero				VARCHAR(9),
	@p_nacionalidad			VARCHAR(20)
)
RETURNS BIT
BEGIN
	DECLARE @r_existe BIT
	IF EXISTS(
		SELECT 1
		FROM gestion_paciente.Paciente
		WHERE nombre			= @p_nombre
			AND	apellido		= @p_apellido
			AND	fecha_nac		= @p_fecha_nac
			AND tipo_doc		= @p_tipo_doc
			AND num_doc			= @p_num_doc
			AND nacionalidad	= @p_nacionalidad
	)
	BEGIN
		SET @r_existe = 1
	END
	ELSE
	BEGIN
		SET @r_existe = 0
	END

	RETURN @r_existe
END
GO	

--- FUNCIONES Y PROCEDIMIENTOS AUXILIARES PARA INSERCION DE MEDICOS

CREATE OR ALTER FUNCTION gestion_sede.ExisteMedico (
	@p_nombre			VARCHAR(30),
	@p_apellido			VARCHAR(30),
	@p_matricula		INT,
	@p_id_especialidad	INT
)
RETURNS BIT
BEGIN
	DECLARE @r_existe BIT
	IF EXISTS(
		SELECT 1
		FROM gestion_sede.Medico
		WHERE nombre = @p_nombre
			AND	apellido = @p_apellido
			AND	matricula = @p_matricula
			AND id_especialidad = @p_id_especialidad
	)
	BEGIN
		SET @r_existe = 1
	END
	ELSE
	BEGIN
		SET @r_existe = 0
	END

	RETURN @r_existe
END
GO	

CREATE OR ALTER FUNCTION gestion_sede.ExisteEspecialidad (@p_nombre VARCHAR(20)
)
RETURNS BIT
BEGIN
	DECLARE @r_existe BIT
	IF EXISTS(
		SELECT 1
		FROM gestion_sede.Especialidad
		WHERE nombre			= @p_nombre
	)
	BEGIN
		SET @r_existe = 1
	END
	ELSE
	BEGIN
		SET @r_existe = 0
	END

	RETURN @r_existe
END
GO	

--- FUNCIONES Y PROCEDIMIENTOS AUXILIARES PARA INSERCION DE SEDES

CREATE OR ALTER FUNCTION gestion_sede.ExisteSede (
	@p_nombre			VARCHAR(30),
	@p_direccion		VARCHAR(30),
	@p_localidad		VARCHAR(30),
	@p_provincia		VARCHAR(30)
)
RETURNS BIT
BEGIN
	DECLARE @r_existe BIT
	IF EXISTS(
		SELECT 1
		FROM gestion_sede.Sede
		WHERE nombre = @p_nombre
			AND	direccion = @p_direccion
			AND	localidad = @p_localidad
			AND provincia = @p_provincia
	)
	BEGIN
		SET @r_existe = 1
	END
	ELSE
	BEGIN
		SET @r_existe = 0
	END

	RETURN @r_existe
END
GO	

--- FUNCIONES AUXILIARES PARA IMPORTACION

CREATE OR ALTER FUNCTION gestion_paciente.ParsearDomicilio (@p_domicilio VARCHAR(50))
RETURNS @r_domicilio TABLE(
	calle		VARCHAR(30),
	numero		VARCHAR(30)
)
AS
BEGIN
	DECLARE @calle			VARCHAR(30)
	DECLARE @numero			VARCHAR(20)
	DECLARE @posicion_ini	INT
	DECLARE @posicion_fin	INT

	IF PATINDEX('% KM %', @p_domicilio) > 0															-- CASO: Ruta 3 KM 690
	BEGIN
		SET @calle	= SUBSTRING(@p_domicilio, 1, CHARINDEX('KM', @p_domicilio) - 1)					-- el -1 es por el ultimo espacio del KM 
		SET @numero = SUBSTRING(@p_domicilio, CHARINDEX('KM', @p_domicilio) + 3, LEN(@p_domicilio))	-- +3 es porque al encontrar 'KM 2' necesitamos movernos hacia el inicio del '2' 
		
		SET @posicion_ini = PATINDEX('%[^0-9]%', @numero)											-- ^ operador de negacion, osea buscaria hasta no encontrar esos valores
		
		IF @posicion_ini != 0																		-- CASO: RUTA NACIONAL 22 KM 856 (ASCENDENTE)	
		BEGIN
			SET @numero = SUBSTRING(@numero, 1, @posicion_ini - 1)
		END
	END
	ELSE IF PATINDEX('%Nº%', @p_domicilio) > 0	-- CASO: 51 Nº 456
	BEGIN
		SET @calle	= SUBSTRING(@p_domicilio, 1, CHARINDEX('Nº', @p_domicilio) - 1)					-- el -1 es por el ultimo espacio del KM 
		SET @numero = SUBSTRING(@p_domicilio, CHARINDEX('Nº', @p_domicilio) + 3, LEN(@p_domicilio))	-- +3 es porque al encontrar 'KM 2' necesitamos movernos hacia el inicio del '2' 
		
	END
	ELSE																							-- CASO: AVENIDA 9 DE JULIO 857 | Av. 520 2650
	BEGIN
		SET @posicion_ini = PATINDEX('%[0-9]%', REVERSE(@p_domicilio));																		-- busco primera aparicion de un numero con el string domicilio invertido
		SET @posicion_fin = @posicion_ini + PATINDEX('%[^0-9]%', SUBSTRING(REVERSE(@p_domicilio), @posicion_ini, LEN(@p_domicilio))) - 2;	-- busco la ultima aparicion de un numero de la secuencia de @auxiliar1

		IF	@posicion_fin = -1	--	 CASO: LOPEZ ENTRE PLANEZ Y MATIENZO
		BEGIN
			SET @posicion_fin = 0
		END
		SET @calle	= SUBSTRING(REVERSE(@p_domicilio), @posicion_fin + 1, LEN(@p_domicilio))
		SET @calle	= REVERSE(@calle)

		SET @numero = SUBSTRING(reverse(@p_domicilio), @posicion_ini , @posicion_fin- @posicion_ini + 1)
		SET @numero = REVERSE(@numero)

	END


	SET @numero = CAST(@numero AS INT)

	INSERT INTO @r_domicilio (calle, numero)
	VALUES (@calle, @numero)

	RETURN;
END
GO

CREATE OR ALTER FUNCTION gestion_paciente.LimpiarApellidoMaterno (@p_apellido	VARCHAR(30))
RETURNS VARCHAR(30)
BEGIN 
	DECLARE @apellido_materno	VARCHAR(30)
	DECLARE @auxiliar			VARCHAR(30)
	SET @p_apellido = LTRIM(@p_apellido)
	SET @auxiliar = LOWER(@p_apellido)
	

	
	IF PATINDEX('de %', @auxiliar) > 0 OR PATINDEX('del %',@auxiliar) > 0
	BEGIN
		SET @apellido_materno = @p_apellido		-- el 3er parametro de charindex indica desde donde comienzo a buscar
	END
	ELSE IF CHARINDEX(' ', @auxiliar) > 0
	BEGIN
		SET @apellido_materno = SUBSTRING(@p_apellido, 1, CHARINDEX(' ', @p_apellido))
	END
	ELSE
	BEGIN
		SET @apellido_materno = @p_apellido
	END
	
	RETURN @apellido_materno
END
GO

CREATE OR ALTER FUNCTION gestion_sede.LimpiarApellidoMedico (@p_nombre VARCHAR(30)
)
RETURNS VARCHAR(30)
BEGIN
	DECLARE @retorno VARCHAR(30)

	SET @retorno = SUBSTRING(@p_nombre, CHARINDEX('.', @p_nombre) + 1, LEN(@p_nombre))	
		
	RETURN @retorno
END
GO	


---- CREACION STORE PROCEDURES ESQUEMA GESTION PACIENTE

--- CREACION STORE PROCEDURES PACIENTE

-- ACTUALIZAR PACIENTE

CREATE OR ALTER PROCEDURE gestion_paciente.ActualizarPaciente
    @p_id                   INT,
    @p_nombre               VARCHAR(30) = NULL,
    @p_apellido             VARCHAR(30) = NULL,
    @p_apellido_materno     VARCHAR(30) = NULL,
    @p_fecha_nac            DATE		= NULL,
    @p_tipo_doc             CHAR(5)		= NULL,
    @p_num_doc              INT			= NULL,
    @p_sexo                 VARCHAR(11) = NULL,
    @p_genero               VARCHAR(9)	= NULL,
    @p_nacionalidad         VARCHAR(30) = NULL,
    @p_foto_perfil          VARCHAR(MAX)= NULL,
    @p_mail                 VARCHAR(30) = NULL,
    @p_tel_fijo             VARCHAR(15) = NULL,
    @p_tel_alt              VARCHAR(15) = NULL,
    @p_tel_laboral          VARCHAR(15) = NULL,
	@p_borrado_logico		BIT			= NULL
AS
BEGIN

	DECLARE
		@nombre					VARCHAR(30),
		@apellido				VARCHAR(30),
		@apellido_materno		VARCHAR(30),
		@fecha_nac				DATE,
		@tipo_doc				CHAR(5),
		@num_doc				INT,
		@sexo					VARCHAR(11),
		@genero					VARCHAR(9),
		@nacionalidad			VARCHAR(30),
		@foto_perfil			VARCHAR(max),
		@mail					VARCHAR(30),
		@tel_fijo				VARCHAR(15),
		@tel_alt				VARCHAR(15),
		@tel_laboral			VARCHAR(15),
		@borrado_logico			BIT
	SELECT
		@nombre					= nombre,
		@apellido				= apellido,
		@apellido_materno		= apellido_materno,
		@fecha_nac				= fecha_nac,
		@tipo_doc				= tipo_doc,
		@num_doc				= num_doc,
		@sexo					= sexo,
		@genero					= genero,
		@nacionalidad			= nacionalidad,
		@foto_perfil			= foto_perfil,
		@mail					= mail,
		@tel_fijo				= tel_fijo,
		@tel_alt				= tel_alt,
		@tel_laboral			= tel_laboral,
		@borrado_logico			= borrado_logico
	FROM gestion_paciente.Paciente
	WHERE id = @p_id

	UPDATE gestion_paciente.Paciente
	SET	
		nombre					= ISNULL(@p_nombre, @nombre),
        apellido				= ISNULL(@p_apellido, @apellido),
        apellido_materno		= ISNULL(@p_apellido_materno, @apellido_materno),
        fecha_nac				= ISNULL(@p_fecha_nac, @fecha_nac),
        tipo_doc				= ISNULL(@p_tipo_doc, @tipo_doc),
        num_doc					= ISNULL(@p_num_doc, @num_doc),
        sexo					= ISNULL(@p_sexo, @sexo),
        genero					= ISNULL(@p_genero, @genero),
        nacionalidad			= ISNULL(@p_nacionalidad, @nacionalidad),
        foto_perfil				= ISNULL(@p_foto_perfil, @foto_perfil),
        mail					= ISNULL(@p_mail, @mail),
        tel_fijo				= ISNULL(@p_tel_fijo, @tel_fijo),
        tel_alt					= ISNULL(@p_tel_alt, @tel_alt),
        tel_laboral				= ISNULL(@p_tel_laboral, @tel_laboral),
		borrado_logico			= ISNULL(@p_borrado_logico, @borrado_logico),
        fecha_actualizacion		= GETDATE(),
		usr_actualizacion		= ORIGINAL_LOGIN()
	WHERE id = @p_id
END;
GO

-- INSERTAR PACIENTE
-- los "fecha" siempre van con un getDate, el usr actualizacion es cuando se crea el usuario y asignamos el nombre ahi
-- los NULL son porque en la estructura de los archivos a importar no son valores dados.
-- el null en p_id es un caso especifico, es identity por lo tanto, no deberia poder enviarse
-- pero al manejar borrado logico, es de esperar que algun operador del hospital envie algun ID de un archivo fisico que ellos tengan del paciente
-- donde se vea el id que se le fue asignado, por lo tanto existen 2 casos:
--	el id es importado, por lo tanto, se utiliza identity y se inserta directamente
--	el id es ingresado por operador, por lo tanto, se valida que exista dicho paciente previo a intentar insertarlo

-- @p_id_identity es para la importacion de archivos, contiene el ID generado por identity (obtenido de SCOPE_IDENTITY())

CREATE OR ALTER PROCEDURE gestion_paciente.InsertarPaciente
	@p_id					INT				= NULL,
	@p_nombre				VARCHAR(30),
	@p_apellido				VARCHAR(30),
	@p_apellido_materno		VARCHAR(30),
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
AS
BEGIN
	DECLARE @existe			BIT
	DECLARE @borrado		BIT

	EXEC @existe = gestion_paciente.ExistePaciente 
						@p_nombre			= @p_nombre,
						@p_apellido			= @p_apellido,
						@p_fecha_nac		= @p_fecha_nac,
						@p_tipo_doc			= @p_tipo_doc,
						@p_num_doc			= @p_num_doc,
						@p_sexo				= @p_sexo,
						@p_genero			= @p_genero,
						@p_nacionalidad		= @p_nacionalidad
				

	SET @borrado = (select borrado_logico from gestion_paciente.Paciente where id = @p_id)

	IF @existe = 1 AND @borrado = 1						--	CASO: el operador de la clinica reincorpora un paciente
    BEGIN
		EXEC gestion_paciente.ActualizarPaciente
				@p_id					= @p_id,
				@p_nombre				= @p_nombre,
				@p_apellido				= @p_apellido,
				@p_apellido_materno		= @p_apellido_materno,
				@p_fecha_nac			= @p_fecha_nac,
				@p_tipo_doc				= @p_tipo_doc,
				@p_num_doc				= @p_num_doc,
				@p_sexo					= @p_sexo,
				@p_genero				= @p_genero,
				@p_nacionalidad			= @p_nacionalidad,
				@p_foto_perfil			= @p_foto_perfil,
				@p_mail					= @p_mail,
				@p_tel_fijo				= @p_tel_fijo,
				@p_tel_alt				= @p_tel_alt,
				@p_tel_laboral			= @p_tel_laboral,
				@p_borrado_logico		= 0
    END
    ELSE IF @existe = 1									--	CASO: el paciente ya esta registrado 
		RETURN
	ELSE
    BEGIN												--	CASO: el operador de la clinica ingresa un nuevo paciente
        INSERT INTO gestion_paciente.Paciente (
            nombre,
            apellido,
            apellido_materno,
            fecha_nac,
            tipo_doc,
            num_doc,
            sexo,
            genero,
            nacionalidad,
            foto_perfil,
            mail,
            tel_fijo,
            tel_alt,
            tel_laboral,
            fecha_registro,
            fecha_actualizacion,
			usr_actualizacion
        )
        VALUES (
            @p_nombre,
            @p_apellido,
            @p_apellido_materno,
            @p_fecha_nac,
            @p_tipo_doc,
            @p_num_doc,
            @p_sexo,
            @p_genero,
            @p_nacionalidad,
            @p_foto_perfil,
            @p_mail,
            @p_tel_fijo,
            @p_tel_alt,
            @p_tel_laboral,
            GETDATE(),
            GETDATE(),
			ORIGINAL_LOGIN()
        );
		SET @p_id_identity = SCOPE_IDENTITY()
    END
END;
GO


-- BORRAR PACIENTE


CREATE OR ALTER PROCEDURE gestion_paciente.BorrarPaciente
	@p_id INT
AS
BEGIN
	UPDATE gestion_paciente.Paciente
	SET	borrado_logico = 1
	WHERE id = @p_id;

	UPDATE gestion_paciente.Paciente
	SET	usr_actualizacion = ORIGINAL_LOGIN()
	WHERE id = @p_id;
END;
GO

--- CREACION STORE PROCEDURES ESTUDIO


-- INSERTAR ESTUDIO


CREATE OR ALTER PROCEDURE gestion_paciente.InsertarEstudio
	@p_id				INT,
	@p_id_paciente		INT,
	@p_fecha			DATE,
	@p_nombre_estudio	VARCHAR(50),
	@p_doc_resultado	VARCHAR(max),
	@p_img_resultado	VARCHAR(max)
AS
BEGIN
	IF EXISTS (
        SELECT 1
        FROM gestion_paciente.Estudio
        WHERE id = @p_id AND borrado_logico = 1
    )
    BEGIN
        UPDATE gestion_paciente.Estudio
        SET
            borrado_logico = 0
        WHERE id = @p_id;
    END
    ELSE
    BEGIN
        INSERT INTO gestion_paciente.Estudio (
            id,
            id_paciente,
            fecha,
            nombre_estudio,
            doc_resultado,
            img_resultado
        )
        VALUES (
            @p_id,
            @p_id_paciente,
            @p_fecha,
            @p_nombre_estudio,
            @p_doc_resultado,
            @p_img_resultado
        );
    END
END;
GO

-- ACTUALIZAR ESTUDIO

CREATE OR ALTER PROCEDURE gestion_paciente.ActualizarEstudio
    @p_id                   INT,
    @p_id_paciente          INT,
    @p_fecha                DATE			= NULL,
    @p_nombre_estudio       VARCHAR(50)	= NULL,
    @p_doc_resultado        VARCHAR(MAX)	= NULL,
    @p_img_resultado        VARCHAR(MAX)	= NULL	
AS
BEGIN
	DECLARE
		@fecha				DATE,
		@nombre_estudio		VARCHAR(50),
		@doc_resultado		VARCHAR(MAX),
		@img_resultado		VARCHAR(MAX)
	SELECT
		@fecha				= fecha,
		@nombre_estudio		= nombre_estudio,
		@doc_resultado		= doc_resultado,
		@img_resultado		= img_resultado
	FROM gestion_paciente.Estudio
	WHERE id = @p_id

    UPDATE gestion_paciente.Estudio
    SET
        fecha				= ISNULL(@p_fecha, @fecha),
        nombre_estudio		= ISNULL(@p_nombre_estudio, @nombre_estudio),
        doc_resultado		= ISNULL(@p_doc_resultado, @doc_resultado),
        img_resultado		= ISNULL(@p_img_resultado, @img_resultado)
    WHERE id = @p_id;
END;
GO


-- BORRAR ESTUDIO

CREATE OR ALTER PROCEDURE gestion_paciente.BorrarEstudio
	@p_id INT
AS
BEGIN
	UPDATE gestion_paciente.Estudio
	SET	borrado_logico = 1
	WHERE id = @p_id;
END;
GO


--- CREACION STORE PROCEDURES USUARIO

-- INSERTAR USUARIO

CREATE OR ALTER PROCEDURE gestion_paciente.InsertarUsuario
	@p_id				INT,
	@p_id_paciente		INT,
	@p_contrasena		VARCHAR(30)
AS
BEGIN
	INSERT INTO gestion_paciente.Usuario (
		id,
		id_paciente,
		contrasena,
		fecha_creacion
	)
	VALUES (
		@p_id,
		@p_id_paciente,
		@p_contrasena,
		GETDATE()
	);

	UPDATE gestion_paciente.Paciente
	SET	usr_actualizacion = GETDATE()
	WHERE id = @p_id_paciente
END;
GO

-- ACTUALIZAR USUARIO

CREATE OR ALTER PROCEDURE gestion_paciente.ActualizarUsuario
    @p_id				INT,
    @p_id_paciente		INT				= NULL,
    @p_contrasena		VARCHAR(30)		= NULL,
    @p_fecha_creacion	VARCHAR(MAX)	= NULL
AS
BEGIN

	DECLARE
		@id_paciente	INT,
		@contrasena		VARCHAR(30)

	SELECT
		@id_paciente	= id_paciente,
		@contrasena		= contrasena
	FROM gestion_paciente.Usuario
	WHERE id = @p_id

	UPDATE gestion_paciente.Usuario
	SET
		id_paciente		= ISNULL(@p_id_paciente, @id_paciente),
		contrasena		= ISNULL(@p_contrasena, @contrasena)
	WHERE id = @p_id

	UPDATE gestion_paciente.Paciente
	SET usr_actualizacion = GETDATE()
	WHERE id = ISNULL(@p_id_paciente, @id_paciente)
END;
GO

-- BORRAR USUARIO


CREATE OR ALTER PROCEDURE gestion_paciente.BorrarUsuario
	@p_id INT
AS
BEGIN
	DELETE gestion_paciente.Usuario
	WHERE id = @p_id;
END;
GO


--- CREACION STORE PROCEDURES DOMICILIO


-- INSERTAR DOMICILIO

CREATE OR ALTER PROCEDURE gestion_paciente.InsertarDomicilio
    @p_id INT				=	NULL,
    @p_id_paciente INT,
    @p_calle VARCHAR(30),
    @p_numero INT,
    @p_piso INT				=	NULL,
    @p_departamento INT		=	NULL,
    @p_cod_postal INT		=	NULL,
    @p_pais VARCHAR(30),
    @p_provincia VARCHAR(30),
    @p_localidad VARCHAR(30)
AS
BEGIN
    INSERT INTO gestion_paciente.Domicilio (
        id_paciente,
        calle,
        numero,
        piso,
        departamento,
        cod_postal,
        pais,
        provincia,
        localidad
    )
    VALUES (
        @p_id_paciente,
        @p_calle,
        @p_numero,
        @p_piso,
        @p_departamento,
        @p_cod_postal,
        @p_pais,
        @p_provincia,
        @p_localidad
    );
END;
GO


-- ACTUALIZAR DOMICILIO
CREATE OR ALTER PROCEDURE gestion_paciente.ActualizarDomicilio
    @p_id           INT,
    @p_calle        VARCHAR(30) = NULL,
    @p_numero       INT			= NULL,
    @p_piso         INT			= NULL,
    @p_departamento INT			= NULL,
    @p_cod_postal   INT			= NULL,
    @p_pais         VARCHAR(30) = NULL,
    @p_provincia    VARCHAR(30) = NULL,
    @p_localidad    VARCHAR(30) = NULL
AS
BEGIN

	DECLARE
		@calle          VARCHAR(30),
		@numero         INT,
		@piso           INT,
		@departamento   INT,
		@cod_postal     INT,
		@pais           VARCHAR(30),
		@provincia      VARCHAR(30),
		@localidad      VARCHAR(30)

	SELECT
		@calle          = calle,
		@numero         = numero,
		@piso           = piso,
		@departamento   = departamento,
		@cod_postal     = cod_postal,
		@pais           = pais,
		@provincia      = provincia,
		@localidad		= localidad
	FROM gestion_paciente.Domicilio
	WHERE id = @p_id

	UPDATE gestion_paciente.Domicilio
	SET	
		calle			= ISNULL(@p_calle, @calle),
		numero			= ISNULL(@p_numero, @numero),
		piso			= ISNULL(@p_piso, @piso),
		departamento	= ISNULL(@p_departamento, @departamento),
		cod_postal		= ISNULL(@p_cod_postal, @cod_postal),
		pais			= ISNULL(@p_pais, @pais),
		provincia		= ISNULL(@p_provincia, @provincia),
		localidad		= ISNULL(@p_localidad, @localidad)
	WHERE id = @p_id
END;
GO


-- BORRAR DOMICILIO

CREATE OR ALTER PROCEDURE gestion_paciente.BorrarDomicilio
	@p_id INT
AS
BEGIN
	DELETE gestion_paciente.Domicilio
	WHERE id = @p_id;
END;
GO


--- CREACION STORE PROCEDURES COBERTURA


-- INSERTAR COBERTURA

CREATE OR ALTER PROCEDURE gestion_paciente.InsertarCobertura
    @p_id					INT,
    @p_id_paciente			INT,
    @p_imagen_credencial	VARCHAR(max),
    @p_nro_socio			INT,
    @p_fecha_registro		DATE
AS
BEGIN
    INSERT INTO gestion_paciente.Cobertura (
        id,
        id_paciente,
        imagen_credencial,
        nro_socio,
        fecha_registro
    )
    VALUES (
        @p_id,
        @p_id_paciente,
        @p_imagen_credencial,
        @p_nro_socio,
        GETDATE()
    );
END;
 GO


 -- ACTUALIZAR COBERTURA

 CREATE OR ALTER PROCEDURE gestion_paciente.ActualizarCobertura
    @p_id                   INT,
    @p_id_paciente          INT				= NULL,
    @p_imagen_credencial    VARCHAR(max)	= NULL,
    @p_nro_socio            INT				= NULL,
    @p_fecha_registro       DATE			= NULL
AS
BEGIN
    DECLARE
        @id_paciente            INT,
        @imagen_credencial      VARCHAR(max),
        @nro_socio              INT,
        @fecha_registro         DATE

    SELECT
        @id_paciente			= id_paciente,
        @imagen_credencial		= imagen_credencial,
        @nro_socio				= nro_socio,
        @fecha_registro			= fecha_registro
    FROM gestion_paciente.Cobertura
    WHERE id = @p_id

    UPDATE gestion_paciente.Cobertura
    SET
        id_paciente				= ISNULL(@p_id_paciente, @id_paciente),
        imagen_credencial		= ISNULL(@p_imagen_credencial, @imagen_credencial),
        nro_socio				= ISNULL(@p_nro_socio, @nro_socio),
        fecha_registro			= ISNULL(@p_fecha_registro, @fecha_registro)
    WHERE id = @p_id
END;
GO


-- BORRAR COBERTURA

CREATE OR ALTER PROCEDURE gestion_paciente.BorrarCobertura
	@p_id INT
AS
BEGIN
	DELETE gestion_paciente.Cobertura
	WHERE id = @p_id;
END;
GO


--- CREACION STORE PROCEDURES PRESTADOR

-- INSERTAR PRESTADOR

CREATE OR ALTER PROCEDURE gestion_paciente.InsertarPrestador
    @p_id_cobertura		INT	= NULL,
    @p_nombre			VARCHAR(30),
    @p_plan				VARCHAR(30)
AS
BEGIN

	IF EXISTS (														--	CASO: se ingresa duplicado
		SELECT 1
		FROM gestion_paciente.Prestador
		WHERE [plan] = @p_plan AND nombre = @p_nombre
	)
	BEGIN
		RETURN
	END

	IF @p_id_cobertura IS NULL										--	CASO: se importa prestadores y estos no tienen dichos ids
	BEGIN
		INSERT INTO gestion_paciente.Prestador (
        nombre,
        [plan]
    )
    VALUES (
        @p_nombre,
        @p_plan
    );
	END
	ELSE
    INSERT INTO gestion_paciente.Prestador (						--	CASO: se ingresa manualmente el id de cobertura, ademas del nombre y plan
        id_cobertura,
        nombre,
        [plan]
    )
    VALUES (
        @p_id_cobertura,
        @p_nombre,
        @p_plan
    );
END;
GO


-- ACTUALIZAR PRESTADOR

CREATE OR ALTER PROCEDURE gestion_paciente.ActualizarPrestador
    @p_id				INT,
    @p_id_cobertura		INT				= NULL,
    @p_nombre			VARCHAR(30)		= NULL,
    @p_plan				VARCHAR(30)		= NULL
AS
BEGIN
    DECLARE
        @id_cobertura		INT,
        @nombre_prestador	VARCHAR(30),
        @plan_prestador		VARCHAR(30)

    SELECT
        @id_cobertura		= id_cobertura,
        @nombre_prestador	= nombre,
        @plan_prestador		= [plan]
    FROM gestion_paciente.Prestador
    WHERE id = @p_id

    UPDATE gestion_paciente.Prestador
    SET
        id_cobertura		= ISNULL(@p_id_cobertura, @id_cobertura),
        nombre				= ISNULL(@p_nombre, @nombre_prestador),
        [plan]				= ISNULL(@p_plan, @plan_prestador)
    WHERE id = @p_id
END;
GO

-- BORRAR PRESTADOR


CREATE OR ALTER PROCEDURE gestion_paciente.BorrarPrestador
	@p_id INT
AS
BEGIN
	DELETE gestion_paciente.Prestador
	WHERE id = @p_id;
END;
GO


---- CREACION STORE PROCEDURES ESQUEMA GESTION SEDE

--- CREACION STORE PROCEDURES SEDE

-- BUSCAR SEDE

CREATE OR ALTER PROCEDURE gestion_sede.ExisteSede
	@p_nombre		VARCHAR(30),
	@p_direccion	VARCHAR(30),
	@p_localidad	VARCHAR(30),
	@p_provincia	VARCHAR(30),
	@r_existe		BIT	OUTPUT
AS
BEGIN
	SET @r_existe = 0
	
	IF EXISTS(
		SELECT 1
		FROM gestion_sede.Sede
		WHERE nombre = @p_nombre
			AND direccion = @p_direccion
			AND localidad = @p_localidad
			AND provincia = @p_provincia
	)
	BEGIN
		SET @r_existe = 1
	END
END
GO

-- ACTUALIZAR SEDE

CREATE OR ALTER PROCEDURE gestion_sede.ActualizarSede
	@p_id			INT,
	@p_nombre		VARCHAR(30) = NULL,
	@p_direccion	VARCHAR(30) = NULL,
	@p_localidad	VARCHAR(30) = NULL,
	@p_provincia	VARCHAR(30) = NULL
AS
BEGIN

	DECLARE
		@nombre		INT,
		@direccion	INT,
		@localidad	DATE,
		@provincia	TIME
	SELECT
		@nombre		= nombre,
		@direccion	= direccion,
		@localidad	= localidad,
		@provincia	= provincia
	FROM gestion_sede.Sede
	WHERE id = @p_id

    UPDATE gestion_sede.Sede
    SET
        nombre			= ISNULL(@p_nombre, @nombre),
        direccion		= ISNULL(@p_direccion, @direccion),
        localidad		= ISNULL(@p_localidad, @localidad),
        provincia		= ISNULL(@p_provincia, @provincia)
    WHERE id = @p_id;
END
GO

-- INSERTAR SEDE

CREATE OR ALTER PROCEDURE gestion_sede.InsertarSede
	@p_id			INT			= NULL,
	@p_nombre		VARCHAR(30),
	@p_direccion	VARCHAR(30),
	@p_localidad	VARCHAR(30),
	@p_provincia	VARCHAR(30)
AS
BEGIN
	DECLARE @existe BIT

	EXEC gestion_sede.ExisteSede
		@p_nombre		= @p_nombre,
		@p_direccion	= @p_direccion,
		@p_localidad	= @p_localidad,
		@p_provincia	= @p_provincia,
		@r_existe		= @existe OUTPUT

	IF @existe = 1
	BEGIN
		EXEC gestion_sede.ActualizarSede
			@p_id			= @p_id,
			@p_nombre		= @p_nombre,
			@p_direccion	= @p_direccion,
			@p_localidad	= @p_localidad,
			@p_provincia	= @p_provincia
	END
	ELSE
	BEGIN
		INSERT INTO gestion_sede.Sede (
			nombre,
			direccion,
			localidad,
			provincia
		)
		VALUES (
			@p_nombre,
			@p_direccion,
			@p_localidad,
			@p_provincia
		)
	END
END
GO	

-- BORRAR SEDE

CREATE OR ALTER PROCEDURE gestion_sede.BorrarSede
	@p_id	INT
AS
BEGIN
	DELETE gestion_sede.Sede 
	WHERE id = @p_id	
END
GO


--- CREACION STORE PROCEDURES MEDICO

-- BUSCAR MEDICO

CREATE OR ALTER PROCEDURE gestion_sede.ExisteMedico 
	@p_nombre			VARCHAR(30),
	@p_apellido			VARCHAR(30),
	@p_matricula		INT,
	@r_existe			BIT OUTPUT
AS
BEGIN
	SET @r_existe = 0
	IF EXISTS(
		SELECT 1
		FROM gestion_sede.Medico
		WHERE nombre			= @p_nombre
			AND	apellido		= @p_apellido
			AND matricula		= @p_matricula
	)
	BEGIN
		SET @r_existe = 1
	END
END
GO	

-- ACTUALIZAR MEDICO

CREATE OR ALTER PROCEDURE gestion_sede.ActualizarMedico
	@p_id				INT, 
	@p_nombre			VARCHAR(30)	= NULL, 
	@p_apellido			VARCHAR(30)	= NULL,
	@p_matricula		INT			= NULL,
	@p_id_especialidad	INT			= NULL
AS
BEGIN
	DECLARE
		@nombre				VARCHAR(30),
		@apellido			VARCHAR(30),
		@matricula			INT,
		@id_especialidad	INT
	SELECT
		@nombre				= nombre,
		@apellido			= apellido,
		@matricula			= matricula,
		@id_especialidad	= id_especialidad
	FROM gestion_sede.Medico
	WHERE id = @p_id

	UPDATE	gestion_sede.Medico
	SET	
		nombre			= ISNULL(@p_nombre, @nombre),
		apellido		= ISNULL(@p_apellido, @apellido),
		matricula		= ISNULL(@p_matricula, @matricula),
		id_especialidad = ISNULL(@p_id_especialidad, @id_especialidad)
	WHERE id = @p_id
END
GO

-- INSERTAR MEDICO

CREATE OR ALTER PROCEDURE gestion_sede.InsertarMedico
	@p_id				INT	= NULL, 
	@p_nombre			VARCHAR(30), 
	@p_apellido			VARCHAR(30),
	@p_matricula		INT,
	@p_id_especialidad	INT
AS
BEGIN
	DECLARE @existe	BIT
	EXEC @existe = gestion_sede.ExisteMedico
		@p_nombre			= @p_nombre,
		@p_apellido			= @p_apellido,
		@p_matricula		= @p_matricula,
		@p_id_especialidad	= @p_id_especialidad

	IF @existe = 1
	BEGIN
		EXEC gestion_sede.ActualizarMedico
			@p_id				= @p_id,
			@p_nombre			= @p_nombre,
			@p_apellido			= @p_apellido,
			@p_matricula		= @p_matricula,
			@p_id_especialidad	= @p_id_especialidad
	END
	ELSE
	BEGIN
		INSERT INTO gestion_sede.Medico (
			nombre,
			apellido,
			matricula,
			id_especialidad
		)
		VALUES (
			@p_nombre,
			@p_apellido,
			@p_matricula,
			@p_id_especialidad
		)

	END
END
GO

-- BORRAR MEDICO

CREATE OR ALTER PROCEDURE gestion_sede.BorrarMedico
	@p_id INT
AS
	DELETE FROM gestion_sede.Medico WHERE id = @p_id;		
GO


--- CREACION STORE PROCEDURES DIASXSEDE

-- INSERTAR DIASXSEDE

CREATE OR ALTER PROCEDURE gestion_sede.InsertarDiasXSede
	@p_id					INT,
	@p_id_sede				INT,
	@p_id_medico			INT, 
	@p_id_reserva_turno		INT,
	@p_dia					DATE, 
	@p_hora_inicio			TIME
AS
	IF(DATEPART(MINUTE, @p_hora_inicio) IN (0,15,30,45))
		INSERT INTO gestion_sede.DiasXSede(
			id,
			id_sede,
			id_medico,
			id_reserva_turno,
			dia,
			hora_inicio
		)
		VALUES (
			@p_id,
			@p_id_sede,
			@p_id_medico,
			@p_id_reserva_turno,
			@p_dia,
			@p_hora_inicio
		);
GO	

-- ACTUALIZAR DIASXSEDE

CREATE OR ALTER PROCEDURE gestion_sede.ActualizarDiasXSede 
	@p_id				INT,
	@p_id_sede			INT	 = NULL,
	@p_id_medico		INT	 = NULL,
	@p_id_reserva_turno	INT,
	@p_dia				DATE = NULL, 
	@p_hora_inicio		TIME = NULL
AS
BEGIN

	DECLARE
		@id_sede			INT,
		@id_medico			INT,
		@id_reserva_turno	INT,
		@dia				DATE,
		@hora_inicio		TIME
	SELECT
		@id_sede		= id_sede,
		@id_medico		= id_medico,
		@dia			= dia,
		@hora_inicio	= hora_inicio
	FROM gestion_sede.DiasXSede
	WHERE id = @p_id

    UPDATE gestion_sede.DiasXSede
    SET
        id_sede			= ISNULL(@p_id_sede, @id_sede),
        id_medico		= ISNULL(@p_id_medico, @id_medico),
        dia				= ISNULL(@p_dia, @dia),
        hora_inicio		= ISNULL(@p_hora_inicio, @hora_inicio)
    WHERE id = @p_id;
END
GO

-- BORRAR DIASXSEDE

CREATE OR ALTER PROCEDURE gestion_sede.BorrarDias
	@p_sede		INT,
	@p_medico	INT
AS
	DELETE gestion_sede.Diasxsede 
	WHERE id_sede = @p_sede 
		AND id_medico = @p_medico;		
GO

---- CREACION STORE PROCEDURES ESPECIALIDAD

--- INSERTAR ESPECIALIDAD

CREATE OR ALTER PROCEDURE gestion_sede.InsertarEspecialidad
	@p_id		INT			= NULL,
	@p_nombre	VARCHAR(30)
AS
BEGIN

	IF NOT EXISTS(
		SELECT 1
		FROM gestion_sede.Especialidad
		WHERE nombre = @p_nombre
	)
	BEGIN
		INSERT INTO gestion_sede.Especialidad(
			nombre
		) 
		VALUES (
			@p_nombre
		);
	END

	
END
GO

--- ACTUALIZAR ESPECIALIDAD

CREATE OR ALTER PROCEDURE gestion_turno.ActualizarEspecialidad
	@p_id		INT,
	@p_nombre	VARCHAR(30) = NULL
AS
BEGIN
	DECLARE
		@nombre         VARCHAR(30)

	SELECT 
		@nombre         = nombre
	FROM gestion_sede.Especialidad
	WHERE id = @p_id

	UPDATE gestion_sede.Especialidad
	SET	
		nombre			= ISNULL(@p_nombre, @nombre)
	WHERE id = @p_id
END
GO

--- BORRAR ESPECIALIDAD

CREATE OR ALTER PROCEDURE gestion_turno.BorrarEspecialidad
	@p_id		INT
AS
BEGIN
	DELETE gestion_sede.Especialidad
	WHERE id = @p_id
END
GO

---- CREACION STORE PROCEDURES GESTION TURNO

--- CREACION STORE PROCEDURES ESTADO TURNO

-- INSERTAR ESTADO TURNO
CREATE OR ALTER PROCEDURE gestion_turno.InsertarEstadoTurno
	@p_id		INT,
	@p_nombre	VARCHAR(11)
AS
BEGIN
	INSERT INTO gestion_turno.EstadoTurno(id, nombre) VALUES (@p_id, @p_nombre);
END
GO

-- ACTUALIZAR ESTADO TURNO

CREATE OR ALTER PROCEDURE gestion_turno.ActualizarEstadoTurno
	@p_id		INT,
	@p_nombre	VARCHAR(11) = NULL
AS
BEGIN
	DECLARE
		@nombre         VARCHAR(11)

	SELECT 
		@nombre         = nombre
	FROM gestion_turno.EstadoTurno
	WHERE id = @p_id

	UPDATE gestion_turno.EstadoTurno
	SET	
		nombre			= ISNULL(@p_nombre, @nombre)
	WHERE id = @p_id
END
GO

-- BORRAR ESTADO
CREATE OR ALTER PROCEDURE gestion_turno.BorrarEstadoTurno
	@p_id		INT
AS
BEGIN
	DELETE gestion_turno.EstadoTurno
	WHERE id = @p_id
END
GO

--- CREACION STORE PROCEDURES TIPO DE TURNO

-- ACTUALIZAR TIPO DE TURNO

CREATE OR ALTER PROCEDURE gestion_turno.ActualizarTipoTurno
    @p_id           INT,
    @p_nombre       VARCHAR(11) = NULL
AS
BEGIN
	DECLARE
		@nombre         VARCHAR(11)

	SELECT 
		@nombre         = nombre
	FROM gestion_turno.TipoTurno
	WHERE id = @p_id

	UPDATE gestion_turno.TipoTurno
	SET	
		nombre			= ISNULL(@p_nombre, @nombre)
	WHERE id = @p_id

END;
GO

-- INSERTAR TIPO DE TURNO

CREATE OR ALTER PROCEDURE gestion_turno.InsertarTipoTurno
	@p_id		INT,
	@p_nombre	VARCHAR(20)
AS
BEGIN
	INSERT INTO gestion_turno.TipoTurno(id, nombre) VALUES (@p_id, @p_nombre);
END
GO

-- BORRAR TIPO DE TURNO

CREATE OR ALTER PROCEDURE gestion_turno.EliminarTipoTurno
	@p_id		INT
AS
BEGIN
	DELETE gestion_turno.TipoTurno
	WHERE id = @p_id

END
GO

--- CREACION STORE PROCEDURES RESERVA TURNO

-- ACTUALIZAR RESERVA DE TURNO

CREATE OR ALTER PROCEDURE gestion_turno.ActualizarReservaTurno
    @p_id						INT,
    @p_fecha					DATE	= NULL,
	@p_hora						TIME	= NULL,
	@p_id_paciente				INT		= NULL,
	@p_id_estado_turno			INT		= NULL,
	@p_id_tipo_turno			INT		= NULL,
	@p_borrado_logico			BIT		= NULL
AS
BEGIN
	DECLARE
		@fecha					DATE,
		@hora					TIME,
		@id_paciente			INT,
		@id_estado_turno		INT,
		@id_tipo_turno			INT,
		@borrado_logico			BIT

	SELECT 
		@fecha					= fecha,
		@hora					= hora,
		@id_paciente			= id_paciente,
		@id_estado_turno		= id_estado_turno,
		@id_tipo_turno			= id_tipo_turno,
		@borrado_logico			= borrado_logico
	FROM gestion_turno.ReservaTurno
	WHERE id = @p_id

	UPDATE gestion_turno.ReservaTurno
	SET	
		fecha					= ISNULL(@p_fecha, @fecha),
		hora					= ISNULL(@p_hora, @hora),
		id_paciente				= ISNULL(@p_id_paciente, @id_paciente),
		id_estado_turno			= ISNULL(@p_id_estado_turno, @id_estado_turno),
		id_tipo_turno			= ISNULL(@p_id_tipo_turno, @id_tipo_turno),
		borrado_logico			= ISNULL(@p_borrado_logico, @borrado_logico)
	WHERE id = @p_id

END;
GO

-- INSERTAR RESERVA DE TURNO

CREATE OR ALTER PROCEDURE gestion_turno.InsertarReservaTurno
	@p_id						INT,
	@p_fecha					DATE,
	@p_hora						TIME,
	@p_id_paciente				INT,
	@p_id_medico				INT	= NULL,
	@p_id_especialidad			INT	= NULL,
	@p_id_sede_atencion			INT	= NULL,
	@p_id_tipo_turno			INT
AS
BEGIN
	DECLARE @disponiblidad	INT
	DECLARE @id_estado		INT
	DECLARE @existe			BIT
	
	IF EXISTS(
		SELECT 1
		FROM gestion_turno.ReservaTurno
		WHERE id = @p_id
	)
	BEGIN
		EXEC gestion_turno.ActualizarReservaTurno
				@p_id				= @p_id,
				@p_borrado_logico	= 1
	END
	ELSE
	BEGIN
		/*
			Los turnos para atención médica tienen como estado inicial disponible, según el médico, la 
			especialidad y la sede.
		*/
		EXEC gestion_turno.ConsultarDisponibilidad
				@p_id_medico		= @p_id_medico,
				@p_id_especialidad	= @p_id_especialidad,
				@p_id_sede_atencion = @p_id_sede_atencion,
				@r_disponiblidad	= @disponiblidad	OUTPUT

		IF @disponiblidad = 1
		BEGIN
			SET @id_estado = (SELECT id FROM gestion_turno.EstadoTurno WHERE nombre = 'Disponible')
		END
		ELSE
		BEGIN
			SET @id_estado = (SELECT id FROM gestion_turno.EstadoTurno WHERE nombre = 'Pendiente')
		END
		INSERT INTO gestion_turno.ReservaTurno(
			id,
			fecha,
			hora,
			id_paciente,
			id_estado_turno,
			id_tipo_turno
		)		
		VALUES (
			@p_id,
			@p_fecha,
			@p_hora,
			@p_id_paciente,
			@id_estado,
			@p_id_tipo_turno
		)
	END
END
GO

-- BORRAR RESERVA DE TURNO

CREATE OR ALTER PROCEDURE gestion_turno.BorrarReservaTurno
	@p_id	INT
AS
BEGIN
	UPDATE gestion_turno.ReservaTurno
	SET borrado_logico = 1
	WHERE id = @p_id
END
GO


--- FUNCIONES Y PROCEDIMIENTOS PARA LOS ITEMS DEL ENUNCIADO


/*
Los estudios clínicos deben ser autorizados, e indicar si se cubre el costo completo del mismo o solo 
un porcentaje. El sistema de Cure se comunica con el servicio de la prestadora, se le envía el código 
del estudio, el dni del paciente y el plan; el sistema de la prestadora informa si está autorizado o no y 
el importe a facturarle al paciente. 
*/

CREATE OR ALTER PROCEDURE gestion_paciente.AutorizarEstudio
	@p_id_estudio		VARCHAR(30),
	@p_dni_paciente		INT,
	@p_plan_prestador	VARCHAR(30),	
	@p_ruta				VARCHAR(max),	
	@p_respuesta		VARCHAR(100) OUTPUT
AS
BEGIN
	set nocount on
	-- busco id de paciente/historia clinica con el dni recibido
	DECLARE @id_historia_clinica	INT				= (SELECT id FROM gestion_paciente.Paciente WHERE num_doc = @p_dni_paciente)
	-- busco si esta autorizado el estudio
	DECLARE @autorizado				BIT				= (SELECT autorizado FROM gestion_paciente.Estudio WHERE id = @p_id_estudio AND id_paciente = @id_historia_clinica) 
	-- busco nombre del estudio relacionado al codigo recibido
	DECLARE @nombre_estudio			VARCHAR(100)	= (SELECT nombre_estudio FROM gestion_paciente.Estudio WHERE id = @p_id_estudio AND id_paciente = @id_historia_clinica)

	-- para el nombre del estudio y el plan recibido calculo importe y verifico si necesita autorizacion
	DECLARE @importe				DECIMAL(10,2)
	DECLARE @req_autorizacion		VARCHAR(5)
	-- para guardar el archivo json en formato texto plano
	DECLARE @json					VARCHAR(max)
	-- para verificar la existencia del estudio y plan recibido
	DECLARE @auxiliar				INT
	SET		@auxiliar = 0

	CREATE TABLE #json_TT (texto VARCHAR(max))
	DECLARE @consulta_sql VARCHAR(max) = 'BULK INSERT #json_TT 
											FROM ''' + @p_ruta + ''' 
											WITH (CODEPAGE = ''65001'')'
	EXEC (@consulta_sql)

	SELECT @json = STRING_AGG(texto, ' ')	-- concatena todas las filas
	FROM #json_TT;

	SELECT
		@importe			= CAST(JSON_VALUE(value, '$."Porcentaje Cobertura"') AS DECIMAL(10,2)) 
								* CAST(JSON_VALUE(value, '$.Costo') AS DECIMAL(10,2)) /100,
		@req_autorizacion	= JSON_VALUE(value, '$."Requiere autorizacion"'),
		@auxiliar = @auxiliar + 1
	FROM OPENJSON(@json) AS j
	WHERE JSON_VALUE(value, '$.Estudio') = @nombre_estudio 
		AND JSON_VALUE(value, '$.Plan') = @p_plan_prestador
	
	IF	@auxiliar = 0
	BEGIN
		SET @p_respuesta = 'No se encontro informacion para el estudio y plan especificados.';
		RETURN;
	END
	SET @p_respuesta = 'El importe a facturar al paciente es: ' + CAST(ISNULL(@importe, 0) as varchar(15)) + '$'
	-- si necesita autorizacion y no la tiene, entonces rechazado.
	IF @req_autorizacion = 'true' AND @autorizado = 0
	BEGIN
		SET @p_respuesta = 'Se requiere autorizacion y el estudio no esta autorizado.'
	END

END;
GO


/*
Adicionalmente se requiere que el sistema sea capaz de generar un archivo XML detallando 
los turnos atendidos para informar a la Obra Social. El mismo debe constar de los datos del 
paciente (Apellido, nombre, DNI), nombre y matrícula del profesional que lo atendió, fecha, 
hora, especialidad. Los parámetros de entrada son el nombre de la obra social y un intervalo 
de fechas. 
*/

CREATE OR ALTER PROCEDURE gestion_turno.ExportarTurnos
	@p_obra_social		VARCHAR(30),
	@p_fecha_inicial	DATE,
	@p_fecha_final		DATE
AS
BEGIN
	DECLARE @id_estado	INT
	SET @id_estado = (SELECT id FROM gestion_turno.EstadoTurno WHERE nombre = 'Atendido')

	SELECT P.nombre, 
			P.apellido, 
			P.num_doc,
			M.nombre,
			M.matricula,
			DXS.dia,
			DXS.hora_inicio,
			E.nombre
	FROM gestion_paciente.Paciente		P
		JOIN gestion_turno.ReservaTurno RT	ON RT.id_paciente = P.id
		JOIN gestion_sede.DiasXSede		DXS	ON DXS.id_reserva_turno = RT.id 
		JOIN gestion_sede.Medico		M	ON M.id = DXS.id_medico 
		JOIN gestion_sede.Especialidad	E	ON E.id = M.id_especialidad
		JOIN gestion_paciente.Cobertura C	ON C.id_paciente = P.id
		JOIN gestion_paciente.Prestador Pre	ON Pre.id_cobertura = C.id

	WHERE Pre.nombre = @p_obra_social
		AND	DXS.dia >= @p_fecha_inicial
		AND	DXS.dia <= @p_fecha_final
		AND RT.id_estado_turno = @id_estado
	FOR XML RAW ('Turno'), ROOT('TurnosAtendidos');
END
GO

/*
Los prestadores están conformador por Obras Sociales y Prepagas con las cuales se establece una 
alianza comercial.  Dicha alianza puede finalizar en cualquier momento, por lo cual debe poder ser 
actualizable de forma inmediata si el contrato no está vigente.  En caso de no estar vigente el contrato, 
deben ser anulados todos los turnos de pacientes que se encuentren vinculados a esa prestadora y 
pasar a estado disponible. 
*/

CREATE OR ALTER PROCEDURE gestion_turno.AnularTurnos
	@p_id_prestador	INT
AS
BEGIN
	UPDATE gestion_turno.ReservaTurno
	SET id_estado_turno = (SELECT id FROM gestion_turno.EstadoTurno WHERE nombre = 'Disponible')
	FROM gestion_turno.ReservaTurno RT
		JOIN gestion_paciente.Paciente	P	ON P.id = RT.id_paciente
		JOIN gestion_paciente.Cobertura C	ON C.id_paciente = P.id
		JOIN gestion_paciente.Prestador Pre ON Pre.id_cobertura = C.id
	WHERE Pre.id = @p_id_prestador

END
GO


--- CREACION DE PROCEDIMIENTOS DE IMPORTACION

-- IMPORTAR PACIENTE

CREATE OR ALTER PROCEDURE gestion_paciente.ImportarPacientes
	@p_ruta				VARCHAR(max)
AS
BEGIN
	set nocount on
	CREATE TABLE #csv_TT (
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
	DECLARE @consulta_sql VARCHAR(max) = 'BULK INSERT #csv_TT 
											FROM ''' + @p_ruta + ''' 
											WITH (
												FIELDTERMINATOR = '';'',
												ROWTERMINATOR = ''\n'',
												CODEPAGE = ''65001'',
												FIRSTROW = 2
											);'
	EXEC (@consulta_sql)
	
	-- cursor es como un puntero a un archivo, se tiene que abrir, cerrar y desalocar por tema de liberacion de recursos
	-- con esto podemos iterar sobre cada fila y ejecutar alguna accion, osea ejecutamos el sp de insertar
	-- @@fetch_status devuelve si la ultima operacion fue exitosa, si insertarPaciente no inserto, entonces fetch_status se vuelve 1 y termina el ciclo
	-- si inserto, entonces se mantiene en 0
	DECLARE 
		@nombre				VARCHAR(30), 
		@apellido			VARCHAR(30), 
		@fecha_nac			VARCHAR(10),
		@fecha_nac_date		DATE,
		@tipo_doc			CHAR(5),
		@nro_doc			INT, 
		@sexo				VARCHAR(11), 
		@genero				VARCHAR(9),
		@telefono			VARCHAR(15),
		@nacionalidad		VARCHAR(30), 
		@mail				VARCHAR(30),
		@calle_y_nro		VARCHAR(50),
        @localidad			VARCHAR(50),
        @provincia			VARCHAR(50),
        @calle				VARCHAR(30),
        @numero				VARCHAR(30),
		@id_paciente		INT,
		@apellido_materno	VARCHAR(30)

	DECLARE cursor_pacientes CURSOR FOR 
    SELECT nombre, apellido, fecha_nac, tipo_doc, nro_doc, sexo, genero, telefono, nacionalidad, mail, calle_y_nro, localidad, provincia 
    FROM #csv_TT;

	OPEN cursor_pacientes

	FETCH NEXT FROM cursor_pacientes INTO @nombre, @apellido, @fecha_nac, @tipo_doc, @nro_doc, @sexo, @genero, @telefono, @nacionalidad, @mail, @calle_y_nro, @localidad, @provincia;

	WHILE @@FETCH_STATUS = 0	
	BEGIN
		SET @Fecha_nac_date = TRY_CONVERT(DATE, @Fecha_nac, 103);	-- 103 es el formato dd/mm/aaaa
		
        SELECT @calle = calle, @numero = numero FROM gestion_paciente.ParsearDomicilio (@calle_y_nro);
		SET @apellido_materno = gestion_paciente.LimpiarApellidoMaterno (@apellido)

		EXEC gestion_paciente.InsertarPaciente
			@p_nombre			= @nombre,
			@p_apellido			= @apellido,
			@p_apellido_materno = @apellido_materno,
			@p_fecha_nac		= @fecha_nac_date,
			@p_tipo_doc			= @tipo_doc,
			@p_num_doc			= @nro_doc,
			@p_sexo				= @sexo,
			@p_genero			= @genero,
			@p_tel_fijo			= @telefono,
			@p_nacionalidad		= @nacionalidad,
			@p_mail				= @mail,
			@p_id_identity		= @id_paciente	OUTPUT
	
		EXEC gestion_paciente.InsertarDomicilio
			@p_id_paciente	= @id_paciente,
			@p_calle		= @calle,
			@p_numero		= @numero,
			@p_pais			= @nacionalidad,
			@p_localidad	= @localidad,
			@p_provincia	= @provincia
	
		FETCH NEXT FROM cursor_pacientes INTO @nombre, @apellido, @fecha_nac, @tipo_doc, @nro_doc, @sexo, @genero, @telefono, @nacionalidad, @mail, @calle_y_nro, @localidad, @provincia;
	END
	CLOSE cursor_pacientes
	DEALLOCATE cursor_pacientes	
	
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
	EXEC (@consulta_sql)

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
	EXEC (@consulta_sql)

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

EXEC gestion_paciente.ImportarSede
	@p_ruta = 'C:\Users\Cristian B\Desktop\Datasets---Informacion-necesaria\Dataset\Sedes.csv'
	
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
	EXEC (@consulta_sql)

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


--- CREACION LOGINS
EXECUTE AS LOGIN = 'sa'	-- ya que tiene todo el control para asignar permisos

-- ADMINISTRADOR
IF NOT EXISTS (
	SELECT 1
	FROM sys.syslogins
	WHERE name = 'db_administrador'
)
BEGIN
	CREATE LOGIN db_administrador WITH PASSWORD = 'pepe123'
END

-- DESARROLLADOR
IF NOT EXISTS (
	SELECT 1
	FROM sys.syslogins
	WHERE name = 'db_desarrollador'
)
BEGIN
	CREATE LOGIN db_desarrollador WITH PASSWORD = 'pepe123'
END

-- OPERADOR DE LA CLINICA
IF NOT EXISTS (
	SELECT 1
	FROM sys.syslogins
	WHERE name = 'clinica_operador'
)
BEGIN
	CREATE LOGIN clinica_operador WITH PASSWORD = 'pepe123'
END

-- ADMINISTRADOR DE LA CLINICA
IF NOT EXISTS (
	SELECT 1
	FROM sys.syslogins
	WHERE name = 'clinica_admin'
)
BEGIN
	CREATE LOGIN clinica_admin WITH PASSWORD = 'pepe123'
END

-- IMPORTADOR DE LA CLINICA
IF NOT EXISTS (
	SELECT 1
	FROM sys.syslogins
	WHERE name = 'clinica_importador'
)
BEGIN
	CREATE LOGIN clinica_importador WITH PASSWORD = 'pepe123'
END

REVERT	-- para quitar el seteo de usuario sa
GO

--- CREACION USUARIOS

EXECUTE AS LOGIN = 'sa'	-- ya que tiene todo el control para asignar permisos


-- USUARIO ADMINISTRADOR
IF NOT EXISTS (
	SELECT 1
	FROM sys.sysusers
	WHERE name = 'db_administrador'
)
BEGIN
	CREATE USER db_administrador FOR LOGIN db_administrador

	GRANT ALL TO db_administrador
END
GO

-- USUARIO DESARROLLADOR
IF NOT EXISTS (
	SELECT 1
	FROM sys.sysusers
	WHERE name = 'db_desarrollador'
)
BEGIN
	CREATE USER db_desarrollador FOR LOGIN db_desarrollador

	GRANT SELECT, INSERT, UPDATE, DELETE ON SCHEMA::gestion_paciente	TO db_desarrollador
	GRANT SELECT, INSERT, UPDATE, DELETE ON SCHEMA::gestion_sede		TO db_desarrollador
	GRANT SELECT, INSERT, UPDATE, DELETE ON SCHEMA::gestion_turno		TO db_desarrollador
END
GO

-- USUARIO OPERADOR DE LA CLINICA
IF NOT EXISTS (
	SELECT 1
	FROM sys.sysusers
	WHERE name = 'clinica_operador'
)
BEGIN
	CREATE USER clinica_operador FOR LOGIN clinica_operador

	GRANT EXECUTE ON OBJECT::gestion_paciente.InsertarPaciente		TO clinica_operador
	GRANT EXECUTE ON OBJECT::gestion_paciente.ActualizarPaciente	TO clinica_operador
	GRANT EXECUTE ON OBJECT::gestion_paciente.BorrarPaciente		TO clinica_operador

	GRANT EXECUTE ON OBJECT::gestion_turno.InsertarReservaTurno		TO clinica_operador
	GRANT EXECUTE ON OBJECT::gestion_turno.ActualizarReservaTurno	TO clinica_operador
	GRANT EXECUTE ON OBJECT::gestion_turno.BorrarReservaTurno		TO clinica_operador
END
GO

-- USUARIO ADMINISTRADOR DE LA CLINICA
IF NOT EXISTS (
	SELECT 1
	FROM sys.sysusers
	WHERE name = 'clinica_admin'
)
BEGIN
	CREATE USER clinica_admin FOR LOGIN clinica_admin

	GRANT EXECUTE ON SCHEMA::gestion_paciente	TO clinica_admin
	GRANT EXECUTE ON SCHEMA::gestion_sede		TO clinica_admin
	GRANT EXECUTE ON SCHEMA::gestion_turno		TO clinica_admin
END
GO

-- USUARIO IMPORTADOR DE LA CLINICA
IF NOT EXISTS (
	SELECT 1
	FROM sys.sysusers
	WHERE name = 'clinica_importador'
)
BEGIN
	CREATE USER clinica_importador FOR LOGIN clinica_importador

	GRANT EXECUTE ON OBJECT::gestion_paciente.ImportarPacientes			TO clinica_importador
	GRANT EXECUTE ON OBJECT::gestion_paciente.ImportarPrestadores		TO clinica_importador
END
GO
REVERT	-- para quitar el seteo de usuario sa
GO
