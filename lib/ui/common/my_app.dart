import '../../core/core.dart';
import '../../providers/auth_provider.dart';
import '../screens/intial_screens/login_screen.dart';
import '../screens/intial_screens/on_boarding.dart';
import 'app_init.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key,});
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
      home: Consumer<AuthProvider>(
        builder: (context, auth, _) {
          if (auth.isFirst) {
            return OnBoardingScreen(screenToNavigate: LoginScreen());
          }
          if (auth.isLoading) {
            return const Scaffold(body: Center(child: CircularProgressIndicator()));
          }
          if (auth.isAuthenticated) {
            return const AppInitializer();
          }
          return const LoginScreen();
        },
      ),
    );
  }
}
