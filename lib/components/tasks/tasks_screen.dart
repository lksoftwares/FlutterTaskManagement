
import 'package:lktaskmanagementapp/packages/headerfiles.dart';

class TasksScreen extends StatefulWidget {
  const TasksScreen({super.key});

  @override
  State<TasksScreen> createState() => _TasksScreenState();
}


class _TasksScreenState extends State<TasksScreen> {
  List<Map<String, dynamic>> projects = [];
  bool isLoading = false;
  String? selectedStatus = 'open';
  String? selectedPriority = 'medium';
  List<Map<String, dynamic>> roles = [];
  String? selectedRoleName;
  String? selectedProject;
  String taskTitle = '';
  String taskDescription = '';
  DateTime? dueDate;
  int? userId;

  @override
  void initState() {
    super.initState();
    fetchProjects();
    _getUserId();
  }

  Future<void> _getUserId() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      userId = prefs.getInt('user_Id');
    });
  }

  Future<void> fetchProjects() async {
    setState(() {
      isLoading = true;
    });

    final response = await new ApiService().request(
      method: 'get',
      endpoint: 'projects/GetAllProject',
    );
    print('Response: $response');
    if (response['statusCode'] == 200 && response['apiResponse'] != null) {
      setState(() {
        projects = List<Map<String, dynamic>>.from(
          response['apiResponse'].map((project) => {
            'projectId': project['projectId'] ?? 0,
            'projectName': project['projectName'] ?? 'Unknown project',
          }),
        );
      });
    } else {
      showToast(msg: response['message'] ?? 'Failed to load projects');
    }
    setState(() {
      isLoading = false;
    });
  }
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

  Future<void> _addTask() async {
    if (taskTitle.isEmpty || taskDescription.isEmpty || selectedProject == null || dueDate == null) {
      showToast(msg: 'Please fill in all the fields');
      return;
    }

    final response = await new ApiService().request(
      method: 'post',
      endpoint: 'tasks/create',
      body: {
        'projectId': selectedProject,
        'taskTitle': taskTitle,
        'taskDescription': taskDescription,
        'taskPriority': selectedPriority,
        'taskDueDate': dueDate?.toIso8601String(),
        'taskStatus': selectedStatus,
        'taskAssignedTo': userId,
        'taskCreatedBy': userId,
        'taskUpdatedBy': userId,
        'taskVersion': 1,
      },
    );

    if (response['statusCode'] == 200) {
      showToast(msg: response['message'] ?? 'Task created successfully', backgroundColor: Colors.green);
      Navigator.pop(context);
    } else {
      showToast(msg: response['message'] ?? 'Failed to create task');
    }
  }

  void _showAddTaskModal() {
    showCustomAlertDialog(
      context,
      title: 'Add Task',
      content: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextField(
            onChanged: (value) => taskTitle = value,
            decoration: InputDecoration(
              labelText: 'Task Title',
              border: OutlineInputBorder(),
            ),
          ),
          SizedBox(height: 10),
          TextField(
            onChanged: (value) => taskDescription = value,
            decoration: InputDecoration(
              labelText: 'Task Description',
              border: OutlineInputBorder(),
            ),
          ),
          SizedBox(height: 10),
          DropdownButtonFormField<String>(
            value: selectedPriority,
            decoration: InputDecoration(labelText: 'Priority'),
            onChanged: (value) {
              setState(() {
                selectedPriority = value;
              });
            },
            items: ['low', 'medium', 'high'].map((priority) {
              return DropdownMenuItem<String>(
                value: priority,
                child: Text(priority),
              );
            }).toList(),
          ),
          SizedBox(height: 10),
          DropdownButtonFormField<String>(
            value: selectedStatus,
            decoration: InputDecoration(labelText: 'Status'),
            onChanged: (value) {
              setState(() {
                selectedStatus = value;
              });
            },
            items: ['open', 'in-progress', 'completed', 'blocked'].map((status) {
              return DropdownMenuItem<String>(
                value: status,
                child: Text(status),
              );
            }).toList(),
          ),
          SizedBox(height: 10),
          DropdownButtonFormField<String>(
            value: selectedProject,
            decoration: InputDecoration(labelText: 'Project'),
            onChanged: (value) {
              setState(() {
                selectedProject = value;
              });
            },
            items: projects.map((project) {
              return DropdownMenuItem<String>(
                value: project['projectId'].toString(),
                child: Text(project['projectName']),
              );
            }).toList(),
          ),
          SizedBox(height: 10),
          TextButton(
            onPressed: () async {
              DateTime? pickedDate = await showDatePicker(
                context: context,
                initialDate: dueDate ?? DateTime.now(),
                firstDate: DateTime(2000),
                lastDate: DateTime(2101),
              );
              if (pickedDate != null) {
                setState(() {
                  dueDate = pickedDate;
                });
              }
            },
            child: Text(dueDate == null ? 'Select Due Date' : dueDate!.toLocal().toString().split(' ')[0]),
          ),
        ],
      ),
      actions: [
        ElevatedButton(
          onPressed: _addTask,
          style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
          child: Text('Add Task', style: TextStyle(color: Colors.white)),
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
      method: 'post',
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
        title: 'Tasks',
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
                              labelText: 'Select Tasks',
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
                      onPressed: _showAddTaskModal,
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