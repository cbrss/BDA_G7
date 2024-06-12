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
		usr_actualizacion	DATE,
		borrado_logico		BIT DEFAULT 0,

		CONSTRAINT CK_Pacientid CHECK(ISNUMERIC(id) = 1),
		CONSTRAINT CK_PacientNumdoc CHECK(ISNUMERIC(num_doc) = 1),
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

		CONSTRAINT CK_Estudioid CHECK(ISNUMERIC(id) = 1),
		CONSTRAINT CK_Estudioid_paciente CHECK(ISNUMERIC(id_paciente) = 1),
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

		CONSTRAINT CK_UsuarioId CHECK(ISNUMERIC(id) = 1),
		CONSTRAINT CK_UsuarioId_paciente CHECK(ISNUMERIC(id_paciente) = 1),
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
		id				INT IDENTITY(1,1),
		id_paciente			INT,
		calle				VARCHAR(30),
		numero				INT,
		piso				INT,
		departamento			INT,
		cod_postal			INT,
		pais				VARCHAR(30),
		provincia			VARCHAR(30),
		localidad			VARCHAR(30),

		CONSTRAINT CK_DomicId CHECK(ISNUMERIC(id) = 1),
		CONSTRAINT CK_DomicIdpaciente CHECK(ISNUMERIC(id_paciente) = 1),
		CONSTRAINT CK_Domicnumero CHECK(ISNUMERIC(numero) = 1),
		CONSTRAINT CK_Domicpiso CHECK(ISNUMERIC(piso) = 1),
		CONSTRAINT CK_Domicdepart CHECK(ISNUMERIC(departamento) = 1),
		CONSTRAINT CK_DomicCodpostal CHECK(ISNUMERIC(cod_postal) = 1),
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
		id				INT,
		id_paciente			INT,
		imagen_credencial	VARCHAR(max),
		nro_socio			INT,
		fecha_registro		DATE,

		CONSTRAINT CK_Cobertid CHECK(ISNUMERIC(id) = 1),
		CONSTRAINT CK_Cobertid_paciente CHECK(ISNUMERIC(id_paciente) = 1),
		CONSTRAINT CK_Cobertnro_socio CHECK(ISNUMERIC(nro_socio) = 1),
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

		CONSTRAINT CK_Prestaid CHECK(ISNUMERIC(id) = 1),
		CONSTRAINT CK_Prestaidcobertura CHECK(ISNUMERIC(id_cobertura) = 1),
		CONSTRAINT PK_PrestadorID PRIMARY KEY (id),
		CONSTRAINT FK_Prestador_CoberturaID FOREIGN KEY (id_cobertura) REFERENCES gestion_paciente.Cobertura(id)
	);
END;
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
		 id			INT IDENTITY(1,1),
		 nombre			VARCHAR(30),
		 direccion		VARCHAR(30),
		 localidad		VARCHAR(30),
		 provincia		VARCHAR(30),

		CONSTRAINT CK_Sedeid CHECK(ISNUMERIC(id) = 1), 
		CONSTRAINT PK_SedeID PRIMARY KEY (id)
	 )
END
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
		 id			INT IDENTITY(1,1),
		 nombre			VARCHAR(25),
		 apellido		VARCHAR(20),
		 matricula		INT UNIQUE,

		CONSTRAINT CK_Medicid CHECK(ISNUMERIC(id) = 1),
		CONSTRAINT CK_Medicmatricula CHECK(ISNUMERIC(matricula) = 1),
		CONSTRAINT PK_MedicoID PRIMARY KEY (id)
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
		 id				INT,
		 id_sede		INT,
		 id_medico		INT,
		 dia			DATE,
		 hora_inicio	TIME,

	 CONSTRAINT CK_Diasid CHECK(ISNUMERIC(id) = 1),
	 CONSTRAINT CK_Diasidsede CHECK(ISNUMERIC(id_sede) = 1),
	 CONSTRAINT CK_Diasidmedico CHECK(ISNUMERIC(id_medico) = 1),
	 CONSTRAINT PK_DiasxsedeID	PRIMARY KEY (id),
	 CONSTRAINT FK_SedeID		FOREIGN KEY (id_sede)	REFERENCES gestion_sede.Sede(id),
	 CONSTRAINT FK_MedicoID		FOREIGN KEY (id_medico) REFERENCES gestion_sede.Medico(id)
	 );
END;
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
		id			INT,
		nombre		VARCHAR(20),

		CONSTRAINT CK_Espid CHECK(ISNUMERIC(id) = 1),
		CONSTRAINT Ck_Espnomb CHECK(PATINDEX('%[^A-Za-z]%', nombre) = 0),
		CONSTRAINT PK_EspecialidadID PRIMARY KEY (id)
	 );
END;
GO
