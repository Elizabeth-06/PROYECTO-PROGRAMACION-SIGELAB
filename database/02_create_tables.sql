USE PROYECTO_SIGELAB;
GO

-- SIGELAB - 02_create_tables.sql
-- Ejecutar después de 01_create_database.sql.
-- Crea las diez tablas si no existen y los índices filtrados de seguridad.
-- No elimina ni modifica registros existentes.
-- IMPORTANTE: IF OBJECT_ID no migra tablas existentes: cualquier cambio de esquema
-- posterior debe realizarse con scripts ALTER TABLE de migración.

-- 01 ROL
IF OBJECT_ID(N'dbo.Rol', N'U') IS NULL
BEGIN
CREATE TABLE dbo.Rol (
                         id_rol INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
                         nombre VARCHAR(30) NOT NULL UNIQUE,
                         descripcion VARCHAR(200) NULL
);
END;
GO

-- 02 LABORATORIO
IF OBJECT_ID(N'dbo.Laboratorio', N'U') IS NULL
BEGIN
CREATE TABLE dbo.Laboratorio (
                                 id_laboratorio INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
                                 codigo VARCHAR(30) NOT NULL UNIQUE,
                                 nombre VARCHAR(100) NOT NULL,
                                 ubicacion VARCHAR(150) NOT NULL,
                                 capacidad INT NOT NULL,
                                 estado VARCHAR(10) NOT NULL CONSTRAINT DF_Laboratorio_Estado DEFAULT ('ACTIVO'),
                                 CONSTRAINT CK_Laboratorio_Capacidad CHECK (capacidad > 0),
                                 CONSTRAINT CK_Laboratorio_Estado CHECK (estado IN ('ACTIVO', 'INACTIVO'))
);
END;
GO

-- 03 TIPO EQUIPO
IF OBJECT_ID(N'dbo.TipoEquipo', N'U') IS NULL
BEGIN
CREATE TABLE dbo.TipoEquipo (
                                id_tipo_equipo INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
                                nombre VARCHAR(100) NOT NULL UNIQUE,
                                descripcion VARCHAR(200) NULL
);
END;
GO

-- 04 USUARIO
IF OBJECT_ID(N'dbo.Usuario', N'U') IS NULL
BEGIN
CREATE TABLE dbo.Usuario (
                             id_usuario INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
                             nombre VARCHAR(100) NOT NULL,
                             apellido VARCHAR(100) NOT NULL,
                             username VARCHAR(50) NOT NULL UNIQUE,
                             password_hash VARCHAR(255) NOT NULL,
                             correo VARCHAR(150) NOT NULL UNIQUE,
                             id_rol INT NOT NULL,
                             estado VARCHAR(10) NOT NULL CONSTRAINT DF_Usuario_Estado DEFAULT ('ACTIVO'),
                             CONSTRAINT FK_Usuario_Rol FOREIGN KEY (id_rol) REFERENCES dbo.Rol(id_rol),
                             CONSTRAINT CK_Usuario_Estado CHECK (estado IN ('ACTIVO', 'INACTIVO'))
);
END;
GO

-- 05 EQUIPO
IF OBJECT_ID(N'dbo.Equipo', N'U') IS NULL
BEGIN
CREATE TABLE dbo.Equipo (
                            id_equipo INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
                            codigo_inventario VARCHAR(50) NOT NULL UNIQUE,
                            nombre VARCHAR(100) NOT NULL,
                            id_tipo_equipo INT NOT NULL,
                            marca VARCHAR(100) NULL,
                            modelo VARCHAR(100) NULL,
                            numero_serie VARCHAR(100) NULL,
                            id_laboratorio INT NOT NULL,
                            estado VARCHAR(20) NOT NULL CONSTRAINT DF_Equipo_Estado DEFAULT ('DISPONIBLE'),
                            observaciones VARCHAR(500) NULL,
                            CONSTRAINT FK_Equipo_Tipo FOREIGN KEY (id_tipo_equipo) REFERENCES dbo.TipoEquipo(id_tipo_equipo),
                            CONSTRAINT FK_Equipo_Laboratorio FOREIGN KEY (id_laboratorio) REFERENCES dbo.Laboratorio(id_laboratorio),
                            CONSTRAINT CK_Equipo_Estado CHECK (estado IN ('DISPONIBLE', 'PRESTADO', 'DANADO', 'MANTENIMIENTO', 'BAJA'))
);
END;
GO

-- =============================================
-- TABLA 6: SOLICITANTE
-- =============================================

IF OBJECT_ID(N'dbo.Solicitante', N'U') IS NULL
BEGIN
CREATE TABLE dbo.Solicitante (
                                 id_solicitante INT IDENTITY(1,1) PRIMARY KEY,

                                 codigo_institucional VARCHAR(30) NOT NULL UNIQUE,

                                 nombre VARCHAR(100) NOT NULL,
                                 apellido VARCHAR(100) NOT NULL,

                                 tipo VARCHAR(20) NOT NULL,

                                 correo VARCHAR(150),
                                 telefono VARCHAR(20),

                                 estado VARCHAR(10) NOT NULL DEFAULT 'ACTIVO',

                                 CONSTRAINT CK_Solicitante_Tipo
                                     CHECK (tipo IN (
                                                     'ESTUDIANTE',
                                                     'DOCENTE',
                                                     'PERSONAL'
                                         )),

                                 CONSTRAINT CK_Solicitante_Estado
                                     CHECK (estado IN ('ACTIVO', 'INACTIVO'))
);
END;
GO

-- =============================================
-- TABLA 7: PRESTAMO
-- =============================================

IF OBJECT_ID(N'dbo.Prestamo', N'U') IS NULL
BEGIN
CREATE TABLE dbo.Prestamo (
                              id_prestamo INT IDENTITY(1,1) PRIMARY KEY,

                              id_solicitante INT NOT NULL,

                              fecha_prestamo DATETIME2 NOT NULL
                                                          DEFAULT SYSDATETIME(),

                              fecha_devolucion_esperada DATETIME2 NOT NULL,

                              fecha_finalizacion DATETIME2 NULL,

                              id_usuario_registra INT NOT NULL,

                              estado VARCHAR(15) NOT NULL DEFAULT 'ACTIVO',

                              observaciones VARCHAR(500),

                              CONSTRAINT FK_Prestamo_Solicitante
                                  FOREIGN KEY (id_solicitante)
                                      REFERENCES dbo.Solicitante(id_solicitante),

                              CONSTRAINT FK_Prestamo_Usuario
                                  FOREIGN KEY (id_usuario_registra)
                                      REFERENCES dbo.Usuario(id_usuario),

                              CONSTRAINT CK_Prestamo_Estado
                                  CHECK (estado IN ('ACTIVO', 'FINALIZADO')),

                              CONSTRAINT CK_Prestamo_Fechas
                                  CHECK (
                                      fecha_devolucion_esperada > fecha_prestamo
                                      ),

                              CONSTRAINT CK_Prestamo_Finalizacion
                                  CHECK (
                                      (estado = 'ACTIVO'
                                          AND fecha_finalizacion IS NULL)
                                          OR
                                      (estado = 'FINALIZADO'
                                          AND fecha_finalizacion IS NOT NULL
                                          AND fecha_finalizacion >= fecha_prestamo)
                                      )
);
END;
GO

-- 07 DETALLE PRESTAMO
IF OBJECT_ID(N'dbo.DetallePrestamo', N'U') IS NULL
BEGIN
CREATE TABLE dbo.DetallePrestamo (
                                     id_detalle INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
                                     id_prestamo INT NOT NULL,
                                     id_equipo INT NOT NULL,
                                     estado VARCHAR(15) NOT NULL CONSTRAINT DF_Detalle_Estado DEFAULT ('PENDIENTE'),
                                     CONSTRAINT FK_Detalle_Prestamo FOREIGN KEY (id_prestamo) REFERENCES dbo.Prestamo(id_prestamo),
                                     CONSTRAINT FK_Detalle_Equipo FOREIGN KEY (id_equipo) REFERENCES dbo.Equipo(id_equipo),
                                     CONSTRAINT UQ_Detalle_Prestamo_Equipo UNIQUE (id_prestamo, id_equipo),
                                     CONSTRAINT CK_Detalle_Estado CHECK (estado IN ('PENDIENTE', 'DEVUELTO'))
);
END;
GO

-- 08 DEVOLUCION
IF OBJECT_ID(N'dbo.Devolucion', N'U') IS NULL
BEGIN
CREATE TABLE dbo.Devolucion (
                                id_devolucion INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
                                id_detalle INT NOT NULL UNIQUE,
                                fecha_devolucion DATETIME2 NOT NULL CONSTRAINT DF_Devolucion_Fecha DEFAULT (SYSDATETIME()),
                                condicion VARCHAR(10) NOT NULL,
                                observaciones VARCHAR(500) NULL,
                                id_usuario_recibe INT NOT NULL,
                                CONSTRAINT FK_Devolucion_Detalle FOREIGN KEY (id_detalle) REFERENCES dbo.DetallePrestamo(id_detalle),
                                CONSTRAINT FK_Devolucion_Usuario FOREIGN KEY (id_usuario_recibe) REFERENCES dbo.Usuario(id_usuario),
                                CONSTRAINT CK_Devolucion_Condicion CHECK (condicion IN ('BUENO', 'DANADO'))
);
END;
GO

-- 09 MANTENIMIENTO
IF OBJECT_ID(N'dbo.Mantenimiento', N'U') IS NULL
BEGIN
CREATE TABLE dbo.Mantenimiento (
                                   id_mantenimiento INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
                                   id_equipo INT NOT NULL,
                                   fecha_ingreso DATETIME2 NOT NULL CONSTRAINT DF_Mantenimiento_Fecha DEFAULT (SYSDATETIME()),
                                   tipo VARCHAR(15) NOT NULL,
                                   descripcion VARCHAR(500) NOT NULL,
                                   responsable VARCHAR(150) NOT NULL,
                                   fecha_salida DATETIME2 NULL,
                                   resultado VARCHAR(20) NULL,
                                   estado VARCHAR(15) NOT NULL CONSTRAINT DF_Mantenimiento_Estado DEFAULT ('EN_PROCESO'),
                                   observaciones VARCHAR(500) NULL,
                                   CONSTRAINT FK_Mantenimiento_Equipo FOREIGN KEY (id_equipo) REFERENCES dbo.Equipo(id_equipo),
                                   CONSTRAINT CK_Mantenimiento_Tipo CHECK (tipo IN ('PREVENTIVO', 'CORRECTIVO')),
                                   CONSTRAINT CK_Mantenimiento_Estado CHECK (estado IN ('EN_PROCESO', 'FINALIZADO')),
                                   CONSTRAINT CK_Mantenimiento_Resultado CHECK (resultado IN ('REPARADO', 'NO_REPARABLE')),
                                   CONSTRAINT CK_Mantenimiento_Fechas CHECK (fecha_salida IS NULL OR fecha_salida >= fecha_ingreso),
                                   CONSTRAINT CK_Mantenimiento_Cierre CHECK (
                                       (estado = 'EN_PROCESO' AND fecha_salida IS NULL AND resultado IS NULL)
                                           OR (estado = 'FINALIZADO' AND fecha_salida IS NOT NULL AND resultado IS NOT NULL)
                                       )
);
END;
GO

-- 10 AUDITORIA
IF OBJECT_ID(N'dbo.Auditoria', N'U') IS NULL
BEGIN
CREATE TABLE dbo.Auditoria (
                               id_auditoria INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
                               id_usuario INT NULL,
                               fecha_hora DATETIME2 NOT NULL CONSTRAINT DF_Auditoria_Fecha DEFAULT (SYSDATETIME()),
                               accion VARCHAR(60) NOT NULL,
                               entidad VARCHAR(60) NOT NULL,
                               id_registro INT NULL,
                               descripcion VARCHAR(500) NOT NULL,
                               CONSTRAINT FK_Auditoria_Usuario FOREIGN KEY (id_usuario) REFERENCES dbo.Usuario(id_usuario)
);
END;
GO

-- Evitar más de un préstamo PENDIENTE para el mismo equipo.
-- Si hay datos históricos inconsistentes, SQL Server rechazará el índice:
-- corregir duplicados ANTES de crearlo, sin borrar el historial.
IF NOT EXISTS (
    SELECT 1 FROM sys.indexes
    WHERE object_id = OBJECT_ID(N'dbo.DetallePrestamo')
      AND name = N'UX_Detalle_Equipo_Pendiente'
)
BEGIN
CREATE UNIQUE INDEX UX_Detalle_Equipo_Pendiente
    ON dbo.DetallePrestamo(id_equipo)
    WHERE estado = 'PENDIENTE';
END;
GO

-- Evitar dos mantenimientos EN_PROCESO para el mismo equipo.
IF NOT EXISTS (
    SELECT 1 FROM sys.indexes
    WHERE object_id = OBJECT_ID(N'dbo.Mantenimiento')
      AND name = N'UX_Mantenimiento_Equipo_Activo'
)
BEGIN
CREATE UNIQUE INDEX UX_Mantenimiento_Equipo_Activo
    ON dbo.Mantenimiento(id_equipo)
    WHERE estado = 'EN_PROCESO';
END;
GO

-- Verificación básica (deben figurar diez tablas y dos índices UX_*).
SELECT name AS tabla
FROM sys.tables
WHERE schema_id = SCHEMA_ID(N'dbo')
ORDER BY name;

SELECT OBJECT_NAME(object_id) AS tabla, name AS indice
FROM sys.indexes
WHERE name IN (N'UX_Detalle_Equipo_Pendiente', N'UX_Mantenimiento_Equipo_Activo')
ORDER BY tabla, indice;
GO
