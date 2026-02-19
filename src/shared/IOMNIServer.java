package shared;
import java.rmi.Remote;
import java.rmi.RemoteException;

public interface IOMNIServer extends Remote {
    void registerClient(INotifyClient client) throws RemoteException;
}