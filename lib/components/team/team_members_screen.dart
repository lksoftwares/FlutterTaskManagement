
import 'package:lktaskmanagementapp/packages/headerfiles.dart';

class TeamMembersScreen extends StatefulWidget {
  const TeamMembersScreen({super.key});

  @override
  State<TeamMembersScreen> createState() => _TeamMembersScreenState();
}

class _TeamMembersScreenState extends State<TeamMembersScreen> {
  List<Map<String, dynamic>> teams = [];
  List<Map<String, dynamic>> usersList = [];
  List<Map<String, dynamic>> rolesList = [];
  List<Map<String, dynamic>> teamsList = [];
  int? selectedUserId;
  String? selectedTeamName;
  int? selectedRoleId;
  int? selectedTeamId;
  bool isLoading = false;
  bool isSubmitting = false;
  final GlobalKey<CustomDropdownState<int>> _dropdownKey = GlobalKey<CustomDropdownState<int>>();


  @override
  void initState() {
    super.initState();
    _getData();
  }
  Future<void> _getData() async {
    await fetchTeamsMembers();
    await fetchUsers();
    await fetchRoles();
    await fetchTeams();
  }

  Future<void> fetchUsers() async {
    final response = await new ApiService().request(
      method: 'get',
      endpoint: 'User/?status=1',
        tokenRequired: true

    );
    if (response['statusCode'] == 200 && response['apiResponse'] != null) {
      setState(() {
        usersList = List<Map<String, dynamic>>.from(response['apiResponse']);
      });
    } else {
      print("Failed to load users");
    }
  }
  Future<void> fetchRoles() async {
    final response = await new ApiService().request(
      method: 'get',
      endpoint: 'teams/GetALlTeamMemberRoles?status=1',
      tokenRequired: true
    );
    if (response['statusCode'] == 200 && response['apiResponse'] != null) {
      setState(() {
        rolesList = List<Map<String, dynamic>>.from(response['apiResponse']);
      });
    } else {
      print("Failed to load roles");
    }
  }

  Future<void> fetchTeams() async {
    final response = await new ApiService().request(
      method: 'get',
      endpoint: 'teams/?status=1',
        tokenRequired: true

    );
    if (response['statusCode'] == 200 && response['apiResponse'] != null) {
      setState(() {
        teamsList = List<Map<String, dynamic>>.from(response['apiResponse']);
      });
    } else {
      print("Failed to load teams");
    }
  }

  Future<void> fetchTeamsMembers() async {
    setState(() {
      isLoading = true;
    });

    final response = await new ApiService().request(
      method: 'get',
      endpoint: 'teams/GetTeamMembers',
        tokenRequired: true
    );
    print('Response: $response');
    if (response['statusCode'] == 200 && response['apiResponse'] != null) {
      setState(() {
        teams = List<Map<String, dynamic>>.from(
          response['apiResponse'].map((role) => {
            'tmemberId': role['tmemberId'] ?? 0,
            'userId': role['userId'] ?? 0,
            'tMRoleId': role['tMRoleId'] ?? 0,
            'tmStatus': role['tmStatus'] ?? false,
            'teamId': role['teamId'] ?? 0,
            'teamName': role['teamName'] ?? 'Unknown team',
            'createdAt': role['createdAt'] ?? '',
            'projectName': role['projectName'] ?? '',
            'teamMemberRole': role['teamMemberRole'] ?? 'Unknown role',
            'userName': role['userName'] ?? 'Unknown team',
          }),
        );
      });
    } else {
      print("Failed to load members");
    }
    setState(() {
      isLoading = false;
    });
  }

  Future<void> _addTeamMembers( int userId, int tMRoleId, int teamId) async {
    final response = await new ApiService().request(
      method: 'post',
      endpoint: 'teams/TeamMember/create',
      tokenRequired: true,
      body: {
        'userId': userId,
        'tMRoleId': tMRoleId,
        'teamId': teamId,
      },
    );

    if (response.isNotEmpty && response['statusCode'] == 200) {
      fetchTeamsMembers();
      showToast(
        msg: response['message'] ?? 'Team Members added successfully',
        backgroundColor: Colors.green,
      );
      Navigator.pop(context);
    } else {
      showToast(
        msg: response['message'] ?? 'Failed to add team member',
      );
    }
  }

  Future<void> _addTeam(String teamName, String tmDescription, VoidCallback onTeamAdded) async {
    final response = await ApiService().request(
      method: 'post',
      endpoint: 'teams/create',
      tokenRequired: true,
      body: {
        'teamName': teamName,
        'tmDescription': tmDescription,
      },
    );

    if (response.isNotEmpty && response['statusCode'] == 200) {
      showToast(
        msg: response['message'] ?? 'Team added successfully',
        backgroundColor: Colors.green,
      );
      onTeamAdded();
      Navigator.pop(context);
    } else {
      showToast(
        msg: response['message'] ?? 'Failed to add Team',
        backgroundColor: Colors.red,
      );
    }
  }

  void _showAddTeamModal(VoidCallback onTeamAdded) {
    String teamName = '';
    String tmDescription = '';

    InputDecoration inputDecoration = InputDecoration(
      labelText: 'Team Name',
      border: OutlineInputBorder(),
    );

    InputDecoration descriptionDecoration = InputDecoration(
      labelText: 'Description',
      border: OutlineInputBorder(),
    );

    showCustomAlertDialog(
      context,
      title: 'Add Team',
      content: StatefulBuilder(
        builder: (context, localSetState) {
          return Padding(
            padding: const EdgeInsets.all(15.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(height: 15),
                TextField(
                  onChanged: (value) => teamName = value,
                  decoration: inputDecoration,
                ),
                SizedBox(height: 15),
                TextField(
                  onChanged: (value) => tmDescription = value,
                  decoration: descriptionDecoration,
                ),
              ],
            ),
          );
        },
      ),
      actions: [
        StatefulBuilder(
          builder: (context, localSetState) {
            return ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
              ),
              onPressed: isSubmitting
                  ? null
                  : () async {
                if (teamName.isEmpty) {
                  showToast(msg: 'Please fill in both fields');
                  return;
                }

                localSetState(() => isSubmitting = true);

                await _addTeam(teamName, tmDescription, onTeamAdded);

                localSetState(() => isSubmitting = false);
              },
              child: isSubmitting
                  ? SizedBox(
                height: 16,
                width: 16,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
                  : Text(
                'Add',
                style: TextStyle(color: Colors.white),
              ),
            );
          },
        ),
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text('Cancel'),
        ),
      ],
      titleHeight: 65,
    );
  }


  Future<void> _showAddRoleModal() async {
    setState(() {
      selectedTeamId = null;
      selectedUserId = null;
      selectedRoleId = null;
      rolesList.clear();
    });
    int? localSelectedTeamId;
    List teams = [];
    void loadTeams(StateSetter modalSetState) async {
      await fetchTeams();
      modalSetState(() {
        teams = teamsList;
      });
    }
    await fetchRoles();
    await fetchTeams();
    await fetchUsers();

    showCustomAlertDialog(
      context,
      title: 'Add Team Members',
      content: StatefulBuilder(
        builder: (context, modalSetState) {
          if (teams.isEmpty) {
            loadTeams(modalSetState);
          }
          return Padding(
            padding: const EdgeInsets.all(15.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(height: 20),
                Row(
                  children: [
                    CustomDropdown<int>(
                      key: _dropdownKey,
                      options: teamsList.map<int>((team) => team['teamId'] as int).toList(),
                      selectedOption: selectedTeamId,
                      displayValue: (teamId) =>
                      teamsList.firstWhere((team) => team['teamId'] == teamId)['teamName'],
                      onChanged: (value) {
                        modalSetState(() {
                          selectedTeamId = value;
                        });
                      },
                      labelText: 'Select Team',
                      width: 280,
                    ),
                    IconButton(
                      onPressed: () {
                        _dropdownKey.currentState?.closeDropdown();
                        _showAddTeamModal(() async {
                          await fetchTeams();
                          WidgetsBinding.instance.addPostFrameCallback((_) {
                            modalSetState(() {});
                          });
                        });

                      },
                      icon: Icon(Icons.add_circle, size: 30, color: Colors.blue),
                    )
                  ],
                ),
                SizedBox(height: 15),
                CustomDropdown<int>(
                  options: usersList.map<int>((user) => user['userId'] as int).toList(),
                  selectedOption: selectedUserId,
                  displayValue: (userId) => usersList.firstWhere((user) => user['userId'] == userId)['userName'],
                  onChanged: (value) {
                    setState(() {
                      selectedUserId = value;
                    });
                  },
                  labelText: 'Select user',
                ),
                SizedBox(height: 15),
            CustomDropdown<int>(
            options: rolesList.map<int>((role) => role['tMRoleId'] as int).toList(),
            selectedOption: selectedRoleId,
            displayValue: (tMRoleId) => rolesList.firstWhere((role) => role['tMRoleId'] == tMRoleId)['teamMemberRole'],
            onChanged: (value) {
            setState(() {
            selectedRoleId = value;
            });
            },
            labelText: 'Select Role',
            ),

              ],
            ),
          );
        },
      ),
      actions: [
        ElevatedButton(
          style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
          onPressed: () {
            if (selectedUserId == null || selectedRoleId == null || selectedTeamId == null) {
              showToast(msg: 'Please select all fields');
              return;
            }
            _addTeamMembers(selectedUserId!, selectedRoleId!,selectedTeamId!);
          },
          child: Text('Add', style: TextStyle(color: Colors.white)),
        ),
        TextButton(onPressed: () => Navigator.pop(context), child: Text('Cancel')),

      ],
      titleHeight: 65,

    );
  }

  void _confirmDeleteTeamMember(int tmemberId) {
    showCustomAlertDialog(
      context,
      title: 'Delete Team Member',
      content: Text('Are you sure you want to delete this team Member?'),
      actions: [

        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.red,
          ),
          onPressed: () {
            _deleteTeamMember(tmemberId);
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

  Future<void> _deleteTeamMember(int tmemberId) async {
    final response = await new ApiService().request(
      method: 'post',
      endpoint: 'teams/TeamMember/delete/$tmemberId',
        tokenRequired: true
    );
    if (response['statusCode'] == 200) {
      String message = response['message'] ?? 'Team Member deleted successfully';
      showToast(msg: message, backgroundColor: Colors.green);
      fetchTeamsMembers();
    } else {
      String message = response['message'] ?? 'Failed to delete TeamMember';
      showToast(msg: message);
    }
  }

  Future<void> _updateUserRole(int tmemberId, int userId, int tMRoleId, int teamId,bool tmStatus) async {
    final response = await ApiService().request(
      method: 'post',
      endpoint: 'teams/TeamMember/update',
      tokenRequired: true,
      body: {
        'tmemberId': tmemberId,
        'userId': userId,
        'tMRoleId': tMRoleId,
        'tmStatus': tmStatus,
        'teamId': teamId,
        'updateFlag': true,
      },
    );

    if (response['statusCode'] == 200) {
      fetchTeamsMembers();
      showToast(msg: response['message'] ?? 'Role updated successfully', backgroundColor: Colors.green);
      Navigator.pop(context);
    } else {
      showToast(msg: response['message'] ?? 'Failed to update role');
    }
  }
  Future<void> _showEditTeammemberModal(int tmemberId, bool? tmStatus) async {

    Map<String, dynamic> currentMember = teams.firstWhere((task) => task['tmemberId'] == tmemberId);

    if (currentMember.isEmpty) {
      showToast(msg: 'Team member not found');
      return;
    }

    selectedUserId = currentMember['userId'];
    selectedRoleId = currentMember['tMRoleId'];
    selectedTeamId = currentMember['teamId'];

    bool? selectedStatus = tmStatus;

    showCustomAlertDialog(
      context,
      title: 'Edit Team Member',
      content: StatefulBuilder(
        builder: (context, setState) {
          return Padding(
            padding: const EdgeInsets.all(15.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(height: 20),
                CustomDropdown<int>(
                  options: teamsList.map<int>((team) => team['teamId'] as int).toList(),
                  selectedOption: selectedTeamId,
                  displayValue: (teamId) =>
                  teamsList.firstWhere(
                        (team) => team['teamId'] == teamId,
                    orElse: () => {'teamName': 'Unknown'},
                  )['teamName'],
                  onChanged: (value) {
                    setState(() {
                      selectedTeamId = value;
                    });
                  },
                  labelText: 'Select Team',
                ),
                SizedBox(height: 15),
                CustomDropdown<int>(
                  options: usersList.map<int>((user) => user['userId'] as int).toList(),
                  selectedOption: selectedUserId,
                  displayValue: (userId) =>
                  usersList.firstWhere(
                        (user) => user['userId'] == userId,
                    orElse: () => {'userName': 'Unknown'},
                  )['userName'],
                  onChanged: (value) {
                    setState(() {
                      selectedUserId = value;
                    });
                  },
                  labelText: 'Select User',
                ),
                SizedBox(height: 15),
                CustomDropdown<int>(
                  options: rolesList.map<int>((role) => role['tMRoleId'] as int).toList(),
                  selectedOption: selectedRoleId,
                  displayValue: (tMRoleId) =>
                  rolesList.firstWhere(
                        (role) => role['tMRoleId'] == tMRoleId,
                    orElse: () => {'teamMemberRole': 'Unknown'},
                  )['teamMemberRole'],
                  onChanged: (value) {
                    setState(() {
                      selectedRoleId = value;
                    });
                  },
                  labelText: 'Select Member Role',
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
        },
      ),
      actions: [
        ElevatedButton(
          style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
          onPressed: () {
            if (selectedUserId == null || selectedRoleId == null || selectedTeamId == null) {
              showToast(msg: 'Please select all fields');
              return;
            }
            _updateUserRole(tmemberId, selectedUserId!, selectedRoleId!, selectedTeamId!, selectedStatus ?? false);
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
    return teams.where((project) {
      bool matchesTeamName = true;
      if (selectedTeamName != null && selectedTeamName!.isNotEmpty) {
        matchesTeamName = project['teamName'] == selectedTeamName;
      }

      return matchesTeamName;
    }).toList();
  }

  Map<String, List<Map<String, dynamic>>> groupmembersByteam() {
    Map<String, List<Map<String, dynamic>>> groupedteam = {};

    for (var log in teams) {
      String teamName = log['teamName'];
      if (!groupedteam.containsKey(teamName)) {
        groupedteam[teamName] = [];
      }
      groupedteam[teamName]!.add(log);
    }

    return groupedteam;
  }
  @override
  Widget build(BuildContext context) {
    Map<String, List<Map<String, dynamic>>> groupedteam = groupmembersByteam();
    List<Map<String, dynamic>> filteredTeams = getFilteredData();
    return Scaffold(
      appBar: CustomAppBar(
        title: 'Team Members',
        onLogout: () => AuthService.logout(context),
      ),
      body: RefreshIndicator(
        onRefresh: fetchTeamsMembers,
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
                        return teamsList
                            .where((team) => team['teamName']!
                            .toLowerCase()
                            .contains(textEditingValue.text.toLowerCase()))
                            .map((team) => team['teamName'] as String)
                            .toList();
                      },
                      onSelected: (String teamName) {
                        setState(() {
                          selectedTeamName = teamName;
                        });
                        fetchTeamsMembers();
                      },
                      fieldViewBuilder: (context, controller, focusNode, onFieldSubmitted) {
                        return Container(
                          width: 290,
                          child: TextField(
                            controller: controller,
                            focusNode: focusNode,
                            decoration: InputDecoration(
                              labelText: 'Select Team',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              prefixIcon: Icon(Icons.people_rounded),
                            ),
                            onChanged: (value) {
                              if (value.isEmpty) {
                                setState(() {
                                  selectedTeamName = null;
                                });
                                fetchTeamsMembers();
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
                else if (teams.isEmpty)
                  NoDataFoundScreen()
                else if (filteredTeams.isEmpty)
                    NoDataFoundScreen()
                else
                    Column(
                      children: groupedteam.entries.map((entry) {
                        String teamName = entry.key;
                        List<Map<String, dynamic>> logs = entry.value;
                        if (selectedTeamName != null && teamName != selectedTeamName) {
                          return SizedBox();
                        }
                        Map<String, dynamic> roleFields = {
                          'Teamname': teamName,
                          '': "",
                        };
                      return buildUserCard(
                        userFields: roleFields,
                        additionalContent: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: logs.map((role) {
                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                SizedBox(height: 20,),
                                Row(
                                  children: [
                                    Text(
                                      'ProjectName    : ',
                                      style: AppTextStyle.boldTextStyle(),
                                    ),
                                    Text(
                                      '${role['projectName']}',
                                      style: AppTextStyle.regularTextStyle(),
                                    ),
                                  ],
                                ),
                                SizedBox(height: 7),

                                Row(
                                  children: [
                                    Text(
                                      'Username         : ',
                                      style: AppTextStyle.boldTextStyle(),
                                    ),
                                    Text(
                                      '${role['userName']}',
                                      style: AppTextStyle.regularTextStyle(),
                                    ),
                                  ],
                                ),
                                SizedBox(height: 7),

                                Row(
                                  children: [
                                    Text(
                                      'Status               : ',
                                      style: AppTextStyle.boldTextStyle(),
                                    ),
                                    Icon(
                                      role['tmStatus'] ? Icons.check_circle : Icons.cancel,
                                      color: role['tmStatus'] ? Colors.green : Colors.red,
                                    ),
                                    SizedBox(width: 5),
                                    Text(
                                      role['tmStatus'] ? '' : '',
                                      style: AppTextStyle.regularTextStyle(),
                                    ),
                                  ],
                                ),


                                SizedBox(height: 7),
                                Row(
                                  children: [
                                    Text(
                                      'MemberRole    : ',
                                      style: AppTextStyle.boldTextStyle(),
                                    ),
                                    Text(
                                      '${role['teamMemberRole']}',
                                      style: AppTextStyle.regularTextStyle(),
                                    ),
                                  ],
                                ),
                                SizedBox(height: 7),
                                Row(
                                  children: [
                                    Text(
                                      'Created At        : ',
                                      style: AppTextStyle.boldTextStyle(),
                                    ),
                                    Text(
                                      '${role['createdAt']}',
                                      style: AppTextStyle.regularTextStyle(),
                                    ),
                                  ],
                                ),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    IconButton(
                                      icon: Icon(Icons.edit, color: Colors.green),
                                      onPressed: () => _showEditTeammemberModal(role['tmemberId'],role['tmStatus']),
                                    ),
                                    IconButton(
                                      onPressed: ()=>_confirmDeleteTeamMember(role['tmemberId']),
                                      icon: Icon(Icons.delete, color: Colors.red),
                                    ),
                                  ],
                                ),
                                SizedBox(height: 5),
                                Divider(color: Colors.grey,),
                                SizedBox(height: 5),                              ],

                            );
                          }).toList(),
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