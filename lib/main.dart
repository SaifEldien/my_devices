 import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:my_devices/funcs/pref_funcs.dart';
import 'package:my_devices/providers/devices_provider.dart';
import 'package:my_devices/providers/theme_provider.dart';
import 'package:my_devices/screens/login_screen.dart';
import 'package:my_devices/screens/main_screens_controller.dart';
import 'package:my_devices/screens/on_boarding.dart';
import 'package:provider/provider.dart';

import 'Server/dio_client.dart';
import 'localDB/local_db.dart';
import 'models/user.dart';
import 'notification/notification_services.dart';

User? currentUser;
 bool signIn = true;
 bool isFirst = true ;
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await LocalDB().init();
  final dioClient = DioClient();
    await NotificationService.init();
  String? email = await getPref('email');
  String? password = await  getPref('password');
   isFirst = (await getPref('isFirst'))??true;
  if (email!=null&&password!=null) {
    try {
      bool success = await dioClient.login(email, password).timeout(const Duration(seconds: 3));
      if (success) {
          var userData = await dioClient.retrieveUser(email);
          if (userData != null) {
            currentUser = User.fromJson(userData);
            LocalDB().insertData('users', currentUser!.toJson());
          }
      }
      else {
        signIn = false;
      }
    }
    catch (e) {
      currentUser = User.fromJson((await Hive.openBox('users')).values.where((e)=>e['id']==email).first);
    }
  }
  else {
    signIn = false;
  }
  bool isArabic = (await getPref('isArabic'))??false;
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => DeviceProvider()),
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
      ],
      child:  EasyLocalization(
        supportedLocales: const [Locale('en'), Locale('ar')],
        path: 'assets/translations',
        startLocale:  isArabic&&currentUser!=null? const Locale('ar') : const Locale('en'),
        fallbackLocale: const Locale('en'),
        child: const MyApp(),
      ),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider>();
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'My Devices',
      themeMode: themeProvider.themeMode,
      theme: themeProvider.lightTheme(context),
      darkTheme: themeProvider.darkTheme(context),
      localizationsDelegates: context.localizationDelegates,
      supportedLocales: context.supportedLocales,
      locale: context.locale,
      home: isFirst ? SplashScreen(screenToNevigate: LoginScreen()) :  signIn? AppInitializer() : LoginScreen(),
    );
  }
}

 class AppInitializer extends StatefulWidget {
   const AppInitializer({super.key});
   @override
   State<AppInitializer> createState() => _AppInitializerState();
 }

 class _AppInitializerState extends State<AppInitializer> {
   bool _isInitialized = false;
   @override
   void initState() {
     super.initState();
     _initializeApp();
   }
   Future<void> _initializeApp() async {
     final deviceProvider = context.read<DeviceProvider>();
     final themeProvider = context.read<ThemeProvider>();
     await Future.wait([
       deviceProvider.getDevicesFromLocalDb(),
       themeProvider.toggleTheme(prefTheme: true),
       deviceProvider.setFilter(prefFilter: true),
     ]);
     if (mounted) {
       setState(() {
         _isInitialized = true; // Now we are ready
       });
     }
   }
   @override
   Widget build(BuildContext context) {
     if (!_isInitialized) {
       return const Scaffold(
         body: Center(child: CircularProgressIndicator(color: Colors.white)),
       );
     }
     return const MainScreensController();
   }
 }

// add ✓
// Device Screen ✓
// edit ✓
// delete ✓
// add dialer button to call renter ✓
// awesome dialog ✓
// nice fall back Image ✓
// image scroller improve ✓
// update device screen after editing ✓
// rent price ✓
// Setting Screen ✓
// actual return date ✓
// returned Button ✓
// show rented history button ✓
// rent history feature ✓
// number validation ( price , Duration ) ✓
// dialog titles ✓
// images to be url or path ✓
// all histories screen ✓
// rent will has device id ✓
// rent images ✓
// counter design on Images ✓
// -----------
// Location From google maps ✓
// go to Renter location button ✓
// ---------
// Dark Mode ✓
// Search (device name, category , address , renter name) ✓
// filter based on status ( make nice buttons in front of the status counter ) ✓
// ----------
// LogIn Screen ✓
// ----------
// Firebase download & upload (backUps) ✓
// arabic support ✓
// save settings ( dark mode. language , filter ) ✓
// back up date to show while restoring and uploading ✓
// renting history search ✓
// arabic address ✓
// User Profile ✓
// onBoarding Screen ✓
// app Icon ✓
//form design ✓
 // card padding ✓
 // counter designing ✓
 //onboarding ✓
 // login Screen color ✓
 // overdue notification ✓
 // Splash Screen title ✓
 // main screen refreshes ✓
// ( render for backend deployment)