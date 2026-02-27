import 'package:shared_preferences/shared_preferences.dart';

Future setPref(String key, var value) async {
  SharedPreferences pref = await SharedPreferences.getInstance();
  if (value.runtimeType == bool) {
    pref.setBool(key, value);
  }
  else if (value.runtimeType == int) {
    pref.setInt(key, value);
  }
  else {
    pref.setString(key, value);
  }
}

Future getPref(String key) async {
  SharedPreferences pref = await SharedPreferences.getInstance();
  return pref.get(key);
}

Future<dynamic> removePref(String key) async {
  SharedPreferences pref = await SharedPreferences.getInstance();
  return pref.remove(key);
}