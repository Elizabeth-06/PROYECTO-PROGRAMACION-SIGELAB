package universidad.sigelab.config;

import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.SQLException;

public class DatabaseConnection {

    private static final String URL =
            "jdbc:sqlserver://localhost:1433;"
                    + "databaseName=PROYECTO_SIGELAB;"
                    + "encrypt=true;"
                    + "trustServerCertificate=true;";

    private static final String USER =
            System.getenv("SIGELAB_DB_USER");

    private static final String PASSWORD =
            System.getenv("SIGELAB_DB_PASSWORD");

    public static Connection getConnection()
            throws SQLException {

        if (USER == null || PASSWORD == null) {
            throw new SQLException(
                    "Faltan las variables de entorno de SQL Server."
            );
        }

        return DriverManager.getConnection(
                URL, USER, PASSWORD
        );
    }
}