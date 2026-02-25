import 'package:hive/hive.dart';

import 'services.dart';

class LocalDB {
    init () async => await Services.initialize();
    insertData (tableName,newValue) async => await Services.insert(tableName: tableName, newValue: newValue);
    getData (tableName,{fk}) async => await Services.getCollection(tableName: tableName,id: fk);
    getSingle (tableName,id) async => await Services.getDoc(tableName: tableName, id: id);
    delete (tableName,id) async => await Services.delete(tableName: tableName,id: id);
    clearTable (tableName) async {
        final box = await Hive.openBox('devices');
        await box.clear();
    }
}
