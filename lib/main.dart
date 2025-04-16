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






//
//
//
// import 'package:flutter/material.dart';
//
// void main() {
//   runApp(MyApp());
// }
//
// class MyApp extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       home: DropdownAlertScreen(),
//     );
//   }
// }
//
// class DropdownAlertScreen extends StatefulWidget {
//   @override
//   _DropdownAlertScreenState createState() => _DropdownAlertScreenState();
// }
//
// class _DropdownAlertScreenState extends State<DropdownAlertScreen> {
//   List<String> jsonValues = ["Apple", "Banana", "Cherry"];
//   String? selectedValue;
//
//   // Function to show an alert for adding new values
//   void _showAddValueAlert(BuildContext context, Function updateDropdown) {
//     TextEditingController controller = TextEditingController();
//     showDialog(
//       context: context,
//       builder: (BuildContext context) {
//         return AlertDialog(
//           title: Text('Add a new value'),
//           content: TextField(
//             controller: controller,
//             decoration: InputDecoration(hintText: 'Enter new value'),
//           ),
//           actions: [
//             TextButton(
//               onPressed: () {
//                 String newValue = controller.text.trim();
//                 if (newValue.isNotEmpty && !jsonValues.contains(newValue)) {
//                   setState(() {
//                     jsonValues.add(newValue);
//                     selectedValue = newValue;
//                   });
//                   updateDropdown();
//                   Navigator.pop(context);
//                 } else {
//                   ScaffoldMessenger.of(context).showSnackBar(SnackBar(
//                     content: Text('Invalid value or already exists!'),
//                   ));
//                 }
//               },
//               child: Text('Add'),
//             ),
//             TextButton(
//               onPressed: () {
//                 Navigator.pop(context); // Close dialog
//               },
//               child: Text('Cancel'),
//             ),
//           ],
//         );
//       },
//     );
//   }
//
//   // Function to show the main dropdown dialog
//   void _showDropdownAlert() {
//     showDialog(
//       context: context,
//       builder: (BuildContext context) {
//         return AlertDialog(
//           title: Text('Choose a value'),
//           content: StatefulBuilder(
//             builder: (BuildContext context, StateSetter setState) {
//               return Column(
//                 mainAxisSize: MainAxisSize.min,
//                 children: [
//                   DropdownButton<String>(
//                     value: selectedValue,
//                     onChanged: (String? newValue) {
//                       setState(() {
//                         selectedValue = newValue;
//                       });
//                     },
//                     items: jsonValues.map<DropdownMenuItem<String>>((String value) {
//                       return DropdownMenuItem<String>(
//                         value: value,
//                         child: Text(value),
//                       );
//                     }).toList(),
//                   ),
//                   IconButton(
//                     icon: Icon(Icons.add),
//                     onPressed: () {
//                       _showAddValueAlert(context, () {
//                         setState(() {});
//                       });
//                     },
//                   ),
//                 ],
//               );
//             },
//           ),
//           actions: [
//             TextButton(
//               onPressed: () {
//                 Navigator.pop(context);
//               },
//               child: Text('Close'),
//             ),
//           ],
//         );
//       },
//     );
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: Text('Dropdown with Alerts')),
//       body: Center(
//         child: ElevatedButton(
//           onPressed: _showDropdownAlert,
//           child: Text('Open Dropdown'),
//         ),
//       ),
//     );
//   }
// }
