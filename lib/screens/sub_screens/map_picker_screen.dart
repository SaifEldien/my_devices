import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'package:geocoding/geocoding.dart';
import 'package:my_devices/models/location.dart';

class MapPickerScreen extends StatefulWidget {
  const MapPickerScreen({super.key, this.latLng});
  final LatLng ? latLng;
  @override
  State<MapPickerScreen> createState() => _MapPickerScreenState();
}

class _MapPickerScreenState extends State<MapPickerScreen> {
  LatLng? selectedLocation;
  String? selectedAddress;
  @override
  void initState() {
    selectedLocation = widget.latLng;
    super.initState();
  }

  final MapController _mapController = MapController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Pick Location"),
        actions: [
          TextButton(
            onPressed: selectedAddress == null
                ? null
                : () {
              Navigator.pop(context, AppLocation(latitude: selectedLocation!.latitude, longitude: selectedLocation!.longitude, address: selectedAddress!));
            },
            child:  Text("SAVE".toLowerCase().tr()),
          )
        ],
      ),
      body: FlutterMap(
        mapController: _mapController,
        options: MapOptions(
          initialCenter: widget.latLng?? LatLng(30.0444, 31.2357),
          initialZoom: 13,
          onTap: (tapPosition, point) async {
            setState(() {
              selectedLocation = point;
            });

            final placemarks = await placemarkFromCoordinates(
              point.latitude,
              point.longitude,
              localeIdentifier: context.locale.toLanguageTag(),
            );

            final place = placemarks.first;
            setState(() {
              selectedAddress = "${place.street}, ${place.locality}, ${place.country}";
            });
          },
        ),
        children: [
          TileLayer(
            urlTemplate:
            "https://tile.openstreetmap.org/{z}/{x}/{y}.png",
            userAgentPackageName: 'com.yourcompany.yourapp',
          ),
          if (selectedLocation != null)
            MarkerLayer(
              markers: [
                Marker(
                  point: selectedLocation!,
                  width: 40,
                  height: 40,
                  child: const Icon(
                    Icons.location_pin,
                    color: Colors.red,
                    size: 40,
                  ),
                ),
              ],
            ),
        ],
      ),
       floatingActionButton:  FloatingActionButton(
          child: const Icon(Icons.my_location),
          onPressed: () async {

            final position = await determinePosition();

            if (position == null) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text("Location permission required"),
                ),
              );
              return;
            }

            print(position.latitude);

            final latLng = LatLng(position.latitude, position.longitude);

            _mapController.move(latLng, 16);

            setState(() {
              selectedLocation = latLng;
            });
          },
        ),
    );
  }

  Future<Position?> determinePosition() async {
    LocationPermission permission;

    // 1️⃣ Check if location services are enabled
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return null; // Or show dialog to enable GPS
    }

    // 2️⃣ Check permission
    permission = await Geolocator.checkPermission();

    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();

      if (permission == LocationPermission.denied) {
        return null; // user denied
      }
    }

    if (permission == LocationPermission.deniedForever) {
      // User permanently denied
      await Geolocator.openAppSettings();
      return null;
    }

    // 3️⃣ Safe to get position
    return await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );
  }
}
