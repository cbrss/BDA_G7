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

		/*CONSTRAINT Ck_PacientNomb		CHECK(PATINDEX('%[^A-Za-zÁÉÍÓÚáéíóú ]%', nombre) = 0),
		CONSTRAINT Ck_PacientApell		CHECK(PATINDEX('%[^A-Za-zÁÉÍÓÚáéíóú ]%', apellido) = 0),
		CONSTRAINT Ck_PacientApellMat	CHECK(PATINDEX('%[^A-Za-zÁÉÍÓÚáéíóú ]%', apellido_materno) = 0),
		CONSTRAINT Ck_PacientTipoDoc	CHECK(PATINDEX('%[^A-Za-zÁÉÍÓÚáéíóú ]%', tipo_doc) = 0),
		CONSTRAINT Ck_PacientSexo		CHECK(PATINDEX('%[^A-Za-zÁÉÍÓÚáéíóú ]%', sexo) = 0),
		CONSTRAINT Ck_PacientGenero		CHECK(PATINDEX('%[^A-Za-zÁÉÍÓÚáéíóú ]%', genero) = 0),
		CONSTRAINT Ck_PacientNacion		CHECK(PATINDEX('%[^A-Za-zÁÉÍÓÚáéíóú ]%', nacionalidad) = 0),
		CONSTRAINT Ck_PacientTelF		CHECK(PATINDEX('%[^+0-9 ]%', tel_fijo) = 0),
		CONSTRAINT Ck_PacientTelAlt		CHECK(PATINDEX('%[^+0-9 ]%', tel_alt) = 0),
		CONSTRAINT Ck_PacientTelLab		CHECK(PATINDEX('%[^+0-9 ]%', tel_laboral) = 0),*/
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

		/*
		CONSTRAINT Ck_EstudioNombre CHECK(PATINDEX('%[^A-Za-zÁÉÍÓÚáéíóú ]%', nombre_estudio) = 0),*/
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
		/*
		
		CONSTRAINT Ck_DomicCalle CHECK(PATINDEX('%[^A-Za-zÁÉÍÓÚáéíóú ]%', calle) = 0),
		CONSTRAINT Ck_DomicPais CHECK(PATINDEX('%[^A-Za-zÁÉÍÓÚáéíóú ]%', pais) = 0),
		CONSTRAINT Ck_DomicProv CHECK(PATINDEX('%[^A-Za-zÁÉÍÓÚáéíóú ]%', provincia) = 0),
		CONSTRAINT Ck_DomicLocalidad CHECK(PATINDEX('%[^A-Za-zÁÉÍÓÚáéíóú ]%', localidad) = 0),*/
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

		/*
		CONSTRAINT Ck_Prestanomb CHECK(PATINDEX('%[^A-Za-zÁÉÍÓÚáéíóú ]%', nombre) = 0),*/
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

		/*CONSTRAINT CK_Sedeid CHECK(ISNUMERIC(id) = 1), 
		CONSTRAINT Ck_Sedenomb CHECK(PATINDEX('%[^A-Za-zÁÉÍÓÚáéíóú ]%', nombre) = 0),
		CONSTRAINT Ck_Sedeprov CHECK(PATINDEX('%[^A-Za-zÁÉÍÓÚáéíóú ]%', provincia) = 0),*/
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

		/*CONSTRAINT CK_Espid CHECK(ISNUMERIC(id) = 1),
		CONSTRAINT Ck_Espnomb CHECK(PATINDEX('%[^A-Za-zÁÉÍÓÚáéíóú ]%', nombre) = 0),*/
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




/*
drop table gestion_paciente.Domicilio
drop table gestion_paciente.Prestador
drop table gestion_paciente.Cobertura
drop table gestion_paciente.Estudio
drop table gestion_paciente.Usuario
drop table gestion_sede.DiasXSede
drop table gestion_sede.Sede
drop table gestion_sede.Medico
drop table gestion_sede.Especialidad

drop table gestion_turno.ReservaTurno
drop table gestion_turno.TipoTurno
drop table gestion_turno.EstadoTurno

drop table gestion_paciente.Paciente
*/