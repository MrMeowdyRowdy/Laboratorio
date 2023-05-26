
CREATE PROCEDURE AddResultado 
@Nexamen VARCHAR(50),
@CI CEDULAIDENTIDAD,
@FechaPedido DATE
AS
INSERT INTO Resultado (idExamen,idUsuario,fechaPedido)
VALUES (