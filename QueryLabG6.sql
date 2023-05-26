
CREATE PROCEDURE AddResultado 
@Nexamen VARCHAR(50),
@CI CEDULAIDENTIDAD,
@FechaPedido DATE
AS
IF (@FechaPedido NOT LIKE '__/__/____')
BEGIN
	RAISERROR ('La fecha no coincide con el formato mm/dd/aaaa')
END
ELSE
BEGIN
	DECLARE @EXID INT
	SET @EXID = (SELECT idExamen FROM Examen WHERE nombre LIKE @Nexamen)
	DECLARE @USID INT
	SET @USID = (SELECT idUsuario FROM Paciente WHERE cedula LIKE @CI)
	INSERT INTO Resultado (idExamen,idUsuario,fechaPedido)
	VALUES (@EXID,@USID,@FechaPedido)
END
