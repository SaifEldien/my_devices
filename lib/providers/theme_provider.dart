import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:my_devices/funcs/pref_funcs.dart';

class ThemeProvider extends ChangeNotifier {
  bool _isDark = false;
  bool get isDark => _isDark;
  ThemeMode get themeMode => _isDark ? ThemeMode.dark : ThemeMode.light;
  Future toggleTheme({bool? prefTheme}) async {
    if (prefTheme != null) {
      bool? fromPref = await getPref('isDark');
      if (fromPref == null) {
        return;
      } else {
        _isDark = await getPref('isDark');
      }
    } else {
      _isDark = !_isDark;
      setPref('isDark', _isDark);
    }
    notifyListeners();
  }
  ThemeData lightTheme(BuildContext context)=> ThemeData(
    brightness: Brightness.light,
    scaffoldBackgroundColor: Colors.grey[100],
    primaryColor: Colors.blue,
    cardColor: Colors.white,
    canvasColor: Colors.transparent,
    fontFamily: context.locale == Locale('ar') ?  'Ge_ss' : null,
    appBarTheme: const AppBarTheme(backgroundColor: Colors.white, foregroundColor: Colors.black, elevation: 0),
  );

  ThemeData  darkTheme (BuildContext context)=> ThemeData(
    brightness: Brightness.dark,
    scaffoldBackgroundColor: const Color(0xFF121212),
    primaryColor: Colors.blue,
    fontFamily: context.locale == Locale('ar') ?  'Ge_ss' : null,
    cardColor: const Color(0xFF1E1E1E),
    canvasColor: Colors.transparent,
    appBarTheme: const AppBarTheme(
      backgroundColor: Color(0xFF1E1E1E),
      foregroundColor: Colors.white,
      elevation: 0,
    ),
  );

}

