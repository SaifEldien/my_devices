import 'package:firebase_core/firebase_core.dart';
import 'package:my_devices/data/repositories/fb_device_impl.dart';
import 'package:my_devices/providers/auth_provider.dart';
import 'package:my_devices/ui/common/my_app.dart';

import 'core/constants/app_config.dart';
import 'core/core.dart';
import 'data/providers/local/local_db.dart';
import 'data/repositories/device_repository.dart';
import 'data/repositories/dio_device_impl.dart';


Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await EasyLocalization.ensureInitialized();
  await LocalDB().init();
  await NotificationService.init();
  await Firebase.initializeApp();
  final IDeviceRepository deviceRepo = kIsFirebase ? FirebaseDeviceRepository() :  DioDeviceRepository();

  runApp(
    EasyLocalization(
      useOnlyLangCode: true,
      supportedLocales: const [Locale('en'), Locale('ar')],
      path: 'assets/translations',
      child: MultiProvider(
        providers: [
          ChangeNotifierProvider(
            create: (_) => DeviceProvider(deviceRepo),
          ),
          ChangeNotifierProvider(
            create: (_) => AuthProvider(deviceRepo),
          ),
          ChangeNotifierProvider(
            create: (_) => ThemeProvider(),
          ),
        ],
        child: MyApp(),
      ),
    ),
  );
}


