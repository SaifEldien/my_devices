import  'package:my_devices/core/core.dart';

import '../../../core/widgets/device_form_screen_elements.dart';
import 'map_picker_screen.dart';

class DeviceFormScreen extends StatefulWidget {
  final Device? deviceToEdit;
  const DeviceFormScreen({super.key, this.deviceToEdit});

  @override
  State<DeviceFormScreen> createState() => _DeviceFormScreenState();
}

class _DeviceFormScreenState extends State<DeviceFormScreen> with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();

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
          child: Padding(
            padding: const EdgeInsets.all(15.0),
            child: ListView(
              children: [
                SizedBox(height: 10,),
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
                        child: buildEmptyImageState("add_device_images".tr()),
                      )
                    : buildImagePreviewList(
                        imagesPaths: imagesPaths,
                        onAddMore: () async {
                          final List<String>? selectedPaths = await showImageSourcePicker(context);
                          if (selectedPaths != null && selectedPaths.isNotEmpty) {
                            imagesPaths.addAll(selectedPaths);
                            setState(() {});
                          }
                        }, setState: ()=>setState(() {}),
                      ),
                gap,
                SizedBox(
                  width: MediaQuery.of(context).size.width,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
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
                          initialValue:  status,
                          decoration: inputStyle("status".tr()),
                          items: [
                            DropdownMenuItem(value: "Available",child: Text("available".tr())),
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
                                    child: buildEmptyImageState("add_rent_images".tr()),
                                  )
                                : buildImagePreviewList(
                                    imagesPaths: rentImagesPaths,
                                    onAddMore: () async {
                                      final List<String>? selectedPaths = await showImageSourcePicker(
                                        context,
                                      );
                                      if (selectedPaths != null && selectedPaths.isNotEmpty) {
                                        rentImagesPaths.addAll(selectedPaths);
                                        setState(() {});
                                      }
                                    }, setState: ()=> setState(() {}),
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
                            SizedBox(
                              width: MediaQuery.of(context).size.width,
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
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
              ],
            ),
          ),
        ),
      ),
    );
  }
}

