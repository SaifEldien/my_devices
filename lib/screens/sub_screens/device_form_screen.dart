import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:latlong2/latlong.dart';
import 'package:my_devices/models/location.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';

import '../../funcs/pick_image_funcs.dart';
import '../../funcs/show_cat_sheet_func.dart';
import '../../models/device.dart';
import '../../models/rent.dart';
import '../../providers/devices_provider.dart';
import '../../widgets/Custom_image_page_view.dart';
import '../../widgets/custom_dialog.dart';
import 'map_picker_screen.dart';

class DeviceFormScreen extends StatefulWidget {
  final Device? deviceToEdit;
  const DeviceFormScreen({super.key, this.deviceToEdit});

  @override
  State<DeviceFormScreen> createState() => _DeviceFormScreenState();
}

class _DeviceFormScreenState extends State<DeviceFormScreen> with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();

  // Controllers
  late TextEditingController nameController;
  late TextEditingController categoryController;
  late TextEditingController notesController;

  late TextEditingController renterNameController;
  late TextEditingController renterPhoneController;
  late TextEditingController rentDurationController;
  late TextEditingController rentPriceController;
  late TextEditingController renterNoteController;

  late TextEditingController renterLocationController;
  late TextEditingController rentStartController;

  List imagesPaths = [];
  List rentImagesPaths = [];

  String status = "Available";
  AppLocation? currentLocation;

  @override
  void initState() {
    super.initState();

    final device = widget.deviceToEdit;

    nameController = TextEditingController(text: device?.name ?? "");
    categoryController = TextEditingController(text: device?.category ?? "");
    notesController = TextEditingController(text: device?.notes ?? "");
    renterNameController = TextEditingController(text: device?.currentRent?.renterName ?? "");
    renterPhoneController = TextEditingController(text: device?.currentRent?.renterPhone ?? "");
    rentDurationController = TextEditingController(
      text: device?.currentRent?.rentDurationInDays.toString() ?? "",
    );
    rentPriceController = TextEditingController(text: device?.currentRent?.rentPrice ?? "");
    renterNoteController = TextEditingController(text: device?.currentRent?.rentNote ?? "");
    rentStartController = TextEditingController(text: device?.currentRent?.rentStart.substring(0,10)??DateTime.now().toString().substring(0,10));
    renterLocationController = TextEditingController(
      text: device?.currentRent?.renterLocation?.address ?? "",
    );
    imagesPaths.addAll(device?.imagesPaths ?? []);
    rentImagesPaths.addAll(device?.currentRent?.rentImagesPaths ?? []);
    if (device!=null) {
      status = device.status;
      status = status=="Overdue" ? "Rented" : status;

    }
    if (device?.currentRent != null &&
        device?.currentRent?.renterLocation != null &&
        device?.currentRent?.renterLocation?.latitude != null) {
      currentLocation = device?.currentRent?.renterLocation;
    }
  }

  @override
  void dispose() {
    nameController.dispose();
    categoryController.dispose();
    notesController.dispose();
    renterNameController.dispose();
    renterPhoneController.dispose();
    rentDurationController.dispose();
    rentPriceController.dispose();
    renterNoteController.dispose();
    super.dispose();
  }

  InputDecoration inputStyle(String label, {Widget? suffixIcon}) {
    return InputDecoration(
      labelText: label,
      filled: true,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      suffixIcon: suffixIcon,
    );
  }

  @override
  Widget build(BuildContext context) {
    const gap = SizedBox(height: 18);
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.deviceToEdit == null ? "add_device".tr() : "edit_device".tr()),
        actions: [
          TextButton(
            //style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16),backgroundColor: Colors.white70),
            onPressed: () {
              if (_formKey.currentState!.validate()) {
                Rent? currentRent;
                String deviceId = widget.deviceToEdit?.id ?? const Uuid().v4();
                if (status == "Rented") {
                  currentRent = Rent(
                    id: widget.deviceToEdit?.currentRent?.id ?? const Uuid().v4(),
                    rentPrice: rentPriceController.text,
                    renterName: renterNameController.text,
                    renterPhone: renterPhoneController.text,
                    rentStart: rentStartController.text,
                    rentDurationInDays: int.parse(rentDurationController.text),
                    rentNote: renterNoteController.text,
                    renterLocation: renterLocationController.text.isEmpty && currentLocation == null
                        ? null
                        : AppLocation(
                      latitude: currentLocation?.latitude,
                      longitude: currentLocation?.longitude,
                      address: renterLocationController.text,
                    ),
                    deviceId: deviceId,
                    rentImagesPaths: rentImagesPaths,
                  );
                }
                Device device = Device(
                  id: deviceId,
                  name: nameController.text,
                  createdAt: widget.deviceToEdit?.createdAt,
                  imagesPaths: imagesPaths,
                  category: categoryController.text,
                  notes: notesController.text,
                  rentingHistory: widget.deviceToEdit?.rentingHistory ?? [],
                  currentRent: currentRent,
                );
                showCustomDialog(
                  context,
                  title: widget.deviceToEdit == null ? "add_device".tr() : "edit_device".tr(),
                  onAccept: () {
                    if (widget.deviceToEdit != null) {
                      Provider.of<DeviceProvider>(context, listen: false).updateDevice(device);
                    } else {
                      Provider.of<DeviceProvider>(context, listen: false).addDevice(device);
                    }
                    Navigator.pop(context);
                  },
                  icon: widget.deviceToEdit != null ? Icons.edit : Icons.add_circle_rounded,
                  color: widget.deviceToEdit != null ? Colors.green : Colors.cyanAccent,
                );
              }
            },
            child: Text("save".tr(), style: const TextStyle(fontSize: 16)),
          )
        ],
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: Icon(Icons.arrow_back_ios_new_outlined),
        ),
      ),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "device_info".tr(),
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                ),
                gap,
                TextFormField(
                  maxLines: null,
                  controller: nameController,
                  decoration: inputStyle("device_name".tr()),
                  keyboardType: TextInputType.multiline,
                  validator: (v) => v == null || v.isEmpty ? "required".tr() : null,
                ),
                gap,
                imagesPaths.isEmpty
                    ? InkWell(
                        onTap: () async {
                          final List<String>? selectedPaths = await showImageSourcePicker(context);
                          if (selectedPaths != null && selectedPaths.isNotEmpty) {
                            imagesPaths.addAll(selectedPaths);
                            setState(() {});
                          }
                        },
                        child: _buildEmptyImageState("add_device_images".tr()),
                      )
                    : _buildImagePreviewList(
                        imagesPaths: imagesPaths,
                        onAddMore: () async {
                          final List<String>? selectedPaths = await showImageSourcePicker(context);
                          if (selectedPaths != null && selectedPaths.isNotEmpty) {
                            imagesPaths.addAll(selectedPaths);
                            setState(() {});
                          }
                        },
                      ),
                gap,
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        maxLines: null,
                        controller: categoryController,
                        decoration: inputStyle(
                          "cat".tr(),
                          suffixIcon: IconButton(
                            icon: const Icon(Icons.arrow_drop_down),
                            onPressed: () {
                              showCategoriesSheet(context, categoryController);
                            },
                          ),
                        ),
                        keyboardType: TextInputType.multiline,
                        validator: (v) => v == null || v.isEmpty ? "required".tr() : null,
                      ),
                    ),
                    SizedBox(width: 10),
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        value:  status,
                        decoration: inputStyle("status".tr()),
                        items: [
                          DropdownMenuItem(value: "Available", child: Text("available".tr())),
                          DropdownMenuItem(value: "Rented", child: Text("rented".tr())),
                        ],
                        onChanged: (value) {
                          setState(() {
                            status = value ?? "Available";
                          });
                        },
                      ),
                    ),
                  ],
                ),
                gap,
                TextFormField(
                  maxLines: null,
                  controller: notesController,
                  minLines: 1,
                  keyboardType: TextInputType.multiline,
                  decoration: inputStyle("device_notes".tr()),
                ),
                gap,
                AnimatedSize(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                  child: status != "Available"
                      ? Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Divider(),
                            gap,
                            Text(
                              "rental_info".tr(),
                              style: Theme.of(
                                context,
                              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                            ),
                            gap,
                            TextFormField(
                              maxLines: null,
                              controller: renterNameController,
                              decoration: inputStyle("renter_name".tr()),
                              keyboardType: TextInputType.multiline,
                              validator: (v) => v == null || v.isEmpty ? "required".tr() : null,
                            ),
                            gap,
                            rentImagesPaths.isEmpty
                                ? InkWell(
                                    onTap: () async {
                                      final List<String>? selectedPaths = await showImageSourcePicker(
                                        context,
                                      );
                                      if (selectedPaths != null && selectedPaths.isNotEmpty) {
                                        rentImagesPaths.addAll(selectedPaths);
                                        setState(() {});
                                      }
                                    },
                                    child: _buildEmptyImageState("add_rent_images".tr()),
                                  )
                                : _buildImagePreviewList(
                                    imagesPaths: rentImagesPaths,
                                    onAddMore: () async {
                                      final List<String>? selectedPaths = await showImageSourcePicker(
                                        context,
                                      );
                                      if (selectedPaths != null && selectedPaths.isNotEmpty) {
                                        rentImagesPaths.addAll(selectedPaths);
                                        setState(() {});
                                      }
                                    },
                                  ),
                            gap,
                            TextFormField(
                              maxLines: null,
                              controller: renterPhoneController,
                              keyboardType: TextInputType.phone,
                              decoration: inputStyle("renter_phone".tr()),
                              validator: (v) => v == null || v.isEmpty ? "required".tr() : null,
                            ),
                            gap,
                            Row(
                              children: [
                                Expanded(
                                  child: TextFormField(
                                    maxLines: null,
                                    validator: (v) => v == null || v.isEmpty ? "required".tr() : null,
                                    controller: rentPriceController,
                                    keyboardType: TextInputType.number,
                                    decoration: inputStyle("price".tr()),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: TextFormField(
                                    maxLines: null,
                                    validator: (v) => v == null || v.isEmpty ? "required".tr() : null,
                                    controller: rentDurationController,
                                    keyboardType: TextInputType.number,
                                    decoration: inputStyle("duration".tr()),
                                  ),
                                ),
                              ],
                            ),
                            gap,
                            TextFormField(
                              maxLines: null,
                              readOnly: true,
                              controller: rentStartController,
                              validator: (v) => v == null || v.isEmpty ? "required".tr() : null,
                              decoration: inputStyle(
                                "start_date".tr(),
                                suffixIcon: IconButton(
                                  onPressed: () async {
                                    final picked = await showDatePicker(
                                      context: context,
                                      initialDate: DateTime.now(),
                                      firstDate: DateTime(2020),
                                      lastDate: DateTime(2100),
                                    );
                                    if (picked != null) {
                                      rentStartController.text = picked.toString().substring(0,10);
                                    }
                                  },
                                  icon: Icon(
                                    Icons.calendar_today,
                                    color: rentStartController.text.isEmpty
                                        ? Colors.grey
                                        : Colors.purple.shade300,
                                  ),
                                ),
                              ),
                            ),
                            gap,
                            TextFormField(
                              maxLines: null,
                              controller: renterLocationController,
                              validator: (v) => v == null || v.isEmpty ? "required".tr() : null,
                              decoration: inputStyle(
                                "location".tr(),
                                suffixIcon: IconButton(
                                  onPressed: () async {
                                    final location = await Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) => MapPickerScreen(
                                          latLng:
                                              widget.deviceToEdit?.currentRent?.renterLocation?.latitude !=
                                                  null
                                              ? LatLng(
                                                  widget.deviceToEdit!.currentRent!.renterLocation!.latitude!,
                                                  widget
                                                      .deviceToEdit!
                                                      .currentRent!
                                                      .renterLocation!
                                                      .longitude!,
                                                )
                                              : null,
                                        ),
                                      ),
                                    );
                                    if (location != null) {
                                      setState(() {
                                        currentLocation = location;
                                        renterLocationController.text = location.address;
                                      });
                                    }
                                  },
                                  icon: Icon(
                                    Icons.location_on,
                                    color: (currentLocation?.latitude == null)
                                        ? Colors.grey
                                        : Colors.purple.shade300,
                                  ),
                                ),
                              ),
                            ),
                            gap,
                            TextFormField(
                              controller: renterNoteController,
                              minLines: 1,
                              maxLines: null,
                              keyboardType: TextInputType.multiline,
                              decoration: inputStyle("rent_note".tr()),
                            ),
                            gap,
                          ],
                        )
                      : const SizedBox(),
                ),

                gap,
                gap,

               /* SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16)),
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        Rent? currentRent;
                        String deviceId = widget.deviceToEdit?.id ?? const Uuid().v4();
                        if (status == "Rented") {
                          currentRent = Rent(
                            id: widget.deviceToEdit?.currentRent?.id ?? const Uuid().v4(),
                            rentPrice: rentPriceController.text,
                            renterName: renterNameController.text,
                            renterPhone: renterPhoneController.text,
                            rentStart: rentStartController.text,
                            rentDurationInDays: int.parse(rentDurationController.text),
                            rentNote: renterNoteController.text,
                            renterLocation: renterLocationController.text.isEmpty && currentLocation == null
                                ? null
                                : AppLocation(
                                    latitude: currentLocation?.latitude,
                                    longitude: currentLocation?.longitude,
                                    address: renterLocationController.text,
                                  ),
                            deviceId: deviceId,
                            rentImagesPaths: rentImagesPaths,
                          );
                        }
                        Device device = Device(
                          id: deviceId,
                          name: nameController.text,
                          status: status,
                          createdAt: widget.deviceToEdit?.createdAt,
                          imagesPaths: imagesPaths,
                          category: categoryController.text,
                          notes: notesController.text,
                          rentingHistory: widget.deviceToEdit?.rentingHistory ?? [],
                          currentRent: currentRent,
                        );
                        showCustomDialog(
                          context,
                          title: widget.deviceToEdit == null ? "add_device".tr() : "edit_device".tr(),
                          onAccept: () {
                            if (widget.deviceToEdit != null) {
                              Provider.of<DeviceProvider>(context, listen: false).updateDevice(device);
                            } else {
                              Provider.of<DeviceProvider>(context, listen: false).addDevice(device);
                            }
                            Navigator.pop(context);
                          },
                          icon: widget.deviceToEdit != null ? Icons.edit : Icons.add_circle_rounded,
                          color: widget.deviceToEdit != null ? Colors.green : Colors.cyanAccent,
                        );
                      }
                    },
                    child: Text("save".tr(), style: const TextStyle(fontSize: 16)),
                  ),
                ),*/
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildImagePreviewList({required List imagesPaths, required Function onAddMore}) {
    return SizedBox(
      height: 100,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: imagesPaths.length + 1,
        itemBuilder: (context, index) {
          if (index == imagesPaths.length) {
            return InkWell(
              onTap: () {
                onAddMore();
              },
              child: _buildAddMoreButton(),
            );
          }
          final path = imagesPaths[index];
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Stack(
              children: [
                SmartImage(path: path, width: 100, height: 100),
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
                      decoration: const BoxDecoration(color: Colors.black54, shape: BoxShape.circle),
                      child: const Icon(Icons.close, size: 18, color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildEmptyImageState(String title) {
    return Container(
      height: 100,
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15),
        border: Border.all(
          color: Colors.grey,
          width: 1,
          style: BorderStyle.solid,
        ), // Dash effect handled by logic usually
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Icon(Icons.camera_alt_outlined, color: Colors.purple.shade100, size: 40),
          SizedBox(height: 8),
          Text(title),
        ],
      ),
    );
  }

  Widget _buildAddMoreButton() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8.0),
      width: 100,
      decoration: BoxDecoration(
        color: Colors.white10,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey),
      ),
      child: Icon(Icons.add, size: 40, color: Colors.purple.shade100),
    );
  }
}

String formatArabicDate(String arabicDate) {
  const englishNumbers = {
    '٠': '0', '١': '1', '٢': '2', '٣': '3', '٤': '4',
    '٥': '5', '٦': '6', '٧': '7', '٨': '8', '٩': '9',
  };
  String cleanDate = arabicDate;
  englishNumbers.forEach((arabic, english) {
    cleanDate = cleanDate.replaceAll(arabic, english);
  });
  cleanDate = cleanDate.replaceAll(RegExp(r'[^\d/]'), '');
  try {
    DateFormat inputFormat = DateFormat("d/M/yyyy");
    DateTime parsedDate = inputFormat.parse(cleanDate);
    return parsedDate.toIso8601String();
  } catch (e) {
    return "Invalid Date Format: $e";
  }
}
