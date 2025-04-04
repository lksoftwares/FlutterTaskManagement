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
    String endpoint = 'User/';

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

  Future<void> _updateUser(int userId, String userName, String userEmail, String userPassword,bool userStatus) async {
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
          'userStatus': userStatus,
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

  void _showUserForm({int? userId, String? userName, String? userEmail, String? userPassword, bool? userStatus}) {
    TextEditingController nameController = TextEditingController(text: userName);
    TextEditingController emailController = TextEditingController(text: userEmail);
    TextEditingController passwordController = TextEditingController(text: userPassword);
    bool? selectedStatus = userStatus;

    showCustomAlertDialog(
      context,
      title: userId == null ? 'Add User' : 'Edit User',
      content: StatefulBuilder(
          builder: (context, setState) {
            return Padding(
              padding: const EdgeInsets.all(15.0),
              child: Container(
                height: userId == null ? 280 : 350,
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      SizedBox(height: 15,),
                      TextField(
                        controller: nameController,
                        decoration: InputDecoration(
                            labelText: 'Username', border: OutlineInputBorder()),
                      ),
                      SizedBox(height: 18),
                      TextField(
                        controller: emailController,
                        decoration: InputDecoration(
                            labelText: 'Email', border: OutlineInputBorder()),
                      ),
                      SizedBox(height: 18),
                      TextField(
                        controller: passwordController,
                        decoration: InputDecoration(
                            labelText: 'Password', border: OutlineInputBorder()),
                      ),
                      SizedBox(height: 18),
                      if (userId != null)
                        Padding(
                          padding: const EdgeInsets.only(right: 10.0),
                          child: Wrap(
                            spacing: 10.0,
                            runSpacing: 4.0,
                            children: [
                              FilterChip(
                                label: Text(
                                  'Active',
                                  style: TextStyle(
                                    color: selectedStatus == true
                                        ? Colors.white
                                        : Colors
                                        .black,
                                  ),
                                ),
                                selected: selectedStatus == true,
                                onSelected: (bool selected) {
                                  setState(() {
                                    selectedStatus = true;
                                  });
                                },
                                selectedColor: Colors.green,
                                backgroundColor: Colors.grey[200],
                                checkmarkColor: Colors.white,
                              ),
                              FilterChip(
                                label: Text(
                                  'Deactive',
                                  style: TextStyle(
                                    color: selectedStatus == false
                                        ? Colors.white
                                        : Colors
                                        .black,
                                  ),
                                ),
                                selected: selectedStatus == false,
                                onSelected: (bool selected) {
                                  setState(() {
                                    selectedStatus = false;
                                  });
                                },
                                selectedColor: Colors.red,
                                backgroundColor: Colors.grey[200],
                                checkmarkColor: Colors.white,
                              ),
                            ],
                          ),
                        ),

                    ],
                  ),
                ),
              ),
            );
          }
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
              _updateUser(userId, nameController.text, emailController.text, passwordController.text, selectedStatus ?? false);
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
      isFullScreen: false

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
                                    userStatus: user['userStatus']
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
