package common;
import java.rmi.Remote;
import java.rmi.RemoteException;
import java.util.List;
import java.util.Map;

public interface InventoryService extends Remote {
    //Check Login role
    String[] login(String username, String password) throws RemoteException;

    //DASHBOARD ANALYTICS ---
    Map<String, Object> getDashboardStats() throws RemoteException;
    List<String[]> getRecentInventorySync() throws RemoteException;
    List<String[]> getInventory() throws RemoteException;
