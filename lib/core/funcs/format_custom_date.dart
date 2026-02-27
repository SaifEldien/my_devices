import 'package:intl/intl.dart';

String formatCustomDate(dynamic inputDate,  {required String locale,bool showTime = false}) {
  try {
    DateTime? date;
    if (inputDate is DateTime) {
      date = inputDate;
    } else if (inputDate is String) {
      date = DateTime.tryParse(inputDate);
    } else if (inputDate.runtimeType.toString() == 'Timestamp') {
      date = inputDate.toDate();
    }

    if (date == null) return "Invalid Date";
    final bool isArabic = locale.contains('ar');
    String pattern;
    if (isArabic) {
      pattern =   showTime ? 'dd-MM-yyyy hh:mm a' : 'dd-MM-yyyy';
    }
    else {
      pattern =   showTime ? 'yyyy-MM-dd hh:mm a' : 'yyyy-MM-dd';
    }
    return DateFormat(pattern,locale).format(date);

  } catch (e) {
    return "Error";
  }
}