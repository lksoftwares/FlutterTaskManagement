import 'package:flutter/material.dart';

class AppTextStyle {
  static TextStyle boldTextStyle({double fontSize = 15}) {
    return TextStyle(
      fontWeight: FontWeight.bold,
      fontSize: fontSize,
    );
  }

  static TextStyle regularTextStyle({double fontSize = 15}) {
    return TextStyle(
      fontWeight: FontWeight.normal,
      fontSize: fontSize,
    );
  }
}
