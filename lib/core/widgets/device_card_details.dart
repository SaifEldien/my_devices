import 'package:my_devices/core/core.dart';
import 'package:my_devices/core/funcs/format_custom_date.dart';

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
          Text("${"created".tr()}: ${formatCustomDate(device.createdAt, locale: context.locale.languageCode,showTime: true)}"),
        ],
      ),
    ),
  );
}

Widget buildRenterCard(Rent rent) {
  return Row(
    children: [
      Card(
        margin: EdgeInsets.only(top: 5, right: 0, bottom: 1),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
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
              SizedBox(width: 5),
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
                      child: CustomImagePageview(
                        imagesPaths: rent.rentImagesPaths,
                        height: 50,
                        width: 50,
                        right: 0,
                        top: 0,
                      ),
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
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.white60, elevation: 20),
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
          padding: const EdgeInsets.symmetric(horizontal: 20),
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
  Function ? removeSearch,
  Function ? addSearch,
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
          if (isSearch && isHistory) ...[
            Row(
              children: [
                InkWell(onTap: (){
                  if (removeSearch == null) return;
                  removeSearch();}
                    , child: Padding(
                      padding: const EdgeInsets.only(left: 5.0),
                      child: Icon(Icons.arrow_back_ios_new_outlined),
                    )),
                SizedBox(
                  height: 65,
                  width: MediaQuery.of(context).size.width - 30,
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
            Stack(
              children: [
                CustomAppBar(
                  title: isHistory ? "renting_history".tr() : "device_details".tr(),
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
                            icon: Icon(Icons.delete_forever, color: Colors.red,size: 35,),
                          ),
                  ],
                ),
                if (isHistory)
                Padding(
                  padding: const EdgeInsets.all(11.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      InkWell(
                        onTap: () {
                          if (addSearch==null) return;
                          addSearch();
                        },
                        child: Icon(Icons.search, size: 35),
                      ),
                    ],
                  ),
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
                  right: 5,
                  imagesPaths: device?.imagesPaths ?? [],
                  width: MediaQuery.of(context).size.width,
                ),
                isHistory
                    ? SizedBox()
                    : Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Row(
                          children: [
                            Container(
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
                          ],
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
 String startDate = formatCustomDate(rent.rentStart, locale: context.locale.languageCode) ;
 String endDate = formatCustomDate(DateTime.parse(rent.rentStart).add(Duration(days: rent.rentDurationInDays)), locale: context.locale.languageCode);
 String rentReturnDate = formatCustomDate(rent.rentReturnDate, locale: context.locale.languageCode);

  return Card(
    margin: const EdgeInsets.symmetric(horizontal: 16),
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
                "${"start".tr()}: $startDate |  ${"end".tr()}: $endDate",
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
                        color: isOverdue ? Colors.red : Colors.orange,
                      ),
                    )
                  : Text("${"return_date".tr()} : $rentReturnDate"),
            ],
          ),
          if (device != null)
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom( elevation: 0 , backgroundColor: Colors.white54),
                  onPressed: () async {
                    final picked = await showDatePicker(
                      helpText: "return_date".tr(),
                      context: context,
                      initialDate: DateTime.now(),
                      firstDate: DateTime.parse(rent.rentStart),
                      lastDate: DateTime(2100),
                    );
                    if (picked != null) {
                      if (!context.mounted) return;
                      String returnDate = formatCustomDate(picked, locale: context.locale.languageCode);
                      showCustomDialog(
                        context,
                        title: "${"Return Device on".tr()} $returnDate",
                        onAccept: () {
                          rent.rentReturnDate = picked.toString();
                          device.currentRent!.deviceId = device.id;
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
                  label: Text("return".tr(), style: TextStyle(color: Colors.greenAccent)),
                ),
              ],
            ),
        ],
      ),
    ),
  );
}
