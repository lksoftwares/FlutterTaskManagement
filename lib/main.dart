// import 'package:lktaskmanagementapp/packages/headerfiles.dart';
//
// void main() {
//   runApp(MyApp());
//   // String apiUrl = Config.getApiUrl('local');
//   // print('API URL: $apiUrl');
// }
//
// class MyApp extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//     theme: ThemeData(
//     appBarTheme: AppBarTheme(
//     iconTheme: IconThemeData(color: Colors.white),
//     ),),
//
//       debugShowCheckedModeBanner: false,
//       title: 'LkTaskManagement',
//       initialRoute: '/',
//       routes: AppRoutes.getRoutes(),
//       onGenerateRoute: (settings) {
//         return MaterialPageRoute(builder: (context) => SplashScreen());
//       },
//     );
//   }
// }

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
      home: SplashScreen(),
    );
  }
}
