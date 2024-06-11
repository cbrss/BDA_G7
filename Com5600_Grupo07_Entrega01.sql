/*
		TODO: agregar enunciado, fecha entrega, nro comision, nro grupo, nombre materia, nombres y dni
		BASE DE DATOS APLICADA
		GRUPO: 07


		admite '_' todos los tipos de objetos
*/


---	CREACION DE BASE DE DATOS

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

use Com5600G07
go

--- CREACION DE ESQUEMAS

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
		usr_actualizacion	DATE,
		borrado_logico		BIT DEFAULT 0,

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
		nombre_estudio		VARCHAR(100),
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
		id_paciente			INT,
		calle				VARCHAR(30),
		numero				INT,
		piso				INT,
		departamento		INT,
		cod_postal			INT,
		pais				VARCHAR(30),
		provincia			VARCHAR(30),
		localidad			VARCHAR(30),

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
		id_paciente			INT,
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
		id_cobertura		INT,
		nombre				VARCHAR(30),
		[plan]				VARCHAR(30),

		CONSTRAINT PK_PrestadorID PRIMARY KEY (id),
		CONSTRAINT FK_Prestador_CoberturaID FOREIGN KEY (id_cobertura) REFERENCES gestion_paciente.Cobertura(id)
	);
END;
GO



--- CREACION STORE PROCEDURES PACIENTE

-- Buscar existencia del paciente
CREATE OR ALTER PROCEDURE gestion_paciente.usp_ExistePaciente
	@p_nombre				VARCHAR(30),
	@p_apellido				VARCHAR(30),
	@p_fecha_nac			DATE,
	@p_tipo_doc				CHAR(5),
	@p_num_doc				INT,
	@p_sexo					VARCHAR(11),
	@p_genero				VARCHAR(9),
	@p_nacionalidad			VARCHAR(20),
	@r_existe				BIT	OUTPUT,
	@r_borrado				BIT = NULL OUTPUT
AS
BEGIN
	SET @r_existe = 0
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
END
GO	

-- Insertar
-- los "fecha" siempre van con un getDate, el usr actualizacion es cuando se crea el usuario y asignamos el nombre ahi
-- los NULL son porque en la estructura de los archivos a importar no son valores dados.
-- el null en p_id es un caso especifico, es identity por lo tanto, no deberia poder enviarse
-- pero al manejar borrado logico, es de esperar que algun operador del hospital envie algun ID de un archivo fisico que ellos tengan del paciente
-- donde se vea el id que se le fue asignado, por lo tanto existen 2 casos:
--	el id es importado, por lo tanto, se utiliza identity y se inserta directamente
--	el id es ingresado por operador, por lo tanto, se valida que exista dicho paciente previo a intentar insertarlo

-- @p_id_identity es para la importacion de archivos, contiene el ID generado por identity (obtenido de SCOPE_IDENTITY())
CREATE OR ALTER PROCEDURE gestion_paciente.usp_InsertarPaciente
	@p_id					INT				= NULL,
	@p_nombre				VARCHAR(30),
	@p_apellido				VARCHAR(30),
	@p_apellido_materno		VARCHAR(30)		= NULL,
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
	EXEC gestion_paciente.usp_ExistePaciente
		@p_nombre			= @p_nombre,
		@p_apellido			= @p_apellido,
		@p_fecha_nac		= @p_fecha_nac,
		@p_tipo_doc			= @p_tipo_doc,
		@p_num_doc			= @p_num_doc,
		@p_sexo				= @p_sexo,
		@p_genero			= @p_genero,
		@p_nacionalidad		= @p_nacionalidad,
		@r_existe			= @existe OUTPUT,
		@r_borrado			= @borrado OUTPUT

	IF @existe = 1 AND @borrado = 1						--	CASO: el operador de la clinica reincorpora un paciente
    BEGIN
		EXEC gestion_paciente.usp_ActualizarPaciente
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
            fecha_actualizacion
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
            GETDATE()
        );
		SET @p_id_identity = SCOPE_IDENTITY()
    END
END;
GO


-- ACTUALIZACION

CREATE OR ALTER PROCEDURE gestion_paciente.usp_ActualizarPaciente
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
        fecha_actualizacion		= GETDATE()
	WHERE id = @p_id
END;
GO

-- Borrado


CREATE OR ALTER PROCEDURE gestion_paciente.usp_BorrarPaciente
	@p_id INT
AS
BEGIN
	UPDATE gestion_paciente.Paciente
	SET	borrado_logico = 1
	WHERE id = @p_id;
END;
GO

--- CREACION STORE PROCEDURES ESTUDIO


-- INSERTAR


CREATE OR ALTER PROCEDURE gestion_paciente.usp_InsertarEstudio
	@p_id				INT,
	@p_id_paciente		INT,
	@p_fecha			DATE,
	@p_nombre_estudio	VARCHAR(100),
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

-- ACTUALIZAR
CREATE OR ALTER PROCEDURE gestion_paciente.usp_ActualizarEstudio
    @p_id                   INT,
    @p_id_paciente          INT,
    @p_fecha                DATE			= NULL,
    @p_nombre_estudio       VARCHAR(100)	= NULL,
    @p_doc_resultado        VARCHAR(MAX)	= NULL,
    @p_img_resultado        VARCHAR(MAX)	= NULL	
AS
BEGIN
	DECLARE
		@fecha				DATE,
		@nombre_estudio		VARCHAR(100),
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


-- BORRADO


CREATE OR ALTER PROCEDURE gestion_paciente.usp_BorrarEstudio
	@p_id INT
AS
BEGIN
	UPDATE gestion_paciente.Estudio
	SET	borrado_logico = 1
	WHERE id = @p_id;
END;
GO


--- CREACION STORE PROCEDURES USUARIO


-- INSERTAR


CREATE OR ALTER PROCEDURE gestion_paciente.usp_InsertarUsuario
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

-- ACTUALIZAR

CREATE OR ALTER PROCEDURE gestion_paciente.usp_ActualizarUsuario
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

-- BORRADO


CREATE OR ALTER PROCEDURE gestion_paciente.usp_BorrarUsuario
	@p_id INT
AS
BEGIN
	DELETE gestion_paciente.Usuario
	WHERE id = @p_id;
END;
GO


--- CREACION STORE PROCEDURES DOMICILIO


-- INSERTAR


CREATE OR ALTER PROCEDURE gestion_paciente.usp_InsertarDomicilio
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


-- ACTUALIZAR
CREATE OR ALTER PROCEDURE gestion_paciente.usp_ActualizarDomicilio
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


-- BORRADO


CREATE OR ALTER PROCEDURE gestion_paciente.usp_BorrarDomicilio
	@p_id INT
AS
BEGIN
	DELETE gestion_paciente.Domicilio
	WHERE id = @p_id;
END;
GO


--- CREACION STORE PROCEDURES COBERTURA


-- INSERTAR


CREATE OR ALTER PROCEDURE gestion_paciente.usp_InsertarCobertura
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


 -- ACTUALIZAR

 CREATE OR ALTER PROCEDURE gestion_paciente.usp_ActualizarCobertura
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


-- BORRADO


CREATE OR ALTER PROCEDURE gestion_paciente.usp_BorrarCobertura
	@p_id INT
AS
BEGIN
	DELETE gestion_paciente.Cobertura
	WHERE id = @p_id;
END;
GO


--- CREACION STORE PROCEDURES PRESTADOR


CREATE OR ALTER PROCEDURE gestion_paciente.usp_InsertarPrestador
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


-- ACTUALIZAR

CREATE OR ALTER PROCEDURE gestion_paciente.usp_ActualizarPrestador
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

-- BORRADO


CREATE OR ALTER PROCEDURE gestion_paciente.usp_BorrarPrestador
	@p_id INT
AS
BEGIN
	DELETE gestion_paciente.Prestador
	WHERE id = @p_id;
END;
GO

-- FUNCION PARA IMPORTAR PACIENTES

-- Av. Córdoba 2529
-- ENTRE RIOS 354
-- CHACABUCO 159 Y MONTECASEROS | LOPEZ ENTRE PLANEZ Y MATIENZO
-- AVENIDA 9 DE JULIO 857
-- RUTA NACIONAL 22 KM 856 (ASCENDENTE)
-- 51 Nº 456
-- Av. 520 2650


/*testing:
CREATE PROCEDURE ImprimirVariable
@p_var varchar(max)
AS
BEGIN
    PRINT @p_var;
END;
GO


*/
CREATE OR ALTER FUNCTION gestion_paciente.fn_ParsearDomicilio (@p_domicilio VARCHAR(50))
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
		-- CASO: RUTA NACIONAL 22 KM 856 (ASCENDENTE)
		IF @posicion_ini != 0
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


-- IMPORTAR PACIENTE

CREATE OR ALTER PROCEDURE gestion_paciente.usp_ImportarPacientes
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
		@nombre			VARCHAR(30), 
		@apellido		VARCHAR(30), 
		@fecha_nac		VARCHAR(10),
		@fecha_nac_date DATE,
		@tipo_doc		CHAR(5),
		@nro_doc		INT, 
		@sexo			VARCHAR(11), 
		@genero			VARCHAR(9),
		@telefono		VARCHAR(15),
		@nacionalidad	VARCHAR(30), 
		@mail			VARCHAR(30),
		@calle_y_nro	VARCHAR(50),
        @localidad		VARCHAR(50),
        @provincia		VARCHAR(50),
        @calle			VARCHAR(30),
        @numero			VARCHAR(30),
		@id_paciente	INT

	DECLARE cursor_pacientes CURSOR FOR 
    SELECT nombre, apellido, fecha_nac, tipo_doc, nro_doc, sexo, genero, telefono, nacionalidad, mail, calle_y_nro, localidad, provincia 
    FROM #csv_TT;

	OPEN cursor_pacientes

	FETCH NEXT FROM cursor_pacientes INTO @nombre, @apellido, @fecha_nac, @tipo_doc, @nro_doc, @sexo, @genero, @telefono, @nacionalidad, @mail, @calle_y_nro, @localidad, @provincia;

	WHILE @@FETCH_STATUS = 0	
	BEGIN
		SET @Fecha_nac_date = TRY_CONVERT(DATE, @Fecha_nac, 103);	-- 103 es el formato dd/mm/aaaa
		
        SELECT @calle = calle, @numero = numero FROM gestion_paciente.fn_ParsearDomicilio(@calle_y_nro);

		EXEC gestion_paciente.usp_InsertarPaciente
			@p_nombre		= @nombre,
			@p_apellido		= @apellido,
			@p_fecha_nac	= @fecha_nac_date,
			@p_tipo_doc		= @tipo_doc,
			@p_num_doc		= @nro_doc,
			@p_sexo			= @sexo,
			@p_genero		= @genero,
			@p_tel_fijo		= @telefono,
			@p_nacionalidad = @nacionalidad,
			@p_mail			= @mail,
			@p_id_identity	= @id_paciente	OUTPUT
	
		EXEC gestion_paciente.usp_InsertarDomicilio
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
TODO: falta apellido materno y en usr actualizacion ver el tema de rol

DECLARE @p_ruta VARCHAR(max) = 'C:\Users\Cristian B\Desktop\Datasets---Informacion-necesaria\Dataset\Pacientes.csv'; 

EXEC gestion_paciente.usp_ImportarPacientes 
		@p_ruta = @p_ruta
GO
*/

-- IMPORTAR PRESTADOR

CREATE OR ALTER PROCEDURE gestion_paciente.usp_ImportarPrestadores
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
		
		EXEC gestion_paciente.usp_InsertarPrestador
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

EXEC gestion_paciente.usp_ImportarPrestadores 
		@p_ruta = @p_ruta
GO

*/

/*
Los estudios clínicos deben ser autorizados, e indicar si se cubre el costo completo del mismo o solo 
un porcentaje. El sistema de Cure se comunica con el servicio de la prestadora, se le envía el código 
del estudio, el dni del paciente y el plan; el sistema de la prestadora informa si está autorizado o no y 
el importe a facturarle al paciente. 
*/

CREATE OR ALTER PROCEDURE gestion_paciente.usp_AutorizarEstudio
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
	where JSON_VALUE(value, '$.Estudio') = @nombre_estudio 
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
	-- TODO: posiblemente se borra al terminar el scoop
	drop table #json_TT
END;
GO
/*
-- para testear

DECLARE @p_id_estudio VARCHAR(30) = '123';
DECLARE @p_dni_paciente INT = 12345678; 
DECLARE @p_plan_prestador VARCHAR(30) = 'OSDE 510';
DECLARE @p_ruta VARCHAR(max) = 'C:\Users\Cristian B\Desktop\Datasets---Informacion-necesaria\Dataset\Centro_Autorizaciones.Estudios clinicos.json'; 
DECLARE @p_respuesta varchar(100)

EXEC gestion_paciente.usp_AutorizarEstudio 
	@p_id_estudio = @p_id_estudio,
	@p_dni_paciente = @p_dni_paciente,
	@p_plan_prestador = @p_plan_prestador,
	@p_ruta = @p_ruta,
	@p_respuesta = @p_respuesta OUTPUT

	print @p_respuesta

*/

-- CREACION LOGINS

CREATE LOGIN dba WITH PASSWORD = 'pepe123'
CREATE LOGIN desarrollador WITH PASSWORD = 'pepe123'
CREATE LOGIN operador_clinica WITH PASSWORD = 'pepe123'
CREATE LOGIN admin_clinica WITH PASSWORD = 'pepe123'
CREATE LOGIN importador_clinica WITH PASSWORD = 'pepe123'
GO

-- CREACION USUARIOS
USE master
CREATE USER dba FOR LOGIN dba
GRANT ALL TO dba
GO

USE Com5600G07

CREATE USER desarrollador FOR LOGIN desarrollador
GRANT SELECT, INSERT, UPDATE, DELETE ON SCHEMA::gestion_usuario		TO desarrollador
-- GRANT SELECT, INSERT, UPDATE, DELETE ON SCHEMA::gestion_sede		TO desarrollador
-- GRANT SELECT, INSERT, UPDATE, DELETE ON SCHEMA::gestion_turno	TO desarrollador
GO

CREATE USER operador_clinica FOR LOGIN operador_clinica;
GRANT EXECUTE ON OBJECT::gestion_paciente.usp_InsertarPaciente		TO operador_clinica
GRANT EXECUTE ON OBJECT::gestion_paciente.usp_ActualizarPaciente	TO operador_clinica
GRANT EXECUTE ON OBJECT::gestion_paciente.usp_EliminarPaciente		TO operador_clinica

-- GRANT EXECUTE ON OBJECT::gestion_paciente.usp_InsertarTurno		TO operador_clinica
-- GRANT EXECUTE ON OBJECT::gestion_paciente.usp_ActualizarTurno	TO operador_clinica
-- GRANT EXECUTE ON OBJECT::gestion_paciente.usp_EliminarTurno		TO operador_clinica
GO

CREATE USER admin_clinica FOR LOGIN admin_clinica
GRANT EXECUTE ON SCHEMA::gestion_paciente	TO admin_clinica
-- GRANT EXECUTE ON SCHEMA::gestion_sede	TO admin_clinica
-- GRANT EXECUTE ON SCHEMA::gestion_turno	TO admin_clinica
GO

CREATE USER importador_clinica FOR LOGIN importador_clinica
GRANT EXECUTE ON OBJECT::gestion_paciente.usp_ImportarPacientes			TO operador_clinica
GRANT EXECUTE ON OBJECT::gestion_paciente.usp_ImportarPrestadores		TO operador_clinica
GO



 IF NOT EXISTS (
    SELECT 1
    FROM sys.tables
    WHERE name = 'Sede'
    AND schema_id = SCHEMA_ID('gestion_sede')
)
BEGIN
	 CREATE TABLE gestion_sede.Sede (
	 id_sede INT not null PRIMARY KEY,
	 nombre VARCHAR(40),
	 direccion VARCHAR(30),
	 );
END
GO;


IF NOT EXISTS (
    SELECT 1
    FROM sys.tables
    WHERE name = 'Medico'
    AND schema_id = SCHEMA_ID('gestion_sede')
)
BEGIN
	 CREATE TABLE gestion_sede.Medico(
	 id_medico INT not null PRIMARY KEY,
	 nombre VARCHAR(25),
	 apellido VARCHAR(20),
	 matricula INT UNIQUE,
	 );
END;
GO;


IF NOT EXISTS (
    SELECT 1
    FROM sys.tables
    WHERE name = 'Diasxsede'
    AND schema_id = SCHEMA_ID('gestion_sede')
)
BEGIN
	 CREATE TABLE gestion_sede.Diasxsede (
	 id_sede int,
	 id_medico int unique,
	 dia date,
	 hora_inicio time,
	 CONSTRAINT FK_SedeID FOREIGN KEY (id_sede) REFERENCES gestion_sede.Sede(id_sede),
	 CONSTRAINT FK_MedicoID FOREIGN KEY (id_medico) REFERENCES gestion_sede.Medico(id_medico),
	 );
END;
GO;


 IF NOT EXISTS (
    SELECT 1
    FROM sys.tables
    WHERE name = 'Especialidad'
    AND schema_id = SCHEMA_ID('gestion_sede')
)
BEGIN
	 CREATE TABLE gestion_sede.Especialidad(
	 id_especialidad INT NOT NULL PRIMARY KEY,
	 nombre_especialidad VARCHAR(15),
	 );
END;
GO;

--- CREACION STORE PROCEDURES SEDE


CREATE PROCEDURE gestion_sede.usp_InsertarSede 
	@id INT, 
	@nomb VARCHAR(40), 
	@direc VARCHAR(30)
AS
	IF EXISTS (@id IN (SELECT id_sede FROM gestion_sede.Sede))
		EXEC gestion_sede.usp_ModificarSede(@id,@nomb,@direc)
	ELSE
		INSERT INTO gestion_sede.Sede VALUES (@id,@nomb,@direc);
	


CREATE PROCEDURE gestion_sede.usp_ModificarSede 
	@id INT, 
	@nomb VARCHAR(40), 
	@direc VARCHAR(30)
AS
BEGIN
	IF (@nomb IS NOT NULL)
		UPDATE gestion_sede.Sede SET nombre=@nomb WHERE id_sede=@id;
	IF (@direc IS NOT NULL)
		UPDATE gestion_sede.Sede SET direccion=@direc WHERE id_sede=@id;
END
GO


CREATE PROCEDURE gestion_sede.usp_BorrarSede
	@id INT
AS
	DELETE FROM gestion_sede.Sede WHERE id_sede=@id;
GO

--- CREACION STORE PROCEDURES MEDICO

CREATE PROCEDURE gestion_sede.usp_ModificarMedico
	@id INT, 
	@nombre VARCHAR(25), 
	@apellido VARCHAR(20),
	@matricula INT
AS
BEGIN
	IF (@nombre IS NOT NULL)
		UPDATE gestion_sede.Medico SET nombre=@nombre WHERE id_medico=@id;
	IF (@apellido IS NOT NULL)
		UPDATE gestion_sede.Medico SET apellido=@apellido WHERE id_medico=@id;
	IF(@matricula IS NOT NULL)
		UPDATE gestion_sede.Medico SET matricula=@matricula WHERE id_medico=@id;
END
GO


CREATE PROCEDURE gestion_sede.usp_InsertarMedico
	@id_medico INT, 
	@nombre VARCHAR(25), 
	@apellido VARCHAR(20),
	@matricula INT
AS
	IF EXISTS (@id IN (SELECT id_medico FROM gestion_sede.Medico))
		EXEC gestion_sede.usp_ModificarMedico(@id,@nomb,@direc)
	ELSE
		INSERT INTO gestion_sede.Medico VALUES (@id,@nombre,@apellido,@matricula);	
GO

CREATE PROCEDURE gestion_sede.usp_BorrarMedico
	@id INT
AS
	DELETE FROM gestion_sede.Medico WHERE id_medico=@id;		
GO


--- CREACION STORE PROCEDURES DIAS


CREATE PROCEDURE gestion_sede.usp_InsertarDias
	@id_sede INT,
	@id_medico INT, 
	@dia DATE, 
	@hora_inicio TIME
AS
	IF(MINUTE(@hora_inicio) IN (0,15,30,45))
		INSERT INTO gestion_sede.Medico VALUES (@id_sede,@id_medico,@dia,@hora_inicio);
GO	

CREATE PROCEDURE gestion_sede.usp_ModificarDias 
	@sede INT,
	@medico INT, 
	@dia DATE, 
	@hora TIME
AS
BEGIN
	IF (@dia IS NOT NULL)
		UPDATE gestion_sede.Dias SET dia=@dia WHERE id_sede=@sede AND id_medico=@medico;
	IF (@hora IS NOT NULL AND MINUTE(@hora_inicio) IN (0,15,30,45))
		UPDATE gestion_sede.Dias SET hora_inicio=@hora WHERE id_sede=@sede AND id_medico=@medico;
END
GO

CREATE PROCEDURE gestion_sede.usp_BorrarDias
	@sede INT,
	@medico INT
AS
	DELETE FROM gestion_sede.Diasxsede WHERE id_sede=@sede AND id_medico=@medico;		
GO
