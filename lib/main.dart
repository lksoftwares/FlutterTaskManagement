import 'package:lktaskmanagementapp/packages/headerfiles.dart';
void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
    theme: ThemeData(
    appBarTheme: AppBarTheme(
    iconTheme: IconThemeData(color: Colors.white),
    ),
    ),
      debugShowCheckedModeBanner: false,
      title: 'LkTaskManagement',
      initialRoute: '/',
      routes: AppRoutes.getRoutes(),
      onGenerateRoute: (settings) {
        return MaterialPageRoute(builder: (context) => SplashScreen());
      },
    );
  }
}

// import 'package:lktaskmanagementapp/components/attendance/attendance_screen.dart';
// import 'package:lktaskmanagementapp/packages/headerfiles.dart';
// void main() {
//   runApp(MyApp());
// }
//
// class MyApp extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       debugShowCheckedModeBanner: false,
//     home: AttendanceScreen(),
//     );
//   }
// }