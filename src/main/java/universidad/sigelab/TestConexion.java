package universidad.sigelab;

import universidad.sigelab.config.DatabaseConnection;

import java.sql.Connection;
import java.sql.SQLException;

public class TestConexion {

    public static void main(String[] args) {

        try (Connection conexion =
                     DatabaseConnection.getConnection()) {

            System.out.println(
                    "CONEXION EXITOSA A PROYECTO_SIGELAB"
            );

            System.out.println(
                    "Base de datos: "
                            + conexion.getCatalog()
            );

        } catch (SQLException e) {

            System.err.println(
                    "ERROR AL CONECTAR CON SQL SERVER"
            );

            System.err.println(e.getMessage());
        }
    }
}