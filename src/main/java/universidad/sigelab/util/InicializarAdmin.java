package universidad.sigelab.util;

import universidad.sigelab.config.DatabaseConnection;

import java.io.Console;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;

public class InicializarAdmin {

    public static void main(String[] args) {

        Console consola = System.console();

        if (consola == null) {
            System.err.println(
                    "Ejecuta esta clase desde una terminal con consola."
            );
            return;
        }

        char[] caracteres = consola.readPassword(
                "Contraseña del administrador: "
        );

        if (caracteres == null || caracteres.length < 8) {
            System.err.println(
                    "La contraseña debe tener al menos 8 caracteres."
            );
            return;
        }

        String password = new String(caracteres);
        java.util.Arrays.fill(caracteres, '\0');

        String sql = """
            INSERT INTO Usuario
                (nombre, apellido, username,
                 password_hash, correo, id_rol, estado)
            SELECT ?, ?, ?, ?, ?, id_rol, 'ACTIVO'
            FROM Rol
            WHERE nombre = 'ADMIN'
            """;

        try (Connection conexion =
                     DatabaseConnection.getConnection()) {

            try (PreparedStatement verificar =
                         conexion.prepareStatement(
                                 "SELECT COUNT(*) FROM Usuario WHERE username = ?"
                         )) {

                verificar.setString(1, "admin");

                try (ResultSet rs = verificar.executeQuery()) {
                    rs.next();

                    if (rs.getInt(1) > 0) {
                        System.out.println(
                                "El administrador ya existe."
                        );
                        return;
                    }
                }
            }

            String hash = PasswordUtil.generarHash(password);

            try (PreparedStatement ps =
                         conexion.prepareStatement(sql)) {

                ps.setString(1, "Administrador");
                ps.setString(2, "SIGELAB");
                ps.setString(3, "admin");
                ps.setString(4, hash);
                ps.setString(5, "admin@sigelab.local");

                int filas = ps.executeUpdate();

                if (filas == 1) {
                    System.out.println(
                            "Administrador creado correctamente."
                    );
                } else {
                    System.err.println(
                            "No se creó el administrador. Verifica el rol ADMIN."
                    );
                }
            }

        } catch (SQLException e) {
            System.err.println(
                    "Error al registrar el administrador: "
                            + e.getMessage()
            );
        } finally {
            password = null;
        }
    }
}