import '../../data/models/device.dart';

List<int> calculateAnalytics(List<Device> devices) {
  int total = devices.length;
  int rented = 0;
  int available = 0;
  int overdue = 0;

  for (final device in devices) {
    final rent = device.currentRent;
    if (rent == null) {
      available++;
    } else {
      final remainingDays = DateTime.parse(
        rent.rentStart,
      ).add(Duration(days: rent.rentDurationInDays)).difference(DateTime.now()).inDays;
      if (remainingDays < 0) {
        overdue++;
      } else {
        rented++;
      }
    }
  }
  return [total, rented, available, overdue];
}
