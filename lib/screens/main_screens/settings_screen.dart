import 'dart:convert';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:my_devices/funcs/loading_funcs.dart';
import 'package:my_devices/funcs/pref_funcs.dart';
import 'package:my_devices/funcs/show_toast_func.dart';
import 'package:my_devices/models/device.dart';
import 'package:my_devices/screens/sub_screens/renting_history_screen.dart';
import 'package:my_devices/widgets/custom_dialog.dart';
import 'package:provider/provider.dart';

import '../../Server/dio_client.dart';
import '../../localDB/local_db.dart';
import '../../main.dart';
import '../../providers/devices_provider.dart';
import '../../providers/theme_provider.dart';

class SettingsScreen extends StatelessWidget {
  final IconData icon = Icons.settings;
  final String title = "settings";

  SettingsScreen({super.key});
  @override
  Widget build(BuildContext context) {
    // final user = context.watch<UserProvider>().user;

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
                   // backgroundImage:   Image.memory(base64Decode(currentUser!.img)).errorBuilder() .image,
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(currentUser!.name, style: Theme.of(context).textTheme.titleLarge),
                        const SizedBox(height: 4),
                        Text(currentUser!.email, style: TextStyle(color: Colors.grey.shade600)),
                      ],
                    ),
                  ),
                  /*IconButton(
                    icon: const Icon(Icons.edit),
                    onPressed: () {
                      // Navigate to edit profile screen
                    },
                  ),*/
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
                final bool _isArabic = context.locale.languageCode == 'ar';
                context.setLocale(Locale(_isArabic ? 'en' : 'ar'));
                setPref('isArabic', !_isArabic);
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
                    showCustomDialog(
                      context,
                      onAccept: () async {
                        List<Device> devices = context.read<DeviceProvider>().devices;
                        showLoading(context, true);
                        final dioClient = DioClient();
                        await dioClient.syncDevices(devices);
                        showLoading(context, false);
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
                    final dioClient = DioClient();
                    String? oldBackUpdate;
                    try {
                      showLoading(context, true);
                      var userData = await dioClient.retrieveUser(currentUser!.email);
                      if (userData != null && userData['lastBackup'] != null) {
                        oldBackUpdate = userData['lastBackup'].toString().substring(0, 16).replaceAll('T', ' ');
                      } else {
                        showToast(context, context.locale.toLanguageTag() == 'ar' ?  "لا يوجد نسخ إحتياطى":  "No backup found");
                        showLoading(context, false);
                        return;
                      }
                      showLoading(context, false);
                    } catch (e) {
                      showToast(context, context.locale.toLanguageTag() == 'ar' ? "خطأ أثناء الإسترجاع" :  "Error fetching backup info");
                      showLoading(context, false);
                      return;
                    }
                    showCustomDialog(
                      context,
                      onAccept: () async {
                        showLoading(context, true);
                        try {
                          List<Device> devices = await dioClient.restoreDevices().timeout(Duration(seconds: 10));
                          await LocalDB().clearTable('devices');
                          for (var device in devices) {
                            await LocalDB().insertData('devices', device.toJson());
                          }
                          context.read<DeviceProvider>().setDevices(devices);
                          showLoading(context, false);
                          showToast(context, "Success Restore!");
                        } catch (e) {
                          showLoading(context, false);
                          showToast(context, "Local DB Error: $e");
                        }
                      },
                      icon: Icons.cloud_download_rounded,
                      color: Colors.grey,
                      title: "${'restore_backup'.tr()} $oldBackUpdate",
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
                      MaterialPageRoute(builder: (context) => Scaffold(body: RentingHistoryScreen())),
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
