import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:my_devices/screens/sub_screens/device_details_screen.dart';
import 'package:my_devices/widgets/device_card.dart';
import 'package:provider/provider.dart';

import '../../funcs/analytics_bar_calc_func.dart';
import '../../models/device.dart';
import '../../providers/devices_provider.dart';
import '../../widgets/analytics_bar.dart';
import '../../widgets/search_bar.dart';

class HomeScreen extends StatelessWidget {
  final IconData icon = Icons.home;
  final String title = "home";
  final TextEditingController _searchController = TextEditingController();
  HomeScreen({super.key});
  @override
  Widget build(BuildContext context) {
    List<Device> devices =
        _searchController.text.isNotEmpty || Provider.of<DeviceProvider>(context).currentFilter != 0
        ? Provider.of<DeviceProvider>(context).filteredDevices
        : Provider.of<DeviceProvider>(context).devices;
    return Column(
      children: [
        AnalyticsBar(analytics: calculateAnalytics(Provider.of<DeviceProvider>(context).devices)),
        CustomSearchBar(
          controller: _searchController,
          onChanged: (val) => context.read<DeviceProvider>().setSearchQuery(val),
        ),
        Expanded(
          child: devices.isEmpty ? Center(child: Text("No Data To Show!".tr()))
              : GridView.builder(
                  shrinkWrap: true,
                  physics: const BouncingScrollPhysics(),
                  itemCount: devices.length,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 1,
                    childAspectRatio: 2.55,
                  ),
                  itemBuilder: (context, i) {
                    return DeviceCard(
                      device: devices[i],
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => DeviceDetailsScreen(deviceId: devices[i].id)),
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }
}




