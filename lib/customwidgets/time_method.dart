import 'package:intl/intl.dart';

class TimeUtils {
  static String getCurrentTime() {
    final now = DateTime.now();
    return DateFormat('HH:mm:00').format(now);
  }
}
