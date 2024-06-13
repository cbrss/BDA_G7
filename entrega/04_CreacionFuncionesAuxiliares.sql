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


--- FUNCIONES Y PROCEDIMIENTOS AUXILIARES PARA LA INSERCION DE RESERVAS DE TURNOS

CREATE OR ALTER PROCEDURE gestion_turno.udf_ConsultarDisponibilidad (
	@p_id_medico		INT, 
	@p_id_especialidad	INT,
	@p_id_sede_atencion	INT,
	@r_disponiblidad		INT OUTPUT
)
AS
BEGIN
    SET @r_disponiblidad = CAST(RAND() + 0.5 AS INT)
END
GO

--- FUNCIONES AUXILIARES PARA LA INSERCION DE PACIENTES

CREATE OR ALTER FUNCTION gestion_paciente.udf_ExistePaciente(
	@p_nombre				VARCHAR(30),
	@p_apellido				VARCHAR(30),
	@p_fecha_nac			DATE,
	@p_tipo_doc				CHAR(5),
	@p_num_doc				INT,
	@p_sexo					VARCHAR(11),
	@p_genero				VARCHAR(9),
	@p_nacionalidad			VARCHAR(20)
)
RETURNS BIT
BEGIN
	DECLARE @r_existe BIT
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
	ELSE
	BEGIN
		SET @r_existe = 0
	END

	RETURN @r_existe
END
GO	


CREATE OR ALTER FUNCTION gestion_paciente.udf_ParsearDomicilio (@p_domicilio VARCHAR(50))
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


