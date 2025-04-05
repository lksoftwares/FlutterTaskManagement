import 'dart:convert';
import 'package:http_parser/http_parser.dart';
import 'package:intl/intl.dart';
import 'package:lktaskmanagementapp/packages/headerfiles.dart';
import 'package:http/http.dart' as http;
class TasksScreen extends StatefulWidget {
  const TasksScreen({super.key});

  @override
  State<TasksScreen> createState() => _TasksScreenState();
}
class _TasksScreenState extends State<TasksScreen> {
  List<Map<String, dynamic>> projects = [];
  List<Map<String, dynamic>> team = [];
  String? selectedProjectName;
  bool isAllFieldsVisible = false;
  bool isLoading = false;
  String? selectedStatus = 'open';
  String? selectedPriority = 'medium';
  List<Map<String, dynamic>> tasks = [];
  String? selectedRoleName;
  String taskTitle = '';
  String taskDescription = '';
  DateTime? dueDate;
  int? userId;
  Map<String, bool> taskExpansionStates = {};
  int? selectedTeamMemberId;
  int? selectedprojectId;
  String? roleName;
  FlutterSoundRecorder? _recorder;
  FlutterSoundPlayer? _player;
  bool isRecording = false;
  String? audioFilePath;
  bool isPlaying = false;
  Map<String, bool> isPlayingMap = {};


  @override
  void initState() {
    super.initState();
    _initializeRecorder();
    _initializePlayer();
    fetchProjects();
    fetchTasks();
    _getUserId();
  }

  Future<void> _initializeRecorder() async {
    _recorder = FlutterSoundRecorder();
    await _recorder!.openRecorder();
  }
  Future<void> _initializePlayer() async {
    _player = FlutterSoundPlayer();
    await _player!.openPlayer();
  }

  Future<void> _startRecording() async {
    PermissionStatus status = await Permission.microphone.request();
    if (status.isGranted) {
      String path = await _getFilePath();
      await _recorder!.startRecorder(toFile: path);
      setState(() {
        audioFilePath = path;
      });
      showToast(msg: "Recording started!", backgroundColor: Colors.green);
      print("Recording started. File path: $audioFilePath");
    } else {
      showToast(msg: "Permission denied. Please allow microphone access.");
    }
  }

  Future<void> _stopRecording() async {
    await _recorder!.stopRecorder();
    setState(() {
      isRecording = false;
    });
    showToast(msg: "Recording stopped!", backgroundColor: Colors.green);
    print("Recording stopped. File saved at: $audioFilePath");
  }

  Future<void> _playAudio(audioFilePath) async {
    if (audioFilePath != null && audioFilePath!.isNotEmpty) {
      setState(() {
        isPlaying = true;
      });
      await _player!.startPlayer(
        fromURI: audioFilePath!,
        whenFinished: () {
          setState(() {
            isPlaying = false;
          });
        },
      );
      print("Audio playing from path: $audioFilePath");
    }
  }

  Future<String> _getFilePath() async {
    Directory appDirectory = await getApplicationDocumentsDirectory();
    String path = '${appDirectory.path}/recording.aac';
    return path;
  }

  Future<void> _getUserId() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      userId = prefs.getInt('user_Id');
      roleName = prefs.getString('role_Name');
    });
  }

  Future<void> fetchTeamMembers() async {
    if (selectedprojectId == null) return;

    final response = await new ApiService().request(
        method: 'get',
        endpoint: 'teams/GetTeamMembers?projectId=$selectedprojectId&status=1',
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
        endpoint: 'projects/?status=1',
        tokenRequired: true
    );

    print('Response: $response');

    if (response['statusCode'] == 200 && response['apiResponse'] != null) {
      setState(() {
        projects = List<Map<String, dynamic>>.from(
          response['apiResponse']['projectList'].map((role) => {
            'projectId': role['projectId'] ?? 0,
            'projectName': role['projectName'] ?? 'Unknown project',
          }),
        );
      });
    } else {
      showToast(msg: response['message'] ?? 'Failed to load team');
    }

    setState(() {
      isLoading = false;
    });
  }
  Future<void> fetchTasks() async {
    setState(() {
      isLoading = true;
    });
    SharedPreferences prefs = await SharedPreferences.getInstance();
    int? userId = prefs.getInt('user_Id');
    roleName = prefs.getString('role_Name');
    String endpoint = 'tasks/';
    if (roleName == 'Admin') {
      endpoint = 'tasks/';
    } else if (userId != null) {
      endpoint = 'tasks/?userId=$userId';
    }
    final response = await new ApiService().request(
        method: 'get',
        endpoint: endpoint,
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
              'taskAssignedTo': role['taskAssignedTo'] ?? '',
              'taskStatus': role['taskStatus'] ?? '',
              'projectName': role['projectName'] ?? '',
              'comments': (role['taskComments'] as List<dynamic>?)
                  ?.map((commentMap) => commentMap['comment'])
                  .toList() ??
                  [],
              'userName': (role['taskComments'] as List<dynamic>?)
                  ?.map((commentMap) => commentMap['userName'])
                  .toList() ??
                  [],
              'createdAt': (role['taskComments'] as List<dynamic>?)
                  ?.map((commentMap) => commentMap['createdAt'])
                  .toList() ??
                  [],
              'audioFilePath': (role['taskComments'] as List<dynamic>?)
                  ?.map((commentMap) => commentMap['audioFilePath'])
                  .toList() ??
                  [],

              'taskAssignedToName': role['taskAssignedToName'],
              'taskCreatedByName': role['taskCreatedByName'] ?? '',
              'taskUpdatedByName': role['taskUpdatedByName'] ?? '',
              'taskDueDate': role['taskDueDate'] ?? '',
            };
          }).toList(),
        );
      });
      print("shreya$tasks");
    } else {}

    setState(() {
      isLoading = false;
    });
  }

  Future<void> _addTask() async {
    final dueDateToSend = dueDate?.toIso8601String() ?? DateTime.now().toIso8601String();
    final response = await new ApiService().request(
      method: 'post',
      endpoint: 'tasks/create',
      tokenRequired: true,
      body: {
        'projectId': selectedprojectId,
        'taskTitle': taskTitle,
        'taskDescription': taskDescription,
        'taskPriority': selectedPriority,
        'taskDueDate': dueDateToSend,
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
              child: Padding(
                padding: const EdgeInsets.all(20.0),
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
                      decoration: InputDecoration(
                        labelText: 'Select Team Member',
                        border: OutlineInputBorder(),
                      ),
                      items: team.map((member) {
                        return DropdownMenuItem<int>(
                          value: member['userId'],
                          child: Text(
                            '${member['userName'] ?? 'Unknown'}',
                            style: TextStyle(fontSize: 16),
                          ),
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

                    SizedBox(height: 15),
                    TextField(
                      controller: TextEditingController(
                          text: dueDate != null
                              ? DateformatddMMyyyy.formatDateddMMyyyy(dueDate!)
                              : DateformatddMMyyyy.formatDateddMMyyyy(DateTime.now())
                      ),
                      readOnly: true,
                      onTap: () async {
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
                      decoration: InputDecoration(
                        labelText: 'Select Due Date',
                        border: OutlineInputBorder(),
                        suffixIcon: Icon(Icons.calendar_month),

                      ),
                    )

                  ],
                ),
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
        isFullScreen: true
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
        isFullScreen: false

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
              child: Padding(
                padding: const EdgeInsets.all(20.0),
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
                          child: Text(
                            '${member['userName'] ?? 'Unknown'}',
                            style: TextStyle(fontSize: 16),
                          ),                      );
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
                    SizedBox(height: 15),

                    TextField(
                      controller: TextEditingController(
                          text: dueDate != null
                              ? DateFormat('dd-MM-yyyy').format(dueDate!)
                              : 'Select Due Date'

                      ),

                      readOnly: true,
                      onTap: () async {
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
                      decoration: InputDecoration(
                        labelText: 'Select Due Date',
                        border: OutlineInputBorder(),
                        suffixIcon: Icon(Icons.calendar_month),
                      ),
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
        isFullScreen: true
    );
  }

  Future<void> _addComments(int taskId, String comment) async {
    if (comment.isEmpty && audioFilePath == null) {
      showToast(msg: 'Please fill in either the description or add an audio recording.', backgroundColor: Colors.red);
      return;
    }
    SharedPreferences prefs = await SharedPreferences.getInstance();
    int? userId = prefs.getInt('user_Id');

    if (userId == null) {
      showToast(msg: 'User ID is not found');
      return;
    }
    if (comment.isEmpty) {
      comment = "Check audio";
    }
    final uri = Uri.parse('${Config.apiUrl}tasks/AddComment');

    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString('token');

      if (token == null) {
        showToast(msg: 'No token found.', backgroundColor: Colors.red);
        return;
      }

      var request = http.MultipartRequest('POST', uri);

      request.headers['Authorization'] = 'Bearer $token';

      request.fields['comment'] = comment;
      request.fields['userId'] = userId.toString();
      request.fields['taskId'] = taskId.toString();

      if (audioFilePath != null) {
        var file = await http.MultipartFile.fromPath(
          'audioFile',
          audioFilePath!,
          contentType: MediaType('audio', 'aac'),
        );
        request.files.add(file);
      }
      var response = await request.send();
      final responseData = await http.Response.fromStream(response);
      final responseJson = jsonDecode(responseData.body);
      if (response.statusCode == 200) {
        if (responseJson != null && responseJson['message'] != null) {
          showToast(msg: responseJson['message'], backgroundColor: Colors.green);
        }
        fetchTasks();
        Navigator.pop(context);
      } else {
        showToast(msg: responseJson['message'], backgroundColor: Colors.green);
      }
    } catch (e) {
      print("Error uploading working desc: $e");
      showToast(msg: 'An error occurred while uploading');
    }
  }


  Future<void> _showAddCommentModal(int taskId) async {
    String comment = '';
    InputDecoration inputDecoration = InputDecoration(
      labelText: 'Comment',
      border: OutlineInputBorder(),
    );
    setState(() {
      audioFilePath = null;
      isRecording = false;
      isPlayingMap.clear();
      isPlaying = false;
    });
    showCustomAlertDialog(
      context,
      title: 'Add Comment',
      content: StatefulBuilder(
        builder: (context, setState) {
          return Padding(
            padding: const EdgeInsets.all(15.0),
            child: Container(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(height: 30,),
                  TextField(
                    onChanged: (value) => comment = value,
                    decoration: inputDecoration,
                    maxLines: 4,
                  ),
                  SizedBox(height: 30,),
                  Text("Add Audio Comment", style: TextStyle(fontWeight: FontWeight.w900,fontSize: 20)),
                  SizedBox(height: 20,),
                  Padding(
                    padding: const EdgeInsets.only(left: 140.0),
                    child: Row(
                      children: [
                        GestureDetector(
                            onTap: () {
                              if (isRecording) {
                                _stopRecording();
                                setState(() {
                                  isRecording = false;
                                });
                              } else {
                                setState(() {
                                  isRecording = true;
                                });
                                _startRecording();
                              }
                            },
                            child: isRecording
                                ? Avatar()
                                : Icon(Icons.mic, color: Color(0xFF005296), size: 40)
                        ),
                        if (audioFilePath != null)
                          IconButton(
                            icon: Icon(
                              isPlaying ? Icons.pause : Icons.play_arrow,
                              size: 35,
                            color: isPlaying ? Colors.red : Colors.green,
                            ),
                            onPressed: () {
                              if (isPlaying) {
                                setState(() {
                                  isPlaying = false;
                                });
                              } else {
                                _playAudio(audioFilePath);
                                setState(() {
                                  isPlaying = true;
                                });
                              }
                            },
                            tooltip: isPlaying ? "Pause Recording" : "Play Recording",
                          ),

                      ],
                    ),
                  ),

                ],
              ),
            ),
          );
        },
      ),
      actions: [
        ElevatedButton(
          style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
          onPressed: () {
            if (comment.isEmpty && audioFilePath == null) {
              showToast(msg: 'Please enter either comment or record audio');
              return;
            }
            _addComments(taskId, comment,);
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
    List<dynamic> userName = task['userName'] ?? [];
    List<dynamic> createdAt = task['createdAt'] ?? [];
    List<dynamic> audioFilePath = task['audioFilePath'] ?? [];
    Map<int, bool> isPlayingMap = {};

    showCustomAlertDialog(
      context,
      title: "Comments",
      content: StatefulBuilder(
        builder: (context, setState) {
          return SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(15.0),
              child: Container(
                height: 500,
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
                              final comment = comments[index];
                              final commentUserName = userName[index];
                              final commentdate = createdAt[index];
                              final commentAudio = audioFilePath[index];

                              if (!isPlayingMap.containsKey(index)) {
                                isPlayingMap[index] = false;
                              }

                              return Padding(
                                padding: const EdgeInsets.symmetric(vertical: 4.0),
                                child: Card(
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  elevation: 4,
                                  child: ListTile(
                                    contentPadding:
                                    EdgeInsets.symmetric(horizontal: 12.0),
                                    leading: Padding(
                                      padding: const EdgeInsets.only(bottom: 40.0),
                                      child: Icon(Icons.comment_outlined,
                                          color: Colors.blue),
                                    ),
                                    title: Row(
                                      mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          comment.toString(),
                                          style: TextStyle(fontSize: 16),
                                        ),
                                        if (commentAudio != null)
                                          IconButton(
                                            icon: Icon(
                                              isPlayingMap[index]!
                                                  ? Icons.pause
                                                  : Icons.play_arrow,
                                                    size: 35,
                                              color: isPlayingMap[index]!
                                                  ? Colors.red
                                                  : Colors.green,
                                            ),
                                            onPressed: () {
                                              if (isPlayingMap[index]!) {
                                                _player!.stopPlayer();
                                                setState(() {
                                                  isPlayingMap[index] = false;
                                                });
                                              } else {
                                                _playAudio(commentAudio);
                                                setState(() {
                                                  isPlayingMap[index] = true;
                                                });
                                              }
                                            },
                                          ),
                                      ],
                                    ),
                                    subtitle: Text(
                                      'UserName: ${commentUserName ?? "N/A"}\nDate: $commentdate',
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: Colors.grey[600],
                                      ),
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
          );
        },
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
    );
  }

  List<Map<String, dynamic>> getFilteredData() {
    return tasks.where((project) {
      bool matchesprojectName = true;
      if (selectedProjectName != null && selectedProjectName!.isNotEmpty) {
        matchesprojectName = project['projectName'] == selectedProjectName;
      }
      return matchesprojectName;
    }).toList();
  }


  Future<void> _updateTaskUser(int taskId) async {
    final response = await new ApiService().request(
      method: 'post',
      endpoint: 'tasks/Update',
      tokenRequired: true,
      body: {
        'taskId': taskId,
        'taskStatus': selectedStatus,
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


  Future<void> _showEditTaskUser(int taskId) async {
    Map<String, dynamic> taskToEdit = tasks.firstWhere((
        task) => task['taskId'] == taskId);
    selectedStatus = taskToEdit['taskStatus'];

    if (selectedprojectId != null) {
      await fetchTeamMembers();
    }
    showCustomAlertDialog(
        context,
        title: 'Edit Task',
        content: StatefulBuilder(
          builder: (context, setState) {
            return SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 15),
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
                ],
              ),
            );
          },
        ),
        actions: [
          ElevatedButton(
            onPressed: () {
              _updateTaskUser(taskId);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
            child: Text('Update', style: TextStyle(color: Colors.white)),
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
                    Autocomplete<String>(
                      optionsBuilder: (TextEditingValue textEditingValue) {
                        return projects
                            .where((user) => user['projectName']!
                            .toLowerCase()
                            .contains(textEditingValue.text.toLowerCase()))
                            .map((user) => user['projectName'] as String)
                            .toList();
                      },
                      onSelected: (String projectName) {
                        setState(() {
                          selectedProjectName = projectName;
                        });
                        fetchTasks();
                      },
                      fieldViewBuilder: (context, controller, focusNode, onFieldSubmitted) {
                        return Container(
                          width: 290,
                          child: TextField(
                            controller: controller,
                            focusNode: focusNode,
                            decoration: InputDecoration(
                              labelText: 'Select Project',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              prefixIcon: Icon(Icons.note_alt_rounded),
                            ),
                            onChanged: (value) {
                              if (value.isEmpty) {
                                setState(() {
                                  selectedProjectName = null;
                                });
                                fetchTasks();
                              }
                            },
                          ),
                        );
                      },
                    ),
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
                    if (getFilteredData().isEmpty)
                      NoDataFoundScreen()
                    else
                      Column(
                        children: getFilteredData().map((task) {
                          String allComments = (task['comments'] as List<
                              dynamic>?) == null ||
                              (task['comments'] as List<dynamic>).isEmpty
                              ? 'No comments'
                              : "Click Icon ";

                          Map<String, dynamic> taskFields = {
                            'ProjectName': task['projectName'],
                            'Title': task['taskTitle'],
                            'Description': task['taskDescription'],
                            'AssignedTo': task['taskAssignedToName'],
                            'Comment': allComments,
                            'Priority': task['taskPriority'],
                            'Status': task['taskStatus'],
                            'DueDate': task['taskDueDate'],
                            'CreatedBy': task['taskCreatedByName'],
                            'UpdatedBy': task['taskUpdatedByName'],
                          };
                          bool canComment = task['taskStatus'] == 'open' ||
                              task['taskStatus'] == 'in-progress';
                          DateTime? dueDate;
                          if (task['taskDueDate'] != null) {
                            try {
                              dueDate = DateFormat('dd-MM-yyyy').parse(task['taskDueDate']);
                            } catch (e) {
                              print('Error parsing due date: ${task['taskDueDate']} - $e');
                            }
                          }
                          bool isOverdue = dueDate != null && dueDate.isBefore(DateTime.now());
                          return buildUserCard(
                            userFields: {
                              'ProjectName': task['projectName'],
                              '': task[''],
                              'Title': task['taskTitle'],
                              'Description': task['taskDescription'],
                              'AssignedTo': task['taskAssignedToName'],
                              'DueDate': task['taskDueDate'],
                              'Comment': allComments,
                            },
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
                                        Icons.comment, color: Colors.orange,
                                        size: 25),
                                    onPressed: () =>
                                        _showCommentsModal(task['taskId']),
                                  ),
                              ],
                            ),
                            trailingIcon: Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                if(roleName == "User")
                                IconButton(onPressed: () => _showEditTaskUser(task['taskId']), icon: Icon(Icons.edit,color: Colors.green,)),
                                if (!(taskExpansionStates[task['taskId']
                                    .toString()] ?? false))
                                  IconButton(
                                    onPressed: () {
                                      setState(() {
                                        taskExpansionStates[task['taskId']
                                            .toString()] = true;
                                      });
                                    },
                                    icon: Icon(Icons.arrow_downward),
                                  ),
                                if ((taskExpansionStates[task['taskId']
                                    .toString()] ?? false))
                                  IconButton(
                                    onPressed: () {
                                      setState(() {
                                        taskExpansionStates[task['taskId']
                                            .toString()] = false;
                                      });
                                    },
                                    icon: Icon(Icons.arrow_upward),

                                  ),
                                if (canComment)
                                  IconButton(
                                    onPressed: () =>
                                        _showAddCommentModal(task['taskId']),
                                    icon: Icon(
                                        Icons.comment, color: Colors.orange),
                                  ),
                                if(roleName == "Admin")
                                  IconButton(
                                    onPressed: () =>
                                        _showEditTaskModal(task['taskId']),
                                    icon: Icon(Icons.edit, color: Colors.green),
                                  ),
                                if(roleName == "Admin")

                                  IconButton(
                                  onPressed: () =>
                                      _confirmDeleteTask(task['taskId']),
                                  icon: Icon(Icons.delete, color: Colors.red),
                                ),
                              ],
                            ),
                            additionalContent: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                if (taskExpansionStates[task['taskId']
                                    .toString()] ?? false)
                                  buildUserCard(
                                    userFields: {
                                      'Priority': task['taskPriority'],
                                      '': task[''],
                                      'Status': task['taskStatus'],
                                      'CreatedBy': task['taskCreatedByName'],
                                      'UpdatedBy': task['taskUpdatedByName'],
                                    },
                                    backgroundColor: isOverdue ? Colors.red.shade400 : null,

                                  ),
                              ],
                            ),
                            backgroundColor: isOverdue ? Colors.red.shade400 : null,

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