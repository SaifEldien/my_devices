import  'package:my_devices/core/core.dart';
import 'package:my_devices/ui/screens/sub_screens/renting_history_screen.dart';
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
        resizeToAvoidBottomInset: false,
        body: CustomScrollView(
          slivers: [
            buildSliverHeader(statusColor, isRented, isOverdue, context, device),
            SliverToBoxAdapter(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
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
                          heroTag: "show_history_btn",
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
                      heroTag: "edit_btn",
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
                        if (!context.mounted) return;
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => DeviceFormScreen(deviceToEdit: device)),
                        );
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
                    if (!context.mounted) return;
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => DeviceFormScreen(deviceToEdit: device)),
                    );
                  },
                ),
        ),
      ),
    );
  }
}

