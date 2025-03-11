import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class InformationMethod extends StatefulWidget {
  const InformationMethod({super.key});

  @override
  State<InformationMethod> createState() => _InformationMethodState();
}

class _InformationMethodState extends State<InformationMethod> {
  String? userName = '';
  String? userRole = '';

  @override
  void initState() {
    super.initState();
    fetchUserData();
  }

  Future<void> fetchUserData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      userName = prefs.getString('user_Name') ?? 'No User';
      userRole = prefs.getString('role_Name') ?? 'No Role';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Row(
        children: [
          Image.asset('images/Logo.png', width: 70, height: 70),
              Text(
                '$userName',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              Text(
                '($userRole)',
                style: TextStyle(fontSize: 15),
              ),

        ],
      ),
    );
  }
}
