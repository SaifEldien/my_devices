import '../../core/core.dart';
import '../../providers/auth_provider.dart';
import 'main_screens_controller.dart';

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
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeApp();
    });
  }

  Future<void> _initializeApp() async {
    final deviceProvider = context.read<DeviceProvider>();
    final themeProvider = context.read<ThemeProvider>();
    final authProvider = context.read<AuthProvider>();
    try {
      await Future.wait([
        deviceProvider.getDevicesFromLocalDb(authProvider: authProvider),
        themeProvider.toggleTheme(prefTheme: true),
        deviceProvider.setFilter(prefFilter: true),
      ]);
    } catch (e) {
      debugPrint("Error during initialization: $e");
    } finally {
      if (mounted) {
        setState(() => _isInitialized = true);
      }
    }
  }
  @override
  Widget build(BuildContext context) {
    if (!_isInitialized) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }
    return const MainScreensController();
  }
}