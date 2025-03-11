
import 'package:lktaskmanagementapp/packages/headerfiles.dart';

void showToast({
  required String msg,
  Toast? toastLength = Toast.LENGTH_LONG,
  ToastGravity? gravity = ToastGravity.BOTTOM,
  Color? backgroundColor = Colors.red,
  Color? textColor = Colors.white,
}) {
  Fluttertoast.showToast(
    msg: msg,
    toastLength: toastLength ?? Toast.LENGTH_LONG,
    gravity: gravity ?? ToastGravity.BOTTOM,
    backgroundColor: backgroundColor ?? Colors.red,
    textColor: textColor ?? Colors.white,
  );
}
