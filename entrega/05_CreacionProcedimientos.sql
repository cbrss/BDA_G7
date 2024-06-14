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

---- CREACION STORE PROCEDURES ESQUEMA GESTION PACIENTE

--- CREACION STORE PROCEDURES PACIENTE
-- ACTUALIZAR PACIENTE

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

CREATE OR ALTER PROCEDURE gestion_paciente.usp_InsertarPaciente
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

	EXEC @existe = gestion_paciente.udf_ExistePaciente 
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


CREATE OR ALTER PROCEDURE gestion_paciente.usp_BorrarPaciente
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


CREATE OR ALTER PROCEDURE gestion_paciente.usp_InsertarEstudio
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

CREATE OR ALTER PROCEDURE gestion_paciente.usp_ActualizarEstudio
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

-- INSERTAR USUARIO

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

-- ACTUALIZAR USUARIO

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

-- BORRAR USUARIO


CREATE OR ALTER PROCEDURE gestion_paciente.usp_BorrarUsuario
	@p_id INT
AS
BEGIN
	DELETE gestion_paciente.Usuario
	WHERE id = @p_id;
END;
GO


--- CREACION STORE PROCEDURES DOMICILIO


-- INSERTAR DOMICILIO

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


-- ACTUALIZAR DOMICILIO
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


-- BORRAR DOMICILIO

CREATE OR ALTER PROCEDURE gestion_paciente.usp_BorrarDomicilio
	@p_id INT
AS
BEGIN
	DELETE gestion_paciente.Domicilio
	WHERE id = @p_id;
END;
GO


--- CREACION STORE PROCEDURES COBERTURA


-- INSERTAR COBERTURA

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


 -- ACTUALIZAR COBERTURA

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


-- BORRAR COBERTURA

CREATE OR ALTER PROCEDURE gestion_paciente.usp_BorrarCobertura
	@p_id INT
AS
BEGIN
	DELETE gestion_paciente.Cobertura
	WHERE id = @p_id;
END;
GO


--- CREACION STORE PROCEDURES PRESTADOR

-- INSERTAR PRESTADOR

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


-- ACTUALIZAR PRESTADOR

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

-- BORRAR PRESTADOR


CREATE OR ALTER PROCEDURE gestion_paciente.usp_BorrarPrestador
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

CREATE OR ALTER PROCEDURE gestion_sede.usp_ExisteSede
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

CREATE OR ALTER PROCEDURE gestion_sede.usp_ActualizarSede
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

CREATE OR ALTER PROCEDURE gestion_sede.usp_InsertarSede
	@p_id			INT			= NULL,
	@p_nombre		VARCHAR(30),
	@p_direccion	VARCHAR(30),
	@p_localidad	VARCHAR(30),
	@p_provincia	VARCHAR(30)
AS
BEGIN
	DECLARE @existe BIT

	EXEC gestion_sede.usp_ExisteSede
		@p_nombre		= @p_nombre,
		@p_direccion	= @p_direccion,
		@p_localidad	= @p_localidad,
		@p_provincia	= @p_provincia,
		@r_existe		= @existe OUTPUT

	IF @existe = 1
	BEGIN
		EXEC gestion_sede.usp_ActualizarSede
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

CREATE OR ALTER PROCEDURE gestion_sede.usp_BorrarSede
	@p_id	INT
AS
BEGIN
	DELETE gestion_sede.Sede 
	WHERE id = @p_id	
END
GO


--- CREACION STORE PROCEDURES MEDICO

-- BUSCAR MEDICO

CREATE OR ALTER PROCEDURE gestion_sede.usp_ExisteMedico 
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

CREATE OR ALTER PROCEDURE gestion_sede.usp_ActualizarMedico
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

CREATE OR ALTER PROCEDURE gestion_sede.usp_InsertarMedico
	@p_id				INT	= NULL, 
	@p_nombre			VARCHAR(30), 
	@p_apellido			VARCHAR(30),
	@p_matricula		INT,
	@p_id_especialidad	INT
AS
BEGIN
	DECLARE @existe	BIT
	EXEC @existe = gestion_sede.udf_ExisteMedico
		@p_nombre			= @p_nombre,
		@p_apellido			= @p_apellido,
		@p_matricula		= @p_matricula,
		@p_id_especialidad	= @p_id_especialidad

	IF @existe = 1
	BEGIN
		EXEC gestion_sede.usp_ActualizarMedico
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

CREATE OR ALTER PROCEDURE gestion_sede.usp_BorrarMedico
	@p_id INT
AS
	DELETE FROM gestion_sede.Medico WHERE id = @p_id;		
GO


--- CREACION STORE PROCEDURES DIASXSEDE

-- INSERTAR DIASXSEDE

CREATE OR ALTER PROCEDURE gestion_sede.usp_InsertarDiasXSede
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

CREATE OR ALTER PROCEDURE gestion_sede.usp_ActualizarDiasXSede 
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

CREATE OR ALTER PROCEDURE gestion_sede.usp_BorrarDias
	@p_sede		INT,
	@p_medico	INT
AS
	DELETE gestion_sede.Diasxsede 
	WHERE id_sede = @p_sede 
		AND id_medico = @p_medico;		
GO

---- CREACION STORE PROCEDURES ESPECIALIDAD

--- INSERTAR ESPECIALIDAD

CREATE OR ALTER PROCEDURE gestion_sede.usp_InsertarEspecialidad
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

CREATE OR ALTER PROCEDURE gestion_turno.usp_ActualizarEspecialidad
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

CREATE OR ALTER PROCEDURE gestion_turno.usp_BorrarEspecialidad
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
CREATE OR ALTER PROCEDURE gestion_turno.usp_InsertarEstadoTurno
	@p_id		INT,
	@p_nombre	VARCHAR(11)
AS
BEGIN
	INSERT INTO gestion_turno.EstadoTurno(id, nombre) VALUES (@p_id, @p_nombre);
END
GO

-- ACTUALIZAR ESTADO TURNO

CREATE OR ALTER PROCEDURE gestion_turno.usp_ActualizarEstadoTurno
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
CREATE OR ALTER PROCEDURE gestion_turno.usp_BorrarEstadoTurno
	@p_id		INT
AS
BEGIN
	DELETE gestion_turno.EstadoTurno
	WHERE id = @p_id
END
GO

--- CREACION STORE PROCEDURES TIPO DE TURNO

-- ACTUALIZAR TIPO DE TURNO

CREATE OR ALTER PROCEDURE gestion_turno.usp_ActualizarTipoTurno
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

CREATE OR ALTER PROCEDURE gestion_turno.usp_InsertarTipoTurno
	@p_id		INT,
	@p_nombre	VARCHAR(20)
AS
BEGIN
	INSERT INTO gestion_turno.TipoTurno(id, nombre) VALUES (@p_id, @p_nombre);
END
GO

-- BORRAR TIPO DE TURNO

CREATE OR ALTER PROCEDURE gestion_turno.usp_EliminarTipoTurno
	@p_id		INT
AS
BEGIN
	DELETE gestion_turno.TipoTurno
	WHERE id = @p_id

END
GO

--- CREACION STORE PROCEDURES RESERVA TURNO

-- ACTUALIZAR RESERVA DE TURNO

CREATE OR ALTER PROCEDURE gestion_turno.usp_ActualizarReservaTurno
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

CREATE OR ALTER PROCEDURE gestion_turno.usp_InsertarReservaTurno
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
		EXEC gestion_turno.usp_ActualizarReservaTurno
				@p_id				= @p_id,
				@p_borrado_logico	= 1
	END
	ELSE
	BEGIN
		/*
			Los turnos para atención médica tienen como estado inicial disponible, según el médico, la 
			especialidad y la sede.
		*/
		EXEC gestion_turno.usp_ConsultarDisponibilidad
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

CREATE OR ALTER PROCEDURE gestion_turno.usp_BorrarReservaTurno
	@p_id	INT
AS
BEGIN
	UPDATE gestion_turno.ReservaTurno
	SET borrado_logico = 1
	WHERE id = @p_id
END
GO

