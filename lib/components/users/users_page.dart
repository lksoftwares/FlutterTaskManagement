import 'package:lktaskmanagementapp/packages/headerfiles.dart';

class UsersPage extends StatefulWidget {
  const UsersPage({super.key});

  @override
  State<UsersPage> createState() => _UsersPageState();
}

class _UsersPageState extends State<UsersPage> {
  List<Map<String, dynamic>> users = [];
  bool isLoading = false;
  String? roleName;
  String? token;
  String? selectedUserName;

  @override
  void initState() {
    super.initState();
    fetchUsers();
    _getsharedpref();
  }
  Future<void> _getsharedpref() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      roleName = prefs.getString('role_Name');
      token = prefs.getString('token');

    });
  }
  Future<void> fetchUsers() async {
    setState(() {
      isLoading = true;
    });

    SharedPreferences prefs = await SharedPreferences.getInstance();
    int? userId = prefs.getInt('user_Id');
    String roleName = prefs.getString('role_Name') ?? "";
    String endpoint = 'Working/GetWorking';

    if (roleName == 'Admin') {
      endpoint = 'User/';
    } else if (userId != null) {
      endpoint = 'User/GetAllUsers?userId=$userId';
    }
    final response = await ApiService().request(
        method: 'get',
        endpoint:endpoint,
        tokenRequired: true
    );

    if (response['statusCode'] == 200 && response['apiResponse'] != null) {
      setState(() {
        users = List<Map<String, dynamic>>.from(
          response['apiResponse'].map((user) => {
            'userId': user['userId'] ?? 0,
            'userName': user['userName'] ?? 'Unknown user',
            'userEmail': user['userEmail'] ?? 'Unknown user',
            'userPassword': user['userPassword'] ?? 'Unknown user',
            'userStatus': user['userStatus'] ?? false,
            'createdAt': user['createdAt'] ?? '',
            'updatedAt': user['updatedAt'] ?? '',
          }),
        );
      });
    } else {
      showToast(msg: response['message'] ?? 'Failed to load users');
    }
    setState(() {
      isLoading = false;
    });
  }

  Future<void> _addUser(String userName, String userEmail, String userPassword) async {
    if (token == null || token!.isEmpty) {
      showToast(msg: 'Token not found');
      return;
    }

    final response = await ApiService().request(
        method: 'post',
        endpoint: 'User/create',
        body: {
          'userName': userName,
          'userEmail': userEmail,
          'userPassword': userPassword,
        },
        isMultipart: true,
        tokenRequired: true
    );

    if (response.isNotEmpty && response['statusCode'] == 200) {
      fetchUsers();
      showToast(
        msg: response['message'] ?? 'User added successfully',
        backgroundColor: Colors.green,
      );
      Navigator.pop(context);
    }

    else {
      showToast(msg: response['message'] ?? 'Failed to add user');
    }
  }

  Future<void> _updateUser(int userId, String userName, String userEmail, String userPassword) async {
    if (token == null || token!.isEmpty) {
      showToast(msg: 'Token not found');
      return;
    }
    final response = await ApiService().request(
        method: 'post',
        endpoint: 'User/update',
        body: {
          'userId': userId,
          'userName': userName,
          'userEmail': userEmail,
          'userPassword': userPassword,
          'updateFlag': true,
        },
        isMultipart: true,
        tokenRequired: true
    );

    if (response.isNotEmpty && response['statusCode'] == 200) {
      fetchUsers();
      showToast(
        msg: response['message'] ?? 'User updated successfully',
        backgroundColor: Colors.green,
      );
      Navigator.pop(context);
    } else {
      showToast(msg: response['message'] ?? 'Failed to update user');
    }
  }

  void _showUserForm({int? userId, String? userName, String? userEmail, String? userPassword}) {
    TextEditingController nameController = TextEditingController(text: userName);
    TextEditingController emailController = TextEditingController(text: userEmail);
    TextEditingController passwordController = TextEditingController(text: userPassword);
    Uint8List? fingerprintData;
    showCustomAlertDialog(
      context,
      title: userId == null ? 'Add User' : 'Edit User',
      content: Container(
        height: 280,
        child: SingleChildScrollView(
          child: Column(
            children: [
              TextField(controller: nameController, decoration: InputDecoration(labelText: 'Username',border: OutlineInputBorder())),
              SizedBox(height: 15,),
              TextField(controller: emailController, decoration: InputDecoration(labelText: 'Email',border: OutlineInputBorder())),
              SizedBox(height: 15,),
              TextField(controller: passwordController, decoration: InputDecoration(labelText: 'Password',border: OutlineInputBorder())),
              SizedBox(height: 15,),
              IconButton(
                icon: Icon(Icons.fingerprint, color: Colors.blue, size: 35),
                onPressed: () async {
                  bool isAuthenticated = await AuthServices().authenticateLocally();
                  if (isAuthenticated) {
                    fingerprintData = await AuthServices().getFingerprintBytes();
                    if (fingerprintData != null ) {
                      showToast(msg: 'Authentication Successful', backgroundColor: Colors.green);
                      print(fingerprintData);
                    } else {
                      showToast(msg: 'Failed to retrieve fingerprint data', backgroundColor: Colors.red);
                    }
                  } else {
                    showToast(msg: 'Authentication Failed', backgroundColor: Colors.red);
                  }
                },
              ),
            ],
          ),
        ),
      ),
      actions: [
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.green,
          ),
          onPressed: () {
            if (nameController.text.isEmpty || emailController.text.isEmpty || passwordController.text.isEmpty) {
              showToast(msg: 'Please fill all fields');
              return;
            }
            if (userId == null) {
              _addUser(nameController.text, emailController.text, passwordController.text);
            } else {
              _updateUser(userId, nameController.text, emailController.text, passwordController.text);
            }
          },
          child: Text(userId == null ? 'Add' : 'Update', style: TextStyle(color: Colors.white)),
        ),
        TextButton(onPressed: () => Navigator.pop(context), child: Text('Cancel')),
      ],
      titleHeight: 65,
    );
  }

  void _confirmDeleteRole(int userId) {
    showCustomAlertDialog(
      context,
      title: 'Delete User',
      content: Text('Are you sure you want to delete this user?'),
      actions: [

        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.red,
          ),
          onPressed: () {
            _deleteUser(userId);
            Navigator.pop(context);
          },
          child: Text('Delete',style: TextStyle(color: Colors.white),),
        ),
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text('Cancel'),
        ),
      ],
      titleHeight: 65,

    );
  }

  Future<void> _deleteUser(int userId) async {
    if (token == null || token!.isEmpty) {
      showToast(msg: 'Token not found');
      return;
    }
    final response = await new ApiService().request(
        method: 'post',
        endpoint: 'User/delete/$userId',
        tokenRequired: true
    );
    if (response['statusCode'] == 200) {
      String message = response['message'] ?? 'User deleted successfully';
      showToast(msg: message, backgroundColor: Colors.green);
      fetchUsers();
    } else if(response['statusCode'] == 208){
      showToast(
        msg: response['message'] ?? 'User deleted successfully',
      );
    }else {
      String message = response['message'] ?? 'Failed to delete User';
      showToast(msg: message);
    }
  }

  List<Map<String, dynamic>> getFilteredData() {
    return users.where((user) {
      bool matchesUserName = true;
      if (selectedUserName != null && selectedUserName!.isNotEmpty) {
        matchesUserName = user['roleName'] == selectedUserName;
      }
      return matchesUserName;
    }).toList();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: 'Users',
        onLogout: () => AuthService.logout(context),
      ),
      body: RefreshIndicator(
        onRefresh: fetchUsers,
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: [
                SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [

                    IconButton(
                      icon: Icon(Icons.add_circle, color: Colors.blue, size: 30),
                      onPressed: () => _showUserForm(),
                    ),
                  ],
                ),

                SizedBox(height: 20),
                if (isLoading)
                  Center(child: CircularProgressIndicator())
                else if (users.isEmpty)
                  NoDataFoundScreen()
                else
                  Column(
                    children: users.map((user) {
                      Map<String, dynamic> roleFields = {
                        'User Name': user['userName'],
                        '': user[''],
                        'UserStatus': user['userStatus'] ?? false,
                        'userEmail': user['userEmail'],
                        'Password: ': user['userPassword'],
                        'CreatedAt': user['createdAt'],
                      };

                      bool isAdmin = roleName == 'Admin';

                      return buildUserCard(
                        userFields: roleFields,
                        trailingIcon: Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            if (isAdmin)
                              IconButton(
                                onPressed: () => _showUserForm(
                                  userId: user['userId'],
                                  userName: user['userName'],
                                  userEmail: user['userEmail'],
                                  userPassword: user['userPassword'],
                                ),
                                icon: Icon(Icons.edit, color: Colors.green),
                              ),
                            IconButton(
                              onPressed: () => _confirmDeleteRole(user['userId']),
                              icon: Icon(Icons.delete, color: Colors.red),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
// import 'package:lktaskmanagementapp/packages/headerfiles.dart';
// import 'package:encrypt/encrypt.dart' as encrypt;
//
// class UsersPage extends StatefulWidget {
//   const UsersPage({super.key});
//
//   @override
//   State<UsersPage> createState() => _UsersPageState();
// }
//
// class _UsersPageState extends State<UsersPage> {
//   List<Map<String, dynamic>> users = [];
//   bool isLoading = false;
//   String? roleName;
// String? token;
//   String? selectedUserName;
//
//   @override
//   void initState() {
//     super.initState();
//     fetchUsers();
//     _getsharedpref();
//   }
//   Future<void> _getsharedpref() async {
//     SharedPreferences prefs = await SharedPreferences.getInstance();
//     setState(() {
//       roleName = prefs.getString('role_Name');
//       token = prefs.getString('token');
//
//     });
//   }
//   Future<void> fetchUsers() async {
//     setState(() {
//       isLoading = true;
//     });
//
//     SharedPreferences prefs = await SharedPreferences.getInstance();
//     int? userId = prefs.getInt('user_Id');
//     String roleName = prefs.getString('role_Name') ?? "";
//     String endpoint = 'Working/GetWorking';
//
//     if (roleName == 'Admin') {
//       endpoint = 'User/';
//     } else if (userId != null) {
//       endpoint = 'User/GetAllUsers?userId=$userId';
//     }
//     final response = await ApiService().request(
//       method: 'get',
//       endpoint:endpoint,
//       tokenRequired: true
//     );
//
//     if (response['statusCode'] == 200 && response['apiResponse'] != null) {
//       setState(() {
//         users = List<Map<String, dynamic>>.from(
//           response['apiResponse'].map((user) => {
//             'userId': user['userId'] ?? 0,
//             'userName': user['userName'] ?? 'Unknown user',
//             'userEmail': user['userEmail'] ?? 'Unknown user',
//             'userPassword': user['userPassword'] ?? 'Unknown user',
//             'userStatus': user['userStatus'] ?? false,
//             'createdAt': user['createdAt'] ?? '',
//             'updatedAt': user['updatedAt'] ?? '',
//           }),
//         );
//       });
//     } else {
//       showToast(msg: response['message'] ?? 'Failed to load users');
//     }
//     setState(() {
//       isLoading = false;
//     });
//   }
//   Future<String> _getEncryptedFingerprint() async {
//     try {
//       final plainText = 'sampleFingerprintData';
//       final key = encrypt.Key.fromUtf8('1234567890123456');
//       final fixedIv = encrypt.IV.fromUtf8('thisisafixediv');
//
//       final encrypter = encrypt.Encrypter(encrypt.AES(key));
//       final encrypted = encrypter.encrypt(plainText, iv: fixedIv);
//
//       return encrypted.base64;
//     } catch (e) {
//       print("Error during fingerprint encryption: $e");
//       return '';
//     }
//   }
//   Future<void> _addUser(String userName, String userEmail, String userPassword, Uint8List? fingerprintData) async {
//     if (token == null || token!.isEmpty) {
//       showToast(msg: 'Token not found');
//       return;
//     }
//     String encryptedFingerprint = await _getEncryptedFingerprint();
// print("shreya$encryptedFingerprint");
//     final response = await ApiService().request(
//       method: 'post',
//       endpoint: 'User/create',
//       body: {
//         'userName': userName,
//         'userEmail': userEmail,
//         'userPassword': userPassword,
//         'fingerLock': encryptedFingerprint,
//       },
//       isMultipart: true,
//       tokenRequired: true
//     );
//
//     if (response.isNotEmpty && response['statusCode'] == 200) {
//       fetchUsers();
//       showToast(
//         msg: response['message'] ?? 'User added successfully',
//         backgroundColor: Colors.green,
//       );
//       Navigator.pop(context);
//     }
//
//       else {
//       showToast(msg: response['message'] ?? 'Failed to add user');
//     }
//   }
//
//   Future<void> _updateUser(int userId, String userName, String userEmail, String userPassword) async {
//     if (token == null || token!.isEmpty) {
//       showToast(msg: 'Token not found');
//       return;
//     }
//     final response = await ApiService().request(
//       method: 'post',
//       endpoint: 'User/update',
//       body: {
//         'userId': userId,
//         'userName': userName,
//         'userEmail': userEmail,
//         'userPassword': userPassword,
//         'updateFlag': true,
//       },
//       isMultipart: true,
//       tokenRequired: true
//     );
//
//     if (response.isNotEmpty && response['statusCode'] == 200) {
//       fetchUsers();
//       showToast(
//         msg: response['message'] ?? 'User updated successfully',
//         backgroundColor: Colors.green,
//       );
//       Navigator.pop(context);
//     } else {
//       showToast(msg: response['message'] ?? 'Failed to update user');
//     }
//   }
//
//   void _showUserForm({int? userId, String? userName, String? userEmail, String? userPassword}) {
//     TextEditingController nameController = TextEditingController(text: userName);
//     TextEditingController emailController = TextEditingController(text: userEmail);
//     TextEditingController passwordController = TextEditingController(text: userPassword);
//     Uint8List? fingerprintData;
//     showCustomAlertDialog(
//       context,
//       title: userId == null ? 'Add User' : 'Edit User',
//       content: Container(
//         height: 280,
//         child: SingleChildScrollView(
//           child: Column(
//             children: [
//               TextField(controller: nameController, decoration: InputDecoration(labelText: 'Username',border: OutlineInputBorder())),
//               SizedBox(height: 15,),
//               TextField(controller: emailController, decoration: InputDecoration(labelText: 'Email',border: OutlineInputBorder())),
//               SizedBox(height: 15,),
//               TextField(controller: passwordController, decoration: InputDecoration(labelText: 'Password',border: OutlineInputBorder())),
//               SizedBox(height: 15,),
//               IconButton(
//                 icon: Icon(Icons.fingerprint, color: Colors.blue, size: 35),
//                 onPressed: () async {
//                   bool isAuthenticated = await AuthServices().authenticateLocally();
//                   if (isAuthenticated) {
//                     fingerprintData = await AuthServices().getFingerprintBytes();
//                     if (fingerprintData != null ) {
//                       showToast(msg: 'Authentication Successful', backgroundColor: Colors.green);
//                       print(fingerprintData);
//                     } else {
//                       showToast(msg: 'Failed to retrieve fingerprint data', backgroundColor: Colors.red);
//                     }
//                   } else {
//                     showToast(msg: 'Authentication Failed', backgroundColor: Colors.red);
//                   }
//                 },
//               ),
//             ],
//           ),
//         ),
//       ),
//       actions: [
//         ElevatedButton(
//           style: ElevatedButton.styleFrom(
//             backgroundColor: Colors.green,
//           ),
//           onPressed: () {
//             if (nameController.text.isEmpty || emailController.text.isEmpty || passwordController.text.isEmpty) {
//               showToast(msg: 'Please fill all fields');
//               return;
//             }
//             if (userId == null) {
//               _addUser(nameController.text, emailController.text, passwordController.text, fingerprintData);
//             } else {
//               _updateUser(userId, nameController.text, emailController.text, passwordController.text);
//             }
//           },
//           child: Text(userId == null ? 'Add' : 'Update', style: TextStyle(color: Colors.white)),
//         ),
//         TextButton(onPressed: () => Navigator.pop(context), child: Text('Cancel')),
//       ],
//       titleHeight: 65,
//     );
//   }
//
//   void _confirmDeleteRole(int userId) {
//     showCustomAlertDialog(
//       context,
//       title: 'Delete User',
//       content: Text('Are you sure you want to delete this user?'),
//       actions: [
//
//         ElevatedButton(
//           style: ElevatedButton.styleFrom(
//             backgroundColor: Colors.red,
//           ),
//           onPressed: () {
//             _deleteUser(userId);
//             Navigator.pop(context);
//           },
//           child: Text('Delete',style: TextStyle(color: Colors.white),),
//         ),
//         TextButton(
//           onPressed: () => Navigator.pop(context),
//           child: Text('Cancel'),
//         ),
//       ],
//       titleHeight: 65,
//
//     );
//   }
//
//   Future<void> _deleteUser(int userId) async {
//     if (token == null || token!.isEmpty) {
//       showToast(msg: 'Token not found');
//       return;
//     }
//     final response = await new ApiService().request(
//       method: 'post',
//       endpoint: 'User/delete/$userId',
//       tokenRequired: true
//     );
//     if (response['statusCode'] == 200) {
//       String message = response['message'] ?? 'User deleted successfully';
//       showToast(msg: message, backgroundColor: Colors.green);
//       fetchUsers();
//     } else if(response['statusCode'] == 208){
//       showToast(
//         msg: response['message'] ?? 'User deleted successfully',
//       );
//     }else {
//       String message = response['message'] ?? 'Failed to delete User';
//       showToast(msg: message);
//     }
//   }
//
//   List<Map<String, dynamic>> getFilteredData() {
//     return users.where((user) {
//       bool matchesUserName = true;
//       if (selectedUserName != null && selectedUserName!.isNotEmpty) {
//         matchesUserName = user['roleName'] == selectedUserName;
//       }
//       return matchesUserName;
//     }).toList();
//   }
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: CustomAppBar(
//         title: 'Users',
//         onLogout: () => AuthService.logout(context),
//       ),
//       body: RefreshIndicator(
//         onRefresh: fetchUsers,
//         child: SingleChildScrollView(
//           child: Padding(
//             padding: const EdgeInsets.all(8.0),
//             child: Column(
//               children: [
//                 SizedBox(height: 20),
//                 Row(
//                   mainAxisAlignment: MainAxisAlignment.end,
//                   children: [
//                     Autocomplete<String>(
//                       optionsBuilder: (TextEditingValue textEditingValue) {
//                         return users
//                             .where((user) => user['userName']!
//                             .toLowerCase()
//                             .contains(textEditingValue.text.toLowerCase()))
//                             .map((user) => user['userName'] as String)
//                             .toList();
//                       },
//                       onSelected: (String roleName) {
//                         setState(() {
//                           selectedUserName = roleName;
//                         });
//                         fetchUsers();
//                       },
//                       fieldViewBuilder: (context, controller, focusNode, onFieldSubmitted) {
//                         return Container(
//                           width: 280,
//                           child: TextField(
//                             controller: controller,
//                             focusNode: focusNode,
//                             decoration: InputDecoration(
//                               labelText: 'Select Role',
//                               border: OutlineInputBorder(
//                                 borderRadius: BorderRadius.circular(10),
//                               ),
//                               prefixIcon: Icon(Icons.person),
//                             ),
//                             onChanged: (value) {
//                               if (value.isEmpty) {
//                                 setState(() {
//                                   selectedUserName = null;
//                                 });
//                                 fetchUsers();
//                               }
//                             },
//                           ),
//                         );
//                       },
//                     ),
//                     IconButton(
//                       icon: Icon(Icons.add_circle, color: Colors.blue, size: 30),
//                       onPressed: () => _showUserForm(),
//                     ),
//                   ],
//                 ),
//
//                 SizedBox(height: 20),
//                 if (isLoading)
//                   Center(child: CircularProgressIndicator())
//                 else if (users.isEmpty)
//                   NoDataFoundScreen()
//                 else
//                   Column(
//                     children: users.map((user) {
//                       Map<String, dynamic> roleFields = {
//                         'User Name': user['userName'],
//                         '': user[''],
//                         'UserStatus': user['userStatus'] ?? false,
//                         'userEmail': user['userEmail'],
//                         'Password: ': user['userPassword'],
//                         'CreatedAt': user['createdAt'],
//                       };
//
//                       bool isAdmin = roleName == 'Admin';
//
//                       return buildUserCard(
//                         userFields: roleFields,
//                         trailingIcon: Row(
//                           mainAxisAlignment: MainAxisAlignment.end,
//                           children: [
//                             if (isAdmin)
//                               IconButton(
//                                 onPressed: () => _showUserForm(
//                                   userId: user['userId'],
//                                   userName: user['userName'],
//                                   userEmail: user['userEmail'],
//                                   userPassword: user['userPassword'],
//                                 ),
//                                 icon: Icon(Icons.edit, color: Colors.green),
//                               ),
//                             IconButton(
//                               onPressed: () => _confirmDeleteRole(user['userId']),
//                               icon: Icon(Icons.delete, color: Colors.red),
//                             ),
//                           ],
//                         ),
//                       );
//                     }).toList(),
//                   )
//
//
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }