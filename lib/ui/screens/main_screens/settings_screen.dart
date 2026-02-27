import 'package:my_devices/core/constants/app_config.dart';
import 'package:my_devices/core/core.dart';
import 'package:my_devices/core/funcs/format_custom_date.dart';

import '../../../core/connectivity/connectivity_service.dart';
import '../../../providers/auth_provider.dart';
import '../sub_screens/renting_history_screen.dart';

class SettingsScreen extends StatelessWidget {
  final IconData icon = Icons.settings;
  final String title = "settings";
  SettingsScreen({super.key});
  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    return Scaffold(
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 35,
                    backgroundImage: provide64baseImage(authProvider.currentUser!.img),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(authProvider.currentUser!.name, style: Theme.of(context).textTheme.titleLarge),
                        const SizedBox(height: 4),
                        Text(authProvider.currentUser!.email, style: TextStyle(color: Colors.grey.shade600)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          Text("app_setting".tr(), style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Card(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: SwitchListTile(
              title: !context.watch<ThemeProvider>().isDark
                  ? Text("dark_mode".tr())
                  : Text("light_mode".tr()),
              value: context.watch<ThemeProvider>().isDark,
              onChanged: (_) {
                context.read<ThemeProvider>().toggleTheme();
              },
              secondary: const Icon(Icons.dark_mode),
            ),
          ),
          Card(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: SwitchListTile(
              title: context.locale.languageCode == 'ar'
                  ? const Text("English")
                  : const Text("اللغة العربية"),
              value: context.locale.languageCode == 'ar',
              onChanged: (_) {
                final bool isArabic = context.locale.languageCode == 'ar';
                context.setLocale(Locale(isArabic ? 'en' : 'ar'));
                context.read<DeviceProvider>().devicesCurrentScreenIndexValue = 1;
              },
              secondary: const Icon(Icons.translate),
            ),
          ),
          const SizedBox(height: 24),
          Text("backup_data".tr(), style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Card(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.cloud_upload),
                  title: Text("upload_backup".tr()),
                  subtitle: Text("Save devices to cloud".tr()),
                  onTap: () async {
                    if (!await ConnectivityService.hasConnection()) return;
                    if (!context.mounted) return;
                    showCustomDialog(
                      context,
                      onAccept: () async {
                        await context.read<DeviceProvider>().uploadBackup(authProvider: authProvider);
                      },
                      icon: Icons.cloud_upload,
                      color: Colors.white,
                      title: "upload_backup".tr(),
                    );
                  },
                ),
              ],
            ),
          ),
          Card(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.restore),
                  title: Text("restore_backup".tr()),
                  subtitle: Text("Restore devices from cloud".tr()),
                  onTap: () async {
                    if (!await ConnectivityService.hasConnection()) {
                      return;
                    } else if (authProvider.currentUser?.lastBackup == null) {
                      showToast("no_backup_found".tr(), isError: true);
                      return;
                    }
                    if (!context.mounted) return;
                    String backupDate = formatCustomDate(authProvider.currentUser!.lastBackup! ,locale: context.locale.languageCode,showTime: true);
                    showCustomDialog(
                      context,
                      onAccept: () async {
                        await context.read<DeviceProvider>().fetchDevicesFromServer();
                      },
                      icon: Icons.cloud_download_rounded,
                      color: Colors.grey,
                      title:
                          "${'restore_backup'.tr()} $backupDate",
                    );
                  },
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),
          Text("overview".tr(), style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Card(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.history),
                  title: Text("renting_history".tr()),
                  subtitle: Text("Show All Renting Histories".tr()),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => RentingHistoryScreen()),
                    );
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }
}
