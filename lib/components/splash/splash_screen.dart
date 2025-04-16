import 'package:lktaskmanagementapp/packages/headerfiles.dart';

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
    _navigateWithDelay();
  }

  Future<void> _getAppVersion() async {
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    setState(() {
      appVersion = packageInfo.version;
    });
  }

  Future<void> _navigateWithDelay() async {
    await Future.delayed(Duration(seconds: 5));
    _checkLoginStatus();
  }

  Future<void> _checkLoginStatus() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    int? userId = prefs.getInt('user_Id');
    if (userId != null) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => DashboardScreen()),
      );
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => LoginScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
   return Scaffold(
        body: Container(
          color: Colors.blue.shade900,
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
                    textAlign: TextAlign.center,
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
                SizedBox(height: 20),
              ],
            ),
          ),
        ),
      );
    }
 }


// import 'dart:io';
// import 'package:encrypt/encrypt.dart' as encrypt;
// import 'package:lktaskmanagementapp/packages/headerfiles.dart';
//
// class SplashScreen extends StatefulWidget {
//   @override
//   State<SplashScreen> createState() => SplashScreenState();
// }
//
// class SplashScreenState extends State<SplashScreen> {
//   String appVersion = '';
//   final LocalAuthentication _localAuth = LocalAuthentication();
//
//   @override
//   void initState() {
//     super.initState();
//     _getAppVersion();
//     _authenticateUser();
//   }
//
//   Future<void> _getAppVersion() async {
//     PackageInfo packageInfo = await PackageInfo.fromPlatform();
//     setState(() {
//       appVersion = packageInfo.version;
//     });
//   }
//
//   Future<void> _authenticateUser() async {
//     bool isAuthenticated = await _authenticateWithFingerprint();
//     if (isAuthenticated) {
//       await Future.delayed(Duration(seconds: 2));
//       _checkLoginStatus();
//     } else {
//       _showLockScreenDialog();
//     }
//   }
//
//   Future<bool> _authenticateWithFingerprint() async {
//     bool canAuthenticate = await _localAuth.canCheckBiometrics;
//     if (canAuthenticate) {
//       try {
//         bool authenticated = await _localAuth.authenticate(
//           localizedReason: 'Please authenticate to continue',
//           options: AuthenticationOptions(
//             useErrorDialogs: true,
//             stickyAuth: true,
//           ),
//         );
//
//         if (authenticated) {
//           String encryptedFingerprint = await _getEncryptedFingerprint();
//           print("Encrypted Fingerprint: $encryptedFingerprint");
//           return true;
//         }
//       } catch (e) {
//         print("Error during fingerprint authentication: $e");
//       }
//     }
//     return false;
//   }
//
//   Future<String> _getEncryptedFingerprint() async {
//     final plainText = 'sampleFingerprintData';
//     final key = encrypt.Key.fromUtf8('1234567890123456');
//     final iv = encrypt.IV.fromLength(16);
//
//     final encrypter = encrypt.Encrypter(encrypt.AES(key));
//     final encrypted = encrypter.encrypt(plainText, iv: iv);
//
//     return encrypted.base64;
//   }
//
//   Future<void> _checkLoginStatus() async {
//     SharedPreferences prefs = await SharedPreferences.getInstance();
//     int? userId = prefs.getInt('user_Id');
//     if (userId != null) {
//       Navigator.pushReplacement(
//         context,
//         MaterialPageRoute(builder: (context) => DashboardScreen()),
//       );
//     } else {
//       Navigator.pushReplacement(
//         context,
//         MaterialPageRoute(builder: (context) => LoginScreen()),
//       );
//     }
//   }
//
//   Future<void> _showLockScreenDialog() async {
//     showDialog(
//       context: context,
//       barrierDismissible: false,
//       builder: (BuildContext context) {
//         return AlertDialog(
//           shape: RoundedRectangleBorder(
//             borderRadius: BorderRadius.circular(20),
//           ),
//           title: Column(
//             children: [
//               Icon(Icons.lock, color: Colors.blue, size: 30),
//               SizedBox(height: 10),
//               Text("LkTaskManagement is locked",
//                   style: TextStyle(fontWeight: FontWeight.bold)),
//             ],
//           ),
//           content: Text(
//             "For your security, you can only use this app when it’s unlocked.",
//           ),
//           actions: [
//             TextButton(
//               onPressed: () => exit(0),
//               child: Text("Cancel", style: TextStyle(color: primaryColor)),
//             ),
//             TextButton(
//               onPressed: () {
//                 Navigator.pop(context);
//                 _authenticateUser();
//               },
//               child: Text("Unlock", style: TextStyle(color: primaryColor)),
//             ),
//           ],
//         );
//       },
//     );
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return WillPopScope(
//       onWillPop: () async {
//         _showLockScreenDialog();
//         return false;
//       },
//       child: Scaffold(
//         body: Container(
//           color: Colors.blue.shade900,
//           child: Center(
//             child: Column(
//               mainAxisAlignment: MainAxisAlignment.center,
//               children: <Widget>[
//                 Image.asset(
//                   'images/Logo.png',
//                   width: 135,
//                   height: 135,
//                 ),
//                 SizedBox(height: 10),
//                 Text(
//                   "Task Management",
//                   style: TextStyle(
//                     fontSize: 27,
//                     fontWeight: FontWeight.w800,
//                     color: Colors.white,
//                   ),
//                 ),
//                 SizedBox(height: 5),
//                 Center(
//                   child: Text(
//                     "Real-time Maintenance, and Seamless reporting for Tasks",
//                     textAlign: TextAlign.center,
//                     style: TextStyle(
//                       fontSize: 11,
//                       color: Colors.white70,
//                     ),
//                   ),
//                 ),
//                 SizedBox(height: 20),
//                 Text(
//                   'Version: $appVersion',
//                   style: TextStyle(
//                     fontSize: 12,
//                     color: Colors.white70,
//                   ),
//                 ),
//                 SizedBox(height: 20),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }
// import 'dart:io';
// import 'dart:typed_data';
// import 'package:lktaskmanagementapp/packages/headerfiles.dart';
//
// class SplashScreen extends StatefulWidget {
//   @override
//   State<SplashScreen> createState() => SplashScreenState();
// }
//
// class SplashScreenState extends State<SplashScreen> {
//   String appVersion = '';
//   final LocalAuthentication _localAuth = LocalAuthentication();
//   final Uuid uuid = Uuid();
//
//   @override
//   void initState() {
//     super.initState();
//     _getAppVersion();
//     _authenticateUser();
//   }
//
//   Future<void> _getAppVersion() async {
//     PackageInfo packageInfo = await PackageInfo.fromPlatform();
//     setState(() {
//       appVersion = packageInfo.version;
//     });
//   }
//
//   Future<void> _authenticateUser() async {
//     bool isAuthenticated = await _authenticateWithFingerprint();
//     if (isAuthenticated) {
//       await Future.delayed(Duration(seconds: 2));
//       String deviceId = await _getDeviceId();
//       await _authenticateAndLogin(deviceId);
//     } else {
//       _showLockScreenDialog();
//     }
//   }
//
//   Future<bool> _authenticateWithFingerprint() async {
//     bool canAuthenticate = await _localAuth.canCheckBiometrics;
//     if (canAuthenticate) {
//       try {
//         bool authenticated = await _localAuth.authenticate(
//           localizedReason: 'Please authenticate to continue',
//           options: AuthenticationOptions(
//             useErrorDialogs: true,
//             stickyAuth: true,
//           ),
//         );
//         return authenticated;
//       } catch (e) {
//         return false;
//       }
//     }
//     return false;
//   }
//
//   Future<String> _getDeviceId() async {
//     final deviceInfoPlugin = DeviceInfoPlugin();
//     SharedPreferences prefs = await SharedPreferences.getInstance();
//     String deviceId = prefs.getString('deviceId') ?? '';
//
//     if (deviceId.isEmpty) {
//       try {
//         if (Platform.isAndroid) {
//           final androidInfo = await deviceInfoPlugin.androidInfo;
//           deviceId = uuid.v4();
//         } else if (Platform.isIOS) {
//           final iosInfo = await deviceInfoPlugin.iosInfo;
//           deviceId = iosInfo.identifierForVendor ?? uuid.v4();
//         }
//       } catch (e) {
//         print("Error generating device ID: $e");
//         deviceId = uuid.v4();
//       }
//       await prefs.setString('deviceId', deviceId);
//     }
//     return deviceId;
//   }
//
//   Future<void> _authenticateAndLogin(String deviceId) async {
//     Uint8List? fingerprintData = await AuthServices().getFingerprintBytes();
//     if (fingerprintData != null) {
//
//       Map<String, dynamic> requestBody = {
//         "deviceId": deviceId,
//         "fingerLock": fingerprintData.toString(),
//       };
//
//       final response = await ApiService().request(
//         method: 'POST',
//         endpoint: 'User/Login',
//         body: requestBody,
//       );
//       if (response['statusCode'] == 200) {
//         int user_Id = response['apiResponse']['user_Id'];
//         int role_Id = response['apiResponse']['role_Id'];
//         String user_Name = response['apiResponse']['user_Name'];
//         String role_Name = response['apiResponse']['role_Name'];
//         SharedPreferences prefs = await SharedPreferences.getInstance();
//         await prefs.setInt('user_Id', user_Id);
//         await prefs.setInt('role_Id', role_Id);
//         await prefs.setString('user_Name', user_Name);
//         await prefs.setString('role_Name', role_Name);
//         Navigator.pushReplacement(
//           context,
//           MaterialPageRoute(builder: (context) => DashboardScreen()),
//         );
//       } else {
//         showToast(msg: 'Fingerprint not found');
//         Navigator.pushReplacement(
//           context,
//           MaterialPageRoute(builder: (context) => LoginScreen()),
//         );
//       }
//     } else {
//       showToast(msg: 'Fingerprint authentication failed');
//     }
//   }
//
//   void _showLockScreenDialog() {
//     showDialog(
//       context: context,
//       barrierDismissible: false,
//       builder: (BuildContext context) {
//         return AlertDialog(
//           shape: RoundedRectangleBorder(
//             borderRadius: BorderRadius.circular(20),
//           ),
//           title: Column(
//             children: [
//               Icon(Icons.lock, color: Colors.blue, size: 30),
//               SizedBox(height: 10),
//               Text("LkTaskManagement is locked",
//                   style: TextStyle(fontWeight: FontWeight.bold)),
//             ],
//           ),
//           content: Text(
//             "For your security, you can only use this app when it’s unlocked.",
//           ),
//           actions: [
//             TextButton(
//               onPressed: () => exit(0),
//               child: Text("Cancel", style: TextStyle(color: primaryColor)),
//             ),
//             TextButton(
//               onPressed: () {
//                 Navigator.pop(context);
//                 _authenticateUser();
//               },
//               child: Text("Unlock", style: TextStyle(color: primaryColor)),
//             ),
//           ],
//         );
//       },
//     );
//   }
//
//
//   @override
//   Widget build(BuildContext context) {
//     return WillPopScope(
//       onWillPop: () async {
//         _showLockScreenDialog();
//         return false;
//       },
//       child: Scaffold(
//         body: Container(
//           color: Colors.blue.shade900,
//           child: Center(
//             child: Column(
//               mainAxisAlignment: MainAxisAlignment.center,
//               children: <Widget>[
//                 Image.asset(
//                   'images/Logo.png',
//                   width: 135,
//                   height: 135,
//                 ),
//                 SizedBox(height: 10),
//                 Text(
//                   "Task Management",
//                   style: TextStyle(
//                     fontSize: 27,
//                     fontWeight: FontWeight.w800,
//                     color: Colors.white,
//                   ),
//                 ),
//                 SizedBox(height: 5),
//                 Center(
//                   child: Text(
//                     "Real-time Maintenance, and Seamless reporting for Tasks",
//                     textAlign: TextAlign.center,
//                     style: TextStyle(
//                       fontSize: 11,
//                       color: Colors.white70,
//                     ),
//                   ),
//                 ),
//                 SizedBox(height: 20),
//                 Text(
//                   'Version: $appVersion',
//                   style: TextStyle(
//                     fontSize: 12,
//                     color: Colors.white70,
//                   ),
//                 ),
//                 SizedBox(height: 20),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }
