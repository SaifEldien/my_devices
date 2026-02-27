import 'package:flutter/foundation.dart';
import 'package:my_devices/data/data.dart';

class Services {

 static Future<void> initialize() async {
    await Hive.initFlutter();
    await Hive.openBox('devices');
    await Hive.openBox('users');
  }

static Future<void> insert({required String tableName, required Map newValue}) async {
    var table = await Hive.openBox(tableName);
    await table.put(newValue['id'].toString(), newValue);
    if (kDebugMode) {
      print('Done Insertion into $tableName with value $newValue');
    }
  }

 static Future<void> update({required String tableName, required Map newValue}) async {
   var table = await Hive.openBox(tableName);
   await table.add(newValue);
 }

 static Future<void> delete({required String tableName, required String id }) async {
   var table = await Hive.openBox(tableName);
   await table.delete(id);
 }


 static Future<List<dynamic>> getCollection({
   required String tableName,
   bool Function(dynamic)? where,
 }) async {
   var table = await Hive.openBox(tableName);
   if (where != null) {
     return table.values.where(where).toList();
   }

   return table.values.toList();
 }

}