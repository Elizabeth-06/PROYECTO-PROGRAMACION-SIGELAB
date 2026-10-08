-- =============================================
-- PROYECTO: SIGELAB
-- Sistema de Gestión y Control de
-- Laboratorios Universitarios
--
-- Universidad Mariano Gálvez de Guatemala
-- Curso: Programación II
-- Base de datos: PROYECTO_SIGELAB
-- =============================================

USE master;
GO

-- Crear la base de datos si no existe
IF DB_ID(N'PROYECTO_SIGELAB') IS NULL
BEGIN
    CREATE DATABASE PROYECTO_SIGELAB;
    PRINT 'Base de datos creada correctamente.';
END
ELSE
BEGIN
    PRINT 'La base de datos ya existe.';
END;
GO

-- Seleccionar la base de datos
USE PROYECTO_SIGELAB;
GO

-- Verificar la base de datos seleccionada
SELECT DB_NAME() AS BaseDeDatosActual;
GO