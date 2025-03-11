import 'package:intl/intl.dart';

class Dateformat {
  static String formatWorkingDate(String dateStr) {
    try {
      DateFormat dateFormat = DateFormat('dd-MM-yyyy');
      DateTime parsedDate = dateFormat.parse(dateStr);
      return DateFormat('MMMM dd, yyyy').format(parsedDate);
    } catch (e) {
      print("Error parsing date: $e");
      return 'Invalid date';
    }
  }
}
