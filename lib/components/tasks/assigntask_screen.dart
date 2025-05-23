import 'package:lktaskmanagementapp/packages/headerfiles.dart';

class AssigntaskScreen extends StatefulWidget {
  const AssigntaskScreen({super.key});

  @override
  State<AssigntaskScreen> createState() => _AssigntaskScreenState();
}

class _AssigntaskScreenState extends State<AssigntaskScreen> {
  List<Map<String, dynamic>> tasks = [];
  List<Map<String, dynamic>> users = [];
  String? selectedUserName;

  List<Map<String, dynamic>> assigntasks = [];
  int? selectedTaskId;
  int? selectedTeamMemberId;
  int? userId;

  List<Map<String, dynamic>> team = [];
  String? selectedRoleName;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    fetchTasks();
    fetchAssigntask();
    fetchUsers();
    _getUserId();
  }

  Future<void> _getUserId() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      userId = prefs.getInt('user_Id');
    });
  }
  Future<void> fetchUsers() async {
    final response = await new ApiService().request(
        method: 'get',
        endpoint: 'User/?status=1',
        tokenRequired: true
    );
    print("responsesssss $response");
    if (response['statusCode'] == 200 && response['apiResponse'] != null) {
      setState(() {
        users = List<Map<String, dynamic>>.from(response['apiResponse']);
      });

    } else {
      showToast(msg: response['message'] ?? 'Failed to load users');
    }
  }
  Future<void> fetchTeamMembers() async {
    if (selectedTaskId == null) return;

    final response = await new ApiService().request(
      method: 'get',
      endpoint: 'teams/GetTeamMembers?taskId=$selectedTaskId&status=1',
        tokenRequired: true

    );

    print('Fetching team members for task ID: $selectedTaskId');

    if (response['statusCode'] == 200 && response['apiResponse'] != null) {
      setState(() {
        team = List<Map<String, dynamic>>.from(response['apiResponse']);
        print('Team members fetched: $team');
      });
      print('Team members fetched: $team');
    } else {
    }
  }

  Future<void> fetchTasks() async {
    setState(() {
      isLoading = true;
    });

    final response = await new ApiService().request(
      method: 'get',
      endpoint: 'tasks',
        tokenRequired: true

    );
    if (response['statusCode'] == 200 && response['apiResponse'] != null) {
      setState(() {
        tasks = List<Map<String, dynamic>>.from(
          response['apiResponse']["taskList"].map((project) => {
            'taskId': project['taskId'] ?? 0,
            'taskTitle': project['taskTitle'] ?? 'Unknown taskTitle',
          }),
        );
      });
    } else {
    }
    setState(() {
      isLoading = false;
    });
  }

  Future<void> fetchAssigntask() async {
    setState(() {
      isLoading = true;
    });

    final response = await new ApiService().request(
      method: 'get',
      endpoint: 'tasks/GetAllAssignTask',
        tokenRequired: true

    );
    print('Response: $response');
    if (response['statusCode'] == 200 && response['apiResponse'] != null) {
      setState(() {
        assigntasks = List<Map<String, dynamic>>.from(
          response['apiResponse'].map((task) => {
            'taskId': task['taskId'] ?? 0,
            'taskAssId': task['taskAssId'] ?? 0,
            'taskTitle': task['taskTitle'] ?? 'unknown title',
            '': task[''],
            'taskAssignedByName': task['taskAssignedByName'] ?? 'unknown name',
            'taskAssignedToName': task['taskAssignedToName'] ?? 'unknown name',
            'taskAssignedTo': task['taskAssignedTo'] ?? 0,
            'createdAt': task['createdAt'] ?? '',
            'updatedAt': task['updatedAt'] ?? '',
          }),
        );
      });
    } else {
    }
    setState(() {
      isLoading = false;
    });
  }

  Future<void> _addAssignTask() async {
    if (selectedTaskId == null || selectedTeamMemberId == null) {
      showToast(msg: 'Please select a task and a team member.');
      return;
    }

    final response = await new ApiService().request(
      method: 'post',
      endpoint: 'tasks/AssignTask',
      tokenRequired: true,
      body: {
        'taskId': selectedTaskId,
        'taskAssignedTo': selectedTeamMemberId,
        'taskAssignedBy': userId,
      },
    );

    if (response['statusCode'] == 200) {
      showToast(
          msg: response['message'] ?? 'Task assigned successfully',
          backgroundColor: Colors.green);
      Navigator.pop(context);
      fetchAssigntask();
    } else {
      showToast(msg: response['message'] ?? 'Failed to assign task');
    }
  }

  void _showAddRoleModal() {
    setState(() {
      selectedTaskId = null;
      selectedTeamMemberId = null;
      team.clear();
    });
    showCustomAlertDialog(
      context,
      title: 'Assign Task',
      content: StatefulBuilder(builder: (context, setState) {
        return Padding(
          padding: const EdgeInsets.all(15.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(height: 20,),
              CustomDropdown<String>(
                options:
                tasks.map((task) => task['taskId'].toString()).toList(),
                displayValue: (taskId) {
                  final task = tasks.firstWhere(
                          (task) => task['taskId'].toString() == taskId);
                  return task['taskTitle'];
                },
                onChanged: (value) async {
                  setState(() {
                    selectedTaskId =
                    value != null ? int.tryParse(value) : null;
                    team.clear();
                  });
                  print("Selected team ID: $selectedTaskId");
                  if (selectedTaskId != null) {
                    await fetchTeamMembers();
                  }
                  setState(() {});
                },
                labelText: ' Select Task',
              ),
              SizedBox(height: 20),
              DropdownButtonFormField<int>(
                decoration: InputDecoration(
                    labelText: 'Select Team Member',
                    border: OutlineInputBorder()),
                items: team.map((member) {
                  return DropdownMenuItem<int>(
                    value: member['userId'],
                    child: Text(member['userName'] ?? 'Unknown'),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    selectedTeamMemberId = value;
                  });
                },
              ),
            ],
          ),
        );
      }),
      actions: [
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.green,
          ),
          onPressed: () {
            _addAssignTask();
          },
          child: Text(
            'Assign',
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

  void _confirmDeleteTask(int taskAssId) {
    showCustomAlertDialog(
      context,
      title: 'Delete Assigned Task',
      content: Text('Are you sure you want to delete this assigned task?'),
      actions: [
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.red,
          ),
          onPressed: () {
            _deleteTask(taskAssId);
            Navigator.pop(context);
          },
          child: Text(
            'Delete',
            style: TextStyle(color: Colors.white),
          ),
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

  Future<void> _deleteTask(int taskAssId) async {
    final response = await new ApiService().request(
      method: 'post',
      endpoint: 'tasks/DeleteAssignTask/$taskAssId',
        tokenRequired: true

    );
    if (response['statusCode'] == 200) {
      String message =
          response['message'] ?? 'Assigned task deleted successfully';
      showToast(msg: message, backgroundColor: Colors.green);
      fetchAssigntask();
    } else {
      String message = response['message'] ?? 'Failed to delete assigned task';
      showToast(msg: message);
    }
  }

  Future<void> _updateAssignTask(int taskAssId) async {
    if (selectedTaskId == null || selectedTeamMemberId == null) {
      showToast(msg: 'Please select a task and a team member.');
      return;
    }

    final response = await new ApiService().request(
      method: 'post',
      endpoint: 'tasks/EditAssignTask',
      tokenRequired: true,
      body: {
        'taskId': selectedTaskId,
        'taskAssignedTo': selectedTeamMemberId,
        'taskAssignedBy': userId,
        'taskAssId': taskAssId,
        'updateFlag': true,
      },
    );

    if (response['statusCode'] == 200) {
      showToast(
        msg: response['message'] ?? 'Task assignment updated successfully',
        backgroundColor: Colors.green,
      );
      Navigator.pop(context);
      fetchAssigntask();
    } else {
      showToast(msg: response['message'] ?? 'Failed to update task assignment');
    }
  }

  Future<void> _showEditTaskModal(int taskAssId) async {
    Map<String, dynamic> taskToEdit =
    assigntasks.firstWhere((task) => task['taskAssId'] == taskAssId);
    selectedTeamMemberId = taskToEdit['taskAssignedTo'];
    selectedTaskId = taskToEdit['taskId'];
    if (selectedTaskId != null) {
      await fetchTeamMembers();
    }

    showCustomAlertDialog(
      context,
      title: 'Edit Assign Task',
      content: StatefulBuilder(
        builder: (context, setState) {
          return SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(15.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 10),
                  CustomDropdown<String>(
                    options: tasks
                        .map((task) => task['taskId'].toString())
                        .toList(),
                    displayValue: (taskId) {
                      final task = tasks.firstWhere(
                              (task) => task['taskId'].toString() == taskId);
                      return task['taskTitle'];
                    },
                    selectedOption: selectedTaskId?.toString(),
                    onChanged: (value) async {
                      setState(() {
                        selectedTaskId =
                        value != null ? int.tryParse(value) : null;
                        team.clear();
                      });
                      if (selectedTaskId != null) {
                        await fetchTeamMembers();
                        if (!team.any((member) => member['userId'] == selectedTeamMemberId)) {
                          selectedTeamMemberId = null;
                        }
                      }
                      setState(() {});
                    },
                    labelText: 'Select Tasks',
                  ),
                  SizedBox(height: 10),
                  DropdownButtonFormField<int>(
                    value: selectedTeamMemberId,
                    decoration: InputDecoration(labelText: 'Select Team Member', border: OutlineInputBorder()),
                    items: team.map((member) {
                      return DropdownMenuItem<int>(
                        value: member['userId'],
                        child: Text(member['userName'] ?? 'Unknown'),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        selectedTeamMemberId = value;
                      });
                    },
                  ),
                ],
              ),
            ),
          );
        },
      ),
      actions: [
        ElevatedButton(
          onPressed: () {
            _updateAssignTask(taskAssId);
          },
          style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
          child: Text('Update Task', style: TextStyle(color: Colors.white)),
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
    return assigntasks.where((user) {
      bool matchesuserName = true;
      if (selectedUserName != null && selectedUserName!.isNotEmpty) {
        matchesuserName = user['taskAssignedToName'] == selectedUserName;
      }

      return matchesuserName;
    }).toList();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: 'Assign Task',
        onLogout: () => AuthService.logout(context),
      ),
      body: RefreshIndicator(
        onRefresh: fetchAssigntask,
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
                        return users
                            .where((user) => user['userName']!
                            .toLowerCase()
                            .contains(textEditingValue.text.toLowerCase()))
                            .map((user) => user['userName'] as String)
                            .toList();
                      },
                      onSelected: (String userName) {
                        setState(() {
                          selectedUserName = userName;
                        });
                        fetchAssigntask();
                      },
                      fieldViewBuilder: (context, controller, focusNode, onFieldSubmitted) {
                        return Container(
                          width: 290,
                          child: TextField(
                            controller: controller,
                            focusNode: focusNode,
                            decoration: InputDecoration(
                              labelText: 'Select User',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              prefixIcon: Icon(Icons.person),
                            ),
                            onChanged: (value) {
                              if (value.isEmpty) {
                                setState(() {
                                  selectedUserName = null;
                                });
                                fetchAssigntask();
                              }
                            },
                          ),
                        );
                      },
                    ),

                    IconButton(
                      icon:
                      Icon(Icons.add_circle, color: Colors.blue, size: 30),
                      onPressed: _showAddRoleModal,
                    ),
                  ],
                ),
                SizedBox(height: 20),
                if (isLoading)
                  Center(child: CircularProgressIndicator())
                else if (assigntasks.isEmpty)
                  NoDataFoundScreen()
                else if (getFilteredData().isEmpty)
                    NoDataFoundScreen()
                else
                  Column(
                    children: getFilteredData().map((task) {
                      Map<String, dynamic> taskFields = {
                        'Title': task['taskTitle'],
                        '': task[''],
                        'AssignedBy': task['taskAssignedByName'],
                        'AssignedTo': task['taskAssignedToName'],
                        'createdAt': task['createdAt'],
                        'updatedAt': task['updatedAt'],
                      };
                      return buildUserCard(
                        userFields: {
                          'Title': task['taskTitle'],
                          '': task[''],
                          'AssignedBy': task['taskAssignedByName'],
                          'AssignedTo': task['taskAssignedToName'],
                          'createdAt': task['createdAt'],
                          'updatedAt': task['updatedAt'],
                        },
                        onEdit: () => _showEditTaskModal(
                          task['taskAssId'],
                        ),
                        onDelete: () =>
                            _confirmDeleteTask(task['taskAssId']),
                        trailingIcon: Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            IconButton(
                              onPressed: () =>
                                  _showEditTaskModal(task['taskAssId']),
                              icon: Icon(
                                Icons.edit,
                                color: Colors.green,
                              ),
                            ),
                            IconButton(
                                onPressed: () => _confirmDeleteTask(
                                    task['taskAssId']),
                                icon: Icon(
                                  Icons.delete,
                                  color: Colors.red,
                                )),
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