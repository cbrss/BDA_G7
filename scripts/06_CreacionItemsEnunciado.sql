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

--- FUNCIONES Y PROCEDIMIENTOS PARA LOS ITEMS DEL ENUNCIADO

/*
Los estudios clínicos deben ser autorizados, e indicar si se cubre el costo completo del mismo o solo 
un porcentaje. El sistema de Cure se comunica con el servicio de la prestadora, se le envía el código 
del estudio, el dni del paciente y el plan; el sistema de la prestadora informa si está autorizado o no y 
el importe a facturarle al paciente. 
*/

CREATE OR ALTER PROCEDURE gestion_paciente.AutorizarEstudio
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

CREATE OR ALTER PROCEDURE gestion_turno.ExportarTurnos
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

CREATE OR ALTER PROCEDURE gestion_turno.AnularTurnos
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


