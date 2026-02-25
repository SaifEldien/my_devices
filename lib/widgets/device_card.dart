import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import '../models/device.dart';
import 'Custom_image_page_view.dart';

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
                child:  CustomImagePageview(imagesPaths: device.imagesPaths)
              ),
              const SizedBox(width: 12),

              // Device Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      device.name,
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.blue),
                    ),
                    const SizedBox(height: 4),
                    Text(device.category, style: TextStyle(fontSize: 14, color: Colors.blueGrey)),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
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
                        SizedBox(width: 7,),
                        Expanded(
                          child: Text(
                            device.currentRent?.renterLocation?.address ?? '',
                            style: TextStyle(color: Colors.blueGrey, fontSize: 12,overflow: TextOverflow.ellipsis),
                          ),
                        ),
                      ],
                    ),
                    if (device.isRented && device.currentRent?.renterName != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Text(
                          isOverdue
                              ? "${"rent_by".tr()}: ${device.currentRent?.renterName}${"overdue".tr()} ${"by".tr()} (${(device.currentRent?.remainingRentalDays ?? 0) * -1} ${"days".tr()} )"
                              : "${"rent_by".tr()}: ${device.currentRent?.renterName} (${device.currentRent?.remainingRentalDays ?? 0} ${"days".tr()}  ${"remain".tr()} )",
                          style: TextStyle(color: isOverdue ? Colors.red : Colors.orange, fontSize: 12,overflow: TextOverflow.ellipsis),
                        ),
                      ),
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
