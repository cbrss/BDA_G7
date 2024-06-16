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
	
-- Mas que este, me parece coherente que se consulte si un medico con tal especialidad en tal sede y fecha
-- esta disponible en esa hora, entiendo que DiasXSede tiene registrado las reservas de turno que tiene cada medico
-- en dichas sedes. Falta probarlo
	
CREATE OR ALTER PROCEDURE gestion_turno.ConsultarDisponibilidadHoraria (
	@p_id_medico			INT, 
	@p_id_especialidad		INT,
	@p_id_sede_atencion		INT,
	@p_fecha				DATE,
	@p_hora					TIME,
	@r_disponiblidad		INT OUTPUT
)
AS
BEGIN
	DECLARE @hora_fin TIME
	SET @hora_fin = DATEADD(MINUTE, 15, @p_hora) -- suma 15 minutos a la Hora

	IF EXISTS (
		Select 'a' from gestion_sede.Medico Join gestion_sede.DiasXSede on id = id_medico
		group by id
		having id_especialidad = @p_id_especialidad
		and id_sede = @p_id_sede_atencion
		and dia = @p_fecha
		and hora_inicio between @p_hora and @hora_fin
		)
		SET @r_disponiblidad = 1
	ELSE
		SET @r_disponiblidad = 0
END
go
	

--- FUNCIONES AUXILIARES PARA IMPORTACION

CREATE OR ALTER FUNCTION gestion_Sede.BuscarIdEspecialidad (@p_nombre VARCHAR(30))
RETURNS INT
BEGIN
	DECLARE @r_id INT

	SET @r_id = (SELECT id FROM gestion_sede.Especialidad WHERE nombre = @p_nombre)

	RETURN @r_id
END
GO


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
