
import 'package:lktaskmanagementapp/packages/headerfiles.dart';

class TeammemberroleScreen extends StatefulWidget {
  const TeammemberroleScreen({super.key});

  @override
  State<TeammemberroleScreen> createState() => _TeammemberroleScreenState();
}

class _TeammemberroleScreenState extends State<TeammemberroleScreen> {
  List<Map<String, dynamic>> roles = [];
  String? selectedRoleName;
  bool isLoading = false;
  String ?token;


  @override
  void initState() {
    super.initState();
    fetchTeammemberrole();
  }


  Future<void> fetchTeammemberrole() async {
    setState(() {
      isLoading = true;
    });

    final response = await new ApiService().request(
      method: 'get',
      endpoint: 'teams/GetAllTeamMemberRoles',
      tokenRequired: true
    );
    print('Response: $response');
    if (response['statusCode'] == 200 && response['apiResponse'] != null) {
      setState(() {
        roles = List<Map<String, dynamic>>.from(
          response['apiResponse'].map((role) => {
            'tMRoleId': role['tMRoleId'] ?? 0,
            'teamMemberRole': role['teamMemberRole'] ?? 'Unknown Role',
            'Description': role['Description'] ?? 'Unknown Description',
            'tmStatus': role['tmStatus'] ?? false,
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


  Future<void> _addTeamMemberrole(String teamMemberRole, String Description) async {

    final response = await new ApiService().request(
      method: 'post',
      endpoint: 'teams/teamMemberRole/create',
      body: {
        'teamMemberRole': teamMemberRole,
        'Description': Description,

      },
      tokenRequired: true,
    );

    if (response.isNotEmpty && response['statusCode'] == 200) {
      fetchTeammemberrole();
      showToast(
        msg: response['message'] ?? 'Member Role added successfully',
        backgroundColor: Colors.green,
      );
      Navigator.pop(context);
    } else {
      showToast(
        msg: response['message'] ?? 'Failed to add Member role',
      );
    }
  }


  void _showAddTeammemberRole() {
      String teamMemberRole = '';
      String Description = '';

      InputDecoration inputDecoration = InputDecoration(
        labelText: 'Team Member Role',
        border: OutlineInputBorder(),
      );

      InputDecoration descriptionDecoration = InputDecoration(
        labelText: 'Description',
        border: OutlineInputBorder(),
      );

      showCustomAlertDialog(
        context,
        title: 'Add Team Member Role',
        content: Padding(
          padding: const EdgeInsets.all(15.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(height: 15),

              TextField(
                onChanged: (value) => teamMemberRole = value,
                decoration: inputDecoration,
              ),
              SizedBox(height: 15),
              TextField(
                onChanged: (value) => Description = value,
                decoration: descriptionDecoration,
              ),
            ],
          ),
        ),
        actions: [

          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
            ),
            onPressed: () {
              if (teamMemberRole.isEmpty ) {
                showToast(msg: 'Please fill team member role');
              } else {
                _addTeamMemberrole(teamMemberRole, Description);
              }
            },
            child: Text(
              'Add',
              style: TextStyle(color: Colors.white),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
        ],
        titleHeight: 65,

      );
    }


    void _DeleteTeammemberRole(int tMRoleId) {
    showCustomAlertDialog(
      context,
      title: 'Delete Member Role',
      content: Text('Are you sure you want to delete this role?'),
      actions: [

        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.red,
          ),
          onPressed: () {
            _deleteTeammemberRole(tMRoleId);
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

  Future<void> _deleteTeammemberRole(int tMRoleId) async {

    final response = await new ApiService().request(
        method: 'post',
        endpoint: 'teams/teamMemberRole/delete/$tMRoleId',tokenRequired: true
    );
    if (response['statusCode'] == 200) {
      String message = response['message'] ?? 'Member Role deleted successfully';
      showToast(msg: message, backgroundColor: Colors.green);
      fetchTeammemberrole();
    } else {
      String message = response['message'] ?? 'Failed to delete Member role';
      showToast(msg: message);
    }
  }

    Future<void> _updateTeammemberRole(int tMRoleId, String teamMemberRole,String Description,bool tmStatus) async {
      final response = await new ApiService().request(
        method: 'post',
        endpoint: 'teams/teamMemberRole/update',
        tokenRequired: true,
        body: {
          'tMRoleId': tMRoleId,
          'teamMemberRole': teamMemberRole,
          'Description':Description,
          'tMStatus': tmStatus,
          'updateFlag': true,
        },
      );

      print('Update Response: $response');

      if (response.isNotEmpty && response['statusCode'] == 200) {
        fetchTeammemberrole();
        showToast(
          msg: response['message'] ?? 'Team updated successfully',
          backgroundColor: Colors.green,
        );
        Navigator.pop(context);
      } else {
        showToast(
          msg: response['message'] ?? 'Failed to update team',
        );
      }
    }



    void _EditTeammemberRole(int tMRoleId, String currentTeamMemberRole, String currentDescription, bool? tmStatus) {
    TextEditingController _teammemberController = TextEditingController(text: currentTeamMemberRole);
    TextEditingController _descriptionController = TextEditingController(text: currentDescription);
    bool? selectedStatus = tmStatus;
    showCustomAlertDialog(
      context,
      title: 'Edit Team Member Role',
      content: StatefulBuilder(
          builder: (context, setState) {
            return Padding(
              padding: const EdgeInsets.all(15.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(height: 15),

                  TextField(
                    controller: _teammemberController,
                    decoration: InputDecoration(
                      labelText: 'Team Member Role',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  SizedBox(height: 15),
                  TextField(
                    controller: _descriptionController,
                    decoration: InputDecoration(
                      labelText: 'Description',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  SizedBox(height: 15),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Status:',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      Transform.scale(
                        scale: 1.3,
                        child: Switch(
                          value: selectedStatus ?? false,
                          onChanged: (bool value) {
                            setState(() {
                              selectedStatus = value;
                            });
                          },
                          activeColor: Colors.green,
                          inactiveThumbColor: Colors.red,
                          inactiveTrackColor: Colors.red[200],
                        ),
                      ),

                    ],
                  ),
                ],
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
            if (_teammemberController.text.isEmpty) {
              showToast(msg: 'Please fill in both fields');
            } else {
              _updateTeammemberRole(tMRoleId, _teammemberController.text, _descriptionController.text, selectedStatus ?? false);
            }
          },
          child: Text('Update', style: TextStyle(color: Colors.white)),
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
        title: 'Member Role',
        onLogout: () => AuthService.logout(context),
      ),
      body: RefreshIndicator(
        onRefresh: fetchTeammemberrole,
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
                      onPressed: _showAddTeammemberRole,
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
                        'MemberRole': role['teamMemberRole'] ,
                        '': role[''] ,
                        'Description': role['Description'] ,
                        'Status': role['tmStatus'] ,
                        'CreatedAt': role['createdAt'] ,
                        'UpdatedAt': role['updatedAt'] ,
                      };

                      return buildUserCard(
                        userFields: {
                          'MemberRole': role['teamMemberRole'] ,
                          '': role[''] ,
                          'Description': role['Description'] ,
                          'Status': role['tmStatus'] ,
                          'CreatedAt': role['createdAt'] ,
                          'UpdatedAt': role['updatedAt'] ,
                        },
                        onEdit: () => _EditTeammemberRole(role['tMRoleId'], role['teamMemberRole'],role['Description'],role['tmStatus']),
                        onDelete: () => _DeleteTeammemberRole(role['tMRoleId']),
                        trailingIcon:
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            IconButton(onPressed: ()=>_EditTeammemberRole(role['tMRoleId'], role['teamMemberRole'],role['Description'],role['tmStatus']),
                                icon: Icon(Icons.edit,color: Colors.green,)),
                            IconButton(onPressed: ()=>_DeleteTeammemberRole(role['tMRoleId']),
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