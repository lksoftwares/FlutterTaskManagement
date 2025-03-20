




import 'package:lktaskmanagementapp/packages/headerfiles.dart';

class UserroleScreen extends StatefulWidget {
  const UserroleScreen({super.key});

  @override
  State<UserroleScreen> createState() => _UserroleScreenState();
}

class _UserroleScreenState extends State<UserroleScreen> {
  List<Map<String, dynamic>> roles = [];
  String? token;
  List<Map<String, dynamic>> rolesList = [];
  List<Map<String, dynamic>> rolessList = [];

  List<Map<String, dynamic>> usersList = [];
  int? selectedUserId;
  int? selectedRoleId;
  bool isLoading = false;
  int? selectedUserRoleId;

  @override
  void initState() {
    super.initState();
    _getData();
  }

  Future<void> _getData() async {
    await fetchUserRoles();
    await fetchUsers();
    await fetchRoles();
    await fetchRoless();
  }
  Future<void> fetchUsers() async {
    final response = await new ApiService().request(
      method: 'get',
      endpoint: 'User/GetAllUsers',
    );
    if (response['statusCode'] == 200 && response['apiResponse'] != null) {
      setState(() {
        usersList = List<Map<String, dynamic>>.from(response['apiResponse']);
      });
    } else {
      showToast(msg: 'Failed to load users');
    }
  }
  Future<void> fetchRoles() async {
    final response = await new ApiService().request(
      method: 'get',
      endpoint: 'roles/GetAllRole?userId=$selectedUserId',
    );
    print(selectedUserId);
    if (response['statusCode'] == 200 && response['apiResponse'] != null) {
      setState(() {
        rolesList = List<Map<String, dynamic>>.from(response['apiResponse']);
      });
    } else {
      print("");
    }
  }
  Future<void> fetchRoless() async {
    final response = await new ApiService().request(
      method: 'get',
      endpoint: 'roles/GetAllRole',
    );
    print(selectedUserId);
    if (response['statusCode'] == 200 && response['apiResponse'] != null) {
      setState(() {
        rolessList = List<Map<String, dynamic>>.from(response['apiResponse']);
      });
    } else {
      showToast(msg: '');
    }
  }
  Future<void> fetchUserRoles() async {
    setState(() {
      isLoading = true;
    });

    final response = await new ApiService().request(
      method: 'get',
      endpoint: 'roles/GetAllUserRole',
    );

    print('Response: $response');

    if (response['statusCode'] == 200 && response['apiResponse'] != null) {
      setState(() {
        roles = List<Map<String, dynamic>>.from(
          response['apiResponse'].map((user) {
            List<Map<String, dynamic>> userRoles = List<Map<String, dynamic>>.from(user['userRoles'] ?? []);

            List<String> roleNames = [];
            List<int> userRoleIds = [];

            for (var role in userRoles) {
              roleNames.add(role['roleName'] ?? 'No Role');
              userRoleIds.add(role['userRoleId'] ?? 0);
            }

            String rolesString = roleNames.join(', ');
            print(userRoleIds);

            return {
              'userId': user['userId'] ?? 0,
              'userName': user['userName'] ?? 'Unknown user',
              'roleName': rolesString,
              'userRoleIds': userRoleIds,
              'createdAt': user['createdAt'] ?? '',

            };

          }),
        );

      });

    } else {
      showToast(msg: response['message'] ?? '');
    }

    setState(() {
      isLoading = false;
    });
  }



  Future<void> _assignUserRole(int userId, int roleId) async {
    final response = await ApiService().request(
      method: 'post',
      endpoint: 'roles/AddUserRole',
      body: {
        'userId': userId,
        'roleId': roleId,
      },
    );

    if (response['statusCode'] == 200) {
      fetchUserRoles();
      showToast(msg: response['message'] ?? 'Role assigned successfully', backgroundColor: Colors.green);
      Navigator.pop(context);
    } else {
      showToast(msg: response['message'] ?? 'Failed to assign role');
    }
  }

  void _showAddRoleModal() async {
    setState(() {
      selectedUserId = null;
      selectedRoleId = null;
      rolesList.clear();
    });

    await fetchRoles();

    showCustomAlertDialog(
      context,
      title: 'Assign Role',
      content: StatefulBuilder(
        builder: (context, setState) {
          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DropdownButtonFormField<int>(
                decoration: InputDecoration(labelText: 'Select User', border: OutlineInputBorder()),
                items: usersList.map((user) {
                  return DropdownMenuItem<int>(
                    value: user['userId'],
                    child: Text(user['userName']),
                  );
                }).toList(),
                onChanged: (value) async {
                  setState(() {
                    selectedUserId = value;
                    rolesList.clear();
                  });
                  await fetchRoles();
                  setState(() {});
                },
              ),
              SizedBox(height: 10),
              DropdownButtonFormField<int>(
                decoration: InputDecoration(labelText: 'Select Role', border: OutlineInputBorder()),
                items: rolesList.map((role) {
                  return DropdownMenuItem<int>(
                    value: role['roleId'],
                    child: Text(role['roleName']),
                  );
                }).toList(),
                onChanged: (value) => selectedRoleId = value,
              ),
            ],
          );
        },
      ),
      actions: [
        ElevatedButton(
          style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
          onPressed: () {
            if (selectedUserId == null || selectedRoleId == null) {
              showToast(msg: 'Please select both user and role');
              return;
            }
            _assignUserRole(selectedUserId!, selectedRoleId!);
          },
          child: Text('Add', style: TextStyle(color: Colors.white)),
        ),
        TextButton(onPressed: () => Navigator.pop(context), child: Text('Cancel')),

      ],
      titleHeight: 65,

    );
  }

  void _confirmDeleteRole(int userId, int? userRoleId) {
    final user = roles.firstWhere((user) => user['userId'] == userId, orElse: () => {});

    if (user.isEmpty) {
      showToast(msg: 'User not found');
      return;
    }

    List<String> userRoles = (user['roleName'] as String).split(',').map((role) => role.trim()).toList();

    if (userRoleId == null) {
      showToast(msg: 'Role ID is invalid or missing');
      return;
    }
    String selectedRole = userRoles.isNotEmpty ? userRoles[0] : '';

    showCustomAlertDialog(
      context,
      title: 'Delete UserRole',
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('Are you sure you want to delete this Role?'),
          SizedBox(height: 20),
          DropdownButtonFormField<String>(
            decoration: InputDecoration(labelText: 'Select Role to Delete', border: OutlineInputBorder()),
            value: selectedRole,
            items: userRoles.map((role) {
              return DropdownMenuItem<String>(
                value: role,
                child: Text(role),
              );
            }).toList(),
            onChanged: (value) {
              selectedRole = value!;
            },
          ),
        ],
      ),
      actions: [

        ElevatedButton(

          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.red,
          ),
          onPressed: () {
            if (selectedRole.isEmpty) {
              showToast(msg: 'Please select a role to delete');
              return;
            }
            int? selectedRoleId = userRoles.indexOf(selectedRole) != -1 ? userRoleId : null;

            if (selectedRoleId != null) {
              _deleteRole(selectedRoleId);
              Navigator.pop(context);
            } else {
              showToast(msg: 'Selected role is not valid');
            }
          },
          child: Text('Delete',style: TextStyle(color: Colors.white),),
        ),
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text('Cancel'),
        ),
      ],

      titleFontSize: 27.0,
      additionalTitleContent: Padding(
        padding: const EdgeInsets.only(top: 1.0),
        child: Column(
          children: [
            Divider(),
            Text(
              "Username: ${user['userName']}",
              style: TextStyle(
                fontSize: 14.0,
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }


  Future<void> _deleteRole(int userRoleId) async {
    final response = await new ApiService().request(
      method: 'post',
      endpoint: 'roles/DeleteUserRole/$userRoleId',
    );
    if (response['statusCode'] == 200) {
      String message = response['message'] ?? 'Role deleted successfully';
      showToast(msg: message, backgroundColor: Colors.green);
      fetchUserRoles();
    } else {
      String message = response['message'] ?? 'Failed to delete role';
      showToast(msg: message);
    }
  }


  Future<void> _updateUserRole(int userRoleId, int userId, int roleId) async {
    final response = await ApiService().request(
      method: 'post',
      endpoint: 'roles/AddEditUserRole',
      body: {
        'userRoleId': userRoleId,
        'userId': userId,
        'roleId': roleId,
        'updateFlag': true,
      },
    );

    if (response['statusCode'] == 200) {
      fetchUserRoles();
      showToast(msg: response['message'] ?? 'Role updated successfully', backgroundColor: Colors.green);
      Navigator.pop(context);
    } else {
      showToast(msg: response['message'] ?? 'Failed to update role');
    }
  }

  void _showUpdateRoleModal(int userId, int userRoleId, String currentRoleName) {
    final user = roles.firstWhere((user) => user['userId'] == userId, orElse: () => {});

    if (user.isEmpty) {
      showToast(msg: 'User not found');
      return;
    }

    List<String> userRoles = (user['roleName'] as String).split(',').map((role) => role.trim()).toList();


    String selectedRole = userRoles.isNotEmpty ? userRoles[0] : '';
    selectedUserId = userId;
    selectedUserRoleId = userRoleId;

    showCustomAlertDialog(
      context,
      title: 'Update Role',
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          DropdownButtonFormField<int>(
            value: selectedUserId,
            decoration: InputDecoration(labelText: 'Select User', border: OutlineInputBorder()),
            items: usersList.map((user) {
              return DropdownMenuItem<int>(
                value: user['userId'],
                child: Text(user['userName']),
              );
            }).toList(),
            onChanged: (value) => selectedUserId = value,
          ),
          SizedBox(height: 10),
          DropdownButtonFormField<int>(
            decoration: InputDecoration(labelText: 'Select Role', border: OutlineInputBorder()),
            items: rolessList.map((role) {
              return DropdownMenuItem<int>(
                value: role['roleId'],
                child: Text(role['roleName']),
              );
            }).toList(),
            onChanged: (value) => selectedRoleId = value,
          ),
          SizedBox(height: 10),

          DropdownButtonFormField<String>(
            decoration: InputDecoration(labelText: 'Assigned Role', border: OutlineInputBorder()),
            value: selectedRole,
            items: userRoles.map((role) {
              return DropdownMenuItem<String>(
                value: role,
                child: Text(role),
              );
            }).toList(),
            onChanged: (value) {
              selectedRole = value!;
            },
          ),
        ],
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: Text('Cancel')),
        ElevatedButton(

          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.green,
          ),
          onPressed: () {

            if (selectedUserId == null || selectedRoleId == null) {
              showToast(msg: 'Please select both user and role');
              return;
            }
            _updateUserRole(selectedUserRoleId!, selectedUserId!, selectedRoleId!);
          },
          child: Text('Update',style: TextStyle(color: Colors.white),),
        ),
      ],
    );
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: 'UserRole',
        onLogout: () => AuthService.logout(context),
      ),
      body: RefreshIndicator(
        onRefresh: fetchUserRoles,
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
                      onPressed: _showAddRoleModal,
                    ),
                  ],
                ),
                SizedBox(height: 20),
                if (isLoading)
                  Center(child: CircularProgressIndicator())
                else if (roles.isEmpty)
                  NoDataFoundScreen()
                else
                  Column(
                    children: roles.map((user) {
                      Map<String, dynamic> userFields = {
                        'Username': user['userName'],
                        '': user[''],
                        'Rolename': user['roleName'],
                        'CreatedAt': user['createdAt'],
                      };
                      return buildUserCard(
                        userFields: userFields,
                        onDelete: () => _confirmDeleteRole(user['userId'],user['userRoleId']),
                        trailingIcon: Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            // IconButton(
                            //   icon: Icon(Icons.edit, color: Colors.green),
                            //   onPressed: () => _showUpdateRoleModal(user['userId'], user['userRoleIds'][0], user['roleName']),
                            // ),
                            IconButton(
                              onPressed: () {
                                int? userRoleId = user['userRoleIds']?.isNotEmpty ?? false ? user['userRoleIds'][0] : null;
                                if (userRoleId != null) {
                                  _confirmDeleteRole(user['userId'], userRoleId);
                                } else {
                                  showToast(msg: 'No role assigned to delete');
                                }
                              },
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