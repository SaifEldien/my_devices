import 'location.dart';
import 'package:uuid/uuid.dart';

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
  final AppLocation? renterLocation;

  Rent({
    required this.renterName,
    required this.renterPhone,
    required this.rentStart,
    required this.rentDurationInDays,
    required this.renterLocation,
    required this.rentPrice,
    required this.rentNote,
    this.rentReturnDate,
    required this.id,
    required this.deviceId,
    required this.rentImagesPaths
  });

  int? get remainingRentalDays {
      final endDate = DateTime.parse(rentStart).add(Duration(days: rentDurationInDays));
      final remaining = endDate.difference(DateTime.now()).inDays;
      return remaining;
  }
   Map<String, Object?> toJson() => {
    'renterName': renterName,
    'rentStart': rentStart,
    'rentDurationInDays': rentDurationInDays,
    'renterPhone' : renterPhone,
    'renterLocation': renterLocation?.toJson(),
     'rentPrice': rentPrice,
     'rentNote': rentNote,
     'rentReturnDate': rentReturnDate,
     'id': id,
     'deviceId': deviceId,
     'rentImagesPaths': rentImagesPaths
  };

  factory Rent.fromJson( json) => Rent(
    id: json['id']?? const Uuid().v4(),
    renterName: json['renterName'],
    renterPhone: json['renterPhone'],
    rentStart: json['rentStart'],
    rentDurationInDays: json['rentDurationInDays']??0,
    renterLocation: json['renterLocation']==null ? null : AppLocation.fromJson(json['renterLocation']),
    rentPrice: json['rentPrice']??'0',
    rentNote: json['rentNote']??'',
    rentReturnDate: json['rentReturnDate'],
    deviceId: json['deviceId']??'8c9d843a-cb33-4749-802d-f3cea20f20c9',
    rentImagesPaths: json['rentImagesPaths']??[],
  );
}
