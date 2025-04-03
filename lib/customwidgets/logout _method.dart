// import 'package:lktaskmanagementapp/packages/headerfiles.dart';
//
// class AuthService {
//   static Future<void> logout(BuildContext context) async {
//     SharedPreferences prefs = await SharedPreferences.getInstance();
//     bool hasCheckedIn = prefs.getBool('hasCheckedIn') ?? false;
//     bool hasCheckedOut = prefs.getBool('hasCheckedOut') ?? false;
//
//     if (hasCheckedIn && !hasCheckedOut) {
//       _showLogoutConfirmationDialog(context);
//     } else {
//       _performLogout(context);
//     }
//   }
//
//   static void _showLogoutConfirmationDialog(BuildContext context) {
//     showDialog(
//       context: context,
//       builder: (context) {
//         return AlertDialog(
//           title: Row(
//             children: [
//               Text(
//                 'Check Out Reminder',
//                 style: TextStyle(fontSize: 21, fontWeight: FontWeight.w900),
//               ),
//               SizedBox(width: 5),
//               Icon(
//                 Icons.notifications_active,
//                 color: Colors.green,
//               )
//             ],
//           ),
//           content: Text(
//               'You have not checked out your attendance. Do you still want to log out of your account?'),
//           actions: <Widget>[
//             TextButton(
//               onPressed: () {
//                 Navigator.of(context).pop();
//               },
//               child: Text('Cancel'),
//             ),
//             TextButton(
//               style: TextButton.styleFrom(
//                 backgroundColor: Colors.green,
//               ),
//               onPressed: () {
//                 _performLogout(context);
//                 Navigator.of(context).pop();
//               },
//               child: Text(
//                 'Logout Anyway',
//                 style: TextStyle(color: Colors.white),
//               ),
//             ),
//           ],
//         );
//       },
//     );
//   }
//
//   static Future<void> _performLogout(BuildContext context) async {
//     SharedPreferences prefs = await SharedPreferences.getInstance();
//     await prefs.remove('user_Id');
//     await prefs.remove('user_Name');
//     await prefs.remove('role_Name');
//     await prefs.remove('token');
//
//     await prefs.remove('role_Id');
//     MenuDataHolder().menuData.clear();
//     MenuDataHolder().isMenuDataLoaded = false;
//
//     showToast(msg: "Logged out successfully", backgroundColor: Colors.green);
//
//     Navigator.pushAndRemoveUntil(
//       context,
//       MaterialPageRoute(builder: (context) => LoginScreen()),
//           (route) => false,
//     );
//   }
// }


import 'package:lktaskmanagementapp/packages/headerfiles.dart';

class AuthService {
  static Future logout(BuildContext context) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool hasCheckedIn = prefs.getBool('hasCheckedIn') ?? false;
    bool hasCheckedOut = prefs.getBool('hasCheckedOut') ?? false;

    if (hasCheckedIn && !hasCheckedOut) {
      _showLogoutConfirmationDialog(context);
    } else {
      _showLogoutConfirmationDialogWithCheckbox(context);
    }
  }

  static void _showLogoutConfirmationDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Row(
            children: [
              Text(
                'Check Out Reminder',
                style: TextStyle(fontSize: 21, fontWeight: FontWeight.w900),
              ),
              SizedBox(width: 5),
              Icon(
                Icons.notifications_active,
                color: Colors.green,
              )
            ],
          ),
          content: Text(
              'You have not checked out your attendance. Do you still want to log out of your account?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cancel'),
            ),
            TextButton(
              style: TextButton.styleFrom(
                backgroundColor: Colors.green,
              ),
              onPressed: () {
                _performLogout(context, logoutFromAllDevices: false);
                Navigator.of(context).pop();
              },
              child: Text(
                'Logout Anyway',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        );
      },
    );
  }

  static void _showLogoutConfirmationDialogWithCheckbox(BuildContext context) {
    bool logoutFromAllDevices = false;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return AlertDialog(
              title: Row(
                children: [
                  Text(
                    'Logout Confirmation',
                    style: TextStyle(fontSize: 21, fontWeight: FontWeight.w900),
                  ),
                  SizedBox(width: 5),
                  Icon(
                    Icons.phone_android,
                    color: Colors.red,
                  )
                ],
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('Are you sure you want to log out from all devices?'),
                  Row(
                    children: [
                      Checkbox(
                        value: logoutFromAllDevices,
                        onChanged: (bool? value) {
                          setState(() {
                            logoutFromAllDevices = value ?? false;
                          });
                        },
                      ),
                      Text('Logout from all devices'),
                    ],
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: Text('Cancel'),
                ),
                TextButton(
                  style: TextButton.styleFrom(
                    backgroundColor: Colors.green,
                  ),
                  onPressed: () {
                    _performLogout(
                        context, logoutFromAllDevices: logoutFromAllDevices);
                    Navigator.of(context).pop();
                  },
                  child: Text(
                    'Logout',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  static Future _performLogout(BuildContext context,
      {bool logoutFromAllDevices = false}) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    int? userId = prefs
        .getInt('user_Id');
    String? token = prefs
        .getString('token');

    if (userId != null && token != null) {
      Map<String, dynamic> requestBody = {
        'userId': userId,
        'token': token,
        'logoutAll': logoutFromAllDevices,
      };
      ApiService apiService = ApiService();
      var response = await apiService.request(
          method: 'post',
          endpoint: 'User/Logout',
          body: requestBody,
          tokenRequired: true
      );

      if (response['statusCode'] == 200) {
        print(response);
        await prefs.remove('user_Id');
        await prefs.remove('user_Name');
        await prefs.remove('token');
        MenuDataHolder().menuData.clear();
        MenuDataHolder().isMenuDataLoaded = false;
        showToast(
            msg:response['message'] ??"Logged out successfully", backgroundColor: Colors.green);
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => LoginScreen()),
              (route) => false,
        );
      } else {
        showToast(msg: response['message'] ?? 'Error logging out.');
        print(response['message']);
      }
    }
  }
}





