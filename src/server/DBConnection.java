package server;

import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.SQLException;

public class DBConnection {
    // PostgreSQL အတွက် URL format
    private static final String URL = "jdbc:postgresql://localhost:5432/smart_logistics_db";
    private static final String USER = "postgres"; // PostgreSQL user
    private static final String PASS = "root"; // သင့် database password

    public static Connection getConnection() throws SQLException {
        try {
            // PostgreSQL Driver ကို Load လုပ်ခြင်း
            Class.forName("org.postgresql.Driver");
            return DriverManager.getConnection(URL, USER, PASS);
        } catch (ClassNotFoundException e) {
            throw new SQLException("PostgreSQL Driver not found! Make sure you added the JAR file.");
        }
    }
}