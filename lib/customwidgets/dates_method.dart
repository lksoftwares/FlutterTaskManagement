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

class Dateformatfull {
  static String formatDatefull(String dateStr) {
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

class DateformatyyyyMMdd {
  static String formatDateyyyyMMdd(DateTime date) {
    try {
      return DateFormat('yyyy-MM-dd').format(date);
    } catch (e) {
      print("Error formatting date: $e");
      return 'Invalid date';
    }
  }
}

class DateformatddMMyyyy {
  static String formatDateddMMyyyy(DateTime date) {
    try {
      return DateFormat('dd-MM-yyyy').format(date);
    } catch (e) {
      print("Error formatting date: $e");
      return 'Invalid date';
    }
  }
  static DateTime parseDateddMMyyyy(String dateStr) {
    try {
      return DateFormat('dd-MM-yyyy').parse(dateStr);
    } catch (e) {
      print("Error parsing date: $e");
      return DateTime(2000);
    }

  }
}