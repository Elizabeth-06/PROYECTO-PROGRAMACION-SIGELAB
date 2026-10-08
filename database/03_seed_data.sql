USE PROYECTO_SIGELAB;
GO

-- ROLES
IF NOT EXISTS (SELECT 1 FROM Rol WHERE nombre = 'ADMIN')
    INSERT INTO Rol (nombre, descripcion)
    VALUES ('ADMIN', 'Administrador del sistema');

IF NOT EXISTS (SELECT 1 FROM Rol WHERE nombre = 'ENCARGADO')
    INSERT INTO Rol (nombre, descripcion)
    VALUES ('ENCARGADO', 'Encargado de laboratorios');

-- LABORATORIOS
IF NOT EXISTS (SELECT 1 FROM Laboratorio WHERE codigo = 'LAB-001')
    INSERT INTO Laboratorio
        (codigo, nombre, ubicacion, capacidad)
    VALUES
        ('LAB-001', 'Laboratorio de Computación',
         'Edificio A', 30);

-- TIPOS DE EQUIPO
IF NOT EXISTS (SELECT 1 FROM TipoEquipo WHERE nombre = 'Laptop')
    INSERT INTO TipoEquipo (nombre, descripcion)
    VALUES ('Laptop', 'Computadora portátil');

IF NOT EXISTS (SELECT 1 FROM TipoEquipo WHERE nombre = 'Camara')
    INSERT INTO TipoEquipo (nombre, descripcion)
    VALUES ('Camara', 'Equipo audiovisual');

IF NOT EXISTS (SELECT 1 FROM TipoEquipo WHERE nombre = 'Proyector')
    INSERT INTO TipoEquipo (nombre, descripcion)
    VALUES ('Proyector', 'Equipo de proyección');

-- EQUIPOS DE PRUEBA
IF NOT EXISTS (
    SELECT 1 FROM Equipo
    WHERE codigo_inventario = 'CAM-001'
)
BEGIN
INSERT INTO Equipo
(codigo_inventario, nombre, id_tipo_equipo,
 marca, modelo, numero_serie, id_laboratorio)
VALUES
    ('CAM-001', 'Camara Canon',
     (SELECT id_tipo_equipo FROM TipoEquipo WHERE nombre = 'Camara'),
     'Canon', 'EOS', 'SERIE001',
     (SELECT id_laboratorio FROM Laboratorio WHERE codigo = 'LAB-001'));
END;
GO