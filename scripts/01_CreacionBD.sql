/*
		BASE DE DATOS APLICADA
		GRUPO: 07
		COMISION: 5600
		INTEGRANTES:
			Cristian Raul Berrios Lima		42875289
			Lautaro Da silva				42816815
			Abigail Karina Pe�afiel Huayta	41913506

		FECHA DE ENTREGA: 5/7/2024
*/


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