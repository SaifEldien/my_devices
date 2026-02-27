import  'package:my_devices/core/core.dart';

import '../data/providers/local/local_db.dart';
import '../data/repositories/device_repository.dart';
import 'auth_provider.dart';

class DeviceProvider extends ChangeNotifier {
  final IDeviceRepository _repository;

  DeviceProvider(this._repository);

  List<Device> _devices = [];
  int currentFilter = 0;
  int devicesCurrentScreenIndex = 0;

  set devicesCurrentScreenIndexValue(int value) {
    devicesCurrentScreenIndex = value;
    notifyListeners();
  }

  List<Device> get devices => _devices;


  Future<void> fetchDevicesFromServer() async {
    for (var e in _devices) {
      await LocalDB().delete('devices', e.id);
    }
    _devices = await _repository.restoreDevices();
    for (var e in _devices) {
       LocalDB().insertData('devices', e.toJson());
    }
    _devices.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    checkOverdueDevices(_devices);
    notifyListeners();
  }

  Future<void> getDevicesFromLocalDb({required  AuthProvider authProvider}) async {
    try {
      List jsonList = await LocalDB().getData('devices',where: (item)=> item["userId"]==authProvider.currentUser!.id);
      _devices = List.generate(jsonList.length, (i) => Device.fromJson(jsonList[i]));
      _devices.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      notifyListeners();
      checkOverdueDevices(_devices);
    } catch (e) {
      return;
    }
  }

  Future<void> uploadBackup({required  AuthProvider authProvider}) async {
      await _repository.syncDevices(_devices);
      await authProvider.refreshUserData();
  }

  void setDevices(List<Device> newDevices) {
    _devices = newDevices;
    checkOverdueDevices(_devices);
    notifyListeners();
  }

  Future<void> addDevice(Device newDevice) async {
    _devices.add(newDevice);
    _devices.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    notifyListeners();
    await LocalDB().insertData('devices', newDevice.toJson());
  }

  void removeDevice(String id) {
    _devices.removeWhere((device) => device.id == id);
    notifyListeners();
    LocalDB().delete('devices', id);
  }

  void updateDevice(Device updatedDevice) {
    final index = _devices.indexWhere((device) => device.id == updatedDevice.id);
    if (index != -1) {
      _devices[index] = updatedDevice;
      checkOverdueDevices([_devices[index]]);
      notifyListeners();
      LocalDB().insertData('devices', updatedDevice.toJson());
    }
  }

  String _searchQuery = "";

  void setSearchQuery(String value) {
    _searchQuery = value.toLowerCase();
    notifyListeners();
  }

  Future<void> setFilter({int? filter, bool prefFilter = false}) async {
    if (filter != null) {
      currentFilter = (filter == currentFilter) ? 0 : filter;
      setPref('currentFilter', currentFilter);
    }
    else if (prefFilter) {
      int? p = await getPref('currentFilter');
      if (p == null) {
        currentFilter = 0;
      }
      else {
        currentFilter = p;
      }
    }
    notifyListeners();
  }

  List<Device> get filteredDevices {
    List<Device> list = _devices;
    switch (currentFilter) {
      case 1:
        list = list.where((device) => device.status == "Rented").toList();
        break;
      case 2:
        list = list.where((device) => device.status == "Available").toList();
        break;
      case 3:
        list = list.where((device) => device.status == "Overdue").toList();
        break;
      default:
        break;
    }

    // 🔹 Apply Search
    if (_searchQuery.isNotEmpty) {
      list = list.where((device) {
        final nameMatch = device.name.toLowerCase().contains(_searchQuery);

        final categoryMatch = device.category.toLowerCase().contains(_searchQuery);

        final addressMatch =
            device.currentRent?.renterLocation?.address.toLowerCase().contains(_searchQuery) ?? false;
        final renterMatch = device.currentRent?.renterName.toLowerCase().contains(_searchQuery) ?? false;

        return nameMatch || categoryMatch || addressMatch || renterMatch;
      }).toList();
    }
    return list;
  }
}