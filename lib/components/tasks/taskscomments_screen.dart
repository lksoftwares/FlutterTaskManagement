import 'package:lktaskmanagementapp/packages/headerfiles.dart';

class TaskscommentsScreen extends StatefulWidget {
  const TaskscommentsScreen({super.key});

  @override
  State<TaskscommentsScreen> createState() => _TaskscommentsScreenState();
}

class _TaskscommentsScreenState extends State<TaskscommentsScreen> {
  List<Map<String, dynamic>> comments = [];
  List<Map<String, dynamic>> tasksList = [];
  String? roleName;
  String? selectedUserName;

  bool isLoading = false;
  int? selectedUserId;
  List<Map<String, dynamic>> usersList = [];

  int? selectedtaskId;

  @override
  void initState() {
    super.initState();
    fetchUsers();
    fetchComments();
    _getRoleName();
  }

  Future<void> _getRoleName() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      roleName = prefs.getString('role_Name');
    });
  }

  Future<void> fetchUsers() async {
    final response = await new ApiService().request(
      method: 'get',
      endpoint: 'User/?status=1',
      tokenRequired: true,

    );
    if (response['statusCode'] == 200 && response['apiResponse'] != null) {
      setState(() {
        usersList = List<Map<String, dynamic>>.from(response['apiResponse']);
      });
    } else {
      print( 'Failed to load users');
    }
  }

  Future<void> fetchTasks() async {
    final response = await new ApiService().request(
      method: 'get',
      endpoint: 'tasks',
      tokenRequired: true,

    );
    if (response['statusCode'] == 200 && response['apiResponse'] != null) {
      setState(() {
        tasksList = List<Map<String, dynamic>>.from(response['apiResponse']["taskList"]);
      });
    } else {
      print('Failed to load tasks');
    }
  }

  Future<void> fetchComments() async {
    setState(() {
      isLoading = true;
    });

    final response = await new ApiService().request(
      method: 'get',
      endpoint: 'tasks/GetAllComments',
      tokenRequired: true,

    );
    print('Response: $response');
    if (response['statusCode'] == 200 && response['apiResponse'] != null) {
      setState(() {
        comments = List<Map<String, dynamic>>.from(
          response['apiResponse'].map((comment) => {
            'taskId': comment['taskId'] ?? 0,
            'projectId': comment['projectId'] ?? 0,
            'taskTitle': comment['taskTitle'] ?? "",
            'taskCmmntId': comment['taskCmmntId'] ?? 0,
            'comment': comment['comment'] ?? 'Unknown comment',
            'userName': comment['userName'] ?? 'Unknown user',
            'createdAt': comment['createdAt'] ?? '',
          }),
        );
      });
    } else {
      print('Failed to load comments');
    }
    setState(() {
      isLoading = false;
    });
  }

  Future<void> _addComments(int userId, int taskId, String comment) async {
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
      fetchComments();
      showToast(
        msg: response['message'] ?? 'comment added successfully',
        backgroundColor: Colors.green,
      );
      Navigator.pop(context);
    } else {
      showToast(
        msg: response['message'] ?? 'Failed to add comment',
      );
    }
  }

  Future<void> _showAddCommentModal() async {
    String comment = '';
    InputDecoration inputDecoration = InputDecoration(
      labelText: 'Comment',
      border: OutlineInputBorder(),
    );

    setState(() {
      selectedUserId = null;
      selectedtaskId = null;
      comment == null;
    });

    await fetchTasks();

    showCustomAlertDialog(
      context,
      title: 'Add Comment',
      content: StatefulBuilder(
        builder: (context, setState) {
          return Padding(
            padding: const EdgeInsets.all(15.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(height: 20,),
                TextField(
                  onChanged: (value) => comment = value,
                  decoration: inputDecoration,
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
                  options: tasksList.map<int>((task) => task['taskId'] as int).toList(),
                  selectedOption: selectedtaskId,
                  displayValue: (taskId) => tasksList.firstWhere((task) => task['taskId'] == taskId)['taskTitle'],
                  onChanged: (value) {
                    setState(() {
                      selectedtaskId = value;
                    });
                  },
                  labelText: 'Select Task',
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
            if (selectedUserId == null || selectedtaskId == null || comment == null) {
              showToast(msg: 'Please select all fields');
              return;
            }
            _addComments(selectedUserId!, selectedtaskId!, comment!);
          },
          child: Text('Add', style: TextStyle(color: Colors.white)),
        ),
        TextButton(onPressed: () => Navigator.pop(context), child: Text('Cancel')),
      ],
      titleHeight: 65,
    );
  }

  void _confirmDeleteComment(int taskCmmntId) {
    showCustomAlertDialog(
      context,
      title: 'Delete Comment',
      content: Text('Are you sure you want to delete this comment?'),
      actions: [
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.red,
          ),
          onPressed: () {
            _deleteComment(taskCmmntId);
            Navigator.pop(context);
            fetchComments();

          },
          child: Text('Delete', style: TextStyle(color: Colors.white)),
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

  Future<void> _deleteComment(int taskCmmntId) async {
    final response = await new ApiService().request(
      method: 'post',
      endpoint: 'tasks/deleteComment',
      tokenRequired: true,

      body: {
        "taskCmmntId": taskCmmntId,
        "delAllFlag": false
      },
    );
    if (response['statusCode'] == 200) {
      String message = response['message'] ?? 'Comment deleted successfully';
      showToast(msg: message, backgroundColor: Colors.green);
      fetchComments();
    } else {
      String message = response['message'] ?? 'Failed to delete comment';
      showToast(msg: message);
    }
  }

  void _confirmDeleteAllComments() {
    showCustomAlertDialog(
      context,
      title: 'Delete All Comments',
      content: Text('Are you sure you want to delete all comments?'),
      actions: [
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.red,
          ),
          onPressed: () {
            _deleteAllComments();
            Navigator.pop(context);
            fetchComments();
          },
          child: Text('Delete All', style: TextStyle(color: Colors.white)),
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

  Future<void> _deleteAllComments() async {
    final response = await new ApiService().request(
      method: 'post',
      endpoint: 'tasks/deleteComment',
      tokenRequired: true,

      body: {
        "taskCmmntId": 0,
        "delAllFlag": true
      },
    );
    if (response['statusCode'] == 200) {
      String message = response['message'] ?? 'All comments deleted successfully';
      showToast(msg: message, backgroundColor: Colors.green);
      fetchComments();
    } else {
      String message = response['message'] ?? 'Failed to delete all comments';
      showToast(msg: message);
    }
  }
  List<Map<String, dynamic>> getFilteredData() {
    return usersList.where((role) {
      bool matchesUserName = true;
      if (selectedUserName != null && selectedUserName!.isNotEmpty) {
        matchesUserName = role['userName'] == selectedUserName;
      }

      return matchesUserName ;
    }).toList();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: 'Tasks Comments',
        onLogout: () => AuthService.logout(context),
      ),
      body: RefreshIndicator(
        onRefresh: fetchComments,
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: [
                SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    // Autocomplete<String>(
                    //   optionsBuilder: (TextEditingValue textEditingValue) {
                    //     return usersList
                    //         .where((user) => user['userName']!
                    //         .toLowerCase()
                    //         .contains(textEditingValue.text.toLowerCase()))
                    //         .map((user) => user['userName'] as String)
                    //         .toList();
                    //   },
                    //   onSelected: (String userName) {
                    //     setState(() {
                    //       selectedUserName = userName;
                    //     });
                    //     fetchComments();
                    //   },
                    //   fieldViewBuilder: (context, controller, focusNode, onFieldSubmitted) {
                    //     return Container(
                    //       width: 230,
                    //       child: TextField(
                    //         controller: controller,
                    //         focusNode: focusNode,
                    //         decoration: InputDecoration(
                    //           labelText: 'Select User',
                    //           border: OutlineInputBorder(
                    //             borderRadius: BorderRadius.circular(10),
                    //           ),
                    //           prefixIcon: Icon(Icons.person),
                    //         ),
                    //         onChanged: (value) {
                    //           if (value.isEmpty) {
                    //             setState(() {
                    //               selectedUserName = null;
                    //             });
                    //             fetchComments();
                    //           }
                    //         },
                    //       ),
                    //     );
                    //   },
                    // ),
                    IconButton(
                      icon: Icon(Icons.add_circle, color: Colors.blue, size: 30),
                      onPressed: _showAddCommentModal,
                    ),
                    if (roleName == "Admin")
                      Row(
                        children: [
                          IconButton(
                            icon: Icon(Icons.delete, color: Colors.red, size: 30),
                            onPressed: _confirmDeleteAllComments,
                          ),
                        ],
                      ),
                  ],
                ),
                SizedBox(height: 20),
                if (isLoading)
                  Center(child: CircularProgressIndicator())
                else if (comments.isEmpty)
                  NoDataFoundScreen()
                else
                  Column(
                    children: comments.map((comment) {
                      Map<String, dynamic> commentFields = {
                        'Username': comment['userName'],
                        '': comment[''],
                        'TaskTitle': comment['taskTitle'],
                        'Comment': comment['comment'],
                        'CreatedAt': comment['createdAt'],
                      };

                      return buildUserCard(
                        userFields: commentFields,
                        onDelete: () => _confirmDeleteComment(comment['taskCmmntId']),
                        trailingIcon: Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            if (roleName == "Admin")
                              IconButton(
                                onPressed: () => _confirmDeleteComment(comment['taskCmmntId']),
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
