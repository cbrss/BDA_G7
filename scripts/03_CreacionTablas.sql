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

		CONSTRAINT Ck_PacienteNombre			CHECK(PATINDEX('%[^A-Za-zÁÉÍÓÚáéíóú ]%', nombre) = 0
													AND LEN(nombre) <= 30
												),
		CONSTRAINT Ck_PacienteApellido			CHECK(PATINDEX('%[^A-Za-zÁÉÍÓÚáéíóú ]%', apellido) = 0
													AND LEN(apellido) <= 30
												),
		CONSTRAINT Ck_PacienteApellidoMaterno	CHECK(PATINDEX('%[^A-Za-zÁÉÍÓÚáéíóú ]%', apellido_materno) = 0
													AND LEN(apellido_materno) <= 30
												),
		CONSTRAINT Ck_PacienteTipoDoc			CHECK(PATINDEX('%[^A-Za-zÁÉÍÓÚáéíóú ]%', tipo_doc) = 0),
		CONSTRAINT Ck_PacienteSexo				CHECK(PATINDEX('%[^A-Za-zÁÉÍÓÚáéíóú ]%', sexo) = 0
													AND LEN(sexo) <= 11
												),
		CONSTRAINT Ck_PacienteGenero			CHECK(PATINDEX('%[^A-Za-zÁÉÍÓÚáéíóú ]%', genero) = 0),
		CONSTRAINT Ck_PacienteNacionalidad		CHECK(PATINDEX('%[^A-Za-zÁÉÍÓÚáéíóú ]%', nacionalidad) = 0
													AND LEN(nacionalidad) <= 20
												),
		CONSTRAINT Ck_PacienteMail				CHECK(mail LIKE '%_@_%.__%'
													AND LEN(mail) <= 30
												),
		CONSTRAINT Ck_PacienteTelFijo			CHECK(tel_fijo LIKE '(%_) %-%'
													AND LEN(tel_fijo) <= 15
												),
		CONSTRAINT Ck_PacienteTelAlt			CHECK(tel_fijo LIKE '(%_) %-%'
													AND LEN(tel_alt) <= 15
												),
		CONSTRAINT Ck_PacienteTelLaboral		CHECK(tel_fijo LIKE '(%_) %-%'
													AND LEN(tel_laboral) <= 15
												),
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
		nombre				VARCHAR(50),
		autorizado			BIT DEFAULT 0,
		doc_resultado		VARCHAR(max),
		img_resultado		VARCHAR(max),
		borrado_logico		BIT DEFAULT 0,

		CONSTRAINT Ck_EstudioNombre		CHECK(PATINDEX('%[^A-Za-zÁÉÍÓÚáéíóú ]%', nombre) = 0
													AND LEN(nombre) <= 30
												),
		CONSTRAINT PK_EstudioID			 PRIMARY KEY(id),
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

		CONSTRAINT Ck_UsuarioContrasena		CHECK(LEN(contrasena) <= 30),
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
		localidad			VARCHAR(50),
		
		CONSTRAINT Ck_DomicilioCalle		CHECK(LEN(calle) <= 30),
		CONSTRAINT Ck_DomicilioPais			CHECK(PATINDEX('%[^A-Za-zÁÉÍÓÚáéíóú ]%', pais) = 0
													AND LEN(pais) <= 30
												),
		CONSTRAINT Ck_DomicilioProvincia	CHECK(PATINDEX('%[^A-Za-zÁÉÍÓÚáéíóú ]%', provincia) = 0	
													AND LEN(provincia) <= 30
												),
		CONSTRAINT Ck_DomicilioLocalidad	CHECK(LEN(localidad) <= 50),
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
		id_cobertura		INT,
		nombre				VARCHAR(30),
		[plan]				VARCHAR(30),

		
		CONSTRAINT Ck_PrestadorNombre	CHECK(PATINDEX('%[^A-Za-zÁÉÍÓÚáéíóú ]%', nombre) = 0
											AND	LEN(nombre) <= 30),
		CONSTRAINT Ck_PrestadorPlan		CHECK(LEN([plan]) <= 30),
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


		CONSTRAINT Ck_EstadoTurnoNombre CHECK(PATINDEX('%[^A-Za-zÁÉÍÓÚáéíóú ]%', nombre) = 0
										AND LEN(nombre) <= 11),
		CONSTRAINT PK_EstadoTurnoID PRIMARY KEY(id)
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

		CONSTRAINT Ck_TipoTurno	CHECK(nombre IN ('Presencial', 'Virtual')
											AND	LEN(nombre) <= 11),
		CONSTRAINT PK_TipoTurnoID PRIMARY KEY(id)
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

--- Esta tabla sirve para el item de disponibilidad que pide el enunciad
--- la idea es que se ejecute el procedimiento de importacion de disponibilidad y se cargue esta tabla
IF NOT EXISTS (
    SELECT 1
    FROM sys.tables
    WHERE name = 'Disponibilidad'
    AND schema_id = SCHEMA_ID('gestion_turno')
)
BEGIN
	CREATE TABLE gestion_turno.Disponibilidad(
	id_medico			INT,
	id_especialidad		INT,
	id_sede_atencion	INT,
	disponible			CHAR(2)
	)
END


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

		
		CONSTRAINT Ck_SedeNombre	CHECK(PATINDEX('%[^A-Za-zÁÉÍÓÚáéíóú ]%', nombre) = 0
										AND LEN(nombre) <= 30),
		CONSTRAINT Ck_SedeDireccion	CHECK(LEN(direccion) <= 30),
		CONSTRAINT Ck_SedeLocalidad	CHECK(LEN(localidad) <= 30),
		CONSTRAINT Ck_SedeProvincia CHECK(PATINDEX('%[^A-Za-zÁÉÍÓÚáéíóú ]%', provincia) = 0
										AND LEN(provincia) <= 30),
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

		
		CONSTRAINT Ck_EspecialidadNombre CHECK(PATINDEX('%[^A-Za-zÁÉÍÓÚáéíóú ]%', nombre) = 0
											AND LEN(nombre) <= 30),
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

		
		CONSTRAINT CK_MedicoNombre CHECK(PATINDEX('%[^A-Za-zÁÉÍÓÚáéíóú ]%', nombre) = 0
										AND LEN(nombre) <= 30),
		CONSTRAINT Ck_MedicoApellido CHECK(PATINDEX('%[^A-Za-zÁÉÍÓÚáéíóú ]%', apellido) = 0
										AND LEN(apellido) <= 30),
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

	 CONSTRAINT CK_DiasXSedeHoraInicio CHECK(DATEPART(MINUTE, hora_inicio) IN (0, 15, 30, 45)),

	 CONSTRAINT PK_DiasXSedeID		PRIMARY KEY (id),
	 CONSTRAINT FK_SedeID			FOREIGN KEY (id_sede)			REFERENCES gestion_sede.Sede (id),
	 CONSTRAINT FK_MedicoID			FOREIGN KEY (id_medico)			REFERENCES gestion_sede.Medico (id),
	 CONSTRAINT FK_ReservaTurnoID	FOREIGN KEY (id_reserva_turno)	REFERENCES gestion_turno.ReservaTurno (id)
	 );
END;
GO

