
CREATE PROCEDURE AddResultado 
@Nexamen VARCHAR(50),
@CI CEDULAIDENTIDAD,
@FechaPedido DATE
AS
DECLARE @EXID INT
SET @EXID = (SELECT idExamen FROM Examen WHERE nombre LIKE @Nexamen)
DECLARE @USID INT
SET @USID = (SELECT idUsuario FROM Paciente WHERE cedula LIKE @CI)
INSERT INTO Resultado (idExamen,idUsuario,fechaPedido)
VALUES (