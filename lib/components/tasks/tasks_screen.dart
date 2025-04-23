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
  bool isSubmitting = false;
  List<Map<String, dynamic>> team = [];
  String? selectedProjectName;
  bool isAllFieldsVisible = false;
  bool isLoading = false;
  String? selectedStatus = 'open';
  String? selectedPriority = 'low';
  String? selectedUserName;

  List<Map<String, dynamic>> tasks = [];
  String? selectedRoleName;
  String taskTitle = '';
  String taskDescription = '';
  DateTime? dueDate;
  int? userId;
  DateTime? fromDate;
  DateTime? toDate;
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
  File? _selectedImage;
  File? _commentImageFile;
  List<Map<String, dynamic>> users = [];

  Timer? positionTimer;
  bool isImageLoading = false;

  @override
  void initState() {
    super.initState();
    _initializeRecorder();
    _initializePlayer();
    fetchProjects();
    fetchUsers();
    fetchTasks();
    _getUserId();
  }

  final _formKey = GlobalKey<FormState>();
  final controller = MultiSelectController<String>();
  List<String> taskStages = ['open', 'in-progress', 'completed', 'blocked'];
  Map<String, bool> selectedStages = {
    'open': true,
    'in-progress': true,
    'completed': false,
    'blocked': false,
  };
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

  Future<void> _playAudio(String? audioFilePath) async {
    if (audioFilePath != null && audioFilePath.isNotEmpty) {
      setState(() {
        isPlayingMap.updateAll((key, value) => false);
        isPlayingMap[audioFilePath] = true;
      });

      await _player!.startPlayer(
        fromURI: audioFilePath,
        whenFinished: () {
          setState(() {
            isPlayingMap[audioFilePath] = false;
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

    if (response['statusCode'] == 200 && response['apiResponse'] != null) {
      setState(() {
        team = List<Map<String, dynamic>>.from(response['apiResponse']);
      });
    } else {
      showToast(msg: response['message'] ?? 'Failed to load team members');
    }
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
          response['apiResponse']["taskList"].map((role) {
            final taskComments = role['taskComments'] as List<dynamic>?;
            return {
              'taskId': role['taskId'] ?? 0,
              'projectId': role['projectId'] ?? 0,
              'taskTitle': role['taskTitle'] ?? 'Unknown title',
              'taskDescription': role['taskDescription'] ?? '',
              'taskPriority': role['taskPriority'] ?? '',
              'viewCount': role['viewCount'] ?? 0,
              'taskAssignedTo': role['taskAssignedTo'] ?? '',
              'createdAt': role['createdAt'] ?? '',
              'taskCompletedAt': role['taskCompletedAt'] ?? "--/--/----",
              'taskHour': role['taskHour'] ?? '00:00',
              'taskStatus': role['taskStatus'] ?? '',
              'imageFilePath': role['imageFilePath'] ?? null,
              'audioFilePath': role['audioFilePath'] ?? null,
              'projectName': role['projectName'] ?? '',
              'cmmntImageFilePath': (role['taskComments'] as List<dynamic>?)
                  ?.map((commentMap) => commentMap['cmmntImageFilePath'])
                  .toList() ??
                  [],
              'comments': (role['taskComments'] as List<dynamic>?)
                  ?.map((commentMap) => commentMap['comment'])
                  .toList() ??
                  [],
              'userName': (role['taskComments'] as List<dynamic>?)
                  ?.map((commentMap) => commentMap['userName'])
                  .toList() ??
                  [],
              'commentCreatedAt': (role['taskComments'] as List<dynamic>?)
                  ?.map((commentMap) => commentMap['commentCreatedAt'])
                  .toList() ??
                  [],
              'cmmntAudioFilePath': (role['taskComments'] as List<dynamic>?)
                  ?.map((commentMap) => commentMap['cmmntAudioFilePath'])
                  .toList() ??
                  [],
              'taskCmmntId': (role['taskComments'] as List<dynamic>?)
                  ?.map((commentMap) => commentMap['taskCmmntId'])
                  .toList() ??
                  [],
              'viewStatus': (role['taskComments'] as List<dynamic>?)
                  ?.map((commentMap) => commentMap['viewStatus'])
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

  Future<void> _addTask(File? imageFile) async {
    final dueDateToSend = dueDate?.toIso8601String() ?? DateTime.now().toIso8601String();
    Map<String, File> files = {};
    if (imageFile != null) {
      files['imageFile'] = imageFile;
    }

    if (audioFilePath != null) {
      files['audioFile'] = File(audioFilePath!);
    }

    final response = await ApiService().request(
      method: 'post',
      endpoint: 'tasks/create',
      tokenRequired: true,
      files: files,
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
      isMultipart: true,
    );

    if (response['statusCode'] == 200) {
      showToast(
        msg: response['message'] ?? 'Task created successfully',
        backgroundColor: Colors.green,
      );
      Navigator.pop(context);
      fetchTasks();
    } else {
      showToast(msg: response['message'] ?? 'Failed to create task');
    }
  }

  Future _showAddTaskModal() async {
    setState(() {
      selectedprojectId = null;
      selectedTeamMemberId = null;
      audioFilePath = null;
      dueDate = null;
      team.clear();
      audioFilePath = null;
      isRecording = false;
      isPlayingMap.clear();
      isPlaying = false;
      _selectedImage = null;
    });

    String? selectedStatus1 = 'open';
    String? selectedPriority1 = 'low';

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
                  CustomDropdown(
                    options: projects.map((project) =>
                        project['projectId'].toString()).toList(),
                    displayValue: (projectId) {
                      final project = projects.firstWhere((project) =>
                      project['projectId'].toString() == projectId);
                      return project['projectName'];
                    },
                    onChanged: (value) async {
                      setState(() {
                        selectedprojectId = value != null ? int.tryParse(value) : null;
                        team.clear();
                      });
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
                    selectedOption: selectedPriority1,
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
                    selectedOption: selectedStatus1,
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
                          : DateformatddMMyyyy.formatDateddMMyyyy(DateTime.now()),
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
                  SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                            : Icon(Icons.mic, color: Color(0xFF005296), size: 40),
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
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          PopupMenuButton<ImageSource>(
                            icon: Icon(Icons.upload, size: 30, color: Colors.blue),
                            tooltip: 'Upload Image',
                            onSelected: (source) async {
                              final picker = ImagePicker();
                              final pickedFile = await picker.pickImage(source: source);
                              if (pickedFile != null) {
                                setState(() {
                                  _selectedImage = File(pickedFile.path);
                                });
                              }
                            },
                            itemBuilder: (BuildContext context) =>
                            <PopupMenuEntry<ImageSource>>[
                              const PopupMenuItem<ImageSource>(
                                value: ImageSource.gallery,
                                child: Text('Choose from Gallery'),
                              ),
                              const PopupMenuItem<ImageSource>(
                                value: ImageSource.camera,
                                child: Text('Take a Picture'),
                              ),
                            ],
                          ),
                          if (isImageLoading)
                            SizedBox(
                              height: 24,
                              width: 24,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          else if (_selectedImage != null)
                            InkWell(
                              onTap: () {
                                showCustomAlertDialog(
                                  context,
                                  title: "Review Image",
                                  content: Padding(
                                    padding: const EdgeInsets.only(top: 60.0),
                                    child: Image.file(_selectedImage!),
                                  ),
                                  actions: [
                                    TextButton(
                                      onPressed: () {
                                        Navigator.of(context).pop();
                                      },
                                      child: Text('Close'),
                                    ),
                                  ],
                                  titleHeight: 65,
                                );
                              },
                              child: Icon(Icons.image, color: Colors.green, size: 30),
                            ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
      actions: [

        StatefulBuilder(
          builder: (context, localSetState) {
            return LoadingButton(
              isLoading: isSubmitting,
              label: 'Add',
              onPressed: () async {
                if (isRecording) {
                  showToast(msg: 'Please stop the recording first.', backgroundColor: Colors.red);
                  return;
                }

                localSetState(() => isSubmitting = true);
                await _addTask(_selectedImage);
                localSetState(() => isSubmitting = false);
              },
            );
          },
        ),
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text('Cancel'),
        ),
      ],
      titleHeight: 65,
      isFullScreen: true,
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

  Future<void> _updateTask(int taskId,File? imageFile) async {
    Map<String, File> files = {};
    if (imageFile != null) {
      files['imageFile'] = imageFile;
    }
    final response = await new ApiService().request(
      method: 'post',
      endpoint: 'tasks/Update',
      tokenRequired: true,
      files: files,
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
        isMultipart: true

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
    Map<String, dynamic> taskToEdit = tasks.firstWhere((task) => task['taskId'] == taskId);

    taskTitle = taskToEdit['taskTitle'] ?? '';
    taskDescription = taskToEdit['taskDescription'] ?? '';
    selectedprojectId = taskToEdit['projectId'];
    selectedTeamMemberId = taskToEdit['taskAssignedTo'];
    selectedPriority = taskToEdit['taskPriority'];
    selectedStatus = taskToEdit['taskStatus'];
    String dueDateString = taskToEdit['taskDueDate'] ?? '';
    dueDate = DateFormat('dd-MM-yyyy').parse(dueDateString);
    String? currentImageUrl = taskToEdit['imageFilePath'];
    _selectedImage = null;

    if (selectedprojectId != null) {
      await fetchTeamMembers();
      if (!team.any((member) => member['userId'] == selectedTeamMemberId)) {
        selectedTeamMemberId = null;
      }
    }

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
                    options: projects.map((project) => project['projectId'].toString()).toList(),
                    displayValue: (projectId) {
                      final project = projects.firstWhere((project) =>
                      project['projectId'].toString() == projectId);
                      return project['projectName'];
                    },
                    selectedOption: selectedprojectId?.toString(),
                    onChanged: (value) async {
                      setState(() {
                        selectedprojectId = value != null ? int.tryParse(value) : null;
                        team.clear();
                      });
                      if (selectedprojectId != null) {
                        await fetchTeamMembers();
                        if (!team.any((member) => member['userId'] == selectedTeamMemberId)) {
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
                    decoration: InputDecoration(
                      labelText: 'Select Team Member',
                      border: OutlineInputBorder(),
                    ),
                    items: team.map((member) {
                      return DropdownMenuItem<int>(
                        value: member['userId'],
                        child: Text('${member['userName'] ?? 'Unknown'}', style: TextStyle(fontSize: 16)),
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
                  SizedBox(height: 15),
                  TextField(
                    controller: TextEditingController(
                      text: dueDate != null
                          ? DateFormat('dd-MM-yyyy').format(dueDate!)
                          : 'Select Due Date',
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
                  SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Upload icon
                          PopupMenuButton<ImageSource>(
                            icon: Icon(Icons.upload, size: 30, color: Colors.blue),
                            onSelected: (source) async {
                              final picker = ImagePicker();
                              final pickedFile = await picker.pickImage(source: source);
                              if (pickedFile != null) {
                                setState(() {
                                  _selectedImage = File(pickedFile.path);
                                });
                              }
                            },
                            itemBuilder: (BuildContext context) => <PopupMenuEntry<ImageSource>>[
                              const PopupMenuItem<ImageSource>(
                                value: ImageSource.gallery,
                                child: Text('Choose from Gallery'),
                              ),
                              const PopupMenuItem<ImageSource>(
                                value: ImageSource.camera,
                                child: Text('Take a Picture'),
                              ),
                            ],
                          ),
                          if (isImageLoading)
                            SizedBox(
                              height: 24,
                              width: 24,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                        else if (_selectedImage != null)
                            InkWell(
                              onTap: () {
                                showCustomAlertDialog(
                                  context,
                                  title: "Review New Image",
                                  content: Padding(
                                    padding: const EdgeInsets.only(top: 60.0),
                                    child: Image.file(_selectedImage!),
                                  ),
                                  actions: [
                                    TextButton(
                                      onPressed: () {
                                        Navigator.of(context).pop();
                                      },
                                      child: Text('Close'),
                                    ),
                                  ],
                                  titleHeight: 65,
                                );
                              },
                              child: Icon(Icons.image, color: Colors.green, size: 30),
                            )
                          else if (currentImageUrl != null)
                            InkWell(
                              onTap: () {
                                showCustomAlertDialog(
                                  context,
                                  title: "Current Image",
                                  content: Padding(
                                    padding: const EdgeInsets.only(top: 60.0),
                                    child: Image.network(currentImageUrl),
                                  ),
                                  actions: [
                                    TextButton(
                                      onPressed: () {
                                        Navigator.of(context).pop();
                                      },
                                      child: Text('Close'),
                                    ),
                                  ],
                                  titleHeight: 65,
                                );
                              },
                              child: Icon(Icons.image, color: Colors.green, size: 30),
                            ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
      actions: [
        StatefulBuilder(
          builder: (context, localSetState) {
            return LoadingButton(
              isLoading: isSubmitting,
              label: 'Edit',
              onPressed: () async {

                localSetState(() => isSubmitting = true);
                _updateTask(taskId, _selectedImage);
                localSetState(() => isSubmitting = false);
              },
            );
          },
        ),
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text('Cancel'),
        ),
      ],
      titleHeight: 65,
      isFullScreen: true,
    );
  }

  Future<void> _addComments(int taskId, String comment) async {
    if (comment.isEmpty && audioFilePath == null && _commentImageFile == null) {
      showToast(
        msg: 'Please fill in a comment, audio, or upload an image.',
        backgroundColor: Colors.red,
      );
      return;
    }

    SharedPreferences prefs = await SharedPreferences.getInstance();
    int? userId = prefs.getInt('user_Id');

    if (userId == null) {
      showToast(msg: 'User ID not found');
      return;
    }

    if (comment.isEmpty) {
      comment = "Check audio";
    }

    final uri = Uri.parse('${Config.apiUrl}tasks/AddComment');
    try {
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
        var audio = await http.MultipartFile.fromPath(
          'audioFile',
          audioFilePath!,
          contentType: MediaType('audio', 'aac'),
        );
        request.files.add(audio);
      }

      if (_commentImageFile != null) {
        var image = await http.MultipartFile.fromPath(
          'imageFile',
          _commentImageFile!.path,
          contentType: MediaType('image', 'jpeg'),
        );
        request.files.add(image);
      }
      var response = await request.send();
      final responseData = await http.Response.fromStream(response);
      final responseJson = jsonDecode(responseData.body);

      if (response.statusCode == 200) {
        showToast(msg: responseJson['message'] ?? 'Comment added', backgroundColor: Colors.green);
        fetchTasks();
        Navigator.pop(context);
      } else {
        showToast(msg: responseJson['message'], backgroundColor: Colors.red);
      }
    } catch (e) {
      print("Error uploading comment: $e");
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
      _commentImageFile = null;
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
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      PopupMenuButton<ImageSource>(
                        icon: Icon(Icons.upload, size: 30, color: Colors.blue,),
                        onSelected: (source) async {
                          final picker = ImagePicker();
                          final pickedFile = await picker.pickImage(source: source);
                          if (pickedFile != null) {
                            setState(() {
                              _commentImageFile = File(pickedFile.path);
                            });
                          }
                        },
                        itemBuilder: (BuildContext context) => <PopupMenuEntry<ImageSource>>[
                          const PopupMenuItem<ImageSource>(
                            value: ImageSource.gallery,
                            child: Text('Choose from Gallery'),
                          ),
                          const PopupMenuItem<ImageSource>(
                            value: ImageSource.camera,
                            child: Text('Take a Picture'),
                          ),
                        ],
                      ),
                      if (isImageLoading)
                        SizedBox(
                          height: 24,
                          width: 24,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                     else if (_commentImageFile != null)
                        InkWell(
                          onTap: () {
                            showCustomAlertDialog(
                                context,
                                title: "Review Image",
                                content: Padding(
                                  padding: const EdgeInsets.only(top: 60.0),
                                  child: Image.file(_commentImageFile!),
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () {
                                      Navigator.of(context).pop();
                                    },
                                    child: Text('Close'),
                                  ),
                                ],
                                titleHeight: 65
                            );
                          },
                          child: Icon(Icons.image, color: Colors.green, size: 30),
                        ),
                    ],
                  ),
                  SizedBox(height: 20,),
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
                        SizedBox(width: 30,),
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
        StatefulBuilder(
          builder: (context, localSetState) {
            return LoadingButton(
              isLoading: isSubmitting,
              label: 'Add',
              onPressed: () async {
                if (isRecording) {
                  showToast(msg: 'Please stop the recording first.', backgroundColor: Colors.red);
                  return;
                }
                if (comment.isEmpty && audioFilePath == null) {
                  showToast(msg: 'Please enter either comment or record audio');
                  return;
                }
                localSetState(() => isSubmitting = true);
                _addComments(taskId, comment,);
                localSetState(() => isSubmitting = false);
              },
            );
          },
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
    List<dynamic> commentCreatedAt = task['commentCreatedAt'] ?? [];
    List<dynamic> audioFilePath = task['cmmntAudioFilePath'] ?? [];
    List<dynamic> viewStatusList = task['viewStatus'] ?? [];
    List<dynamic> cmmntImageFilePath = task['cmmntImageFilePath'] ?? [];
    Map<int, bool> isPlayingMap = {};
    String? taskTitle = task['taskTitle'];

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
                        child: ListView.builder(
                          shrinkWrap: true,
                          itemCount: comments.length,
                          itemBuilder: (context, index) {
                            final comment = comments[index];
                            final commentUserName = userName[index];
                            final commentdate = commentCreatedAt[index];
                            final isViewed = index < viewStatusList.length && viewStatusList[index] == true;
                            final commentAudio = audioFilePath[index];
                            final commentImage = index < cmmntImageFilePath.length ? cmmntImageFilePath[index] : null;
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
                                  contentPadding: EdgeInsets.symmetric(horizontal: 12.0),
                                  leading: Padding(
                                    padding: const EdgeInsets.only(bottom: 40.0),
                                    child: Icon(Icons.comment_outlined, color: Colors.blue),
                                  ),
                                  title: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Expanded(
                                        child: Text(
                                          comment.toString(),
                                          style: TextStyle(fontSize: 16),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),

                                      if (commentImage != null && commentImage.toString().isNotEmpty)
                                        IconButton(
                                          icon: Icon(Icons.image, color: Colors.orange, size: 30),
                                          tooltip: "View Image",
                                          onPressed: () {
                                            _showImageDialog(commentImage);
                                          },
                                        ),
                                      IconButton(
                                        icon: Icon(Icons.visibility, size: 30, color: Colors.blue),
                                        onPressed: () {
                                          if (roleName == 'Admin') {
                                            if (index < task['taskCmmntId'].length) {
                                              final commentId = task['taskCmmntId'][index];
                                              _viewTask(commentId);
                                              _showFullComment(context, comment.toString());
                                            } else {
                                              print('Error: Index out of bounds for taskCmmntId');
                                            }
                                          } else {
                                            _showFullComment(context, comment.toString());
                                          }
                                        },
                                      ),
                                      if (commentAudio != null)
                                        IconButton(
                                          icon: Icon(
                                            isPlayingMap[index]!
                                                ? Icons.pause_circle
                                                : Icons.play_circle,
                                            size: 30,
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
                                      if (isViewed)
                                        Icon(Icons.check_circle_outline, color: Colors.green, size: 30)
                                      else
                                        Icon(Icons.check_circle_outline, color: Colors.grey, size: 30),
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
      titleHeight: 85,
      additionalTitleContent: Column(
        children: [
          Text("TaskTitle: $taskTitle", style: TextStyle(fontSize: 18, color: Colors.white)),
        ],
      ),
    );
  }
  Future<void> _stopAudio(String url) async {
    await _player!.stopPlayer();
    setState(() {
      isPlayingMap[url] = false;
    });
    positionTimer?.cancel();
  }
  void _showFullComment(BuildContext context, String comment) {
    showCustomAlertDialog(
      context,
      title: 'Full Comment',
      titleHeight: 65,
      content: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(15.0),
          child: Text(comment),
        ),
      ),
      actions: <Widget>[
        TextButton(
          child: Text('Close'),
          onPressed: () async {
            Navigator.of(context).pop();
          },
        ),
      ],
    );
  }

  Future<void> _viewTask(int taskCmmntId) async {
    print(taskCmmntId);
    final response = await new ApiService().request(
        method: 'post',
        endpoint: 'tasks/ViewComment',
        tokenRequired: true,
        body: {
          'updateFlag': 'true',
          'taskCmmntId': taskCmmntId.toString(),
        },
        isMultipart: true
    );

    if (response['statusCode'] == 200) {
      // String message = response['message'] ?? 'View Status updated successfully';
      // showToast(msg: message, backgroundColor: Colors.green);
      fetchTasks();
    } else {
      String message = response['message'] ?? 'Failed to update status';
      showToast(msg: message);
    }
  }

  List<Map<String, dynamic>> getFilteredData() {
    if (selectedStages.values.every((value) => !value)) {
      return tasks.where((task) {
        final status = task['taskStatus']?.toString().trim().toLowerCase();
        return status == 'open' || status == 'in-progress';
      }).toList();
    }

    return tasks.where((task) {
      bool matchesStage = selectedStages[task['taskStatus']] ?? false;
      bool matchesDate = true;
      bool matchesuserName = true;
      if (selectedUserName != null && selectedUserName!.isNotEmpty) {
        matchesuserName = task['taskAssignedToName'] == selectedUserName;
      }
      if (fromDate != null && toDate != null) {
        DateTime workingDate = _parseDate(task['taskDueDate']);
        matchesDate = (workingDate.isAtSameMomentAs(fromDate!) ||
            workingDate.isAfter(fromDate!)) &&
            (workingDate.isAtSameMomentAs(toDate!) ||
                workingDate.isBefore(toDate!));
      }
      return matchesStage && matchesDate && matchesuserName;
    }).toList();
  }

  DateTime _parseDate(String dateStr) {
    try {
      return DateFormat('dd-MM-yyyy').parse(dateStr);
    } catch (e) {
      print("Error parsing date: $e");
      return DateTime(2000);
    }
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
        'taskUpdatedBy': userId,
      },
        isMultipart: true
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
        isFullScreen: false,
    );
  }

  void _showFullDescription(String taskDescription,  BuildContext context) {
    showCustomAlertDialog(
      context,
      title: 'Working Description',
      content: Padding(
        padding: const EdgeInsets.only(left:20,right: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(height: 20,),
            Container(
              child: SingleChildScrollView(
                child: Text(
                  "$taskDescription",
                  style: TextStyle(fontSize: 18),
                ),
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.pop(context);
          },
          child: Text('Close'),
        ),
      ],
      titleFontSize: 27.0,
      isFullScreen: true,
    );
  }

  void _showFilter() {
    List<DropdownItem<String>> stageItems = taskStages
        .map((stage) => DropdownItem(label: stage, value: stage))
        .toList();
    showCustomAlertDialog(
     context,
          title: 'Select Data',
          content: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(15.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    MultiSelectDropdown(
                      width: 275,
                      items: stageItems,
                      controller: controller,
                      hintText: 'Select Task Stage',
                      onSelectionChange: (selectedItems) {
                        setState(() {
                          selectedStages = {
                            for (var stage in taskStages)
                              stage: selectedItems.contains(stage),
                          };
                        });
                        fetchTasks();
                      },
                    ),
                    IconButton(
                      icon: Icon(Icons.date_range, size: 30, color: Colors.blue),
                      onPressed: () async {
                        Navigator.of(context).pop();
                        final pickedDateRange = await showDateRangePicker(
                          context: context,
                          firstDate: DateTime(2025, DateTime.february),
                          lastDate: DateTime(2025, DateTime.december),
                          initialDateRange: fromDate != null && toDate != null
                              ? DateTimeRange(start: fromDate!, end: toDate!)
                              : null,
                        );

                        if (pickedDateRange != null) {
                          setState(() {
                            fromDate = pickedDateRange.start;
                            toDate = pickedDateRange.end;
                          });
                        }
                      },
                    ),
                    SizedBox(height: 10),
                  ],
                ),
              ),
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
                  fetchTasks();
                },
                fieldViewBuilder: (context, controller, focusNode, onFieldSubmitted) {
                  return Container(
                    width: 320,
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
                          fetchTasks();
                        }
                      },
                    ),
                  );
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              child: Text('Apply'),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ],
       titleHeight: 65
    );
  }

  // void _showFilter() {
  //   MultiSelectController<String> controller = MultiSelectController<String>();
  //   List<Map<String, String>> userStringList = users
  //       .map((user) => {
  //     'userName': user['userName'] as String,
  //   })
  //       .toList();
  //   showCustomAlertDialog(
  //     context,
  //      title: "Filter",
  //      content: FilterDialog(
  //         taskStages: taskStages,
  //         users: userStringList,
  //         controller: controller,
  //         onStageSelected: (selectedStages) {
  //           setState(() {
  //             selectedStages = selectedStages;
  //           });
  //           fetchTasks();
  //         },
  //         onDateRangeSelected: (pickedDateRange) {
  //           if (pickedDateRange != null) {
  //             setState(() {
  //               fromDate = pickedDateRange.start;
  //               toDate = pickedDateRange.end;
  //             });
  //           }
  //         },
  //         onUserSelected: (userName) {
  //           setState(() {
  //             selectedUserName = userName;
  //           });
  //           fetchTasks();
  //         },
  //         fromDate: fromDate,
  //         toDate: toDate,
  //       ), actions: [
  //     TextButton(
  //       child: Text('Apply'),
  //       onPressed: () => Navigator.of(context).pop(),
  //     ),    ]
  //
  //    showStageDropdown: true,
  //       showDatePicker: true,
  //       showUserAutocomplete: false,
  //   );
  // }

  void _showImageDialog(String? imageUrl) {
    if (imageUrl == null || imageUrl.isEmpty) {
      showToast(msg: "No image available", backgroundColor: Colors.red);
      return;
    }
    showCustomAlertDialog(
      context,
      title: 'Task Image',
      content: Padding(
        padding: const EdgeInsets.only(top: 30.0),
        child: InteractiveViewer(
          panEnabled: true,
          minScale: 0.5,
          maxScale: 6.0,
          child: Image.network(
            imageUrl,
            fit: BoxFit.contain,
            loadingBuilder: (context, child, loadingProgress) {
              if (loadingProgress == null) return child;
              return Padding(
                padding: const EdgeInsets.all(20.0),
                child: CircularProgressIndicator(),
              );
            },
            errorBuilder: (context, error, stackTrace) =>
                Center(child: Text("Failed to load image.")),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text("Close"),
        )
      ],
      titleHeight: 60,
    );
  }


  @override
  Widget build(BuildContext context) {
    List<DropdownItem<String>> stageItems = taskStages
        .map((stage) => DropdownItem(label: stage, value: stage))
        .toList();
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
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      // MultiSelectDropdown(
                      //   width: 240,
                      //   items: stageItems,
                      //   controller: controller,
                      //   hintText: 'Select Task Stage',
                      //   onSelectionChange: (selectedItems) {
                      //     setState(() {
                      //       selectedStages = {
                      //         for (var stage in taskStages)
                      //           stage: selectedItems.contains(stage),
                      //       };
                      //     });
                      //     fetchTasks();
                      //   },
                      // ),
                      IconButton(
                        icon: Icon(
                            Icons.filter_alt_outlined, color: Colors.blue, size: 30),
                        onPressed: _showFilter,
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
                              'Project': task['projectName'],
                              'Title': task['taskTitle'],
                              'Description': task['taskDescription'],
                              'AssignedTo': task['taskAssignedToName'],
                              'createdAt': task['createdAt'],
                              'Comment': allComments,
                              'Priority': task['taskPriority'],
                              'Status': task['taskStatus'],
                              'CreatedAt': task['createdAt'],
                              'CompletedAt': task['taskCompletedAt']  ,
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
                            String shortenedTaskDesc = task['taskDescription']
                                .length > 10
                                ? task['taskDescription'].substring(0, 10) + '...'
                                : task['taskDescription'];
                            bool isOverdue = dueDate != null &&
                                dueDate.isBefore(DateTime.now().subtract(Duration(days: 1)).add(Duration(
                                  hours: -DateTime.now().hour,
                                  minutes: -DateTime.now().minute,
                                  seconds: -DateTime.now().second,
                                  milliseconds: -DateTime.now().millisecond,
                                  microseconds: -DateTime.now().microsecond,
                                )));
                            bool hasAudioFile = task['audioFilePath'] != null && task['audioFilePath'] != '';

                            return buildUserCard(
                              userFields: {
                                'ProjectName': task['projectName'],
                                '': task[''],
                                'Title': task['taskTitle'],
                                'Description': shortenedTaskDesc,
                                'DueDate': task['taskDueDate'],
                                'TaskAssign': 'To:${task['taskAssignedToName']}\nBy:${task['taskCreatedByName']}',
                                'CreatedAt': task['createdAt'],
                                'CompletionAt': '${task['taskCompletedAt']}\nHours:${task['taskHour']}',
                                'Comment': allComments,
                                },
                              onEdit: () => _showEditTaskModal(task['taskId']),
                              showView: task['taskDescription'].toString().trim().isNotEmpty,                              onView: () {
                                _showFullDescription(task['taskDescription'], context);
                              },
                              onDelete: () => _confirmDeleteTask(task['taskId']),
                              leadingIcon3: Row(
                                children: [
                                  if (task['comments'] != null && task['comments'].isNotEmpty)
                                    Stack(
                                      children: [
                                        IconButton(
                                          icon: Icon(Icons.comment, size: 25, color: Colors.orange),
                                          onPressed: () => _showCommentsModal(task['taskId']),
                                        ),
                                        Positioned(
                                          top: 0,
                                          right: 0,
                                          child: Container(
                                            padding: EdgeInsets.all(6),
                                            decoration: BoxDecoration(
                                              color: Colors.white,
                                              shape: BoxShape.circle,
                                            ),
                                            constraints: BoxConstraints(
                                              minWidth: 19,
                                              minHeight: 19,
                                            ),
                                            child: Center(
                                              child: Text(
                                                '${task['viewCount']}',
                                                style: TextStyle(
                                                  color: Colors.black,
                                                  fontSize: 12,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                                textAlign: TextAlign.center,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    )
                                ],
                              ),

                              leadingIcon4: Row(
                                children: [
                                  if (hasAudioFile)
                                    IconButton(
                                      icon: Icon(
                                        size: 25,
                                        isPlayingMap[task['audioFilePath']] == true
                                            ? Icons.pause_circle
                                            : Icons.play_circle,
                                        color: isPlayingMap[task['audioFilePath']] == true
                                            ? Colors.red
                                            : Colors.green,
                                      ),
                                      onPressed: () {
                                        if (isPlayingMap[task['audioFilePath']] == true) {
                                          _stopAudio(task['audioFilePath']);
                                        } else {
                                          _playAudio(task['audioFilePath']);
                                        }
                                      },
                                    ),

                                  if (task['imageFilePath'] != null && task['imageFilePath'].toString().isNotEmpty)
                                    IconButton(
                                      icon: Icon(Icons.image, color: Colors.blue),
                                      onPressed: () => _showImageDialog(task['imageFilePath']),
                                    ),
                                ],
                              ),
                              trailingIcon: Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [

                                  if(roleName == "User")
                                    IconButton(onPressed: () => _showEditTaskUser(task['taskId']),
                                        icon: Icon(Icons.edit,color: Colors.green,)),
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
      ),
    );
  }
}