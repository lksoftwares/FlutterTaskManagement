import 'package:lktaskmanagementapp/packages/headerfiles.dart';
Widget buildCardLayout({required Widget child}) {
  return Card(
    margin: EdgeInsets.symmetric(vertical: 8),
    elevation: 8,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(15),
    ),
    color: Colors.white,
    shadowColor: Colors.black.withOpacity(0.3),
    child: Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.blueAccent.withOpacity(0.1), Colors.white],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(15),
      ),
      child: child,
    ),
  );
}