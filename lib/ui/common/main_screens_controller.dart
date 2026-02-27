import  'package:my_devices/core/core.dart';

import '../../core/widgets/bottom_navigation_bar.dart';
import '../../providers/auth_provider.dart';
import '../screens/main_screens/home_screen.dart';
import '../screens/main_screens/settings_screen.dart';
import '../screens/sub_screens/device_form_screen.dart';

class MainScreensController extends StatefulWidget {
  const MainScreensController({super.key});

  @override
  State<MainScreensController> createState() => _MainScreensControllerState();
}
class _MainScreensControllerState extends State<MainScreensController> {
  final List _screens = [
    HomeScreen(),
    SettingsScreen(),
  ];
  @override
  Widget build(BuildContext context) {
    int currentIndex = context.watch<DeviceProvider>().devicesCurrentScreenIndex;
    return Scaffold(
      resizeToAvoidBottomInset: false,
      extendBody: true,
      extendBodyBehindAppBar: true,
      body: SafeArea(
        child: Column(
          children: [
            CustomAppBar(icon: _screens[currentIndex].icon, title: _screens[currentIndex].title.toString().tr()),
            Expanded(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                transitionBuilder: (child, animation) {
                  return SlideTransition(
                    position: Tween<Offset>(begin: const Offset(1, 0), end: Offset.zero).animate(animation),
                    child: FadeTransition(
                      opacity: animation,
                      child: ScaleTransition(scale: animation, child: child),
                    ),
                  );
                },
                child: _screens[currentIndex],
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        heroTag: "main_screens_fab",
        shape: CircleBorder(),
        elevation: 10,
        child: Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.blueGrey, Colors.lightBlue],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            shape: BoxShape.circle,
          ),
          child: Icon(currentIndex == 1 ? Icons.logout : Icons.add, size: 30, color: Colors.white),
        ),
        onPressed: () async {
          if (currentIndex == 1) {
            await showCustomDialog(context, onAccept: () {
              final authProvider = context.read<AuthProvider>();
              authProvider.logout(context);
            }, icon: Icons.logout, color: Colors.black, title: "logout".tr());
          }
          if (!context.mounted || currentIndex != 0) return;
          Navigator.push(context, MaterialPageRoute(builder: (c)=>DeviceFormScreen()));
        },
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: CustomBottomNavigationBar(
        children: List.generate(
          _screens.length,
          (i) => buildNavItem(
            icon: _screens[i].icon,
            title: _screens[i].title.toString().tr(),
            isActive: currentIndex == i,
            onTap: () => {
              context.read<DeviceProvider>().devicesCurrentScreenIndexValue = i,
            },
          ),
        ),
      ),
    );
  }
}
