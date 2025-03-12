
import 'package:lktaskmanagementapp/packages/headerfiles.dart';

class RolesPage extends StatefulWidget {
  const RolesPage({super.key});

  @override
  State<RolesPage> createState() => _RolesPageState();
}

class _RolesPageState extends State<RolesPage> {
  List<Map<String, dynamic>> roles = [];
  String? selectedRoleName;

  bool isLoading = false;


  @override
  void initState() {
    super.initState();

      fetchRoles();
  }

  // Future<void> _getToken() async {
  //   SharedPreferences prefs = await SharedPreferences.getInstance();
  //   setState(() {
  //     token = prefs.getString('token');
  //   });
  // }

  Future<void> fetchRoles() async {
    setState(() {
      isLoading = true;
    });

    final response = await new ApiService().request(
      method: 'get',
      endpoint: 'Roles/GetAllRole',
    );
    print('Response: $response');
    if (response['statusCode'] == 200 && response['apiResponse'] != null) {
      setState(() {
        roles = List<Map<String, dynamic>>.from(
          response['apiResponse'].map((role) => {
            'roleId': role['roleId'] ?? 0,
            'roleName': role['roleName'] ?? 'Unknown Role',
            'roleStatus': role['roleStatus'] ?? false,
            'createdAt': role['createdAt'] ?? '',
            'updatedAt': role['updatedAt'] ?? '',
          }),
        );
      });
    } else {
      showToast(msg: response['message'] ?? 'Failed to load roles');
    }
    setState(() {
      isLoading = false;
    });
  }

  Future<void> _addRole(String roleName) async {
    final response = await new ApiService().request(
      method: 'post',
      endpoint: 'Roles/AddRole',
      body: {
        'roleName': roleName,
      },
    );

    if (response.isNotEmpty && response['statusCode'] == 200) {
      fetchRoles();
      showToast(
        msg: response['message'] ?? 'Role added successfully',
        backgroundColor: Colors.green,
      );
      Navigator.pop(context);
    }  else {
      showToast(
        msg: response['message'] ?? 'Failed to add role',
      );
    }
  }

  void _showAddRoleModal() {
    String roleName = '';
    InputDecoration inputDecoration = InputDecoration(
      labelText: 'Role Name',
      border: OutlineInputBorder(),
    );

    showCustomAlertDialog(
      context,
      title: 'Add Role',
      content: TextField(
        onChanged: (value) => roleName = value,
        decoration: inputDecoration,
      ),
      actions: [

        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.green,
          ),
          onPressed: () {
            if (roleName.isEmpty) {
              showToast(msg: 'Please fill in the role name');
            } else {
              _addRole(roleName);
            }
          },
          child: Text('Add',style: TextStyle(color: Colors.white),),
        ),
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text('Cancel'),
        ),
      ],
      titleHeight: 65,
    );
  }

  void _confirmDeleteRole(int roleId) {
    showCustomAlertDialog(
      context,
      title: 'Delete Role',
      content: Text('Are you sure you want to delete this role?'),
      actions: [

        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.red,
          ),
          onPressed: () {
            _deleteRole(roleId);
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

  Future<void> _deleteRole(int roleId) async {

    final response = await new ApiService().request(
      method: 'delete',
      endpoint: 'Roles/deleteRole/$roleId',
    );
    if (response['statusCode'] == 200) {
      String message = response['message'] ?? 'Role deleted successfully';
      showToast(msg: message, backgroundColor: Colors.green);
      fetchRoles();
    } else {
      String message = response['message'] ?? 'Failed to delete role';
      showToast(msg: message);
    }
  }

  Future<void> _updateRole(int roleId, String roleName) async {
    final response = await new ApiService().request(
      method: 'post',
      endpoint: 'Roles/EditRole',
      body: {
        'roleId': roleId,
        'roleName': roleName,
        'updateFlag': true,
      },
    );

    print('Update Response: $response');

    if (response.isNotEmpty && response['statusCode'] == 200) {
      fetchRoles();
      showToast(
        msg: response['message'] ?? 'Role updated successfully',
        backgroundColor: Colors.green,
      );
      Navigator.pop(context);
    } else {
      showToast(
        msg: response['message'] ?? 'Failed to update role',
      );
    }
  }


  void _showEditRoleModal(int roleId, String currentRoleName) {
    TextEditingController _roleController =
    TextEditingController(text: currentRoleName);

    showCustomAlertDialog(
      context,
      title: 'Edit Role',
      content: TextField(
        controller: _roleController,
        decoration: InputDecoration(
          labelText: 'Role Name',
          border: OutlineInputBorder(),
        ),
      ),
      actions: [

        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.green,
          ),
          onPressed: () {
            if (_roleController.text.isEmpty) {
              showToast(msg: 'Please enter a role name');
            } else {
              _updateRole(roleId, _roleController.text);
            }
          },
          child: Text('Update',style: TextStyle(color: Colors.white),),
        ),
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text('Cancel'),
        ),
      ],
      titleHeight: 65,
    );
  }

  List<Map<String, dynamic>> getFilteredData() {
    return roles.where((role) {
      bool matchesRoleName = true;
      if (selectedRoleName != null && selectedRoleName!.isNotEmpty) {
        matchesRoleName = role['roleName'] == selectedRoleName;
      }
      return matchesRoleName;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: 'Roles',
        onLogout: () => AuthService.logout(context),
      ),
      body: RefreshIndicator(
        onRefresh: fetchRoles,
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: [
                SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Autocomplete<String>(
                      optionsBuilder: (TextEditingValue textEditingValue) {
                        return roles
                            .where((role) => role['roleName']!
                            .toLowerCase()
                            .contains(textEditingValue.text.toLowerCase()))
                            .map((role) => role['roleName'] as String)
                            .toList();
                      },
                      onSelected: (String roleName) {
                        setState(() {
                          selectedRoleName = roleName;
                        });
                        fetchRoles();
                      },
                      fieldViewBuilder: (context, controller, focusNode, onFieldSubmitted) {
                        return Container(
                          width: 280,
                          child: TextField(
                            controller: controller,
                            focusNode: focusNode,
                            decoration: InputDecoration(
                              labelText: 'Select Role',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              prefixIcon: Icon(Icons.person),
                            ),
                            onChanged: (value) {
                              if (value.isEmpty) {
                                setState(() {
                                  selectedRoleName = null;
                                });
                                fetchRoles();
                              }
                            },
                          ),
                        );
                      },
                    ),
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
                    children: getFilteredData().map((role) {
                      Map<String, dynamic> roleFields = {
                        'RoleName': role['roleName'],
                        '': role[''],
                        'Status': role['roleStatus'],
                        'CreatedAt': role['createdAt'],
                      };

                      return buildUserCard(
                        userFields: {
                          'RoleName': role['roleName'],
                          '': role[''],
                          'Status': role['roleStatus'],
                          'CreatedAt': role['createdAt'],
                        },
                        onEdit: () => _showEditRoleModal(role['roleId'], role['roleName']),
                        onDelete: () => _confirmDeleteRole(role['roleId']),
                        trailingIcon:
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            IconButton(onPressed: ()=>_showEditRoleModal(role['roleId'], role['roleName']),
                                icon: Icon(Icons.edit,color: Colors.green,)),
                            IconButton(onPressed: ()=>_confirmDeleteRole(role['roleId']),
                                icon: Icon(Icons.delete,color: Colors.red,)),

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