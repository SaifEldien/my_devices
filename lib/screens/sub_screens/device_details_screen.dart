import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:my_devices/screens/sub_screens/renting_history_screen.dart';
import 'package:my_devices/widgets/custom_dialog.dart';
import 'package:my_devices/widgets/search_bar.dart';
import 'package:provider/provider.dart';

import '../../funcs/open_dial_func.dart';
import '../../funcs/open_maps_func.dart';
import '../../models/device.dart';
import '../../models/rent.dart';
import '../../providers/devices_provider.dart';
import '../../widgets/Custom_image_page_view.dart';
import '../../widgets/app_bar.dart';
import 'device_form_screen.dart';

class DeviceDetailsScreen extends StatelessWidget {
  final String deviceId;
  const DeviceDetailsScreen({super.key, required this.deviceId});
  @override
  Widget build(BuildContext context) {
    final device = context.watch<DeviceProvider>().devices.where((d) => d.id == deviceId).firstOrNull;
    if (device == null) {
      return const Scaffold(body: Center(child: Text("No device found")));
    }
    final rent = device.currentRent;
    bool isRented = rent != null;
    bool isOverdue = isRented && rent.remainingRentalDays! < 0;
    Color statusColor = Colors.lightBlue;
    if (isOverdue) {
      statusColor = Colors.red;
    } else if (isRented) {
      statusColor = Colors.orange;
    }
    return SafeArea(
      child: Scaffold(
        body: CustomScrollView(
          slivers: [
            buildSliverHeader(statusColor, isRented, isOverdue, context, device),
            SliverToBoxAdapter(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Expanded(
                      child: Row(
                        children: [
                          if (!isRented)
                            SizedBox(
                              width: MediaQuery.of(context).size.width,
                              child: Padding(
                                padding: const EdgeInsets.symmetric(vertical: 8.0),
                                child: buildDeviceInfo(context, device),
                              ),
                            )
                          else
                            buildDeviceInfo(context, device),
                          if (isRented)
                            Center(
                              child: ConstrainedBox(
                                constraints: const BoxConstraints(minWidth: 200),
                                child: buildRenterCard(rent),
                              ),
                            ),
                          SizedBox(width: 10),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  if (isRented) buildRentalCard(context, rent, isOverdue, device: device),
                  const SizedBox(height: 10),
                  if (isRented) buildMapPreview(device),
                  buildNotesSection(device),
                  const SizedBox(height: 100),
                ],
              ),
            ),
          ],
        ),
        floatingActionButton: SizedBox(
          height: 140,
          child: device.rentingHistory.isNotEmpty
              ? Column(
                  children: [
                    Stack(
                      children: [
                        FloatingActionButton(
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
                            child: const Icon(Icons.history, size: 30, color: Colors.white),
                          ),
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => RentingHistoryScreen(deviceId: deviceId),
                              ),
                            );
                          },
                        ),
                        Positioned(
                          top: 0,
                          right: 0,
                          child: Container(
                            padding: const EdgeInsets.all(10),
                            decoration: const BoxDecoration(color: Colors.black54, shape: BoxShape.circle),
                            child: Text(
                              '${device.rentingHistory.length}',
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 10),
                    FloatingActionButton(
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
                        child: const Icon(Icons.edit, size: 30, color: Colors.white),
                      ),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => DeviceFormScreen(deviceToEdit: device)),
                        );
                        /* showDialog(
                          context: context,
                          builder: (_) => DeviceFormDialog(deviceToEdit: device),
                        );*/
                      },
                    ),
                  ],
                )
              : FloatingActionButton(
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
                    child: const Icon(Icons.edit, size: 30, color: Colors.white),
                  ),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => DeviceFormScreen(deviceToEdit: device)),
                    );

                    /*showDialog(
                      context: context,
                      builder: (_) => DeviceFormDialog(deviceToEdit: device),
                    );*/
                  },
                ),
        ),
      ),
    );
  }
}

Widget buildDeviceInfo(BuildContext context, Device device) {
  return Card(
    margin: const EdgeInsets.symmetric(horizontal: 16),
    child: Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(device.name, style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: 8),
          Text("${"cat".tr()}: ${device.category}"),
          Text("${"created".tr()}: ${device.createdAt.toLocal().toString().substring(0, 10)}"),
        ],
      ),
    ),
  );
}

Widget buildRenterCard(Rent rent) {
  return Row(
    children: [
      Card(
        margin: EdgeInsets.only(top: 15, right: 0, bottom: 1),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 10),
          child: Row(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("rental_info".tr(), style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Text("${"name".tr()}: ${rent.renterName}"),
                  Text("${"phone".tr()}: ${rent.renterPhone}"),
                  rent.renterLocation == null || rent.renterLocation!.address.isEmpty
                      ? SizedBox()
                      : Text("${"address".tr()}: ${rent.renterLocation?.address ?? ''}"),
                ],
              ),
              SizedBox(width: 5,),
              Column(
                children: [
                  IconButton(
                    onPressed: () {
                      openDialPad(rent.renterPhone);
                    },
                    icon: Icon(Icons.phone, color: Colors.blue, size: 35),
                  ),

                  if (rent.rentImagesPaths.isNotEmpty)
                    SizedBox(
                      height: 50,
                      width: 50,
                      child: CustomImagePageview(imagesPaths: rent.rentImagesPaths, height: 50, width: 50,right: 0,top: 0,),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
      SizedBox(width: 0),
    ],
  );
}

Widget buildMapPreview(Device device) {
  return !(device.currentRent?.renterLocation?.latitude != null ||
          device.currentRent?.renterLocation?.longitude != null)
      ? SizedBox()
      : Stack(
          children: [
            Padding(
              padding: const EdgeInsets.only(right: 16, left: 16, bottom: 20),
              child: SizedBox(
                height: 200,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: FlutterMap(
                    key: ValueKey(
                      "${device.currentRent!.renterLocation!.latitude}-${device.currentRent!.renterLocation!.longitude}",
                    ),
                    options: MapOptions(
                      initialCenter: LatLng(
                        device.currentRent!.renterLocation!.latitude!,
                        device.currentRent!.renterLocation!.longitude!,
                      ),
                      initialZoom: 15,
                      interactionOptions: const InteractionOptions(flags: InteractiveFlag.none),
                    ),
                    children: [
                      TileLayer(
                        urlTemplate: "https://tile.openstreetmap.org/{z}/{x}/{y}.png",
                        userAgentPackageName: 'com.yourcompany.yourapp',
                      ),
                      MarkerLayer(
                        markers: [
                          Marker(
                            point: LatLng(
                              device.currentRent!.renterLocation!.latitude!,
                              device.currentRent!.renterLocation!.longitude!,
                            ),
                            width: 40,
                            height: 40,
                            child: const Icon(Icons.location_pin, color: Colors.red, size: 40),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Container(
              margin: EdgeInsets.only(top: 145),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(backgroundColor:  Colors.white60, elevation: 20),
                    onPressed: () {
                      openGoogleMaps(
                        device.currentRent!.renterLocation!.latitude!,
                        device.currentRent!.renterLocation!.longitude!,
                      );
                    },
                    icon: const Icon(Icons.navigation),
                    label: Text("go_to".tr()),
                  ),
                ],
              ),
            ),
          ],
        );
}

Widget buildNotesSection(Device device) {
  return device.notes.isEmpty
      ? SizedBox()
      : Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text("${"device_notes".tr()} : ${device.notes}", style: const TextStyle(fontSize: 16)),
        );
}

Widget buildSliverHeader(
  Color statusColor,
  bool isRented,
  bool isOverdue,
  BuildContext context,
  Device? device, {
  bool isHistory = false,
  bool isSearch = false,
  TextEditingController? searchCont,
  Function(String? val)? onSearch,
}) {
  return SliverAppBar(
    expandedHeight: 260,
    pinned: true,
    leading: SizedBox(),
    flexibleSpace: FlexibleSpaceBar(
      background: Column(
        children: [
          if (isSearch) ...[
            Row(
              children: [
                IconButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  icon: Icon(Icons.arrow_back_ios_new_outlined),
                ),
                SizedBox(
                  width: MediaQuery.of(context).size.width - 50,
                  child: CustomSearchBar(
                    controller: searchCont!,
                    onChanged: (val) => onSearch!(val),
                    title: "${'search_rents'.tr()}...",
                  ),
                ),
              ],
            ),
          ],
          if (!isSearch)
            CustomAppBar(
              title: isHistory ? "renting_history".tr() : "device_details".tr(),
              isSearch: isSearch,
              actions: [
                isHistory
                    ? SizedBox()
                    : IconButton(
                        onPressed: () {
                          showCustomDialog(
                            context,
                            title: "delete_device".tr(),
                            onAccept: () {
                              context.read<DeviceProvider>().removeDevice(device!.id);
                              if (context.mounted) {
                                Navigator.pop(context);
                              }
                            },
                            icon: Icons.delete_forever,
                            color: Colors.red,
                          );
                        },
                        icon: Icon(Icons.delete_forever, color: Colors.red),
                      ),
              ],
            ),
          Expanded(
            child: Stack(
              fit: StackFit.loose,
              children: [
                CustomImagePageview(
                  height: 200,
                  isRounded: false,
                  //right: 370,
                  imagesPaths: device?.imagesPaths ?? [],
                  width: MediaQuery.of(context).size.width,
                ),
                isHistory
                    ? SizedBox()
                    : Positioned(
                        top: 9,
                        right: 16,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                          decoration: BoxDecoration(
                            color: statusColor,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            isOverdue
                                ? "overdue".tr()
                                : isRented
                                ? "rented".tr()
                                : "available".tr(),
                            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
              ],
            ),
          ),
        ],
      ),
    ),
  );
}

Widget buildRentalCard(BuildContext context, Rent rent, bool isOverdue, {Device? device}) {
  double progress =
      (DateTime.now().difference(DateTime.parse(rent.rentStart)).inDays / rent.rentDurationInDays).clamp(
        0.0,
        1.0,
      );

  return Card(
    margin: const EdgeInsets.symmetric(horizontal: 16),
    //color: isOverdue ? Colors.red.shade50 : Colors.orange.shade50,
    child: Padding(
      padding: const EdgeInsets.all(16),
      child: Stack(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("rent_details".tr(), style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Text(
                "${"start".tr()}: ${DateTime.parse(rent.rentStart).toLocal().toString().substring(0, 10)} |  ${"end".tr()}: ${DateTime.parse(rent.rentStart).add(Duration(days: rent.rentDurationInDays)).toLocal().toString().substring(0, 10)}",
              ),
              const SizedBox(height: 8),
              Text("${"price".tr()}: ${rent.rentPrice}"),
              const SizedBox(height: 8),
              Text("${"duration".tr()}: ${rent.rentDurationInDays} ${"days".tr()}"),
              const SizedBox(height: 12),
              LinearProgressIndicator(value: progress),
              const SizedBox(height: 8),
              if (rent.rentNote.isNotEmpty) Text("${"rent_note".tr()}: ${rent.rentNote}"),
              const SizedBox(height: 8),
              rent.rentReturnDate == null
                  ? Text(
                      isOverdue
                          ? "${"overdue".tr()} ${"by".tr()} ${(rent.remainingRentalDays)! * -1}  ${"days".tr()} "
                          : "${rent.remainingRentalDays} ${"days".tr()} ${"remain".tr()}",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: isOverdue ? Colors.red : Colors.grey,
                      ),
                    )
                  : Text("${"return_date".tr()} : ${rent.rentReturnDate!.substring(0, 10)}"),
            ],
          ),
          if (device != null)
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton.icon(
                  onPressed: () async {
                    final picked = await showDatePicker(
                      helpText: "return_date".tr(),
                      context: context,
                      initialDate: DateTime.now(),
                      firstDate: DateTime.parse(rent.rentStart),
                      lastDate: DateTime(2100),
                    );
                    if (picked != null) {
                      showCustomDialog(
                        context,
                        title: "Return Device on".tr() + " ${picked.toString().substring(0, 10)}",
                        onAccept: () {
                          rent.rentReturnDate = picked.toString();
                          device.rentingHistory = [...device.rentingHistory, device.currentRent!];
                          device.currentRent = null;
                          Provider.of<DeviceProvider>(context, listen: false).updateDevice(device);
                        },
                        icon: Icons.check_circle,
                        color: Colors.lightGreenAccent,
                      );
                    }
                  },
                  icon: Icon(Icons.check_circle, color: Colors.greenAccent, size: 20),
                  label: Text("return".tr(), style: TextStyle(color: Colors.grey)),
                ),
              ],
            ),
        ],
      ),
    ),
  );
}

