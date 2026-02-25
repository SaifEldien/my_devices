import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:my_devices/funcs/pref_funcs.dart';
import 'package:my_devices/screens/main_screens/settings_screen.dart';
import 'package:my_devices/screens/sub_screens/device_form_screen.dart';
import 'package:my_devices/widgets/custom_dialog.dart';
import 'package:provider/provider.dart';
import '../providers/devices_provider.dart';
import '../widgets/app_bar.dart';
import '../widgets/bottom_navigation_bar.dart';
import 'login_screen.dart';
import 'main_screens/home_screen.dart';

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
            bool sure = false;
            await showCustomDialog(context, onAccept: (){
              removePref('email');
              removePref('password');
              sure = true;
            }, icon: Icons.logout, color: Colors.black, title: "logout".tr());
            if (sure) {
              Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=>LoginScreen()));
            }
            return;
          }
          Navigator.push(context, MaterialPageRoute(builder: (c)=>DeviceFormScreen()));
        //  showDialog(context: context, builder: (_) => DeviceFormDialog());
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
