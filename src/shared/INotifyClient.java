package shared;
import java.rmi.Remote;
import java.rmi.RemoteException;

public interface INotifyClient extends Remote {
    void receiveNotification(String message) throws RemoteException;
}