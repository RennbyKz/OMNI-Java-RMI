package common;
import java.rmi.Remote;
import java.rmi.RemoteException;
import java.util.List;
import java.util.Map;

public interface
InventoryService extends Remote {
    //Check Login role
    String[] login(String username, String password) throws RemoteException;

    //DASHBOARD ANALYTICS ---
    Map<String, Object> getDashboardStats() throws RemoteException;
    List<String[]> getRecentInventorySync() throws RemoteException;
    List<String[]> getInventory() throws RemoteException;

    // Inventory CRUD
    boolean addInventory(String name, double price, int qty, int branchId, int supplierId,
                         String category, String metadata, String imageUrl) throws RemoteException;
    boolean deleteInventory(int id) throws RemoteException;
    boolean updateInventory(int id, String name, int qty, double price, int bId, int sId, String cat, String meta, String imageUrl) throws RemoteException;

    // AUXILIARY DATA ---
    List<String[]> getBranches() throws RemoteException;
    boolean saveBranch(String id, String name, String loc) throws RemoteException;
    boolean deleteBranch(int id) throws RemoteException;
    boolean toggleBranchStatus(int id, String currentStatus) throws RemoteException;

    // Supplier Management
    List<String[]> getSuppliers() throws RemoteException;
    boolean saveSupplier(String id, String name, String address, String phone, String email, String contactPerson) throws RemoteException;
    boolean deleteSupplier(int id) throws RemoteException;


    //  Procurement Analytics Data
    List<String[]> getProcurementReport(String category) throws RemoteException;
    List<String> getCategories() throws RemoteException;

    // Stock Transfer Logic
    boolean transferStock(int fromBranch, int toBranch, int productId, int qty, int userId) throws RemoteException;
    List<String[]> getTransferHistory() throws RemoteException;

    // Stock Request Management
    List<String[]> getPendingRequests() throws RemoteException;
    boolean approveRequest(int requestId, String adminUsername) throws RemoteException;
    boolean rejectRequest(int requestId, String remark, String adminUsername) throws RemoteException;

    // Procurement & Orders
    boolean placeOrder(int productId, int quantity, int branchId) throws RemoteException;
    List<String[]> getPendingOrders() throws RemoteException;

    // Logistics & Shipment Tracking
    List<String[]> getShipments(String filter) throws RemoteException;
    boolean receiveShipment(int requestId, int actualQty) throws RemoteException;
    boolean deleteShipmentHistory(int requestId) throws RemoteException;

    //USER MANAGEMENT LOGIC ---
    List<String[]> getUsers(String search, String roleFilter) throws RemoteException;
    List<String[]> getRoles() throws RemoteException;
    boolean saveUser(String id, String username, int roleId, String branchId) throws RemoteException;
    boolean resetPassword(int userId) throws RemoteException;
    boolean toggleUserStatus(int userId, String currentStatus) throws RemoteException;
    boolean deleteUser(int userId) throws RemoteException;

    //  Audit Log Management
    List<String[]> getAllLogs(String branchId, String date) throws RemoteException;
    boolean deleteLog(int logId) throws RemoteException;
    boolean clearAllLogs() throws RemoteException;

    //Manager Dashboard
    // --- Manager Dashboard & Inventory ---
    Map<String, Object> getManagerStats(int branchId) throws RemoteException;
    List<String[]> getStockRequests(int branchId, String search, String statusFilter) throws RemoteException;
    boolean createStockRequest(int supplierId, String productName, int quantity, int branchId, String remark) throws RemoteException;
    boolean deleteStockRequest(int requestId, int branchId) throws RemoteException;
    boolean wipeBranchHistory(int branchId) throws RemoteException;
    List<String[]> getProductsBySupplier(int supplierId) throws RemoteException;
    List<String[]> getBranchInventory(int branchId) throws RemoteException;
    List<String[]> getBranchStaffWithActivity(int branchId) throws RemoteException;
    List<String[]> getStaffAuditLogs(int userId) throws RemoteException;
    List<String[]> getBranchAuditLogs(int branchId, String dateFilter) throws RemoteException;

    //Supplier Dashboard
    Map<String, Object> getSupplierStats(int supplierId) throws RemoteException;
    List<String[]> getSupplierInventoryMonitor(int supplierId) throws RemoteException;
    List<String[]> getRecentSupplierOrders(int supplierId, int limit) throws RemoteException;
    List<String[]> getStockRequestsBySupplier(int supplierId, String status) throws RemoteException;
    boolean updateStockRequestStatus(int requestId, String status) throws RemoteException;

    //Storekeeper Dashboard
    Map<String, Object> getBranchStats(int branchId) throws RemoteException;
    List<String[]> getLowStockAlerts(int branchId, int limit) throws RemoteException;
    List<String[]> getInventoryByBranch(int branchId) throws RemoteException;
    boolean updateProductQuantity(int pid, int qty, int branchId, int userId, String pname) throws RemoteException;
    boolean addStock(int productId, int qty, int branchId, int userId, String productName) throws RemoteException;
    List<String[]> getAvailableInventory(int branchId) throws RemoteException;
    String removeStock(int pid, int outQty, int branchId, int userId, String pname) throws RemoteException;

    //Notification and Setting
    List<Map<String, String>> getNotificationsForAdmin() throws RemoteException;
    List<Map<String, String>> getNotificationsForBranch(int branchId) throws RemoteException;
    List<Map<String, String>> getNotificationsForSupplier(int supplierId) throws RemoteException;
    boolean updatePassword(int userId, String currentPass, String newPass, String role) throws RemoteException;


}