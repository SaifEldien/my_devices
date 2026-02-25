import 'package:my_devices/models/rent.dart';

class Device {
  final String id;
  final String name;
  final String category;
  final List  imagesPaths;
  final DateTime createdAt;
  final String notes;
  final String userId;
  Rent? currentRent;
  List<Rent> rentingHistory;
  Device({
    required this.id,
    required this.name,
    required this.imagesPaths,
    required this.category,
    required this.notes,
    this.currentRent,
    this.rentingHistory = const [],
    DateTime? createdAt,
    this.userId = "saif@gmail.com",
  }) : createdAt = createdAt ?? DateTime.now();

  bool get isRented => status.toLowerCase() == "rented";

  String get calculatedStatus {
    if (currentRent == null) return "Available";

    try {
      final rentEndDate = DateTime.parse(currentRent!.rentStart)
          .add(Duration(days: currentRent!.rentDurationInDays));

      final difference = rentEndDate.difference(DateTime.now()).inDays;

      if (difference >= 0) {
        return "Rented";
      } else {
        return "Overdue";
      }
    } catch (e) {
      return "Available"; // في حال وجود خطأ في التاريخ
    }
  }

  // يمكنك الاحتفاظ بمتغير status القديم لسهولة التعامل مع الـ UI إذا أردت
  String get status => calculatedStatus;

   toJson() => {
    'id': id,
    'name': name,
    'imagesPaths': imagesPaths,
    'createdAt': createdAt.toIso8601String(),
    'category': category,
    'notes': notes,
    'currentRent': currentRent?.toJson(),
    'rentingHistory': List.generate(rentingHistory.length, (index) => rentingHistory[index].toJson()),
    'userId': userId,
  };

  factory Device.fromJson(Map json) => Device(
    id: json['_id'] ?? json['id'] ?? '',
    name: json['name'],
    imagesPaths: json['imagesPaths'],
    createdAt: DateTime.parse(json['createdAt']),
    category: json['category'],
    notes: json['notes'],
    currentRent: json['currentRent']==null? null : Rent.fromJson(json['currentRent']),
    rentingHistory: List.generate(json['rentingHistory'].length, (index) => Rent.fromJson(json['rentingHistory'][index])),
    userId: json['userId'],
  );
}
