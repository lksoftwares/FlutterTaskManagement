import 'package:lktaskmanagementapp/packages/headerfiles.dart';

class AuthService {
  static Future<void> logout(BuildContext context) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool hasCheckedIn = prefs.getBool('hasCheckedIn') ?? false;
    bool hasCheckedOut = prefs.getBool('hasCheckedOut') ?? false;

    if (hasCheckedIn && !hasCheckedOut) {
      _showLogoutConfirmationDialog(context);
    } else {
      _performLogout(context);
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
          actions: <Widget>[
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
                _performLogout(context);
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

  static Future<void> _performLogout(BuildContext context) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove('user_Id');
    await prefs.remove('user_Name');
    await prefs.remove('role_Name');
    await prefs.remove('role_Id');
    MenuDataHolder().menuData.clear();
    MenuDataHolder().isMenuDataLoaded = false;

    showToast(msg: "Logged out successfully", backgroundColor: Colors.green);

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => LoginScreen()),
          (route) => false,
    );
  }
}
