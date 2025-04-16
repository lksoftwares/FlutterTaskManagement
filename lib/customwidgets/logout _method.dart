import 'package:lktaskmanagementapp/packages/headerfiles.dart';

class AuthService {
  static Future logout(BuildContext context) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool? hasCheckedOut = prefs.getBool('hasCheckedOut');

    if (hasCheckedOut == null || !hasCheckedOut) {
      _showLogoutConfirmationDialog(context);
    } else {
      _showLogoutConfirmationDialogWithCheckbox(context);
    }
  }

  static void _showLogoutConfirmationDialog(BuildContext context) {
    showCustomAlertDialog(
      context,
      title: 'Check Out Reminder',
      titleHeight: 68,
      content: Container(
        height: 100,
        child: Padding(
          padding: const EdgeInsets.only(top: 15.0),
          child: Text(
            'You have not checked out your attendance. Do you still want to log out of your account?',
            style: TextStyle(fontSize: 15),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text('Cancel'),
        ),
        TextButton(
          style: TextButton.styleFrom(backgroundColor: Colors.green),
          onPressed: () {
            Navigator.of(context).pop();
            _showLogoutConfirmationDialogWithCheckbox(context);
          },
          child: Text(
            'Logout Anyway',
            style: TextStyle(color: Colors.white),
          ),
        ),
      ],
      isFullScreen: false
    );
  }


  static void _showLogoutConfirmationDialogWithCheckbox(BuildContext context) {
    bool logoutFromAllDevices = false;

    showCustomAlertDialog(
      context,
      title: 'Logout Confirmation',
        titleHeight: 68,
        content: StatefulBuilder(
        builder: (BuildContext context, StateSetter setState) {
          return Column(
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
          );
        },
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text('Cancel'),
        ),
        TextButton(
          style: TextButton.styleFrom(backgroundColor: Colors.green),
          onPressed: () {
            Navigator.of(context).pop();
            _performLogout(context, logoutFromAllDevices: logoutFromAllDevices);
          },
          child: Text(
            'Logout',
            style: TextStyle(color: Colors.white),
          ),
        ),
      ],
        isFullScreen: false

    );
  }

  static Future<void> _performLogout(BuildContext context,
      {bool logoutFromAllDevices = false}) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    int? userId = prefs.getInt('user_Id');
    String? token = prefs.getString('token');

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
          tokenRequired: true);

      if (response['statusCode'] == 200) {
        print(response);
        await prefs.remove('user_Id');
        await prefs.remove('user_Name');
        await prefs.remove('role_Id');
        await prefs.remove('role_Name');
        await prefs.remove('token');
        MenuDataHolder().menuData.clear();
        MenuDataHolder().isMenuDataLoaded = false;

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => LoginScreen()),
        );
        Fluttertoast.showToast(
            msg: response['message'] ?? "Logged out successfully",
            backgroundColor: Colors.green);
      } else {
        Fluttertoast.showToast(
            msg: response['message'] ?? 'Error logging out.');
        print(response['message']);
      }
    } else {
      print('Error: User ID or token is null during logout.');
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => LoginScreen()),
      );
    }
  }
}