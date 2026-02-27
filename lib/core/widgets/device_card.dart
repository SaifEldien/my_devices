import '../core.dart';

class DeviceCard extends StatelessWidget {
  final Device device;
  final VoidCallback? onTap;

  const DeviceCard({super.key, required this.device, this.onTap});

  @override
  Widget build(BuildContext context) {
    final rent = device.currentRent;
    bool isRented = rent != null;
    bool isOverdue = isRented && rent.remainingRentalDays! < 0;

    Color statusColor = Colors.lightBlue;

    if (isOverdue) {
      statusColor = Colors.red;
    } else if (isRented) {
      statusColor = Colors.orange;
    }
    return GestureDetector(
      onTap: onTap,
      child: Card(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Row(
            children: [
              SizedBox(
                width: 120,
                height: 120,
                child: CustomImagePageview(imagesPaths: device.imagesPaths, right: 3),
              ),
              const SizedBox(width: 12),

              // Device Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: Row(
                              children: [
                                Text(
                                  device.name,
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.blue,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        SizedBox(width: 5),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: statusColor,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            isOverdue ? 'overdue'.tr() : device.status.toLowerCase().tr(),
                            style: const TextStyle(color: Colors.white, fontSize: 12),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(device.category, style: TextStyle(fontSize: 14, color: Colors.blueGrey)),
                    const SizedBox(height: 8),
                    if (device.currentRent?.renterName != null) ...[
                      if ((device.currentRent?.renterLocation?.address ?? "").isNotEmpty) ...[
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Expanded(
                              child: SingleChildScrollView(
                                scrollDirection: Axis.horizontal,
                                physics: const BouncingScrollPhysics(),
                                child: Row(
                                  children: [
                                    const Icon(Icons.location_on_outlined, size: 14, color: Colors.blueGrey),
                                    const SizedBox(width: 4),
                                    Text(
                                      device.currentRent?.renterLocation?.address ?? '',
                                      style: const TextStyle(color: Colors.blueGrey, fontSize: 12),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                      ],
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Expanded(
                            child: SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              physics: const BouncingScrollPhysics(),
                              child: Row(
                                children: [
                                  Icon(Icons.person, size: 14, color: isOverdue ? Colors.red : Colors.orange),
                                  const SizedBox(width: 4),
                                  Text(
                                    isOverdue
                                        ? "${device.currentRent?.renterName} ${"overdue".tr()} ${"by".tr()} (${(device.currentRent?.remainingRentalDays ?? 0) * -1} ${"days".tr()} )"
                                        : "${device.currentRent?.renterName} ( ${device.currentRent?.remainingRentalDays ?? 0} ${"days".tr()}  ${"remain".tr()} )",
                                    style: TextStyle(
                                      color: isOverdue ? Colors.red : Colors.orange,
                                      fontSize: 12,
                                      overflow: TextOverflow.fade,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
