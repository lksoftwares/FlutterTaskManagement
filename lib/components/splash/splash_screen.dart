import 'package:flutter/material.dart';
import 'package:lktaskmanagementapp/packages/headerfiles.dart';
import 'package:shared_preferences/shared_preferences.dart';


class SplashScreen extends StatefulWidget {
  @override
  State<SplashScreen> createState() => SplashScreenState();
}

class SplashScreenState extends State<SplashScreen> {
  String appVersion = '';

  @override
  void initState() {
    super.initState();
    _getAppVersion();
    _checkLoginStatus();
  }

  Future<void> _getAppVersion() async {
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    setState(() {
      appVersion = packageInfo.version;
    });
  }

  // Check if the user is logged in
  Future<void> _checkLoginStatus() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    int? userId = prefs.getInt('user_Id');

    // Simulate a delay for splash screen appearance
    Timer(Duration(seconds: 3), () {
      if (userId != null) {
        // User is already logged in, navigate to Dashboard
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => DashboardScreen()),
        );
      } else {
        // User is not logged in, navigate to Login screen
        Navigator.pushReplacementNamed(context, '/login');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        color: primaryColor, // Replace with your actual primary color
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Image.asset(
                'images/Logo.png',
                width: 135,
                height: 135,
              ),
              SizedBox(height: 10),
              Text(
                "Task Management",
                style: TextStyle(
                  fontSize: 27,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                ),
              ),
              SizedBox(height: 5),
              Center(
                child: Text(
                  "Real-time Maintenance, and Seamless reporting for Tasks",
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.white70,
                  ),
                ),
              ),
              SizedBox(height: 20),
              Text(
                'Version: $appVersion',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.white70,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
