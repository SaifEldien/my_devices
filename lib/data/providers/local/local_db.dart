import 'package:my_devices/data/data.dart';
import 'package:my_devices/data/providers/local/services.dart';

class LocalDB {
  static final LocalDB _instance = LocalDB._internal();
  factory LocalDB() {
    return _instance;
  }
  LocalDB._internal();

  Future<void> init() async => await Services.initialize();
  Future insertData(String tableName, newValue) async =>
      await Services.insert(tableName: tableName, newValue: newValue);
  Future getData(String tableName, {where}) async => await Services.getCollection(tableName: tableName, where: where);
  Future delete(String tableName, id) async => await Services.delete(tableName: tableName, id: id);
  Future<void> clearTable(String tableName) async {
    final box = await Hive.openBox('devices');
    await box.clear();
  }

  Future<User?> retrieveUser(String email) async {
    try {
      final localData = await LocalDB().getData('users');
      if (localData != null && localData.isNotEmpty) {
        final userMap = localData.firstWhere((element) => element['email'] == email, orElse: () => null);
        if (userMap != null) {
          return User.fromJson(userMap);
        }
      }
      return null;
    } catch (e) {
      return null;
    }
  }
}
