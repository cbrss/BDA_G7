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


--- CREACION LOGINS
EXECUTE AS USER = 'dbo'	-- ya que tiene todo el control para asignar permisos

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

REVERT	-- para quitar el seteo de usuario DBO
GO