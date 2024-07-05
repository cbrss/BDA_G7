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