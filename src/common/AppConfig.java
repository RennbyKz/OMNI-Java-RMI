package common;
import server.DBConnection;

import java.sql.*;

public class AppConfig {
    public static String getRmiUrl() {
        String serverIP = "localhost"; // အကယ်၍ error တက်ရင် သုံးမယ့် default

        try (Connection conn = DBConnection.getConnection()) {
            // Database ထဲမှ လက်ရှိ Server IP ကို လှမ်းဖတ်ခြင်း
            String sql = "SELECT config_value FROM system_config WHERE config_key = 'server_ip'";
            Statement stmt = conn.createStatement();
            ResultSet rs = stmt.executeQuery(sql);

            if (rs.next()) {
                serverIP = rs.getString("config_value");
            }
        } catch (Exception e) {
            System.err.println("Config Error: " + e.getMessage());
        }

        return "rmi://" + serverIP + ":1100/InventoryService";
    }
}