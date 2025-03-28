import 'package:lktaskmanagementapp/packages/headerfiles.dart';


class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  TextEditingController usernameController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  Map<String, dynamic>? selectedRole;
  List<Map<String, dynamic>> roles = [];
  bool isLoading = true;
  bool _obscurePassword = true;


  @override
  void initState() {
    super.initState();
    fetchRoles();
  }

  Future<String> getDeviceId() async {
    final deviceInfoPlugin = DeviceInfoPlugin();
    SharedPreferences prefs = await SharedPreferences.getInstance();
    const uuid = Uuid();
    String deviceId = prefs.getString('deviceId') ?? '';

    if (deviceId.isEmpty) {
      try {
        if (Platform.isAndroid) {
          final androidInfo = await deviceInfoPlugin.androidInfo;
          deviceId = uuid.v4();
        } else if (Platform.isIOS) {
          final iosInfo = await deviceInfoPlugin.iosInfo;
          deviceId = iosInfo.identifierForVendor ?? uuid.v4();
        }
      } catch (e) {
        print("Error fetching generating device ID: $e");
        deviceId = uuid.v4();
      }
      await prefs.setString('deviceId', deviceId);
    }
    return deviceId;
  }

  Future<void> fetchRoles() async {
    final response = await ApiService().request(
      method: 'GET',
      endpoint: 'Roles/GetAllRole',
    );

    if (response['statusCode'] == 200) {
      List<Map<String, dynamic>> fetchedRoles = [];
      for (var role in response['apiResponse']) {
        fetchedRoles.add({
          'roleId': role['roleId'],
          'roleName': role['roleName'],
        });
      }

      setState(() {
        roles = fetchedRoles;
        isLoading = false;
      });
    } else {
      showToast(msg: 'Failed to load roles');
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> loginUser() async {
    String username = usernameController.text;
    String password = passwordController.text;

    if (username.isNotEmpty && password.isNotEmpty && selectedRole != null) {
      String deviceId = await getDeviceId();

      Map<String, dynamic> requestBody = {
        "userEmail": username,
        "userPassword": password,
        "roleId": selectedRole!['roleId'],
        "deviceId": deviceId,
      };

      final response = await ApiService().request(
        method: 'POST',
        endpoint: 'User/Login',
        body: requestBody,
      );

      if (response['statusCode'] == 200) {
        print(response);
        int user_Id = response['apiResponse']['user_Id'];
        int role_Id = response['apiResponse']['role_Id'];
        String user_Name = response['apiResponse']['user_Name'];
        String role_Name = response['apiResponse']['role_Name'];
        String token = response['apiResponse']['token'];

        SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setInt('user_Id', user_Id);
        await prefs.setInt('role_Id', role_Id);
        await prefs.setString('user_Name', user_Name);
        await prefs.setString('role_Name', role_Name);
        await prefs.setString('token', token);
        showToast(msg: response['message'] ?? 'Login successfully',
            backgroundColor: Colors.green);
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => DashboardScreen()),
        );
      } else {
        showToast(msg: 'Login Failed: ${response['message']}');
      }
    } else {
      showToast(msg: 'Please fill all fields');
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: "Login",
      ),
      body: Stack(
        children: [
          Container(
            width: double.infinity,
            height: MediaQuery.of(context).size.height,
            child: Image.asset(
              'images/Login8.jpg',
              fit: BoxFit.cover,
            ),
          ),
          SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Center(
                child: Column(
                  children: [
                    Image.asset(
                      'images/Logo.png',
                      width: 120,
                      height: 120,
                    ),
                    SizedBox(height: 20),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        if (isLoading)
                          CircularProgressIndicator(),
                        if (!isLoading) ...[
                          CustomDropdown<String>(
                            options: roles.map(
                                  (role) => role['roleName'] as String,
                            ).toList(),
                            selectedOption: selectedRole?['roleName'],
                            displayValue: (roleName) => roleName,
                            onChanged: (roleName) {
                              setState(() {
                                selectedRole = roles.firstWhere(
                                        (role) => role['roleName'] == roleName);
                              });
                            },
                            labelText: 'Select Role',
                            prefixIcon: Icon(Icons.person),
                            width: 320,
                          ),
                          SizedBox(height: 20),
                          // Username TextField
                          CustomTextField(
                            controller: usernameController,
                            label: 'Username',
                            hintText: 'Enter your username',
                            prefixIcon: Icon(Icons.people_alt_outlined),
                          ),
                          SizedBox(height: 10),
                          // Password TextField
                          CustomTextField(
                            controller: passwordController,
                            label: 'Password',
                            hintText: 'Enter your password',
                            obscureText: _obscurePassword,
                            prefixIcon: Icon(Icons.lock),
                            maxLines: 1,
                            suffixIcon: Icon(
                              _obscurePassword
                                  ? Icons.visibility_off
                                  : Icons.visibility,
                            ),
                            onSuffixIconPressed: () {
                              setState(() {
                                _obscurePassword = !_obscurePassword;
                              });
                            },
                          ),
                          SizedBox(height: 15),
                          CustomButton(
                            buttonText: 'Login',
                            onPressed: loginUser,
                            color: primaryColor,
                            width: 170,
                          ),

                        ],
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

