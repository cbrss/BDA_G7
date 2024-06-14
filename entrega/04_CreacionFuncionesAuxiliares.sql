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

--- FUNCIONES Y PROCEDIMIENTOS PARA LOS ITEMS DEL ENUNCIADO


/*
Los estudios clínicos deben ser autorizados, e indicar si se cubre el costo completo del mismo o solo 
un porcentaje. El sistema de Cure se comunica con el servicio de la prestadora, se le envía el código 
del estudio, el dni del paciente y el plan; el sistema de la prestadora informa si está autorizado o no y 
el importe a facturarle al paciente. 
*/

CREATE OR ALTER PROCEDURE gestion_paciente.usp_AutorizarEstudio
	@p_id_estudio		VARCHAR(30),
	@p_dni_paciente		INT,
	@p_plan_prestador	VARCHAR(30),	
	@p_ruta				VARCHAR(max),	
	@p_respuesta		VARCHAR(100) OUTPUT
AS
BEGIN
	set nocount on
	-- busco id de paciente/historia clinica con el dni recibido
	DECLARE @id_historia_clinica	INT				= (SELECT id FROM gestion_paciente.Paciente WHERE num_doc = @p_dni_paciente)
	-- busco si esta autorizado el estudio
	DECLARE @autorizado				BIT				= (SELECT autorizado FROM gestion_paciente.Estudio WHERE id = @p_id_estudio AND id_paciente = @id_historia_clinica) 
	-- busco nombre del estudio relacionado al codigo recibido
	DECLARE @nombre_estudio			VARCHAR(100)	= (SELECT nombre_estudio FROM gestion_paciente.Estudio WHERE id = @p_id_estudio AND id_paciente = @id_historia_clinica)

	-- para el nombre del estudio y el plan recibido calculo importe y verifico si necesita autorizacion
	DECLARE @importe				DECIMAL(10,2)
	DECLARE @req_autorizacion		VARCHAR(5)
	-- para guardar el archivo json en formato texto plano
	DECLARE @json					VARCHAR(max)
	-- para verificar la existencia del estudio y plan recibido
	DECLARE @auxiliar				INT
	SET		@auxiliar = 0

	CREATE TABLE #json_TT (texto VARCHAR(max))
	DECLARE @consulta_sql VARCHAR(max) = 'BULK INSERT #json_TT 
											FROM ''' + @p_ruta + ''' 
											WITH (CODEPAGE = ''65001'')'
	EXEC (@consulta_sql)

	SELECT @json = STRING_AGG(texto, ' ')	-- concatena todas las filas
	FROM #json_TT;

	SELECT
		@importe			= CAST(JSON_VALUE(value, '$."Porcentaje Cobertura"') AS DECIMAL(10,2)) 
								* CAST(JSON_VALUE(value, '$.Costo') AS DECIMAL(10,2)) /100,
		@req_autorizacion	= JSON_VALUE(value, '$."Requiere autorizacion"'),
		@auxiliar = @auxiliar + 1
	FROM OPENJSON(@json) AS j
	WHERE JSON_VALUE(value, '$.Estudio') = @nombre_estudio 
		AND JSON_VALUE(value, '$.Plan') = @p_plan_prestador
	
	IF	@auxiliar = 0
	BEGIN
		SET @p_respuesta = 'No se encontro informacion para el estudio y plan especificados.';
		RETURN;
	END
	SET @p_respuesta = 'El importe a facturar al paciente es: ' + CAST(ISNULL(@importe, 0) as varchar(15)) + '$'
	-- si necesita autorizacion y no la tiene, entonces rechazado.
	IF @req_autorizacion = 'true' AND @autorizado = 0
	BEGIN
		SET @p_respuesta = 'Se requiere autorizacion y el estudio no esta autorizado.'
	END

END;
GO


/*
Adicionalmente se requiere que el sistema sea capaz de generar un archivo XML detallando 
los turnos atendidos para informar a la Obra Social. El mismo debe constar de los datos del 
paciente (Apellido, nombre, DNI), nombre y matrícula del profesional que lo atendió, fecha, 
hora, especialidad. Los parámetros de entrada son el nombre de la obra social y un intervalo 
de fechas. 
*/

CREATE OR ALTER PROCEDURE gestion_turno.usp_ExportarTurnos
	@p_obra_social		VARCHAR(30),
	@p_fecha_inicial	DATE,
	@p_fecha_final		DATE
AS
BEGIN
	DECLARE @id_estado	INT
	SET @id_estado = (SELECT id FROM gestion_turno.EstadoTurno WHERE nombre = 'Atendido')

	SELECT P.nombre, 
			P.apellido, 
			P.num_doc,
			M.nombre,
			M.matricula,
			DXS.dia,
			DXS.hora_inicio,
			E.nombre
	FROM gestion_paciente.Paciente		P
		JOIN gestion_turno.ReservaTurno RT	ON RT.id_paciente = P.id
		JOIN gestion_sede.DiasXSede		DXS	ON DXS.id_reserva_turno = RT.id 
		JOIN gestion_sede.Medico		M	ON M.id = DXS.id_medico 
		JOIN gestion_sede.Especialidad	E	ON E.id = M.id_especialidad
		JOIN gestion_paciente.Cobertura C	ON C.id_paciente = P.id
		JOIN gestion_paciente.Prestador Pre	ON Pre.id_cobertura = C.id

	WHERE Pre.nombre = @p_obra_social
		AND	DXS.dia >= @p_fecha_inicial
		AND	DXS.dia <= @p_fecha_final
		AND RT.id_estado_turno = @id_estado
	FOR XML RAW ('Turno'), ROOT('TurnosAtendidos');
END
GO

/*
Los prestadores están conformador por Obras Sociales y Prepagas con las cuales se establece una 
alianza comercial.  Dicha alianza puede finalizar en cualquier momento, por lo cual debe poder ser 
actualizable de forma inmediata si el contrato no está vigente.  En caso de no estar vigente el contrato, 
deben ser anulados todos los turnos de pacientes que se encuentren vinculados a esa prestadora y 
pasar a estado disponible. 
*/

CREATE OR ALTER PROCEDURE gestion_turno.usp_AnularTurnos
	@p_id_prestador	INT
AS
BEGIN
	UPDATE gestion_turno.ReservaTurno
	SET id_estado_turno = (SELECT id FROM gestion_turno.EstadoTurno WHERE nombre = 'Disponible')
	FROM gestion_turno.ReservaTurno RT
		JOIN gestion_paciente.Paciente	P	ON P.id = RT.id_paciente
		JOIN gestion_paciente.Cobertura C	ON C.id_paciente = P.id
		JOIN gestion_paciente.Prestador Pre ON Pre.id_cobertura = C.id
	WHERE Pre.id = @p_id_prestador

END
GO



--- FUNCIONES Y PROCEDIMIENTOS AUXILIARES PARA LA INSERCION DE RESERVAS DE TURNOS

CREATE OR ALTER PROCEDURE gestion_turno.usp_ConsultarDisponibilidad (
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

--- FUNCIONES Y PROCEDIMIENTOS AUXILIARES PARA LA INSERCION DE PACIENTES

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

CREATE OR ALTER FUNCTION gestion_paciente.udf_LimpiarApellidoMaterno (@p_apellido	VARCHAR(30))
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

--- FUNCIONES Y PROCEDIMIENTOS AUXILIARES PARA IMPORTACION DE PACIENTES

CREATE OR ALTER FUNCTION gestion_paciente.tvf_ParsearDomicilio (@p_domicilio VARCHAR(50))
RETURNS @r_domicilio TABLE(
	calle		VARCHAR(30),
	numero		VARCHAR(20)
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


--- FUNCIONES Y PROCEDIMIENTOS AUXILIARES PARA IMPORTAR MEDICOS

CREATE OR ALTER FUNCTION gestion_sede.udf_ExisteEspecialidad (@p_nombre VARCHAR(20)
)
RETURNS BIT
BEGIN
	DECLARE @r_existe BIT
	IF EXISTS(
		SELECT 1
		FROM gestion_sede.Especialidad
		WHERE nombre			= @p_nombre
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

CREATE OR ALTER FUNCTION gestion_sede.udf_LimpiarApellidoMedico (@p_nombre VARCHAR(30)
)
RETURNS VARCHAR(30)
BEGIN
	DECLARE @retorno VARCHAR(30)

	SET @retorno = SUBSTRING(@p_nombre, CHARINDEX('.', @p_nombre) + 1, LEN(@p_nombre))	
		
	RETURN @retorno
END
GO	

--- FUNCIONES Y PROCEDIMIENTOS AUXILIARES PARA INSERCION DE MEDICOS

CREATE OR ALTER FUNCTION gestion_sede.udf_ExisteMedico (
	@p_nombre			VARCHAR(30),
	@p_apellido			VARCHAR(30),
	@p_matricula		INT,
	@p_id_especialidad	INT
)
RETURNS BIT
BEGIN
	DECLARE @r_existe BIT
	IF EXISTS(
		SELECT 1
		FROM gestion_sede.Medico
		WHERE nombre = @p_nombre
			AND	apellido = @p_apellido
			AND	matricula = @p_matricula
			AND id_especialidad = @p_id_especialidad
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

