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

	GRANT EXECUTE ON OBJECT::gestion_paciente.usp_InsertarPaciente		TO clinica_operador
	GRANT EXECUTE ON OBJECT::gestion_paciente.usp_ActualizarPaciente	TO clinica_operador
	GRANT EXECUTE ON OBJECT::gestion_paciente.usp_BorrarPaciente		TO clinica_operador

	GRANT EXECUTE ON OBJECT::gestion_turno.usp_InsertarReservaTurno		TO clinica_operador
	GRANT EXECUTE ON OBJECT::gestion_turno.usp_ActualizarReservaTurno	TO clinica_operador
	GRANT EXECUTE ON OBJECT::gestion_turno.usp_BorrarReservaTurno		TO clinica_operador
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
	GRANT EXECUTE ON SCHEMA::gestion_turno	TO clinica_admin
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

	GRANT EXECUTE ON OBJECT::gestion_paciente.usp_ImportarPacientes			TO clinica_importador
	GRANT EXECUTE ON OBJECT::gestion_paciente.usp_ImportarPrestadores		TO clinica_importador
END
GO
REVERT	-- para quitar el seteo de usuario DBO
GO
