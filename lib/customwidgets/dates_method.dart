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

class Dateformat3 {
  static String formatWorkingDate3(DateTime date) {
    try {
      return DateFormat('yyyy-MM-dd').format(date);
    } catch (e) {
      print("Error formatting date: $e");
      return 'Invalid date';
    }
  }
}

class Dateformat4 {
  static String formatWorkingDate4(DateTime date) {
    try {
      return DateFormat('dd-MM-yyyy').format(date);
    } catch (e) {
      print("Error formatting date: $e");
      return 'Invalid date';
    }
  }
}