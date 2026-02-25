import 'package:hive_flutter/hive_flutter.dart';
import 'package:hive/hive.dart';

import '../main.dart';


class Services {

 static Future<void> initialize() async {
    await Hive.initFlutter();
    await Hive.openBox('devices');
    await Hive.openBox('users');
  }

static insert({required String tableName, required Map newValue}) async {
    var table = await Hive.openBox(tableName);
    await table.put(newValue['id'], newValue);
    print('done' + newValue.toString());
  }

 static update({required String tableName, required Map newValue}) async {
   var table = await Hive.openBox(tableName);
   await table.add(newValue);
 }

 static delete({required String tableName, required String id }) async {
   var table = await Hive.openBox(tableName);
   await table.delete(id);
 }


 static Future<Iterable<dynamic>> getCollection({required String tableName, String? id}) async {
   var table = await Hive.openBox(tableName);
   return table.values.toList().where((element) => element['userId']==(id??currentUser!.id)).toList();
 }
 static getDoc({required String tableName, required int id}) async {
  // var table = await Hive.openBox(tableName);
  // return table.values.toList().firstWhere((element) => element["userId"]==userId&&element['id']==id);
 }

}