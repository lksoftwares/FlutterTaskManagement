//
//
// import '../packages/headerfiles.dart';
//
// class TimePickerClass {
//   static Future<String?> selectTime(BuildContext context, bool isStartTime) async {
//     TimeOfDay? picked = await showTimePicker(
//       context: context,
//       initialTime: TimeOfDay.now(),
//     );
//
//     if (picked != null) {
//       String formattedTime = "${picked.hour.toString().padLeft(2, '0')}:${picked.minute.toString().padLeft(2, '0')}:00";
//       return formattedTime;
//     }
//
//     return null;
//   }
// }
import 'package:flutter/material.dart';

class TimePickerClass {
  static Future<String?> selectTime(BuildContext context, bool isStartTime, {String? initialTime}) async {
    TimeOfDay initial = TimeOfDay.now();

    if (initialTime != null) {
      List<String> timeParts = initialTime.split(":");
      initial = TimeOfDay(hour: int.parse(timeParts[0]), minute: int.parse(timeParts[1]));
    }

    TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: initial,
    );

    if (picked != null) {
      String formattedTime = "${picked.hour.toString().padLeft(2, '0')}:${picked.minute.toString().padLeft(2, '0')}:00";
      return formattedTime;
    }

    return null;
  }
}
