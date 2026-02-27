import 'package:latlong2/latlong.dart';

class AppLocation {
  final double? latitude;
  final double? longitude;
  final String address;

  const AppLocation({
    required this.latitude,
    required this.longitude,
    required this.address,
  });

  LatLng? toLatLng() {
    if (latitude == null || longitude == null) {
      return null;
    }
    return LatLng(latitude!, longitude!);
  }

  Map<String, dynamic> toJson() {
    return {
      'latitude': latitude,
      'longitude': longitude,
      'address': address,
    };
  }

  factory AppLocation.fromJson(Map json) {
    return AppLocation(
      latitude: json['latitude']==null ? null :  (json['latitude'] as num).toDouble(),
      longitude: json['longitude']==null ? null : (json['longitude'] as num).toDouble(),
      address: json['address'],
    );
  }

  @override
  String toString() =>
      'AppLocation(latitude: $latitude, longitude: $longitude, address: $address)';
}
