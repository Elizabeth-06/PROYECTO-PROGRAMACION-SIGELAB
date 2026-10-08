-- =====================================================================
-- SIGELAB | 04_agregar_solicitante.sql
-- MIGRACION PARA BASES ANTIGUAS (10 TABLAS), NO PARA INSTALACIONES NUEVAS.
-- Instalar desde cero: ejecutar SOLO 01, 02 y 03.
-- Esta migracion NO borra registros existentes y se puede volver a ejecutar.
-- Si hay prestamos con el campo textual 'solicitante', se detiene y exige
-- una migracion individual de esos datos antes de eliminar la columna.
-- Hacer copia de seguridad antes de usarla en una base con datos reales.
-- =====================================================================
USE PROYECTO_SIGELAB;
GO

SET XACT_ABORT ON;
GO

BEGIN TRY
BEGIN TRANSACTION;

    IF OBJECT_ID(N'dbo.Prestamo', N'U') IS NULL
        THROW 50001, 'No existe la tabla dbo.Prestamo. Ejecuta primero el esquema anterior.', 1;

    -- Nunca eliminar 'solicitante' si existen prestamos antiguos sin migrar.
    IF COL_LENGTH('dbo.Prestamo', 'solicitante') IS NOT NULL
       AND EXISTS (SELECT 1 FROM dbo.Prestamo)
        THROW 50002, 'Hay prestamos antiguos: primero identifica y migra sus solicitantes. No se ha modificado la base.', 1;

    -- 1. Crear Solicitante solamente si todavia no existe.
    IF OBJECT_ID(N'dbo.Solicitante', N'U') IS NULL
BEGIN
CREATE TABLE dbo.Solicitante (
                                 id_solicitante INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
                                 codigo_institucional VARCHAR(30) NOT NULL UNIQUE,
                                 nombre VARCHAR(100) NOT NULL,
                                 apellido VARCHAR(100) NOT NULL,
                                 tipo VARCHAR(20) NOT NULL,
                                 correo VARCHAR(150) NULL,
                                 telefono VARCHAR(20) NULL,
                                 estado VARCHAR(10) NOT NULL DEFAULT 'ACTIVO',
                                 CONSTRAINT CK_Solicitante_Tipo
                                     CHECK (tipo IN ('ESTUDIANTE', 'DOCENTE', 'PERSONAL')),
                                 CONSTRAINT CK_Solicitante_Estado
                                     CHECK (estado IN ('ACTIVO', 'INACTIVO'))
);
END;

    -- 2. Agregar columna nueva de Prestamo solamente cuando falta.
    -- El esquema anterior debe estar VACIO para agregarla como NOT NULL.
    IF COL_LENGTH('dbo.Prestamo', 'id_solicitante') IS NULL
BEGIN
        IF EXISTS (SELECT 1 FROM dbo.Prestamo)
            THROW 50003, 'No se puede agregar id_solicitante NOT NULL con prestamos existentes. Solicita una migracion de datos.', 1;

EXEC (N'ALTER TABLE dbo.Prestamo ADD id_solicitante INT NOT NULL;');
END;

    -- 3. Crear clave foranea, si falta.
    IF NOT EXISTS (
        SELECT 1 FROM sys.foreign_keys
        WHERE parent_object_id = OBJECT_ID(N'dbo.Prestamo')
          AND name = N'FK_Prestamo_Solicitante'
    )
BEGIN
EXEC (N'ALTER TABLE dbo.Prestamo
            ADD CONSTRAINT FK_Prestamo_Solicitante
            FOREIGN KEY (id_solicitante)
            REFERENCES dbo.Solicitante(id_solicitante);');
END;

    -- 4. Quitar texto antiguo solo si esta vacio y existe la FK nueva.
    IF COL_LENGTH('dbo.Prestamo', 'solicitante') IS NOT NULL
BEGIN
        IF EXISTS (SELECT 1 FROM dbo.Prestamo)
            THROW 50004, 'Quedan prestamos con la columna solicitante. No se elimina.', 1;

EXEC (N'ALTER TABLE dbo.Prestamo DROP COLUMN solicitante;');
END;

    -- 5. Registrar fecha real de finalizacion; NULL mientras sigue activo.
    IF COL_LENGTH('dbo.Prestamo', 'fecha_finalizacion') IS NULL
BEGIN
EXEC (N'ALTER TABLE dbo.Prestamo ADD fecha_finalizacion DATETIME2 NULL;');
END;

    -- 6. Coherencia entre estado y fecha (como el script nuevo 02).
    IF NOT EXISTS (
        SELECT 1 FROM sys.check_constraints
        WHERE parent_object_id = OBJECT_ID(N'dbo.Prestamo')
          AND name = N'CK_Prestamo_Finalizacion'
    )
BEGIN
EXEC (N'ALTER TABLE dbo.Prestamo WITH CHECK
            ADD CONSTRAINT CK_Prestamo_Finalizacion CHECK (
                (estado = ''ACTIVO'' AND fecha_finalizacion IS NULL)
                OR
                (estado = ''FINALIZADO''
                    AND fecha_finalizacion IS NOT NULL
                    AND fecha_finalizacion >= fecha_prestamo)
            );');
END;

COMMIT TRANSACTION;
PRINT 'Migracion 04 aplicada o ya estaba completa.';
END TRY
BEGIN CATCH
IF @@TRANCOUNT > 0
        ROLLBACK TRANSACTION;
    THROW;
END CATCH;
GO

-- Verificacion (no modifica datos):
SELECT
    OBJECT_ID(N'dbo.Solicitante', N'U') AS IdTablaSolicitante,
    COL_LENGTH('dbo.Prestamo', 'id_solicitante') AS LongitudIdSolicitante,
    COL_LENGTH('dbo.Prestamo', 'fecha_finalizacion') AS LongitudFechaFinalizacion,
    COL_LENGTH('dbo.Prestamo', 'solicitante') AS LongitudTextoAntiguo;
GO

SELECT fk.name AS Relacion,
       OBJECT_NAME(fk.parent_object_id) AS TablaOrigen,
       OBJECT_NAME(fk.referenced_object_id) AS TablaDestino
FROM sys.foreign_keys AS fk
WHERE fk.parent_object_id = OBJECT_ID(N'dbo.Prestamo')
  AND fk.name = N'FK_Prestamo_Solicitante';
GO
