USE LabX
GO

----------------------
--Tabla y Trigger de auditor�a
----------------------

DROP TABLE IF EXISTS AuditoriaResultado

CREATE TABLE AuditoriaResultado(
	Id_Auditoria INT IDENTITY (1,1) NOT NULL,
	Id_Resultado INT NOT NULL,
	campo VARCHAR(50) NOT NULL,
	valorAnt VARCHAR(50) NOT NULL,
	valorNuevo VARCHAR(50) NOT NULL,
    usuarioRegistro NVARCHAR(128) NOT NULL DEFAULT SYSTEM_USER,
	fechaRegistro DATETIME NOT NULL DEFAULT GETDATE(),
	CONSTRAINT PK_Auditoria PRIMARY KEY(Id_Auditoria)
);

GO

DROP TRIGGER IF EXISTS tr_UpdateRegistro
GO

CREATE TRIGGER tr_UpdateRegistro ON Resultado
FOR Update
AS
	IF (@@ROWCOUNT != 0)
	BEGIN
		DECLARE @IDRES INT
		DECLARE @CAMPO VARCHAR(20)
		DECLARE @valorAnt VARCHAR(30)
		DECLARE @valorNuevo VARCHAR(30)
		BEGIN TRY
			IF(UPDATE(idUsuario) OR UPDATE (idLaboratorista) OR UPDATE (idResultado) OR UPDATE (idExamen) OR UPDATE (fechaRegistro) OR UPDATE (usuarioRegistro))
			BEGIN
				RAISERROR('Error no puede cambiar los campos identificadores o la fecha y usuario que realizaron el registro',16,10)
				ROLLBACK TRANSACTION;
			END
			IF((SELECT fechaPedido FROM deleted) != (SELECT fechaPedido FROM inserted))
			BEGIN
				SET @IDRES = (SELECT idResultado FROM deleted)
				SET @CAMPO = 'fechaPedido'
				SET @valorAnt = (SELECT fechaPedido FROM deleted)
				SET @valorNuevo = (SELECT fechaPedido FROM inserted)
				INSERT INTO AuditoriaResultado (Id_Resultado, campo, valorAnt, valorNuevo)
				VALUES(@IDRES,@CAMPO,@valorAnt,@valorNuevo)
			END
			IF((SELECT fechaExamen FROM deleted) != (SELECT fechaExamen FROM inserted))
			BEGIN
				SET @IDRES = (SELECT idResultado FROM deleted)
				SET @CAMPO = 'fechaExamen'
				SET @valorAnt = (SELECT fechaExamen FROM deleted)
				SET @valorNuevo = (SELECT fechaExamen FROM inserted)
				INSERT INTO AuditoriaResultado (Id_Resultado, campo, valorAnt, valorNuevo)
				VALUES(@IDRES,@CAMPO,@valorAnt,@valorNuevo)
			END
			IF((SELECT fechaEntrega FROM deleted) != (SELECT fechaEntrega FROM inserted))
			BEGIN
				SET @IDRES = (SELECT idResultado FROM deleted)
				SET @CAMPO = 'fechaEntrega'
				SET @valorAnt = (SELECT fechaEntrega FROM deleted)
				SET @valorNuevo = (SELECT fechaEntrega FROM inserted)
				INSERT INTO AuditoriaResultado (Id_Resultado, campo, valorAnt, valorNuevo)
				VALUES(@IDRES,@CAMPO,@valorAnt,@valorNuevo)
			END
			IF((SELECT resultado FROM deleted) != (SELECT resultado FROM inserted))
			BEGIN
				SET @IDRES = (SELECT idResultado FROM deleted)
				SET @CAMPO = 'resultado'
				SET @valorAnt = (SELECT resultado FROM deleted)
				SET @valorNuevo = (SELECT resultado FROM inserted)
				INSERT INTO AuditoriaResultado (Id_Resultado, campo, valorAnt, valorNuevo)
				VALUES(@IDRES,@CAMPO,@valorAnt,@valorNuevo)
			END
		END TRY
		BEGIN CATCH
			RAISERROR('Errores al insertar en la tabla de auditor�a',16,10)
			ROLLBACK TRANSACTION;
		END CATCH
	END
	ELSE
	BEGIN
		PRINT ('No han existido modificaciones en la tabla de resultados')
	END

GO

SELECT * FROM Resultado
WHERE idResultado=1

GO

IF EXISTS(SELECT name FROM sys.objects WHERE type = 'TR' AND name = 'tr_Resultado')
BEGIN
    DROP TRIGGER tr_Resultado
END
GO

UPDATE Resultado 
SET resultado = 80.000
WHERE idResultado=1;

UPDATE Resultado 
SET fechaPedido = '2023-04-18 09:00:00'
WHERE idResultado=1;

SELECT * FROM AuditoriaResultado
GO

----------------------
--Creacion tabla Laboratorista
----------------------

CREATE TABLE Laboratorista (
    idLaboratorista TINYINT IDENTITY(1,1) NOT NULL,

    cedula cedulaIdentidad NOT NULL UNIQUE,
    nombre NVARCHAR(55) NOT NULL,
    apellido NVARCHAR(55) NOT NULL,
    mail correo NOT NULL UNIQUE,
    telefono VARCHAR(16),
    fechaNacimiento DATE NOT NULL,
    tipoSangre VARCHAR(3) NOT NULL,
    usuarioRegistro NVARCHAR(128) NOT NULL DEFAULT SYSTEM_USER,
    fechaRegistro DATETIME NOT NULL DEFAULT GETDATE(),

    CONSTRAINT PK_idLaboratorista PRIMARY KEY (idLaboratorista),
    CONSTRAINT CH_TipoSangreLab CHECK (tipoSangre IN ('A+', 'A-', 'B+', 'B-', 'AB+', 'AB-', 'O+', 'O-')),
    CONSTRAINT CH_NombreLab CHECK (PATINDEX('%[0-9]%', nombre) = 0),
    CONSTRAINT CH_ApellidoLab CHECK (PATINDEX('%[0-9]%', apellido) = 0),
    CONSTRAINT CH_TelefonoLab CHECK (PATINDEX('%[^+0-9 ()-]%', telefono) = 0),
    CONSTRAINT CH_FechaNacimientoLab CHECK (fechaNacimiento <= GETDATE())
)
GO

----------------------
--Alteraci�n de tabla resultado
----------------------

ALTER TABLE Resultado
ADD idLaboratorista SMALLINT;
GO

----------------------
--Alteraci�n de tabla paciente
----------------------

ALTER TABLE paciente
ADD examenes SMALLINT;
GO

----------------------
--Creaci�n de trigger de calculo de examenes
----------------------

CREATE TRIGGER tr_UpdateExamenPaciente ON Resultado
FOR Insert
AS
GO


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
