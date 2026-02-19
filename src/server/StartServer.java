package server;
import common.InventoryService;
import java.net.InetAddress;
import java.rmi.Naming;
import java.rmi.registry.LocateRegistry;
import java.sql.Connection;
import java.sql.PreparedStatement;

public class StartServer {
    public static void main(String[] args) {
        try {
            // ၁။ စက်ရဲ့ လက်ရှိ Local IP Address ကို အလိုအလျောက် ရှာယူခြင်း
            String currentIP = InetAddress.getLocalHost().getHostAddress();

            // ၂။ ⭐ Database ထဲမှာ Server IP ကို သွားရောက် Update လုပ်ခြင်း
            try (Connection conn = DBConnection.getConnection()) {
                String sql = "UPDATE system_config SET config_value = ? WHERE config_key = 'server_ip'";
                try (PreparedStatement ps = conn.prepareStatement(sql)) {
                    ps.setString(1, currentIP);
                    ps.executeUpdate();
                    System.out.println("💾 Database Synced: Server IP set to " + currentIP);
                }
            }

            // ၃။ RMI အတွက် IP ကို Dynamic သတ်မှတ်ခြင်း
            System.setProperty("java.rmi.server.hostname", currentIP);

            // ၄။ RMI Registry ကို Port 1100 မှာ စတင်ခြင်း
            LocateRegistry.createRegistry(1100);

            // ၅။ Server Implementation Object ဆောက်ခြင်း
            InventoryService service = new InventoryServerImpl();

            // ၆။ Bind လုပ်ခြင်း
            String rmiUrl = "rmi://" + currentIP + ":1100/InventoryService";
            Naming.rebind(rmiUrl, service);

            System.out.println("🚀 OMNI RMI Server is ready!");
            System.out.println("🌐 Current Server IP: " + currentIP);
            System.out.println("📡 Multi-device access enabled via DB Sync.");

        } catch (Exception e) {
            System.err.println("❌ Server Exception: " + e.toString());
            e.printStackTrace();
        }
    }
}