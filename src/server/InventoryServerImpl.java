package server;
import common.InventoryService;
import java.rmi.RemoteException;
import java.rmi.server.UnicastRemoteObject;
import java.sql.*;
import java.text.SimpleDateFormat;
import java.util.*;
import org.mindrot.jbcrypt.BCrypt;

public class InventoryServerImpl extends UnicastRemoteObject implements InventoryService {

    public InventoryServerImpl() throws RemoteException { super(); }

    // AUTHENTICATION (Login Logic) ---
    @Override
    public String[] login(String username, String password) throws RemoteException {
        System.out.println("\n[Client Request]: အကောင့်ဝင်ရန် ကြိုးပမ်းမှု - အသုံးပြုသူအမည်: " + username);

        String sql = "SELECT u.user_id, u.password_hash, r.role_name, u.branch_id, u.supplier_id, b.branch_name " +
                "FROM users u " +
                "JOIN roles r ON u.role_id = r.role_id " +
                "LEFT JOIN branches b ON u.branch_id = b.branch_id " +
                "WHERE u.username = ? AND u.status = 'ACTIVE'";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {

            pstmt.setString(1, username);
            try (ResultSet rs = pstmt.executeQuery()) {
                if (rs.next()) {
                    String storedHash = rs.getString("password_hash");

                    // Compatibility for PHP password hashes
                    if (storedHash != null && storedHash.startsWith("$2y$")) {
                        storedHash = storedHash.replaceFirst("\\$2y\\$", "\\$2a\\$");
                    }

                    if (storedHash != null && BCrypt.checkpw(password, storedHash)) {
                        System.out.println("<<< [Success]: Authentication passed for " + username + " [" + rs.getString("role_name") + "]");
                        return new String[]{
                                rs.getString("role_name"),   // [0]
                                rs.getString("branch_id"),   // [1]
                                rs.getString("supplier_id"), // [2]
                                rs.getString("branch_name"), // [3]
                                rs.getString("user_id")      // [4]
                        };
                    }
                }
            }
            System.out.println("<<< [ငြင်းပယ်သည်]: အသုံးပြုသူအမည် သို့မဟုတ် လျှို့ဝှက်နံပါတ် မှားယွင်းနေသည်။");
        } catch (SQLException e) {
            System.err.println("Database Error in Login: " + e.getMessage());
        }
        return null;
    }

    // --- Admin Side ---
    // --- 1.DASHBOARD ANALYTICS ---
    @Override
    public Map<String, Object> getDashboardStats() throws RemoteException {
        System.out.println("[Client Request]: ပင်မစာမျက်နှာအတွက် အစီရင်ခံစာများ တွက်ချက်နေပါသည်။");
        Map<String, Object> stats = new HashMap<>();
        try (Connection conn = DBConnection.getConnection()) {
            ResultSet rs = conn.createStatement().executeQuery("SELECT SUM(quantity * price), SUM(quantity) FROM products");
            if (rs.next()) { stats.put("totalValuation", rs.getLong(1)); stats.put("totalStock", rs.getInt(2)); }

            ResultSet rsB = conn.createStatement().executeQuery("SELECT COUNT(*) FROM branches WHERE status = 'ONLINE'");
            if (rsB.next()) stats.put("activeBranches", rsB.getInt(1));

            ResultSet rsA = conn.createStatement().executeQuery("SELECT COUNT(*) FROM products WHERE quantity < 10");
            if (rsA.next()) stats.put("lowStock", rsA.getInt(1));
        } catch (SQLException e) { e.printStackTrace(); }
        return stats;
    }

    @Override
    public List<String[]> getRecentInventorySync() throws RemoteException {
        System.out.println("[RMI Call]: Fetching Latest Inventory Sync (Top 5)...");
        List<String[]> list = new ArrayList<>();
        String sql = "SELECT product_name, quantity, price FROM products ORDER BY product_id DESC LIMIT 5";

        try (Connection conn = DBConnection.getConnection();
             Statement stmt = conn.createStatement();
             ResultSet rs = stmt.executeQuery(sql)) {
            while (rs.next()) {
                list.add(new String[]{
                        rs.getString("product_name"),
                        rs.getString("quantity"),
                        String.format("%,.2f", rs.getDouble("price"))
                });
            }
        } catch (SQLException e) { e.printStackTrace(); }
        return list;
    }

    //--- End Dashboard ---

    // --- 2.INVENTORY CORE OPERATIONS ---
    @Override
    public List<String[]> getInventory() throws RemoteException {
        System.out.println("[Client Request]: ကုန်ပစ္စည်းလက်ကျန်စာရင်း တစ်ခုလုံးကို ဆွဲထုတ်နေပါသည်။");
        List<String[]> items = new ArrayList<>();

        String sql = "SELECT p.product_id, p.product_name, p.quantity, p.price, b.branch_name, " +
                "p.branch_id, p.supplier_id, p.category, p.metadata, p.image_url " +
                "FROM products p " +
                "LEFT JOIN branches b ON p.branch_id = b.branch_id " +
                "ORDER BY p.product_id DESC";

        try (Connection conn = DBConnection.getConnection();
             Statement stmt = conn.createStatement();
             ResultSet rs = stmt.executeQuery(sql)) {

            while (rs.next()) {

                items.add(new String[]{
                        rs.getString(1),  // id [0]
                        rs.getString(2),  // name [1]
                        rs.getString(3),  // qty [2]
                        rs.getString(4),  // price [3]
                        rs.getString(5),  // branch_name [4]
                        rs.getString(6),  // branch_id [5]
                        rs.getString(7),  // supplier_id [6]
                        rs.getString(8),  // category [7]
                        rs.getString(9),  // metadata [8]
                        rs.getString(10) // image_url [9]
                });
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return items;
    }

    @Override
    public boolean addInventory(String name, double price, int qty, int branchId, int supplierId,
                                String category, String metadata, String imageUrl) throws RemoteException {

        // metadata::jsonb ဟု သတ်မှတ်ပေးရမည်
        System.out.println("\n[Client Request]: ပစ္စည်းအသစ်ထည့်သွင်းခြင်း - " + name);
        String sql = "INSERT INTO products (product_name, price, quantity, branch_id, supplier_id, category, metadata, image_url) " +
                "VALUES (?, ?, ?, ?, ?, ?, ?::jsonb, ?)";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {

            pstmt.setString(1, name);
            pstmt.setDouble(2, price);
            pstmt.setInt(3, qty);
            pstmt.setInt(4, branchId);
            pstmt.setInt(5, supplierId);
            pstmt.setString(6, category);
            pstmt.setString(7, (metadata == null || metadata.isEmpty()) ? "{}" : metadata);
            pstmt.setString(8, (imageUrl == null || imageUrl.isEmpty()) ? "assets/uploads/products/default.png" : imageUrl);

            boolean success = pstmt.executeUpdate() > 0;
            if (success) System.out.println("<<< [အောင်မြင်သည်]: ပစ္စည်းအသစ် '" + name + "' ကို Database ထဲသို့ ထည့်သွင်းပြီးပါပြီ။");
            return success;
        } catch (SQLException e) { e.printStackTrace(); return false; }
    }

    @Override
    public boolean updateInventory(int id, String name, int qty, double price, int bId, int sId, String cat, String meta, String imageUrl) throws RemoteException {
        System.out.println("\n[Client Request]: ပစ္စည်းအချက်အလက် ပြင်ဆင်ခြင်း - ID: " + id);
        try (Connection conn = DBConnection.getConnection()) {
            String sql;
            if (imageUrl != null && !imageUrl.isEmpty()) {
                // ⭐ metadata=? နေရာတွင် metadata=?::jsonb ဟု ပြင်ပါ
                sql = "UPDATE products SET product_name=?, quantity=?, price=?, branch_id=?, supplier_id=?, category=?, metadata=?::jsonb, image_url=? WHERE product_id=?";
            } else {
                sql = "UPDATE products SET product_name=?, quantity=?, price=?, branch_id=?, supplier_id=?, category=?, metadata=?::jsonb WHERE product_id=?";
            }

            PreparedStatement ps = conn.prepareStatement(sql);
            ps.setString(1, name);
            ps.setInt(2, qty);
            ps.setDouble(3, price);
            ps.setInt(4, bId);
            ps.setInt(5, sId);
            ps.setString(6, cat);
            ps.setString(7, meta); // Java က String အဖြစ် ပို့မည်

            if (imageUrl != null && !imageUrl.isEmpty()) {
                ps.setString(8, imageUrl);
                ps.setInt(9, id);
            } else {
                ps.setInt(8, id);
            }
            boolean success = ps.executeUpdate() > 0;
            if (success) System.out.println("<<< [အောင်မြင်သည်]: ID " + id + " ၏ အချက်အလက်များကို Update လုပ်ပြီးပါပြီ။");
            return success;
        } catch (Exception e) {
            e.printStackTrace();
            return false;
        }
    }

    @Override
    public boolean deleteInventory(int id) throws RemoteException {
        System.out.println("\n[Client Request]: ပစ္စည်းဖျက်သိမ်းခြင်း - ID: " + id);
        String sql = "DELETE FROM products WHERE product_id = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {

            pstmt.setInt(1, id);
            boolean success = pstmt.executeUpdate() > 0;
            if (success) System.out.println("<<< [အောင်မြင်သည်]: ပစ္စည်းကို စနစ်အတွင်းမှ ဖယ်ရှားပြီးပါပြီ။");
            return success;
        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
    }

    //--- End Inventory ---

    // --- 3. Branch ---
    @Override
    public List<String[]> getBranches() throws RemoteException {
        List<String[]> branches = new ArrayList<>();
        String sql = "SELECT branch_id, branch_name, location, status FROM branches";
        try (Connection conn = DBConnection.getConnection();
             Statement stmt = conn.createStatement();
             ResultSet rs = stmt.executeQuery(sql)) {
            while (rs.next()) {
                branches.add(new String[]{
                        rs.getString("branch_id"),   // index [0]
                        rs.getString("branch_name"), // index [1]
                        rs.getString("location"),    // index [2] ⭐ ဒါရှိမှ JSP က Error မတက်မှာပါ
                        rs.getString("status")      // index [3]
                });
            }
        } catch (SQLException e) { e.printStackTrace(); }
        return branches;
    }

    // Branch Add and Edit
    @Override
    public boolean saveBranch(String id, String name, String loc) throws RemoteException {
        System.out.println("\n[Admin Request]: ဌာနခွဲ (Branch) အချက်အလက် ပြင်ဆင်ခြင်း/အသစ်ဖွင့်ခြင်း - " + name);
        try (Connection conn = DBConnection.getConnection()) {

            boolean isInsert = (id == null || id.trim().isEmpty() || "null".equalsIgnoreCase(id));

            if (isInsert) {

                String sql = "INSERT INTO branches (branch_name, location, status) VALUES (?, ?, 'ONLINE')";
                try (PreparedStatement ps = conn.prepareStatement(sql)) {
                    ps.setString(1, name);
                    ps.setString(2, loc);
                    return ps.executeUpdate() > 0;
                }
            } else {

                String sql = "UPDATE branches SET branch_name = ?, location = ? WHERE branch_id = ?";
                try (PreparedStatement ps = conn.prepareStatement(sql)) {
                    ps.setString(1, name);
                    ps.setString(2, loc);
                    ps.setInt(3, Integer.parseInt(id));
                    boolean success = ps.executeUpdate() > 0;
                    if(success) System.out.println("<<< [အောင်မြင်သည်]: Distributed Node (" + name + ") Configuration ကို Update လုပ်ပြီးပါပြီ။");
                    return success;
                }
            }
        } catch (SQLException e) {
            System.err.println("Database Error in saveBranch: " + e.getMessage());
            e.printStackTrace();
            return false;
        }
    }

    // Branch ဖျက်သိမ်းခြင်း
    @Override
    public boolean deleteBranch(int id) throws RemoteException {
        String updateProducts = "UPDATE products SET branch_id = NULL WHERE branch_id = ?";
        String updateUsers = "UPDATE users SET branch_id = NULL WHERE branch_id = ?"; // ⭐ ထပ်တိုးရမည့်စာကြောင်း
        String deleteBranch = "DELETE FROM branches WHERE branch_id = ?";

        try (Connection conn = DBConnection.getConnection()) {
            conn.setAutoCommit(false);
            try (PreparedStatement ps1 = conn.prepareStatement(updateProducts);
                 PreparedStatement psU = conn.prepareStatement(updateUsers);
                 PreparedStatement ps2 = conn.prepareStatement(deleteBranch)) {

                ps1.setInt(1, id); ps1.executeUpdate();
                psU.setInt(1, id); psU.executeUpdate(); // Users များကိုပါ အရင်ရှင်းလင်းခြင်း

                ps2.setInt(1, id);
                int rows = ps2.executeUpdate();
                conn.commit();
                return rows > 0;
            } catch (SQLException e) {
                conn.rollback();
                throw e;
            }
        } catch (SQLException e) {
            throw new RemoteException("Database Error: " + e.getMessage());
        }
    }

    @Override
    public boolean toggleBranchStatus(int id, String currentStatus) throws RemoteException {
        // လက်ရှိ status က ONLINE ဆိုရင် OFFLINE ပြောင်းမယ်၊ မဟုတ်ရင် ONLINE ပြောင်းမယ်
        String nextStatus = "ONLINE".equals(currentStatus) ? "OFFLINE" : "ONLINE";
        String sql = "UPDATE branches SET status = ? WHERE branch_id = ?";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setString(1, nextStatus);
            ps.setInt(2, id);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
    }
    //--- End Branch ---

    //-- Supplier --
    @Override
    public List<String[]> getSuppliers() throws RemoteException {
        List<String[]> list = new ArrayList<>();
        // ⭐ SQL မှာ s.contact_person ကိုပါ ထည့်သွင်းဆွဲထုတ်ပါ
        String sql = "SELECT s.*, u.username FROM suppliers s LEFT JOIN users u ON s.supplier_id = u.supplier_id ORDER BY s.supplier_id DESC";

        try (Connection conn = DBConnection.getConnection();
             Statement stmt = conn.createStatement();
             ResultSet rs = stmt.executeQuery(sql)) {

            while (rs.next()) {
                list.add(new String[]{
                        rs.getString("supplier_id"),   // [0]
                        rs.getString("name"),          // [1]
                        rs.getString("info"),          // [2]
                        rs.getString("username"),      // [3]
                        rs.getString("contact_person") // [4] ⭐ ဒါမှ JSP ဘက်မှာ ပြလို့ရမှာပါ
                });
            }
        } catch (SQLException e) { e.printStackTrace(); }
        return list;
    }


    @Override
    public boolean saveSupplier(String id, String name, String address, String phone, String email, String contactPerson) throws RemoteException {
        System.out.println("\n[Admin Request]: ကုန်သွင်းသူ (Supplier) အချက်အလက် သိမ်းဆည်းခြင်း - " + name);
        String infoJson = String.format("{\"address\": \"%s\", \"phone\": \"%s\", \"email\": \"%s\"}", address, phone, email);

        try (Connection conn = DBConnection.getConnection()) {
            conn.setAutoCommit(false); // Transaction စတင်ပါ
            boolean success;

            if (id == null || id.trim().isEmpty() || id.equals("null")) {
                // INSERT: contact_person ကို တိုက်ရိုက်ထည့်ပါ
                String sql = "INSERT INTO suppliers (name, info, contact_person) VALUES (?, ?::jsonb, ?) RETURNING supplier_id";
                System.out.println(">>> ကုန်သွင်းသူအသစ်အတွက် Portal အကောင့် ဖန်တီးနေပါသည်။");
                PreparedStatement ps = conn.prepareStatement(sql);
                ps.setString(1, name); ps.setString(2, infoJson); ps.setString(3, contactPerson);
                ResultSet rs = ps.executeQuery();

                if (rs.next()) {
                    int newSid = rs.getInt("supplier_id");
                    // Portal Access အတွက် အကောင့်ဖွင့်ပေးခြင်း
                    String username = name.toLowerCase().replace(" ", "_") + "_" + (int)(Math.random() * 900 + 100);
                    String sqlUser = "INSERT INTO users (username, password_hash, role_id, supplier_id, status) VALUES (?, ?, 5, ?, 'ACTIVE')";
                    PreparedStatement psUser = conn.prepareStatement(sqlUser);
                    psUser.setString(1, username);
                    psUser.setString(2, "$2a$10$YourHashedPassword"); // Default: 123456
                    psUser.setInt(3, newSid);
                    psUser.executeUpdate();
                }
                success = true;
            } else {
                // UPDATE: contact_person ပါဝင်အောင် ပြင်ဆင်ခြင်း
                String sql = "UPDATE suppliers SET name = ?, info = ?::jsonb, contact_person = ? WHERE supplier_id = ?";
                PreparedStatement ps = conn.prepareStatement(sql);
                ps.setString(1, name); ps.setString(2, infoJson); ps.setString(3, contactPerson);
                ps.setInt(4, Integer.parseInt(id));
                success = ps.executeUpdate() > 0;
            }
            conn.commit();
            if(success) System.out.println("<<< [အောင်မြင်သည်]: ကုန်သွင်းသူစာရင်းနှင့် Portal Access အကောင့်များကို တစ်ပြိုင်နက် Update လုပ်ပြီးပါပြီ။");
            return success;
        } catch (Exception e) { e.printStackTrace(); return false; }
    }

    // --- Delete Supplier Logic ---
    @Override
    public boolean deleteSupplier(int id) throws RemoteException {
        // ၁။ Users table မှာ ချိတ်ဆက်နေတဲ့ supplier_id ကို အရင် NULL ပြောင်းပေးရပါမယ်
        String sqlUpdateUsers = "UPDATE users SET supplier_id = NULL WHERE supplier_id = ?";
        String sqlDeleteSupplier = "DELETE FROM suppliers WHERE supplier_id = ?";

        try (Connection conn = DBConnection.getConnection()) {
            conn.setAutoCommit(false);
            try (PreparedStatement ps1 = conn.prepareStatement(sqlUpdateUsers);
                 PreparedStatement ps2 = conn.prepareStatement(sqlDeleteSupplier)) {

                ps1.setInt(1, id);
                ps1.executeUpdate(); // User accounts များကို ဖြုတ်ချခြင်း

                ps2.setInt(1, id);
                int rows = ps2.executeUpdate(); // Supplier ကို အပြီးတိုင် ဖျက်ခြင်း

                conn.commit();
                return rows > 0;
            } catch (SQLException e) {
                conn.rollback();
                throw e;
            }
        } catch (SQLException e) {
            throw new RemoteException("Delete Failed: " + e.getMessage());
        }
    }

    //--- End Supplier ---


    @Override
    public List<String[]> getProcurementReport(String category) throws RemoteException {
        List<String[]> report = new ArrayList<>();
        // PHP SQL Logic အတိုင်း JSONB threshold ပါ ဆွဲထုတ်ခြင်း
        String sql = "SELECT p.product_id, p.product_name, p.quantity, p.price, p.category, " +
                "(p.quantity * p.price) as total_value, s.name as supplier_name, " +
                "b.branch_name, p.metadata->>'threshold' as threshold " +
                "FROM products p " +
                "JOIN suppliers s ON p.supplier_id = s.supplier_id " +
                "JOIN branches b ON p.branch_id = b.branch_id WHERE 1=1";

        if (category != null && !category.equals("ALL")) {
            sql += " AND p.category = '" + category + "'";
        }
        sql += " ORDER BY p.product_id DESC";

        try (Connection conn = DBConnection.getConnection();
             Statement stmt = conn.createStatement();
             ResultSet rs = stmt.executeQuery(sql)) {
            while (rs.next()) {
                report.add(new String[]{
                        rs.getString("product_id"),   // [0]
                        rs.getString("product_name"), // [1]
                        rs.getString("quantity"),     // [2]
                        rs.getString("price"),        // [3]
                        rs.getString("category"),      // [4]
                        rs.getString("total_value"),   // [5]
                        rs.getString("supplier_name"), // [6]
                        rs.getString("branch_name"),   // [7]
                        rs.getString("threshold")      // [8]
                });
            }
        } catch (SQLException e) { e.printStackTrace(); }
        return report;
    }

    @Override
    public List<String> getCategories() throws RemoteException {
        List<String> cats = new ArrayList<>();
        try (Connection conn = DBConnection.getConnection();
             Statement stmt = conn.createStatement();
             ResultSet rs = stmt.executeQuery("SELECT DISTINCT category FROM products WHERE category IS NOT NULL")) {
            while (rs.next()) { cats.add(rs.getString(1)); }
        } catch (SQLException e) { e.printStackTrace(); }
        return cats;
    }

    //--- 7.Transfer ---
    @Override
    public boolean transferStock(int fromBranch, int toBranch, int productId, int qty, int userId) throws RemoteException {
        // try-with-resources ကိုသုံးခြင်းဖြင့် conn.close() ကို manual ပိတ်စရာမလိုတော့ပါ
        System.out.println("\n[Client Request]: ဌာနခွဲအချင်းချင်း ပစ္စည်းလွှဲပြောင်းခြင်း စတင်နေပါသည်။");
        System.out.println("အသေးစိတ်: ပစ္စည်း ID " + productId + " [" + qty + " ခု] ကို ဌာန " + fromBranch + " မှ ဌာန " + toBranch + " သို့ လွှဲပြောင်းမည်။");
        try (Connection conn = DBConnection.getConnection()) {

            // ⭐ PostgreSQL အတွက် CALL syntax ကို တိုက်ရိုက်သုံးပါ
            String sql = "CALL sp_transfer_stock(?, ?, ?, ?, ?)";

            try (CallableStatement cs = conn.prepareCall(sql)) {
                cs.setInt(1, fromBranch);
                cs.setInt(2, toBranch);
                cs.setInt(3, productId);
                cs.setInt(4, qty);
                cs.setInt(5, userId);

                cs.execute();
                System.out.println("<<< [အောင်မြင်သည်]: Database ရှိ Stored Procedure ကို အသုံးပြု၍ လွှဲပြောင်းမှု ပြီးမြောက်ပါသည်။");
                return true;
            }
        } catch (SQLException e) {
            // ⭐ JSP ဘက်က Error Message ကို အတိအကျ မြင်ရအောင် ပို့ပေးခြင်း
            System.err.println("Database Logic Breach: " + e.getMessage());
            throw new RemoteException(e.getMessage());
        }
    }

    @Override
    public List<String[]> getTransferHistory() throws RemoteException {
        List<String[]> logs = new ArrayList<>();
        String sql = "SELECT * FROM audit_logs WHERE action ILIKE '%transfer%' ORDER BY timestamp DESC LIMIT 5";
        try (Connection conn = DBConnection.getConnection(); Statement stmt = conn.createStatement(); ResultSet rs = stmt.executeQuery(sql)) {
            while (rs.next()) {
                logs.add(new String[]{ rs.getString("action"), rs.getString("timestamp") });
            }
        } catch (SQLException e) { e.printStackTrace(); }
        return logs;
    }
    // --- End Transfer ---

    // --- 8.Order ---
    @Override
    public List<String[]> getPendingRequests() throws RemoteException {
        List<String[]> list = new ArrayList<>();
        // PENDING ဖြစ်နေသော request များကို ဆိုင်ခွဲနာမည်နှင့်တကွ ဆွဲထုတ်ခြင်း
        String sql = "SELECT r.*, b.branch_name FROM stock_requests r " +
                "JOIN branches b ON r.branch_id = b.branch_id " +
                "WHERE r.status = 'PENDING' ORDER BY r.requested_at ASC";

        try (Connection conn = DBConnection.getConnection();
             Statement stmt = conn.createStatement();
             ResultSet rs = stmt.executeQuery(sql)) {
            while (rs.next()) {
                list.add(new String[]{
                        rs.getString("request_id"),   // [0]
                        rs.getString("product_name"), // [1]
                        rs.getString("quantity"),     // [2]
                        rs.getString("requested_at"), // [3]
                        rs.getString("branch_name")   // [4]
                });
            }
        } catch (SQLException e) { e.printStackTrace(); }
        return list;
    }

    @Override
    public boolean approveRequest(int requestId, String adminUsername) throws RemoteException {
        System.out.println("\n[Client Request]: အမှာစာ အတည်ပြုခြင်း - Request ID: " + requestId);
        String sql = "UPDATE stock_requests SET status = 'APPROVED', " +
                "approved_by = (SELECT user_id FROM users WHERE username = ?) " +
                "WHERE request_id = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, adminUsername);
            ps.setInt(2, requestId);
            boolean success = ps.executeUpdate() > 0;
            if (success) System.out.println("<<< [အောင်မြင်သည်]: အမှာစာကို အတည်ပြုပြီးပါပြီ။");
            return success;
        } catch (SQLException e) { e.printStackTrace(); return false; }
    }

    @Override
    public boolean rejectRequest(int requestId, String remark, String adminUsername) throws RemoteException {
        String sql = "UPDATE stock_requests SET status = 'REJECTED', remark = ?, " +
                "approved_by = (SELECT user_id FROM users WHERE username = ?) " +
                "WHERE request_id = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, remark);
            ps.setString(2, adminUsername);
            ps.setInt(3, requestId);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) { e.printStackTrace(); return false; }
    }

    @Override
    public boolean placeOrder(int productId, int quantity, int branchId) throws RemoteException {
        String getProductSql = "SELECT product_name, supplier_id, price, category FROM products WHERE product_id = ?";
        String insertOrderSql = "INSERT INTO stock_requests (product_name, quantity, supplier_id, branch_id, price, category, status, requested_at) " +
                "VALUES (?, ?, ?, ?, ?, ?, 'PENDING', NOW())";

        try (Connection conn = DBConnection.getConnection()) {
            // ၁။ Product အချက်အလက်အရင်ရယူခြင်း
            PreparedStatement psProd = conn.prepareStatement(getProductSql);
            psProd.setInt(1, productId);
            ResultSet rs = psProd.executeQuery();

            if (rs.next()) {
                // ၂။ Order တင်ခြင်း
                PreparedStatement psOrder = conn.prepareStatement(insertOrderSql);
                psOrder.setString(1, rs.getString("product_name"));
                psOrder.setInt(2, quantity);
                psOrder.setInt(3, rs.getInt("supplier_id"));
                psOrder.setInt(4, branchId);
                psOrder.setDouble(5, rs.getDouble("price"));
                psOrder.setString(6, rs.getString("category"));

                return psOrder.executeUpdate() > 0;
            }
        } catch (SQLException e) { e.printStackTrace(); }
        return false;
    }

    @Override
    public List<String[]> getPendingOrders() throws RemoteException {
        List<String[]> list = new ArrayList<>();
        String sql = "SELECT r.*, b.branch_name FROM stock_requests r " +
                "JOIN branches b ON r.branch_id = b.branch_id WHERE r.status = 'PENDING' " +
                "ORDER BY r.requested_at DESC";
        try (Connection conn = DBConnection.getConnection(); Statement stmt = conn.createStatement(); ResultSet rs = stmt.executeQuery(sql)) {
            while (rs.next()) {
                list.add(new String[]{
                        rs.getString("request_id"), rs.getString("product_name"),
                        rs.getString("quantity"), rs.getString("branch_name"),
                        rs.getString("status"), rs.getString("requested_at"),
                        rs.getString("price"), rs.getString("category")
                });
            }
        } catch (SQLException e) { e.printStackTrace(); }
        return list;
    }
    //--- End Order ---

    //--- 9.Tracking ---
    @Override
    public List<String[]> getShipments(String filter) throws RemoteException {
        List<String[]> list = new ArrayList<>();
        String sql = "SELECT sr.*, s.name as supplier_name, b.branch_name FROM stock_requests sr " +
                "JOIN suppliers s ON sr.supplier_id = s.supplier_id " +
                "JOIN branches b ON sr.branch_id = b.branch_id " +
                "WHERE sr.status IN ('SHIPPED', 'RECEIVED')";

        if ("SHIPPED".equals(filter)) sql += " AND sr.status = 'SHIPPED'";
        if ("RECEIVED".equals(filter)) sql += " AND sr.status = 'RECEIVED'";
        sql += " ORDER BY sr.received_at DESC NULLS LAST, sr.requested_at DESC";

        try (Connection conn = DBConnection.getConnection(); Statement stmt = conn.createStatement(); ResultSet rs = stmt.executeQuery(sql)) {
            while (rs.next()) {
                list.add(new String[]{
                        rs.getString("request_id"), rs.getString("product_name"), rs.getString("quantity"),
                        rs.getString("status"), rs.getString("supplier_name"), rs.getString("branch_name"),
                        rs.getString("received_at"), rs.getString("remark")
                });
            }
        } catch (SQLException e) { e.printStackTrace(); }
        return list;
    }

    @Override
    public boolean receiveShipment(int requestId, int actualQty) throws RemoteException {
        Connection conn = null;
        System.out.println("\n[Client Request]: ပစ္စည်းရောက်ရှိကြောင်း အတည်ပြုခြင်း - ID: " + requestId);
        try {
            conn = DBConnection.getConnection();
            conn.setAutoCommit(false);

            // ၁။ Request အချက်အလက်ယူခြင်း
            PreparedStatement psGet = conn.prepareStatement("SELECT * FROM stock_requests WHERE request_id = ?");
            psGet.setInt(1, requestId);
            ResultSet rs = psGet.executeQuery();

            if (rs.next()) {
                int targetQty = rs.getInt("quantity");
                String productName = rs.getString("product_name");
                int branchId = rs.getInt("branch_id");
                String remark = (actualQty != targetQty) ? "Shortage: Received " + actualQty + " of " + targetQty : "Full order received";

                // ၂။ Status Update လုပ်ခြင်း
                PreparedStatement psUpd = conn.prepareStatement("UPDATE stock_requests SET status = 'RECEIVED', received_at = NOW(), remark = ? WHERE request_id = ?");
                psUpd.setString(1, remark);
                psUpd.setInt(2, requestId);
                psUpd.executeUpdate();

                // ၃။ Product Stock တိုးခြင်း (Trigger မရှိပါက ဤနေရာတွင် ရေးရပါမည်)
                PreparedStatement psStock = conn.prepareStatement("UPDATE products SET quantity = quantity + ? WHERE product_name = ? AND branch_id = ?");
                psStock.setInt(1, actualQty);
                psStock.setString(2, productName);
                psStock.setInt(3, branchId);
                psStock.executeUpdate();

                conn.commit();
                System.out.println("<<< [အောင်မြင်သည်]: ပစ္စည်းလက်ခံရရှိမှု မှတ်တမ်းတင်ပြီး လက်ကျန်စာရင်းကို တိုးမြှင့်ပြီးပါပြီ။");
                return true;
            }
        } catch (SQLException e) { if (conn != null) try { conn.rollback(); } catch (Exception ex) {} e.printStackTrace(); }
        return false;
    }

    @Override
    public boolean deleteShipmentHistory(int requestId) throws RemoteException {
        String sql = "DELETE FROM stock_requests WHERE request_id = ? AND status = 'RECEIVED'";
        try (Connection conn = DBConnection.getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, requestId);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) { e.printStackTrace(); return false; }
    }
    //--- End Tracking ---

    // --- 10.USER MANAGEMENT ---
    @Override
    public List<String[]> getUsers(String search, String roleFilter) throws RemoteException {
        List<String[]> list = new ArrayList<>();
        String sql = "SELECT u.*, r.role_name, b.branch_name FROM users u " +
                "LEFT JOIN roles r ON u.role_id = r.role_id " +
                "LEFT JOIN branches b ON u.branch_id = b.branch_id WHERE 1=1";

        if (search != null && !search.isEmpty()) sql += " AND u.username ILIKE '%" + search + "%'";
        if (roleFilter != null && !roleFilter.isEmpty()) sql += " AND u.role_id = " + roleFilter;
        sql += " ORDER BY u.user_id ASC";

        try (Connection conn = DBConnection.getConnection(); Statement stmt = conn.createStatement(); ResultSet rs = stmt.executeQuery(sql)) {
            while (rs.next()) {
                list.add(new String[]{
                        rs.getString("user_id"), rs.getString("username"), rs.getString("role_name"),
                        rs.getString("branch_name"), rs.getString("status"), rs.getString("role_id"),
                        rs.getString("branch_id")
                });
            }
        } catch (SQLException e) { e.printStackTrace(); }
        return list;
    }
    @Override
    public List<String[]> getRoles() throws RemoteException {
        List<String[]> roles = new ArrayList<>();
        // Database ထဲက roles table ကနေ ဒေတာဆွဲထုတ်ခြင်း
        String sql = "SELECT * FROM roles ORDER BY role_id ASC";

        try (Connection conn = DBConnection.getConnection();
             Statement stmt = conn.createStatement();
             ResultSet rs = stmt.executeQuery(sql)) {

            while (rs.next()) {
                roles.add(new String[]{
                        rs.getString("role_id"),   // [0]
                        rs.getString("role_name")  // [1]
                });
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return roles;
    }
    @Override
    public boolean saveUser(String id, String username, int roleId, String branchId) throws RemoteException {
        System.out.println("\n[Client Request]: အသုံးပြုသူအသစ်/ပြင်ဆင်ခြင်း ဆောင်ရွက်နေပါသည်။ - " + username);
        try (Connection conn = DBConnection.getConnection()) {
            if (id != null && !id.isEmpty()) {
                // Update User
                String sql = "UPDATE users SET username = ?, role_id = ?, branch_id = ? WHERE user_id = ?";
                PreparedStatement ps = conn.prepareStatement(sql);
                ps.setString(1, username);
                ps.setInt(2, roleId);
                if (branchId == null || branchId.isEmpty()) ps.setNull(3, java.sql.Types.INTEGER);
                else ps.setInt(3, Integer.parseInt(branchId));
                ps.setInt(4, Integer.parseInt(id));
                return ps.executeUpdate() > 0;
            } else {
                // Insert New User (Default Password: password123)
                String sql = "INSERT INTO users (username, password_hash, role_id, branch_id, status) VALUES (?, ?, ?, ?, 'ACTIVE')";
                PreparedStatement ps = conn.prepareStatement(sql);
                ps.setString(1, username);
                ps.setString(2, BCrypt.hashpw("password123", BCrypt.gensalt())); // BCrypt သုံး၍ Hash လုပ်ခြင်း
                ps.setInt(3, roleId);
                if (branchId == null || branchId.isEmpty()) ps.setNull(4, java.sql.Types.INTEGER);
                else ps.setInt(4, Integer.parseInt(branchId));
                return ps.executeUpdate() > 0;
            }
        } catch (SQLException e) { e.printStackTrace(); return false; }
    }

    @Override
    public boolean resetPassword(int userId) throws RemoteException {
        String newHash = BCrypt.hashpw("password123", BCrypt.gensalt());
        String sql = "UPDATE users SET password_hash = ? WHERE user_id = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, newHash);
            ps.setInt(2, userId);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) { e.printStackTrace(); return false; }
    }

    @Override
    public boolean toggleUserStatus(int userId, String currentStatus) throws RemoteException {
        String newStatus = currentStatus.equals("ACTIVE") ? "DISABLED" : "ACTIVE";
        String sql = "UPDATE users SET status = ? WHERE user_id = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, newStatus);
            ps.setInt(2, userId);  // ✅ pass int
            return ps.executeUpdate() > 0;
        } catch (SQLException e) { e.printStackTrace(); return false; }
    }

    @Override
    public boolean deleteUser(int userId) throws RemoteException {
        String sql = "DELETE FROM users WHERE user_id = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, userId); // ✅ pass int
            return ps.executeUpdate() > 0;
        } catch (SQLException e) { e.printStackTrace(); return false; }
    }


    //--- End UserRoles ---

    //--- 11.Audit Logs ---
    @Override
    public List<String[]> getAllLogs(String branchId, String date) throws RemoteException {
        System.out.println("[Client Request]: စနစ်လုပ်ဆောင်ချက် မှတ်တမ်းများကို ဆွဲထုတ်နေပါသည်။");
        List<String[]> logs = new ArrayList<>();
        StringBuilder sql = new StringBuilder(
                "SELECT l.*, u.username, b.branch_name FROM audit_logs l " +
                        "JOIN users u ON l.user_id = u.user_id " +
                        "LEFT JOIN branches b ON u.branch_id = b.branch_id WHERE 1=1"
        );

        if (branchId != null && !branchId.equals("ALL")) sql.append(" AND u.branch_id = ").append(branchId);
        if (date != null && !date.isEmpty()) sql.append(" AND DATE(l.timestamp) = '").append(date).append("'");

        sql.append(" ORDER BY l.timestamp DESC LIMIT 150");

        try (Connection conn = DBConnection.getConnection();
             Statement stmt = conn.createStatement();
             ResultSet rs = stmt.executeQuery(sql.toString())) {
            while (rs.next()) {
                logs.add(new String[]{
                        rs.getString("log_id"),    // [0]
                        rs.getString("timestamp"), // [1]
                        rs.getString("username"),  // [2]
                        rs.getString("action"),    // [3]
                        rs.getString("branch_name") != null ? rs.getString("branch_name") : "System Core" // [4]
                });
            }
        } catch (SQLException e) { e.printStackTrace(); }
        return logs;
    }

    @Override
    public boolean deleteLog(int logId) throws RemoteException {
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement("DELETE FROM audit_logs WHERE log_id = ?")) {
            ps.setInt(1, logId);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) { e.printStackTrace(); return false; }
    }

    @Override
    public boolean clearAllLogs() throws RemoteException {
        try (Connection conn = DBConnection.getConnection();
             Statement stmt = conn.createStatement()) {

            stmt.executeUpdate("DELETE FROM audit_logs");
            return true;

        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
    }

    //--- End Audit Log ---

    //Manager Dashboard
    @Override
    public Map<String, Object> getManagerStats(int branchId) throws RemoteException {
        System.out.println("\n[Manager Request]: ဌာနခွဲ ID (" + branchId + ") အတွက် အစီရင်ခံစာများ တွက်ချက်နေပါသည်။");
        Map<String, Object> stats = new HashMap<>();
        try (Connection conn = DBConnection.getConnection()) {
            // ၁။ SKU အရေအတွက်နှင့် စုစုပေါင်းတန်ဖိုး (PHP Logic ၁ အတိုင်း)
            String sqlStats = "SELECT COUNT(*) as skus, SUM(quantity * price) as val FROM products WHERE branch_id = ?";
            try (PreparedStatement ps = conn.prepareStatement(sqlStats)) {
                ps.setInt(1, branchId);
                ResultSet rs = ps.executeQuery();
                System.out.println(">>> ဌာနခွဲ၏ လက်ရှိပစ္စည်းအမျိုးအမည်နှင့် စုစုပေါင်းတန်ဖိုးကို တွက်ချက်ပြီးပါပြီ။");
                if (rs.next()) {
                    stats.put("skus", rs.getInt("skus"));
                    stats.put("totalValuation", rs.getDouble("val"));
                }
            }

            // ၂။ Pending Stock Requests (PHP Logic ၂ အတိုင်း)
            String sqlPending = "SELECT COUNT(*) FROM stock_requests WHERE branch_id = ? AND status = 'PENDING'";
            try (PreparedStatement ps = conn.prepareStatement(sqlPending)) {
                ps.setInt(1, branchId);
                ResultSet rs = ps.executeQuery();
                if (rs.next()) stats.put("pendingRequests", rs.getInt(1));
            }

            // ၃။ Critical Stock Alerts (Threshold Check - PHP Logic ၃ အတိုင်း)
            List<String[]> alerts = new ArrayList<>();
            // Note: သင့် Table ထဲတွင် metadata->>'threshold' ရှိရန် လိုအပ်ပါသည်
            String sqlAlerts = "SELECT product_name, category, quantity FROM products " +
                    "WHERE branch_id = ? AND quantity < (metadata->>'threshold')::int " +
                    "ORDER BY quantity ASC LIMIT 5";
            try (PreparedStatement ps = conn.prepareStatement(sqlAlerts)) {
                ps.setInt(1, branchId);
                ResultSet rs = ps.executeQuery();
                while (rs.next()) {
                    alerts.add(new String[]{ rs.getString(1), rs.getString(2), rs.getString(3) });
                }
            }
            stats.put("alerts", alerts);

        } catch (SQLException e) { e.printStackTrace(); }
        return stats;
    }

    @Override
    public List<String[]> getProductsBySupplier(int supplierId) throws RemoteException {
        List<String[]> products = new ArrayList<>();
        String sql = "SELECT product_name FROM products WHERE supplier_id = ? GROUP BY product_name";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, supplierId);
            ResultSet rs = ps.executeQuery();
            while (rs.next()) {
                products.add(new String[]{ rs.getString("product_name") });
            }
        } catch (SQLException e) { e.printStackTrace(); }
        return products;
    }

    @Override
    public List<String[]> getStockRequests(int branchId, String search, String status) throws RemoteException {
        List<String[]> list = new ArrayList<>();
        StringBuilder sql = new StringBuilder(
                "SELECT r.*, s.name as supplier_name FROM stock_requests r " +
                        "LEFT JOIN suppliers s ON r.supplier_id = s.supplier_id " +
                        "WHERE r.branch_id = ?"
        );

        if (search != null && !search.isEmpty()) sql.append(" AND r.product_name ILIKE '%").append(search).append("%'");
        if (status != null && !status.isEmpty()) sql.append(" AND r.status = '").append(status).append("'");
        sql.append(" ORDER BY r.requested_at DESC");

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql.toString())) {
            ps.setInt(1, branchId);
            ResultSet rs = ps.executeQuery();
            while (rs.next()) {
                list.add(new String[]{
                        rs.getString("request_id"), rs.getString("product_name"),
                        rs.getString("quantity"), rs.getString("status"),
                        rs.getString("requested_at"), rs.getString("supplier_name"),
                        rs.getString("remark")
                });
            }
        } catch (SQLException e) { e.printStackTrace(); }
        return list;
    }
    @Override
    public boolean createStockRequest(int supplierId, String productName, int quantity, int branchId, String remark) throws RemoteException {
        // PHP Logic အတိုင်း status ကို 'PENDING' ဟု သတ်မှတ်၍ ထည့်သွင်းခြင်း
        System.out.println("\n[Manager Request]: အမှာစာအသစ် တင်သွင်းခြင်း - " + productName);
        System.out.println("အသေးစိတ်: ဌာနခွဲ (" + branchId + ") မှ Supplier (" + supplierId + ") ဆီသို့ [" + quantity + "] ခု မှာယူပါသည်။");
        String sql = "INSERT INTO stock_requests (supplier_id, product_name, quantity, branch_id, remark, status, requested_at) " +
                    "VALUES (?, ?, ?, ?, ?, 'PENDING', CURRENT_TIMESTAMP)";

        try (Connection conn = DBConnection.getConnection();
            PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setInt(1, supplierId);
            ps.setString(2, productName);
            ps.setInt(3, quantity);
            ps.setInt(4, branchId);
            ps.setString(5, remark);

            boolean success = ps.executeUpdate() > 0;
            if (success) System.out.println("<<< [အောင်မြင်သည်]: အမှာစာကို မှတ်တမ်းတင်ပြီး Supplier ဆီသို့ ချိတ်ဆက်ပေးလိုက်ပါပြီ။");
            return success;
        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
    }

    @Override
    public boolean deleteStockRequest(int requestId, int branchId) throws RemoteException {
        String sql = "DELETE FROM stock_requests WHERE request_id = ? AND branch_id = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, requestId);
            ps.setInt(2, branchId);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) { e.printStackTrace(); return false; }
    }

    @Override
    public boolean wipeBranchHistory(int branchId) throws RemoteException {
        // PHP: DELETE FROM stock_requests WHERE branch_id = ?
        String sql = "DELETE FROM stock_requests WHERE branch_id = ?";

        try (Connection conn = DBConnection.getConnection();
            PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setInt(1, branchId);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
    }

    @Override
    public List<String[]> getBranchInventory(int branchId) throws RemoteException {
        List<String[]> list = new ArrayList<>();
        // quantity * price ကို SQL ထဲမှာတင် တွက်ချက်ခြင်း
        String sql = "SELECT product_name, price, quantity, (quantity * price) as asset_value, metadata " +
                "FROM products WHERE branch_id = ? ORDER BY quantity ASC";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, branchId);
            ResultSet rs = ps.executeQuery();
            while (rs.next()) {
                list.add(new String[]{
                        rs.getString("product_name"), rs.getString("price"),
                        rs.getString("quantity"), rs.getString("asset_value"),
                        rs.getString("metadata")
                });
            }
        } catch (SQLException e) { e.printStackTrace(); }
        return list;
    }

    @Override
    public List<String[]> getBranchStaffWithActivity(int branchId) throws RemoteException {
        System.out.println("\n[Manager Request]: ဌာနခွဲ ID (" + branchId + ") ရှိ ဝန်ထမ်းများ၏ လှုပ်ရှားမှုမှတ်တမ်းကို စစ်ဆေးနေပါသည်။");
        List<String[]> staffList = new ArrayList<>();
        // Role ID 3 (StockKeeper) များကိုသာ ဆွဲထုတ်ခြင်း
        String sql = "SELECT u.user_id, u.username, u.status, " +
                "(SELECT action FROM audit_logs WHERE user_id = u.user_id ORDER BY timestamp DESC LIMIT 1) as last_activity, " +
                "(SELECT timestamp FROM audit_logs WHERE user_id = u.user_id ORDER BY timestamp DESC LIMIT 1) as last_seen " +
                "FROM users u WHERE u.branch_id = ? AND u.role_id = 3 ORDER BY u.username ASC";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, branchId);
            ResultSet rs = ps.executeQuery();
            while (rs.next()) {
                staffList.add(new String[]{
                        rs.getString("user_id"),       // [0]
                        rs.getString("username"),      // [1]
                        rs.getString("status"),        // [2]
                        rs.getString("last_activity"),  // [3]
                        rs.getString("last_seen")       // [4]
                });
            }
        } catch (SQLException e) { e.printStackTrace(); }
        System.out.println("<<< [အောင်မြင်သည်]: ဝန်ထမ်းများ၏ နောက်ဆုံးအခြေအနေ (Last Seen) ကို ပေးပို့လိုက်ပါပြီ။");
        return staffList;
    }

    @Override
    public List<String[]> getStaffAuditLogs(int userId) throws RemoteException {
        List<String[]> logs = new ArrayList<>();
        // အချိန်အလိုက် နောက်ဆုံးလုပ်ဆောင်ချက်ကို အရင်ပြရန်
        String sql = "SELECT action, timestamp FROM audit_logs WHERE user_id = ? ORDER BY timestamp DESC";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, userId);
            ResultSet rs = ps.executeQuery();
            while (rs.next()) {
                logs.add(new String[]{
                        rs.getString("action"),
                        rs.getString("timestamp")
                });
            }
        } catch (SQLException e) { e.printStackTrace(); }
        return logs;
    }

    @Override
    public List<String[]> getBranchAuditLogs(int branchId, String dateFilter) throws RemoteException {
        List<String[]> logs = new ArrayList<>();
        // STOCK သို့မဟုတ် PRODUCT ပါဝင်သော action မှတ်တမ်းများကိုသာ ရှာဖွေခြင်း
        StringBuilder sql = new StringBuilder(
                "SELECT l.*, u.username FROM audit_logs l " +
                        "JOIN users u ON l.user_id = u.user_id " +
                        "WHERE u.branch_id = ? AND (l.action ILIKE '%STOCK%' OR l.action ILIKE '%PRODUCT%')"
        );

        if (dateFilter != null && !dateFilter.isEmpty()) {
            sql.append(" AND DATE(l.timestamp) = '").append(dateFilter).append("'");
        }
        sql.append(" ORDER BY l.timestamp DESC LIMIT 100");

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql.toString())) {
            ps.setInt(1, branchId);
            ResultSet rs = ps.executeQuery();
            while (rs.next()) {
                logs.add(new String[]{
                        rs.getString("timestamp"), // [0]
                        rs.getString("username"),  // [1]
                        rs.getString("action")     // [2]
                });
            }
        } catch (SQLException e) { e.printStackTrace(); }
        return logs;
    }
    //Manager End

    // Supplier Start
    @Override
    public Map<String, Object> getSupplierStats(int supplierId) throws RemoteException {
        Map<String, Object> stats = new HashMap<>();
        try (Connection conn = DBConnection.getConnection()) {
            // ၁။ စုစုပေါင်း မှာယူမှု အရေအတွက် (Pending Requests)
            String sql1 = "SELECT COUNT(*) FROM stock_requests WHERE supplier_id = ? AND status = 'PENDING'";
            try (PreparedStatement ps = conn.prepareStatement(sql1)) {
                ps.setInt(1, supplierId);
                ResultSet rs = ps.executeQuery();
                if (rs.next()) stats.put("pending_orders", rs.getInt(1));
            }

            // ၂။ ပို့ဆောင်ပြီးသော အော်ဒါများ (Total Fulfilled)
            String sql2 = "SELECT COUNT(*) FROM stock_requests WHERE supplier_id = ? AND status = 'SHIPPED'";
            try (PreparedStatement ps = conn.prepareStatement(sql2)) {
                ps.setInt(1, supplierId);
                ResultSet rs = ps.executeQuery();
                if (rs.next()) stats.put("total_shipped", rs.getInt(1));
            }
            String sql3 = "SELECT COUNT(*) FROM stock_requests WHERE supplier_id = ? AND status != 'CANCELLED'";
            try (PreparedStatement ps = conn.prepareStatement(sql3)) {
                ps.setInt(1, supplierId);
                ResultSet rs = ps.executeQuery();
                if (rs.next()) stats.put("total_invoices", rs.getInt(1));
            }

            // ၃။ စုစုပေါင်း ရောင်းရငွေ (Revenue Estimate)
            // Null Error မတက်စေရန် COALESCE ကို သုံး၍ တန်ဖိုးမရှိပါက 0 ပြန်စေပါမည်
            String sql4 = "SELECT COALESCE(SUM(quantity * price), 0) FROM stock_requests " +
                    "WHERE supplier_id = ? AND status != 'CANCELLED'";
            try (PreparedStatement ps = conn.prepareStatement(sql4)) {
                ps.setInt(1, supplierId);
                ResultSet rs = ps.executeQuery();
                if (rs.next()) stats.put("total_revenue", rs.getDouble(1));
            }
        } catch (SQLException e) { e.printStackTrace(); }
        return stats;
    }

    @Override
    public List<String[]> getSupplierInventoryMonitor(int supplierId) throws RemoteException {
        List<String[]> list = new ArrayList<>();
        // မိမိသွင်းထားသော ပစ္စည်းများ၏ လက်ရှိ Stock အခြေအနေ
        String sql = "SELECT p.product_name, p.quantity, b.branch_name, " +
                "(p.metadata->>'threshold')::int as threshold " +
                "FROM products p JOIN branches b ON p.branch_id = b.branch_id " +
                "WHERE p.supplier_id = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, supplierId);
            ResultSet rs = ps.executeQuery();
            while (rs.next()) {
                list.add(new String[]{
                        rs.getString(1), rs.getString(2), rs.getString(3), rs.getString(4)
                });
            }
        } catch (SQLException e) { e.printStackTrace(); }
        return list;
    }

    @Override
    public List<String[]> getRecentSupplierOrders(int supplierId, int limit) throws RemoteException {
        List<String[]> list = new ArrayList<>();
        // နောက်ဆုံးမှာယူမှုများကို ရက်စွဲအလိုက် ဆွဲထုတ်ခြင်း
        String sql = "SELECT request_id, product_name, quantity, status, requested_at " +
                "FROM stock_requests WHERE supplier_id = ? ORDER BY requested_at DESC LIMIT ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, supplierId);
            ps.setInt(2, limit);
            ResultSet rs = ps.executeQuery();
            while (rs.next()) {
                list.add(new String[]{
                        rs.getString(1), rs.getString(2), rs.getString(3), rs.getString(4), rs.getString(5)
                });
            }
        } catch (SQLException e) { e.printStackTrace(); }
        return list;
    }
    @Override
    public List<String[]> getStockRequestsBySupplier(int supplierId, String status) throws RemoteException {
        System.out.println("\n[Supplier Request]: မိမိဆီသို့ မှာယူထားသော အော်ဒါများကို စစ်ဆေးနေပါသည်။");
        System.out.println("အသေးစိတ်: Supplier ID (" + supplierId + ") အတွက် '" + status + "' အခြေအနေရှိသော ဒေတာများကို ရယူနေသည်။");
        List<String[]> list = new ArrayList<>();

        // SQL Query: Supplier ID အလိုက် ဆိုင်ခွဲအမည်နှင့်တကွ ဆွဲထုတ်ခြင်း
        StringBuilder sql = new StringBuilder(
                "SELECT r.request_id, r.product_name, r.quantity, r.status, b.branch_name, r.requested_at " +
                        "FROM stock_requests r " +
                        "JOIN branches b ON r.branch_id = b.branch_id " +
                        "WHERE r.supplier_id = ?"
        );

        // Status Filter: "ALL" မဟုတ်ပါက သက်ဆိုင်ရာ status အလိုက် filter လုပ်မည်
        if (!"ALL".equalsIgnoreCase(status)) {
            sql.append(" AND r.status = '").append(status).append("'");
        }

        sql.append(" ORDER BY r.requested_at DESC");

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql.toString())) {

            ps.setInt(1, supplierId);
            ResultSet rs = ps.executeQuery();

            while (rs.next()) {
                // JSP ဘက်တွင် ပြန်သုံးမည့် String Array များ
                list.add(new String[]{
                        rs.getString("request_id"),   // [0]
                        rs.getString("product_name"), // [1]
                        rs.getString("quantity"),     // [2]
                        rs.getString("status"),       // [3]
                        rs.getString("branch_name"),  // [4]
                        rs.getString("requested_at")  // [5]
                });
            }
        } catch (SQLException e) {
            e.printStackTrace();
            throw new RemoteException("Database Error in getStockRequestsBySupplier: " + e.getMessage());
        }
        System.out.println("<<< [အောင်မြင်သည်]: အော်ဒါစာရင်းများကို Supplier Node ဆီသို့ ပေးပို့လိုက်ပါပြီ။");
        return list;
    }
    @Override
    public boolean updateStockRequestStatus(int requestId, String status) throws RemoteException {
        System.out.println("\n[Supplier Request]: အမှာစာ အခြေအနေ (Status) ပြောင်းလဲနေပါသည်။");
        System.out.println("အသေးစိတ်: Request ID (" + requestId + ") ကို '" + status + "' အဖြစ်သို့ ပြောင်းလဲမည်။");
        String sql = "UPDATE stock_requests SET status = ? WHERE request_id = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setString(1, status);
            ps.setInt(2, requestId);

            boolean success = ps.executeUpdate() > 0;
            if (success) {
                System.out.println("<<< [အောင်မြင်သည်]: Status ပြောင်းလဲမှု ပြီးမြောက်ပါသည်။ Manager ဘက်တွင် ချက်ချင်းမြင်ရမည်ဖြစ်သည်။");
            }
            return success;
        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
    }
    // End supplier

    // Storekeeper
    @Override
    public Map<String, Object> getBranchStats(int branchId) throws RemoteException {
        Map<String, Object> stats = new HashMap<>();
        try (Connection conn = DBConnection.getConnection()) {
            String sql = "SELECT COUNT(*) as total_items, SUM(quantity * price) as inventory_value " +
                    "FROM products WHERE branch_id = ?";
            PreparedStatement ps = conn.prepareStatement(sql);
            ps.setInt(1, branchId);
            ResultSet rs = ps.executeQuery();
            if (rs.next()) {
                stats.put("total_items", rs.getLong("total_items"));
                stats.put("inventory_value", rs.getDouble("inventory_value"));
            }
        } catch (SQLException e) { e.printStackTrace(); }
        return stats;
    }

    @Override
    public List<String[]> getLowStockAlerts(int branchId, int limit) throws RemoteException {
        List<String[]> list = new ArrayList<>();

        // ⭐ Query ထဲတွင် (metadata->>'threshold') ကိုပါ select လုပ်ထားသည်
        String sql = "SELECT product_id, product_name, quantity, (metadata->>'threshold')::int as safety_limit " +
                "FROM products " +
                "WHERE branch_id = ? AND quantity < (metadata->>'threshold')::int " +
                "ORDER BY quantity ASC LIMIT ?";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setInt(1, branchId);
            ps.setInt(2, limit);
            ResultSet rs = ps.executeQuery();

            while (rs.next()) {
                list.add(new String[]{
                        rs.getString("product_id"),   // [0]
                        rs.getString("product_name"), // [1]
                        rs.getString("quantity"),     // [2]
                        rs.getString("safety_limit")  // [3] ⭐ Index 3 မှာ threshold ကိုထည့်လိုက်သည်
                });
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return list;
    }

    @Override
    public List<String[]> getInventoryByBranch(int branchId) throws RemoteException {
        List<String[]> list = new ArrayList<>();
        // [0]id, [1]name, [2]qty, [3]price, [4]category, [5]threshold (from metadata)
        String sql = "SELECT product_id, product_name, quantity, price, category, (metadata->>'threshold')::int " +
                "FROM products WHERE branch_id = ? ORDER BY product_name ASC";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, branchId);
            ResultSet rs = ps.executeQuery();
            while (rs.next()) {
                list.add(new String[]{ rs.getString(1), rs.getString(2), rs.getString(3), rs.getString(4), rs.getString(5), rs.getString(6) });
            }
        } catch (SQLException e) { e.printStackTrace(); }
        return list;
    }

    @Override
    public boolean updateProductQuantity(int pid, int qty, int branchId, int userId, String pname) throws RemoteException {
        String sql = "UPDATE products SET quantity = ? WHERE product_id = ? AND branch_id = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, qty);
            ps.setInt(2, pid);
            ps.setInt(3, branchId);

            int rows = ps.executeUpdate();
            if (rows > 0) {
                // Activity Log မှတ်တမ်းတင်ခြင်း
                logActivity(userId, "Inventory Sync: Adjusted @" + pname + " to " + qty + " units");
                return true;
            }
        } catch (SQLException e) { e.printStackTrace(); }
        return false;
    }
    private void logActivity(int userId, String action) {
        System.out.println("[Log မှတ်တမ်း]: အသုံးပြုသူ " + userId + " က " + action + " ကို ဆောင်ရွက်ခဲ့သည်။");
        String sql = "INSERT INTO audit_logs (user_id, action, timestamp) VALUES (?, ?, CURRENT_TIMESTAMP)";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setInt(1, userId);
            ps.setString(2, action);
            ps.executeUpdate();

            System.out.println("Log Registered: " + action); // Server Console တွင် ကြည့်ရန်
        } catch (SQLException e) {
            System.err.println("Audit Log Failure: " + e.getMessage());
            e.printStackTrace();
        }
    }
    @Override
    public boolean addStock(int productId, int qty, int branchId, int userId, String productName) throws RemoteException {
        // Transaction အနေဖြင့် အလုပ်လုပ်ရန်
        System.out.println("\n[Storekeeper Request]: ပစ္စည်းအဝင် (Inbound) မှတ်တမ်းတင်နေပါသည်။");
        System.out.println("အသေးစိတ်: " + productName + " [" + qty + " ခု] ကို ဌာနခွဲ ID (" + branchId + ") ထဲသို့ ထည့်သွင်းမည်။");
        String updateSql = "UPDATE products SET quantity = quantity + ? WHERE product_id = ? AND branch_id = ?";

        try (Connection conn = DBConnection.getConnection()) {
            conn.setAutoCommit(false);

            try (PreparedStatement ps = conn.prepareStatement(updateSql)) {
                ps.setInt(1, qty);
                ps.setInt(2, productId);
                ps.setInt(3, branchId);

                int rows = ps.executeUpdate();
                if (rows > 0) {
                    // အရင်က ရေးခဲ့သော logActivity method ကို ပြန်သုံးခြင်း
                    logActivity(userId, "Inbound: Received " + qty + " units for @" + productName);
                    conn.commit();
                    System.out.println("<<< [အောင်မြင်သည်]: လက်ကျန်စာရင်းကို တိုးမြှင့်ပြီး Log မှတ်တမ်းတင်ပြီးပါပြီ။");
                    return true;
                }
                conn.rollback();
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }
    // ၁။ လက်ကျန်ရှိသော ပစ္စည်းများသာ ဆွဲယူရန် (Quantity > 0)
    @Override
    public List<String[]> getAvailableInventory(int branchId) throws RemoteException {
        List<String[]> list = new ArrayList<>();
        String sql = "SELECT product_id, product_name, quantity FROM products WHERE branch_id = ? AND quantity > 0 ORDER BY product_name ASC";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, branchId);
            ResultSet rs = ps.executeQuery();
            while (rs.next()) {
                list.add(new String[]{ rs.getString(1), rs.getString(2), rs.getString(3) });
            }
        } catch (SQLException e) { e.printStackTrace(); }
        return list;
    }

    // ၂။ ပစ္စည်းထုတ်ယူခြင်း (Validation ပါဝင်သည်)
    @Override
    public String removeStock(int pid, int outQty, int branchId, int userId, String pname) throws RemoteException {
        System.out.println("\n[Storekeeper Request]: ပစ္စည်းထုတ်ယူခြင်း (Outbound) ဆောင်ရွက်နေပါသည်။");
        System.out.println("အသေးစိတ်: " + pname + " [" + outQty + " ခု] ကို ထုတ်ယူရန် စစ်ဆေးနေပါသည်။");
        try (Connection conn = DBConnection.getConnection()) {
            // ပစ္စည်းလက်ကျန် စစ်ဆေးခြင်း
            String checkSql = "SELECT quantity FROM products WHERE product_id = ? AND branch_id = ?";
            PreparedStatement psCheck = conn.prepareStatement(checkSql);
            psCheck.setInt(1, pid);
            psCheck.setInt(2, branchId);
            ResultSet rs = psCheck.executeQuery();

            if (rs.next()) {
                int currentQty = rs.getInt("quantity");
                if (currentQty >= outQty) {
                    // လက်ကျန်လုံလောက်ပါက နှုတ်ခြင်း
                    String updateSql = "UPDATE products SET quantity = quantity - ? WHERE product_id = ? AND branch_id = ?";
                    PreparedStatement psUpdate = conn.prepareStatement(updateSql);
                    psUpdate.setInt(1, outQty);
                    psUpdate.setInt(2, pid);
                    psUpdate.setInt(3, branchId);
                    psUpdate.executeUpdate();

                    logActivity(userId, "Outbound: Dispatched " + outQty + " units of @" + pname);
                    System.out.println("<<< [အောင်မြင်သည်]: ပစ္စည်းထုတ်ပေးလိုက်ပါပြီ။ လက်ကျန်အသစ်မှာ " + (currentQty - outQty) + " ဖြစ်သည်။");
                    return "SUCCESS";
                } else {
                    System.out.println("<<< [မအောင်မြင်ပါ]: လက်ကျန်မလုံလောက်ပါ။ (လက်ရှိ: " + currentQty + ")");
                    return "Insufficient Stock: Only " + currentQty + " units available.";
                }
            }
        } catch (SQLException e) {
            return "Database Error: " + e.getMessage();
        }
        return "Product Not Found";
    }
    // End Shopkeeper

    // Notification and Setting
    @Override
    public List<Map<String, String>> getNotificationsForAdmin() throws RemoteException {
        System.out.println("[Client Request]: Admin အတွက် အသိပေးချက်များ ရယူနေပါသည်။");
        List<Map<String, String>> list = new ArrayList<>();
        String sql = "SELECT action, timestamp FROM audit_logs ORDER BY timestamp DESC LIMIT 15";
        try (Connection conn = DBConnection.getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {
            ResultSet rs = ps.executeQuery();
            while (rs.next()) {
                Map<String, String> m = new HashMap<>();
                m.put("title", rs.getString("action"));
                m.put("date", new SimpleDateFormat("yyyy-MM-dd HH:mm:ss").format(rs.getTimestamp("timestamp")));
                m.put("type", "system"); m.put("sub", "စနစ်မှတ်တမ်း");
                list.add(m);
            }
        } catch (Exception e) { e.printStackTrace(); }
        return list;
    }

    @Override
    public List<Map<String, String>> getNotificationsForBranch(int branchId) throws RemoteException {
        List<Map<String, String>> list = new ArrayList<>();
        String sql = "SELECT product_name FROM products WHERE branch_id = ? AND quantity < (metadata->>'threshold')::int";
        try (Connection conn = DBConnection.getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, branchId);
            ResultSet rs = ps.executeQuery();
            while (rs.next()) {
                Map<String, String> m = new HashMap<>();
                m.put("title", rs.getString("product_name") + " is running low!");
                m.put("date", new SimpleDateFormat("yyyy-MM-dd HH:mm:ss").format(new java.util.Date()));
                m.put("type", "warning");
                m.put("sub", "Inventory Warning");
                list.add(m);
            }
        } catch (Exception e) { e.printStackTrace(); }
        return list;
    }

    @Override
    public List<Map<String, String>> getNotificationsForSupplier(int supplierId) throws RemoteException {
        List<Map<String, String>> list = new ArrayList<>();
        String sql = "SELECT product_name, requested_at FROM stock_requests WHERE supplier_id = ? AND status = 'PENDING' ORDER BY requested_at DESC";
        try (Connection conn = DBConnection.getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, supplierId);
            ResultSet rs = ps.executeQuery();
            while (rs.next()) {
                Map<String, String> m = new HashMap<>();
                m.put("title", "New request for " + rs.getString("product_name"));
                m.put("date", new SimpleDateFormat("yyyy-MM-dd HH:mm:ss").format(rs.getTimestamp("requested_at")));
                m.put("type", "Order");
                m.put("sub", "Incoming Procurement");
                list.add(m);
            }
        } catch (Exception e) { e.printStackTrace(); }
        return list;
    }

    @Override
    public boolean updatePassword(int userId, String currentPass, String newPass, String role) throws RemoteException {
        System.out.println("\n[RMI Call]: Security - Password change requested for User ID: " + userId);
        String query = "SELECT password_hash FROM users WHERE user_id = ?";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(query)) {

            ps.setInt(1, userId);
            ResultSet rs = ps.executeQuery();

            if (rs.next()) {
                String storedHash = rs.getString("password_hash");
                if (storedHash != null && storedHash.startsWith("$2y$")) {
                    storedHash = storedHash.replaceFirst("\\$2y\\$", "\\$2a\\$");
                }

                if (BCrypt.checkpw(currentPass, storedHash)) {
                    String newHashed = BCrypt.hashpw(newPass, BCrypt.gensalt());
                    String updateQuery = "UPDATE users SET password_hash = ? WHERE user_id = ?";

                    try (PreparedStatement psUpd = conn.prepareStatement(updateQuery)) {
                        psUpd.setString(1, newHashed);
                        psUpd.setInt(2, userId);
                        psUpd.executeUpdate();
                        logActivity(userId, "Security: Password synchronization completed by @" + role + "-Node");
                        System.out.println("<<< [Success]: Password updated and synced.");
                        return true;
                    }
                }
            }
            System.out.println("<<< [Failed]: Current password incorrect.");
        } catch (SQLException e) { e.printStackTrace(); }
        return false;
    }
}