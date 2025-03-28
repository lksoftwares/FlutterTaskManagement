
import 'package:intl/intl.dart';
import 'package:lktaskmanagementapp/packages/headerfiles.dart';

class TasksScreen extends StatefulWidget {
  const TasksScreen({super.key});

  @override
  State<TasksScreen> createState() => _TasksScreenState();
}
class _TasksScreenState extends State<TasksScreen> {
  List<Map<String, dynamic>> projects = [];
  List<Map<String, dynamic>> team = [];
  bool isLoading = false;
  String? selectedStatus = 'open';
  String? selectedPriority = 'medium';
  List<Map<String, dynamic>> tasks = [];
  String? selectedRoleName;
  String taskTitle = '';
  String taskDescription = '';
  DateTime? dueDate;
  int? userId;
  int? selectedTeamMemberId;
  int? selectedprojectId;


  @override
  void initState() {
    super.initState();
    fetchProjects();
    fetchTasks();
    _getUserId();
  }

  Future<void> _getUserId() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      userId = prefs.getInt('user_Id');
    });
  }

  Future<void> fetchTeamMembers() async {
    if (selectedprojectId == null) return;

    final response = await new ApiService().request(
      method: 'get',
      endpoint: 'teams/GetTeamMembers?projectId=$selectedprojectId',
        tokenRequired: true

    );

    print('Fetching team members for project ID: $selectedprojectId');

    if (response['statusCode'] == 200 && response['apiResponse'] != null) {
      setState(() {
        team = List<Map<String, dynamic>>.from(response['apiResponse']);
      });
      print('Team members fetched: $team');
    } else {
      showToast(msg: response['message'] ?? 'Failed to load team members');
    }
  }


  Future<void> fetchProjects() async {
    setState(() {
      isLoading = true;
    });

    final response = await new ApiService().request(
      method: 'get',
      endpoint: 'projects/',
        tokenRequired: true

    );
    if (response['statusCode'] == 200 && response['apiResponse'] != null) {
      setState(() {
        projects = List<Map<String, dynamic>>.from(
          response['apiResponse'].map((project) =>
          {
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
          response['apiResponse'].map((role) {
            final taskComments = role['taskComments'] as List<dynamic>?;
            return {
              'taskId': role['taskId'] ?? 0,
              'projectId': role['projectId'] ?? 0,
              'taskTitle': role['taskTitle'] ?? 'Unknown title',
              'taskDescription': role['taskDescription'] ?? 'Unknown description',
              'taskPriority': role['taskPriority'] ?? '',
              'taskStatus': role['taskStatus'] ?? '',
              'projectName': role['projectName'] ?? '',
              'comments': (role['taskComments'] as List<dynamic>?)
                  ?.map((commentMap) => commentMap['comment'])
                  .toList() ??
                  [],
              'userName': taskComments?.isNotEmpty == true ? taskComments![0]['userName'] : '',
              'taskAssignedToName': role['taskAssignedToName'],
              'taskCreatedByName': role['taskCreatedByName'] ?? '',
              'taskUpdatedByName': role['taskUpdatedByName'] ?? '',
              'taskDueDate': role['taskDueDate'] ?? '',
            };
          }).toList(),
        );
      });
      print(tasks);
    } else {
    }

    setState(() {
      isLoading = false;
    });
  }


  Future<void> _addTask() async {
    final response = await new ApiService().request(
      method: 'post',
      endpoint: 'tasks/create',
      tokenRequired: true,
      body: {
        'projectId': selectedprojectId,
        'taskTitle': taskTitle,
        'taskDescription': taskDescription,
        'taskPriority': selectedPriority,
        'taskDueDate': dueDate?.toIso8601String(),
        'taskStatus': selectedStatus,
        'taskAssignedTo': selectedTeamMemberId,
        'taskCreatedBy': userId,
        'taskUpdatedBy': userId,
        'taskVersion': 1,
      },
    );

    if (response['statusCode'] == 200) {
      showToast(msg: response['message'] ?? 'Task created successfully',
          backgroundColor: Colors.green);
      Navigator.pop(context);
      fetchTasks();
    } else {
      showToast(msg: response['message'] ?? 'Failed to create task');
    }
  }

  Future<void> _showAddTaskModal() async {
    setState(() {
      selectedprojectId = null;
      selectedTeamMemberId = null;
      dueDate = null;
      team.clear();
    });

    showCustomAlertDialog(
      context,
      title: 'Add Task',
      content: StatefulBuilder(
        builder: (context, setState) {
          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [

                CustomDropdown<String>(
                  options: projects.map((project) =>
                      project['projectId'].toString()).toList(),
                  displayValue: (projectId) {
                    final project = projects.firstWhere(
                            (project) =>
                        project['projectId'].toString() == projectId);
                    return project['projectName'];
                  },
                  onChanged: (value) async {
                    setState(() {
                      selectedprojectId =
                      value != null ? int.tryParse(value) : null;
                      team.clear();
                    });

                    print("Selected project ID: $selectedprojectId");

                    if (selectedprojectId != null) {
                      await fetchTeamMembers();
                    }
                    setState(() {});
                  },
                  labelText: ' Select Project',
                ),
                SizedBox(height: 10),
                DropdownButtonFormField<int>(
                  decoration: InputDecoration(labelText: 'Select Team Member',
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
                SizedBox(height: 10),
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
                  maxLines: 3,
                ),
                SizedBox(height: 10),

                CustomDropdown<String>(
                  options: ['low', 'medium', 'high'],
                  displayValue: (priority) => priority,
                  onChanged: (value) {
                    setState(() {
                      selectedPriority = value;
                    });
                  },
                  labelText: ' Select Priority',
                ),
                SizedBox(height: 10),
                CustomDropdown<String>(
                  options: ['open', 'in-progress', 'completed', 'blocked'],
                  displayValue: (status) => status,
                  onChanged: (value) {
                    setState(() {
                      selectedStatus = value;
                    });
                  },
                  labelText: 'Select Status',
                ),


                SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      dueDate != null
                          ? DateformatddMMyyyy.formatDateddMMyyyy(dueDate!)
                          : 'Select Due Date:', style: TextStyle(fontSize: 19),
                    ),
                    IconButton(
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
                            print(dueDate);
                          });
                        }
                      },
                      icon: Icon(Icons.calendar_month, size: 34),
                    ),
                  ],
                )
              ],
            ),
          );
        },
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

  void _confirmDeleteTask(int taskId) {
    showCustomAlertDialog(
      context,
      title: 'Delete Task',
      content: Text('Are you sure you want to delete this task?'),
      actions: [

        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.red,
          ),
          onPressed: () {
            _deleteTask(taskId);
            Navigator.pop(context);
          },
          child: Text('Delete', style: TextStyle(color: Colors.white),),
        ),
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text('Cancel'),
        ),
      ],
      titleHeight: 65,

    );
  }

  Future<void> _deleteTask(int taskId) async {
    final response = await new ApiService().request(
      method: 'post',
      endpoint: 'tasks/delete/$taskId',
      tokenRequired: true
    );
    if (response['statusCode'] == 200) {
      String message = response['message'] ?? ' deleted successfully';
      showToast(msg: message, backgroundColor: Colors.green);
      fetchTasks();
    } else {
      String message = response['message'] ?? 'Failed to delete task';
      showToast(msg: message);
    }
  }

  Future<void> _updateTask(int taskId) async {
    final response = await new ApiService().request(
      method: 'post',
      endpoint: 'tasks/Update',
      tokenRequired: true,
      body: {
        'taskId': taskId,
        'projectId': selectedprojectId,
        'taskTitle': taskTitle,
        'taskDescription': taskDescription,
        'taskPriority': selectedPriority,
        'taskDueDate': dueDate?.toIso8601String(),
        'taskStatus': selectedStatus,
        'taskAssignedTo': selectedTeamMemberId,
        'taskUpdatedBy': userId,
        'taskCreatedBy': userId,
        'taskVersion': 1,
        'updateFlag': true,
      },
    );
    if (response['statusCode'] == 200) {
      showToast(msg: response['message'] ?? 'Task updated successfully',
          backgroundColor: Colors.green);
      Navigator.pop(context);
      fetchTasks();
    } else {
      showToast(msg: response['message'] ?? 'Failed to update task');
    }
  }


  Future<void> _showEditTaskModal(int taskId) async {
    Map<String, dynamic> taskToEdit = tasks.firstWhere((
        task) => task['taskId'] == taskId);
    taskTitle = taskToEdit['taskTitle'] ?? '';
    taskDescription = taskToEdit['taskDescription'] ?? '';
    selectedprojectId = taskToEdit['projectId'];
    selectedTeamMemberId = taskToEdit['taskAssignedTo'];
    selectedPriority = taskToEdit['taskPriority'];
    selectedStatus = taskToEdit['taskStatus'];
    String dueDateString = taskToEdit['taskDueDate'] ?? '';
    dueDate = DateFormat('dd-MM-yyyy').parse(dueDateString);

    if (selectedprojectId != null) {
      await fetchTeamMembers();
    }
    print("SHreyashrma$selectedTeamMemberId");
    showCustomAlertDialog(
      context,
      title: 'Edit Task',
      content: StatefulBuilder(
        builder: (context, setState) {
          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CustomDropdown<String>(
                  options: projects.map((project) =>
                      project['projectId'].toString()).toList(),
                  displayValue: (projectId) {
                    final project = projects.firstWhere(
                            (project) =>
                        project['projectId'].toString() == projectId);
                    return project['projectName'];
                  },
                  selectedOption: selectedprojectId?.toString(),
                  onChanged: (value) async {
                    setState(() {
                      selectedprojectId =
                      value != null ? int.tryParse(value) : null;
                      team.clear();
                    });
                    if (selectedprojectId != null) {
                      await fetchTeamMembers();
                      if (!team.any((member) =>
                      member['userId'] == selectedTeamMemberId)) {
                        selectedTeamMemberId = null;
                      }
                    }
                    setState(() {});
                  },
                  labelText: 'Select Project',
                ),
                SizedBox(height: 10),
                DropdownButtonFormField<int>(
                  value: selectedTeamMemberId,
                  decoration: InputDecoration(labelText: 'Select Team Member',
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
                SizedBox(height: 10),
                TextField(
                  controller: TextEditingController(text: taskTitle),
                  onChanged: (value) => taskTitle = value,
                  decoration: InputDecoration(
                    labelText: 'Task Title',
                    border: OutlineInputBorder(),
                  ),
                ),
                SizedBox(height: 10),

                TextField(
                  controller: TextEditingController(text: taskDescription),
                  onChanged: (value) => taskDescription = value,
                  decoration: InputDecoration(
                    labelText: 'Task Description',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 3,
                ),
                SizedBox(height: 10),

                CustomDropdown<String>(
                  options: ['low', 'medium', 'high'],
                  displayValue: (priority) => priority,
                  selectedOption: selectedPriority,
                  onChanged: (value) {
                    setState(() {
                      selectedPriority = value;
                    });
                  },
                  labelText: 'Select Priority',
                ),
                SizedBox(height: 10),
                CustomDropdown<String>(
                  options: ['open', 'in-progress', 'completed', 'blocked'],
                  displayValue: (status) => status,
                  selectedOption: selectedStatus,
                  onChanged: (value) {
                    setState(() {
                      selectedStatus = value;
                    });
                  },
                  labelText: 'Select Status',
                ),
                SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      dueDate != null
                          ? DateformatddMMyyyy.formatDateddMMyyyy(dueDate!)
                          : 'Select Due Date:', style: TextStyle(fontSize: 19),
                    ), IconButton(
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
                      icon: Icon(Icons.calendar_month, size: 34),
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
          onPressed: () {
            _updateTask(taskId);
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


  Future<void> _addComments(int taskId, String comment) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    int? userId = prefs.getInt('user_Id');

    if (userId == null) {
      showToast(msg: 'User ID is not found');
      return;
    }

    final response = await new ApiService().request(
      method: 'post',
      endpoint: 'tasks/AddComment',
      tokenRequired: true,
      body: {
        'userId': userId,
        'taskId': taskId,
        'comment': comment,
      },
    );

    if (response.isNotEmpty && response['statusCode'] == 200) {
      fetchTasks();
      showToast(
        msg: response['message'] ?? 'Comment added successfully',
        backgroundColor: Colors.green,
      );
      Navigator.pop(context);
    } else {
      showToast(
        msg: response['message'] ?? 'Failed to add comment',
      );
    }
  }

  Future<void> _showAddCommentModal(int taskId) async {
    String comment = '';
    InputDecoration inputDecoration = InputDecoration(
      labelText: 'Comment',
      border: OutlineInputBorder(),
    );
    showCustomAlertDialog(
      context,
      title: 'Add Comment',
      content: StatefulBuilder(
        builder: (context, setState) {
          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                onChanged: (value) => comment = value,
                decoration: inputDecoration,
              ),
            ],
          );
        },
      ),
      actions: [
        ElevatedButton(
          style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
          onPressed: () {
            if (comment.isEmpty) {
              showToast(msg: 'Please enter a comment');
              return;
            }
            _addComments(taskId, comment);
          },
          child: Text('Add', style: TextStyle(color: Colors.white)),
        ),
        TextButton(
            onPressed: () => Navigator.pop(context), child: Text('Cancel')),
      ],
      titleHeight: 70,
    );
  }

  Future<void> _showCommentsModal(int taskId) async {
    final task = tasks.firstWhere((task) => task['taskId'] == taskId);
    List<dynamic> comments = task['comments'] ?? [];
    String? userName = task['userName'];
    showCustomAlertDialog(
      context,
      title: "Comments",
      content: SingleChildScrollView(
        child: Container(
          height: 250,
          child: Column(
            children: [
              SizedBox(height: 4),
              if (comments.isEmpty)
                Text(
                  'No comments yet.',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey[600],
                    fontStyle: FontStyle.italic,
                  ),
                )
              else
                Expanded(
                  child: Container(
                    child: ListView.builder(
                      shrinkWrap: true,
                      itemCount: comments.length,
                      itemBuilder: (context, index) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4.0),
                          child: Card(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            elevation: 4,
                            child: ListTile(
                              contentPadding: EdgeInsets.symmetric(horizontal: 12.0),
                              leading: Icon(Icons.comment_outlined, color: Colors.blue),
                              title: Text(
                                comments[index].toString(),
                                style: TextStyle(fontSize: 16),
                              ),
                              tileColor: Colors.blue[50],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(
            'Close',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
      titleHeight: 90,
      additionalTitleContent: Column(
        children: [
          if (userName != null && userName.isNotEmpty)
            SizedBox(height: 8,),
          Padding(
            padding: const EdgeInsets.only(bottom: 0.0),
            child: Text(
              'Username: $userName',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: 'Tasks',
        onLogout: () => AuthService.logout(context),
      ),
      body: RefreshIndicator(
        onRefresh: fetchTasks,
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
                      icon: Icon(
                          Icons.add_circle, color: Colors.blue, size: 30),
                      onPressed: _showAddTaskModal,
                    ),
                  ],
                ),
                SizedBox(height: 20),
                if (isLoading)
                  Center(child: CircularProgressIndicator())
                else
                  if (tasks.isEmpty)
                    NoDataFoundScreen()
                  else
                    Column(
                      children: tasks.map((task) {
                        String allComments = (task['comments'] as List<
                            dynamic>?) == null ||
                            (task['comments'] as List<dynamic>).isEmpty
                            ? 'No comments'
                            : "Check Comment ";

                        Map<String, dynamic> taskFields = {
                          'projectName': task['projectName'],
                          '': task[''],
                          'Title': task['taskTitle'],
                          'Description': task['taskDescription'],
                          'AssignedTo': task['taskAssignedToName'],
                          'Priority': task['taskPriority'],
                          'Status': task['taskStatus'],
                          'DueDate': task['taskDueDate'],
                          'Comment': allComments,
                          'CreatedBy': task['taskCreatedByName'],
                          'UpdatedBy': task['taskUpdatedByName'],
                        };

                        bool canComment = task['taskStatus'] == 'open' ||
                            task['taskStatus'] == 'in-progress';
                        return buildUserCard(
                          userFields: taskFields,
                          onEdit: () => _showEditTaskModal(task['taskId']),
                          onDelete: () => _confirmDeleteTask(task['taskId']),
                          leadingIcon3: Row(
                            children: [
                              if (task['comments'] == null ||
                                  task['comments'].isEmpty)
                                Container()
                              else
                                IconButton(
                                  icon: Icon(
                                      Icons.comment, color: Colors.orange,size: 25,),
                                  onPressed: () =>
                                      _showCommentsModal(task['taskId']),
                                ),
                            ],
                          ),
                          trailingIcon: Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              if (canComment)
                                IconButton(
                                  onPressed: () =>
                                      _showAddCommentModal(task['taskId']),
                                  icon: Icon(
                                      Icons.comment, color: Colors.orange),
                                ),
                              IconButton(
                                onPressed: () =>
                                    _showEditTaskModal(task['taskId']),
                                icon: Icon(Icons.edit, color: Colors.green),
                              ),
                              IconButton(
                                onPressed: () =>
                                    _confirmDeleteTask(task['taskId']),
                                icon: Icon(Icons.delete, color: Colors.red),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                    ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}