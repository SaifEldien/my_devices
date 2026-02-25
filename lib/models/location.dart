import 'dart:convert';

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

   Map<String, Object?> toJson() {
    return {
      'latitude': latitude,
      'longitude': longitude,
      'address': address,
    };
  }

  factory AppLocation.fromJson( json) {
    return AppLocation(
      latitude: json['latitude']==null ? null :  (json['latitude'] as num).toDouble(),
      longitude: json['longitude']==null ? null : (json['longitude'] as num).toDouble(),
      address: json['address'],
    );
  }

  /// Convert to JSON string
  String toRawJson() => jsonEncode(toJson());

  /// Create from JSON string
  factory AppLocation.fromRawJson(String str) =>
      AppLocation.fromJson(jsonDecode(str));

  @override
  String toString() =>
      'AppLocation(latitude: $latitude, longitude: $longitude, address: $address)';
}
/*
class Device {
  final String id;
  final String name;
  final String category;
   String status;
  final List  imagesPaths;
  final DateTime createdAt;
  final String notes;
  final String userId;
  Rent? currentRent;
  List<Rent> rentingHistory;}

class Rent {
  final String renterName;
  final String id;
  final String renterPhone;
  final String rentStart;
  final int rentDurationInDays;
  final String rentPrice;
  final String rentNote;
  String ? rentReturnDate;
  final List rentImagesPaths;
  final String deviceId;
  final AppLocation? renterLocation;}
class AppLocation {
  final double? latitude;
  final double? longitude;
  final String address;}
  
 */