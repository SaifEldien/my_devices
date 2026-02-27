import '../models/device.dart';
import '../models/user.dart';

abstract class IDeviceRepository {

  Future<void> syncDevices(List<Device> devices);

  Future<List<Device>> restoreDevices();

  Future<User> retrieveUser(String email);

  Future<bool> login(String email,String password);

  Future<void> logout();

  Future<User?> retrieveUserLocally(String email);

  Future <void> restPassword (String email);

}