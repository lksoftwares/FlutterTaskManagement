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

class Dateformat2 {
  static String formatWorkingDate2(String dateStr) {
    try {
      DateFormat dateFormat = DateFormat('dd-MM-yyyy HH:mm:ss');
      DateTime parsedDate = dateFormat.parse(dateStr);
      return DateFormat('dd-MM-yyyy HH:mm:ss').format(parsedDate);
    } catch (e) {
      print("Error parsing date: $e");
      return 'Invalid date';
    }
  }
}