import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:my_devices/funcs/is_numeric_func.dart';
import 'package:my_devices/models/location.dart';
import 'package:my_devices/widgets/Custom_image_page_view.dart';
import 'package:my_devices/widgets/custom_dialog.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';

import '../funcs/pick_image_funcs.dart';
import '../funcs/show_cat_sheet_func.dart';
import '../models/device.dart';
import '../models/rent.dart';
import '../providers/devices_provider.dart';
import '../screens/sub_screens/map_picker_screen.dart';

class DeviceFormDialog extends StatelessWidget {
  final Device? deviceToEdit;
  final _formKey = GlobalKey<FormState>();
  final nameController = TextEditingController();
  final categoryController = TextEditingController();
  final locationController = TextEditingController();
  final renterNameController = TextEditingController();
  final renterPhoneController = TextEditingController();
  final notesController = TextEditingController();
  final rentDurationController = TextEditingController();
  final rentPriceController = TextEditingController();
  final renterNoteController = TextEditingController();
  final List imagesPaths = [];
  final List rentImagesPaths = [];
  String status = "Available";
  DateTime? rentStart = DateTime.now();
  AppLocation? currentLocation;

  @override
  void dispose() {
    nameController.dispose();
    categoryController.dispose();
    locationController.dispose();
    renterNameController.dispose();
    renterPhoneController.dispose();
    notesController.dispose();
    rentDurationController.dispose();
    rentPriceController.dispose();
    renterNoteController.dispose();
  }
  DeviceFormDialog({super.key, this.deviceToEdit}) {
    if (deviceToEdit != null) {
      nameController.text = deviceToEdit!.name;
      categoryController.text = deviceToEdit!.category;
      status = deviceToEdit!.status;
      status.toLowerCase() == "rented" ? status = "Rented" : status = "Available";
      imagesPaths.addAll(deviceToEdit!.imagesPaths);
      notesController.text = deviceToEdit!.notes;
      if (deviceToEdit!.currentRent != null) {
        locationController.text = deviceToEdit!.currentRent?.renterLocation?.address ?? "";
        renterNameController.text = deviceToEdit!.currentRent?.renterName ?? "";
        renterPhoneController.text = deviceToEdit!.currentRent?.renterPhone ?? "";
        currentLocation = deviceToEdit!.currentRent?.renterLocation;
        rentStart = DateTime.parse(deviceToEdit!.currentRent!.rentStart);
        rentPriceController.text = deviceToEdit!.currentRent!.rentPrice;
        rentDurationController.text = deviceToEdit!.currentRent!.rentDurationInDays.toString();
        renterNoteController.text = deviceToEdit!.currentRent!.rentNote;
        rentImagesPaths.addAll(deviceToEdit!.currentRent!.rentImagesPaths);
      }
    }
  }
  @override
  Widget build(BuildContext context) {
    return StatefulBuilder(
      builder: (context, setState) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                icon: Icon(Icons.highlight_remove, color: Colors.blue),
              ),
              Spacer(),

              if (deviceToEdit != null)  Text("edit_device".tr()) else Text("add_device".tr()),

            ],
          ),
          content: SizedBox(
            width: MediaQuery.of(context).size.width * 0.9,
            child: SingleChildScrollView(
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                         Text("device_info".tr(), style: TextStyle(fontWeight: FontWeight.bold)),
                      ],
                    ),
                    Divider(),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: nameController,
                            decoration:  InputDecoration(
                              labelText: "name".tr(),
                              border: OutlineInputBorder(),
                            ),
                            validator: (value) => value!.isEmpty ? "required".tr() : null,
                          ),
                        ),
                        SizedBox(width: 10),
                        Expanded(
                          child: TextFormField(
                            controller: categoryController,
                            decoration: InputDecoration(
                              labelText: "cat".tr(),
                              border: const OutlineInputBorder(),
                              suffixIcon: IconButton(
                                icon: const Icon(Icons.arrow_drop_down),
                                onPressed: () {
                                  showCategoriesSheet(context, categoryController);
                                },
                              ),
                            ),
                            validator: (value) => value == null || value.isEmpty ? "required".tr()  : null,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: DropdownButtonFormField<String>(
                            value: status,
                            decoration:  InputDecoration(
                              labelText: "status".tr(),
                              border: OutlineInputBorder(),
                            ),
                            items:  [
                              DropdownMenuItem(value: "Available", child: Text("available".tr())),
                              DropdownMenuItem(value: "Rented", child: Text("rented".tr())),
                            ],
                            onChanged: (value) {
                              setState(() {
                                status = value!;
                              });
                            },
                          ),
                        ),
                        SizedBox(width: 7),
                        Expanded(
                          child: TextButton.icon(
                            onPressed: () async {
                              final List<String>? selectedPaths = await showImageSourcePicker(context);
                              if (selectedPaths != null && selectedPaths.isNotEmpty) {
                                imagesPaths.addAll(selectedPaths);
                                setState(() {});
                              }
                            },
                            label: Text('add_device_images'.tr()),
                            icon: Icon(Icons.camera_alt, size: 35),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    if (imagesPaths.isNotEmpty)
                      // Images
                      SizedBox(
                        height: 80,
                        child: ListView.separated(
                          scrollDirection: Axis.horizontal,
                          itemCount: imagesPaths.length,
                          separatorBuilder: (_, _) => const SizedBox(width: 12),
                          itemBuilder: (context, index) {
                            final path = imagesPaths[index];
                            return Stack(
                              children: [
                                SmartImage(path: path, width: 80, height: 80),
                                Positioned(
                                  top: 6,
                                  right: 6,
                                  child: GestureDetector(
                                    onTap: () {
                                      setState(() {
                                        imagesPaths.removeAt(index);
                                      });
                                    },
                                    child: Container(
                                      padding: const EdgeInsets.all(4),
                                      decoration: const BoxDecoration(
                                        color: Colors.black54,
                                        shape: BoxShape.circle,
                                      ),
                                      child: const Icon(Icons.close, size: 18, color: Colors.white),
                                    ),
                                  ),
                                ),
                              ],
                            );
                          },
                        ),
                      ),

                    //  Rental Info (Conditional)
                    if (status == "Rented") ...[
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                           Text("rental_info".tr(), style: TextStyle(fontWeight: FontWeight.bold)),
                        ],
                      ),
                      Divider(),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: renterNameController,
                              decoration:  InputDecoration(
                                labelText: "name".tr(),
                                border: OutlineInputBorder(),
                              ),
                              validator: (value) => value!.isEmpty ? "required".tr() : null,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: TextFormField(
                              controller: renterPhoneController,
                              keyboardType: TextInputType.phone,
                              decoration:  InputDecoration(
                                labelText: "phone".tr(),
                                border: OutlineInputBorder(),
                              ),
                              validator: (value) => value!.isEmpty ? "required".tr() : null,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: rentPriceController,
                              keyboardType: TextInputType.number,
                              decoration:  InputDecoration(
                                labelText: "price".tr(),
                                border: OutlineInputBorder(),
                              ),
                              validator: (value) => value!.isEmpty
                                  ? "required".tr()
                                  : isNumeric(value)
                                  ? null
                                  : "invalid_num".tr(),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: TextFormField(
                              controller: renterNoteController,
                              keyboardType: TextInputType.phone,
                              decoration:  InputDecoration(
                                labelText: "rent_note".tr(),
                                border: OutlineInputBorder(),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: rentDurationController,
                              keyboardType: TextInputType.number,
                              decoration:  InputDecoration(
                                labelText: "${"duration".tr()}(${"days".tr()})",
                                border: OutlineInputBorder(),
                              ),
                              validator: (value) => value!.isEmpty
                                  ? "required".tr()
                                  : isNumeric(value)
                                  ? null
                                  : "invalid_num".tr(),
                            ),
                          ),
                          const SizedBox(width: 10),
                          SizedBox(
                            width: 140,
                            child: TextButton.icon(
                              onPressed: () async {
                                final picked = await showDatePicker(
                                  context: context,
                                  initialDate: DateTime.now(),
                                  firstDate: DateTime(2020),
                                  lastDate: DateTime(2100),
                                );
                                if (picked != null) {
                                  setState(() {
                                    rentStart = picked;
                                  });
                                }
                              },
                              icon: Icon(Icons.date_range, size: 35),
                              label: Text(
                                rentStart == null
                                    ? "start".tr()
                                    : "${"start".tr()}${rentStart!.toLocal().toString().split(' ')[0]}",
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: locationController,
                              decoration:  InputDecoration(
                                labelText: "location".tr(),
                                border: OutlineInputBorder(),
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          SizedBox(
                            width: 140,
                            child: TextButton.icon(
                              icon: const Icon(Icons.location_on, size: 35),
                              label:  Text("${"location".tr()}  "),
                              onPressed: () async {
                                final location = await Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (_) => const MapPickerScreen()),
                                );

                                if (location != null) {
                                  setState(() {
                                    currentLocation = location;
                                    locationController.text = location.address;
                                  });
                                }
                              },
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                           if (rentImagesPaths.isNotEmpty)
                          Expanded(
                            child: SizedBox(
                              height: 80,
                              child: ListView.separated(
                                scrollDirection: Axis.horizontal,
                                itemCount: rentImagesPaths.length,
                                separatorBuilder: (_, _) => const SizedBox(width: 12),
                                itemBuilder: (context, index) {
                                  final path = rentImagesPaths[index];
                                  return Stack(
                                    children: [
                                      SmartImage(path: path, width: 80, height: 80),
                                      Positioned(
                                        top: 6,
                                        right: 6,
                                        child: GestureDetector(
                                          onTap: () {
                                            setState(() {
                                              rentImagesPaths.removeAt(index);
                                            });
                                          },
                                          child: Container(
                                            padding: const EdgeInsets.all(4),
                                            decoration: const BoxDecoration(
                                              color: Colors.black54,
                                              shape: BoxShape.circle,
                                            ),
                                            child: const Icon(Icons.close, size: 18, color: Colors.white),
                                          ),
                                        ),
                                      ),
                                    ],
                                  );
                                },
                              ),
                            ),
                          ),
                          SizedBox(
                            width:  rentImagesPaths.isNotEmpty ? 140 : null  ,
                            child: TextButton.icon(
                              onPressed: () async {
                                final List<String>? selectedPaths = await showImageSourcePicker(context);
                                if (selectedPaths != null && selectedPaths.isNotEmpty) {
                                  rentImagesPaths.addAll(selectedPaths);
                                  setState(() {});
                                }
                              },
                              label: Text('add_rent_images'.tr()),
                              icon: Icon(Icons.person, size: 35),
                            ),
                          ),
                        ],
                      ),
                    ],
                    Divider(),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: notesController,
                      maxLines: 3,
                      decoration: InputDecoration(
                        labelText: "notes".tr(),
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ],
                ),

                // Images
              ),
            ),
          ),
          actions: [
            ElevatedButton(
              onPressed: () {
                if (_formKey.currentState!.validate()) {
                  Rent? currentRent;
                  String deviceId = deviceToEdit?.id ?? const Uuid().v4();
                  if (status == "Rented") {
                    currentRent = Rent(
                      id: deviceToEdit?.currentRent?.id ?? const Uuid().v4(),
                      rentPrice: rentPriceController.text,
                      renterName: renterNameController.text,
                      renterPhone: renterPhoneController.text,
                      rentStart: rentStart!.toLocal().toString().split(' ')[0],
                      rentDurationInDays: int.parse(rentDurationController.text),
                      rentNote: renterNoteController.text,
                      renterLocation: locationController.text.isEmpty && currentLocation == null
                          ? null
                          : AppLocation(
                              latitude: currentLocation?.latitude,
                              longitude: currentLocation?.longitude,
                              address: locationController.text,
                            ),
                      deviceId: deviceId,
                      rentImagesPaths: rentImagesPaths,
                    );
                  }
                  Device device = Device(
                    id: deviceId,
                    name: nameController.text,
                    createdAt: deviceToEdit?.createdAt,
                    imagesPaths: imagesPaths,
                    category: categoryController.text,
                    notes: notesController.text,
                    rentingHistory: deviceToEdit?.rentingHistory ?? [],
                    currentRent: currentRent,
                  );
                  showCustomDialog(
                    context,
                    title: deviceToEdit == null ? "add_device".tr() : "edit_device".tr(),
                    onAccept: () {
                      if (deviceToEdit != null) {
                        Provider.of<DeviceProvider>(context, listen: false).updateDevice(device);
                      } else {
                        Provider.of<DeviceProvider>(context, listen: false).addDevice(device);
                      }
                      Navigator.pop(context);
                    },
                    icon: deviceToEdit != null ? Icons.edit : Icons.add_circle_rounded,
                    color: deviceToEdit != null ? Colors.green : Colors.cyanAccent,
                  );
                }
              },
              child:  Text("save".tr()),
            ),
          ],
        );
      },
    );
  }
}
