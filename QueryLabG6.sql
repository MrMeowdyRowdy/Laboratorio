
CREATE PROCEDURE AddResultado 
@Nexamen VARCHAR(50),
@CI CEDULAIDENTIDAD,
@FechaPedido DATE
AS
IF (@FechaPedido NOT LIKE '__/__/____')
BEGIN
	RAISERROR ('La fecha no coincide con el formato mm/dd/aaaa',16,10)
END
ELSE
BEGIN
	IF (SELECT idExamen FROM Examen WHERE nombre LIKE @Nexamen) IS NULL
	BEGIN
		RAISERROR ('El examen especificado no existe',16,10)
	END
	ELSE
	BEGIN
		DECLARE @EXID INT
		SET @EXID = (SELECT idExamen FROM Examen WHERE nombre LIKE @Nexamen)
	END
	IF (SELECT idUsuario FROM Paciente WHERE cedula LIKE @CI) IS NULL
	BEGIN
		RAISERROR ('El paciente especificado no existe',16,10)
	END
	ELSE
	BEGIN
		DECLARE @USID INT
		SET	@USID = (SELECT idUsuario FROM Paciente WHERE cedula LIKE @CI)
	END
	
	INSERT INTO Resultado (idExamen,idUsuario,fechaPedido)
	VALUES (@EXID,@USID,@FechaPedido)
END

GO

CREATE PROCEDURE ingresoResultadoDetalles
    @fechaExamen DATETIME,
    @fechaEntrega DATETIME,
    @resultado DECIMAL(7, 3)
AS
	INSERT INTO Resultado(fechaExamen, fechaEntrega, resultado) 
	VALUES(@fechaExamen,@fechaEntrega,@resultado)
GO
