import 'dart:ui';
import '../core.dart';

void setAppLanguageFromDevice (BuildContext context) {
  Future.microtask(() {
    if (!context.mounted) return;
    String systemLang = PlatformDispatcher.instance.locale.languageCode;
    if (systemLang.toLowerCase().contains('ar')) {
      context.setLocale(const Locale('ar'));
    } else {
      context.setLocale(const Locale('en'));
    }
  });
}