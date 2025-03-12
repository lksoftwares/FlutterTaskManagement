
import 'package:intl/intl.dart';
import 'package:lktaskmanagementapp/packages/headerfiles.dart';
import 'package:http/http.dart' as http;
import'dart:convert';
import 'package:http_parser/http_parser.dart';

class DailyWorkingStatus extends StatefulWidget {
  const DailyWorkingStatus({super.key});

  @override
  State<DailyWorkingStatus> createState() => _DailyWorkingStatusState();
}

class _DailyWorkingStatusState extends State<DailyWorkingStatus> {
  FlutterSoundRecorder? _recorder;
  FlutterSoundPlayer? _player;
  bool isRecording = false;
  String? audioFilePath;
  bool isPlaying = false;
  String? selectedUserId;
  Map<String, bool> isPlayingMap = {};
  bool isLoading = false;
  DateTime? fromDate;
  DateTime? toDate;
  String? selectedUserName;
  Map<String, dynamic>? selectedUser;
  List<Map<String, dynamic>> roles = [];
  List<Map<String, dynamic>> users = [];
  double currentPosition = 0.0;
  Timer? positionTimer;
  bool isListening = false;
  String? roleName;

  @override
  void initState() {
    super.initState();
    _initializeRecorder();
    _initializePlayer();
    _getData();
  }

  Future<int?> getUserIdFromPrefs() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getInt('user_Id');
  }
  Future<void> _initializeRecorder() async {
    _recorder = FlutterSoundRecorder();
    await _recorder!.openRecorder();
  }
  Future<void> _initializePlayer() async {
    _player = FlutterSoundPlayer();
    await _player!.openPlayer();
  }
  Future<void> _getData() async {
    await fetchWorking();
    await fetchUsers();
    await _getRoleName();

  }
  Future<void> _getRoleName() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      roleName = prefs.getString('role_Name');
    });
  }
  Future<void> _startRecording() async {

    PermissionStatus status = await Permission.microphone.request();
    if (status.isGranted) {
      String path = await _getFilePath();
      await _recorder!.startRecorder(toFile: path);
      setState(() {
        audioFilePath = path;
      });
      showToast(msg: "Recording started!",backgroundColor: Colors.green);

      print("Recording started. File path: $audioFilePath");
    } else {
      showToast(msg: "Permission denied. Please allow microphone access.");
    }
  }

  Future<void> _stopRecording() async {
    await _recorder!.stopRecorder();
    setState(() {
      isRecording=false;
    });
    showToast(msg: "Recording stopped!",backgroundColor: Colors.green);
    print("Recording stopped. File saved at: $audioFilePath");
  }


  Future<String> _getFilePath() async {
    Directory appDirectory = await getApplicationDocumentsDirectory();
    String path = '${appDirectory.path}/recording.aac';
    return path;
  }

  Future<void> fetchUsers() async {
    final response = await new ApiService().request(
      method: 'get',
      endpoint: 'User/GetAllUsers',
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
  Future<void> fetchWorking() async {
    setState(() {
      isLoading = true;
    });

    SharedPreferences prefs = await SharedPreferences.getInstance();
    int? userId = prefs.getInt('user_Id');
    String roleName = prefs.getString('role_Name') ?? "";


    String endpoint = 'Working/GetWorking';

    if (roleName == 'Admin') {
      endpoint = 'Working/GetWorking';
    } else if (userId != null) {
      endpoint = 'Working/GetWorking?userId=$userId';
    }


    try {
      final response = await new ApiService().request(
        method: 'get',
        endpoint: endpoint,
      );
      if (response['statusCode'] == 200 && response['apiResponse'] != null) {
        setState(() {
          var workingStatusList = response['apiResponse']['workingStatusList'];

          roles = List<Map<String, dynamic>>.from(
            workingStatusList.map((role) {
              String workingDateStr = role['workingDate'] ?? 'Unknown';
              String formattedWorkingDate = 'Unknown';
              try {
                DateTime parsedDate = DateFormat("dd-MM-yyyy HH:mm:ss").parse(workingDateStr);
                formattedWorkingDate = DateFormat('dd-MM-yyyy').format(parsedDate);
              } catch (e) {
                print("Error parsing date: $e");
              }

              return {
                'txnId': role['txnId'] ?? 0,
                'userName': role['userName'] ?? 'Unknown userName',
                'workingDesc': role['workingDesc'] ?? 'Unknown Desc',
                'workingDate': formattedWorkingDate,
                'createdAt': role['createdAt'] ?? '',
                'updatedAt': role['updatedAt'] ?? '',
                'workingNote': role['workingNote'] ?? '',
                'workingDescFilePath': role['workingDescFilePath'] ?? '',
              };
            }),
          );
        });
      } else {
        showToast(msg: response['message'] ?? 'Failed to load roles');
      }
    } catch (error) {
      print("Error fetching data: $error");
      showToast(msg: "Error fetching data: $error", backgroundColor: Colors.red);
    }

    setState(() {
      isLoading = false;
    });
  }

  DateTime _parseDate(String dateStr) {
    try {
      return DateFormat('dd-MM-yyyy').parse(dateStr);
    } catch (e) {
      print("Error parsing date: $e");
      return DateTime(2000);
    }
  }
  Future<void> _showAddWorkingModal() async {
    print("isRecording$isRecording");
    String workingDesc = '';
    InputDecoration inputDecoration = InputDecoration(
      labelText: 'Working Desc',
      border: OutlineInputBorder(),
    );

    int? userId = await getUserIdFromPrefs();
    if (userId == null) {
      showToast(msg: 'User ID not found in preferences.');
      return;
    }

    setState(() {
      audioFilePath = null;
      isRecording = false;
      isPlayingMap.clear();
    });

    String currentDateTime = DateFormat('dd-MM-yyyy HH:mm:ss').format(DateTime.now());

    showCustomAlertDialog(
      context,
      title: 'Add Working Desc',
      content: StatefulBuilder(
        builder: (context, setState) {
          return Container(
            height: 250,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextField(
                  onChanged: (value) => workingDesc = value,
                  decoration: inputDecoration,
                  maxLines: 7,
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 10.0),
                  child: Center(
                      child: GestureDetector(
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
                      )
                  ),
                ),
              ],
            ),
          );
        },
      ),
      actions: [
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.green,
          ),
          onPressed: () {
            if (isRecording) {
              showToast(msg: 'Please stop the recording first.', backgroundColor: Colors.red);
            } else {
              _addWorking(workingDesc, userId!);
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
      additionalTitleContent: Padding(
        padding: const EdgeInsets.only(top: 1.0),
        child: Column(
          children: [
            Divider(),
            Text(
              " Date: $currentDateTime",
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



  Future<void> _addWorking(String workingDesc, int userId) async {
    if (workingDesc.isEmpty) {
      workingDesc = "Check audio";
    }

    final uri = Uri.parse('${Config.apiUrl}Working/AddWorking');

    try {
      var request = http.MultipartRequest('POST', uri);

      request.fields['workingDesc'] = workingDesc;
      request.fields['userId'] = userId.toString();
      if (audioFilePath != null) {
        var file = await http.MultipartFile.fromPath(
          'workingAudioFile',
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
        fetchWorking();
        Navigator.pop(context);
        setState(() {
          selectedUserId = null;
        });
      } else {
        showToast(msg: responseJson['message'], backgroundColor: Colors.green);
      }
    } catch (e) {
      print("Error uploading working desc: $e");
      showToast(msg: 'An error occurred while uploading');
    }
  }



  void _showDatePicker() {
    showDateRangePicker(
      context: context,
      firstDate: DateTime(2025,DateTime.february),
      lastDate: DateTime(2025,DateTime.april),
      initialDateRange: fromDate != null && toDate != null
          ? DateTimeRange(start: fromDate!, end: toDate!)
          : null,
    ).then((pickedDateRange) {
      if (pickedDateRange != null) {
        setState(() {
          fromDate = pickedDateRange.start;
          toDate = pickedDateRange.end;
        });
      }
    });
  }

  void _confirmDeleteRole(int txnId) {
    showCustomAlertDialog(
      context,
      title: 'Delete Working Desc',
      content: Text('Are you sure you want to delete this Description?'),
      actions: [

        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.red,
          ),
          onPressed: () {
            _deleteRole(txnId);
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

  Future<void> _deleteRole(int txnId) async {
    final response = await new ApiService().request(
      method: 'delete',
      endpoint: 'Working/DeleteWorking/$txnId',
    );
    if (response.isNotEmpty && response['statusCode'] == 200) {
      fetchWorking();
      showToast(
        msg: response['message'] ?? 'Working Desc deleted successfully',
        backgroundColor: Colors.green,
      );
    } else {
      showToast(
        msg: response['message'] ?? 'Failed to delete Working Desc',
      );
    }
  }
  void _showFullDescription(String workingDesc, String workingDate, String userName, BuildContext context) {
    DateTime parsedDate = DateFormat('dd-MM-yyyy').parse(workingDate);
    String formattedWorkingDate = DateFormat('dd-MM-yyyy').format(parsedDate);

    showCustomAlertDialog(
      context,
      title: 'Working Description',

      content: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            height: 250,
            constraints: BoxConstraints(
              maxHeight: 500,
            ),
            child: SingleChildScrollView(
              child: Text(
                "Description: $workingDesc",
                style: TextStyle(fontSize: 18),
              ),
            ),
          ),
        ],
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
      additionalTitleContent: Padding(
        padding: const EdgeInsets.only(top: 1.0),
        child: Column(
          children: [
            Divider(),
            Text(
              "User: $userName         Date: $formattedWorkingDate",
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


  void _showWorkingNoteDialog(String? workingNote, String workingDate, String userName, BuildContext context) {
    if (workingNote == null || workingNote.isEmpty) {
      showToast(msg: "No working note available");
      return;
    }

    DateTime parsedDate = DateFormat('dd-MM-yyyy').parse(workingDate);
    String formattedWorkingDate = DateFormat('dd-MM-yyyy').format(parsedDate);

    showCustomAlertDialog(
      context,
      title: 'Working Note',
      content: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            height: 250,
            constraints: BoxConstraints(
              maxHeight: 400,
            ),
            child: SingleChildScrollView(
              child: Text(
                "Note: $workingNote",
                style: TextStyle(fontSize: 18),
              ),
            ),
          ),
        ],
      ),
      actions: <Widget>[
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text("Close"),
        ),
      ],
      titleFontSize: 27.0,
      additionalTitleContent: Padding(
        padding: const EdgeInsets.only(top: 1.0),
        child: Column(
          children: [
            Divider(),
            Text(
              "User: $userName               Date: $formattedWorkingDate",
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

  List<Map<String, dynamic>> getFilteredData() {
    return roles.where((role) {
      bool matchesUserName = true;
      bool matchesDate = true;
      if (selectedUserName != null && selectedUserName!.isNotEmpty) {
        matchesUserName = role['userName'] == selectedUserName;
      }
      if (fromDate != null && toDate != null) {
        DateTime workingDate = _parseDate(role['workingDate']);
        matchesDate = (workingDate.isAtSameMomentAs(fromDate!) ||
            workingDate.isAfter(fromDate!)) &&
            (workingDate.isAtSameMomentAs(toDate!) ||
                workingDate.isBefore(toDate!));
      }
      return matchesUserName && matchesDate;
    }).toList();
  }

  Future<void> _playAudio(String url) async {
    try {
      setState(() {
        isPlayingMap[url] = true;
      });
      await _player!.startPlayer(
        fromURI: url,
        whenFinished: () {
          setState(() {
            isPlayingMap[url] = false;
          });
        },
      );
    } catch (e) {
      print("Error playing audio: $e");
      showToast(msg: 'Error playing audio');
    }
  }

  Future<void> _stopAudio(String url) async {
    await _player!.stopPlayer();
    setState(() {
      isPlayingMap[url] = false;
    });
    positionTimer?.cancel();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: 'Working Status',
        onLogout: () => AuthService.logout(context),
      ),
      body: RefreshIndicator(
        onRefresh: fetchWorking,
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
                        fetchWorking();
                      },
                      fieldViewBuilder: (context, controller, focusNode, onFieldSubmitted) {
                        return Container(
                          width: 230,
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
                                fetchWorking();
                              }
                            },
                          ),
                        );
                      },
                    ),

                    IconButton(
                      icon: Icon(
                          Icons.filter_alt_outlined, color: Colors.blue, size: 30),
                      onPressed: _showDatePicker,
                    ),
                    SizedBox(width: 10),

                    IconButton(
                      icon: Icon(Icons.add_circle, color: Colors.blue, size: 30),
                      onPressed: _showAddWorkingModal,
                    ),
                  ],
                ),
                SizedBox(height: 20),
                if (isLoading)
                  Center(child: CircularProgressIndicator())
                else
                  if (roles.isEmpty)
                    NoDataFoundScreen()
                  else
                    if (getFilteredData().isEmpty)
                      NoDataFoundScreen()
                    else
                      Column(
                        children: getFilteredData().map((role) {
                          Map<String, dynamic> workingFields = {
                            'Username': role['userName'],
                            'workingDate': role['workingDate'],
                            'Note ': role[''] ?? "",
                            'WorkingDesc': role['workingDesc'],
                            'CreatedAt': role['createdAt'],
                            'updatedAt': role['updatedAt'],
                            'WorkingNote': role['workingNote'],
                          };

                          String shortenedWorkingDesc = role['workingDesc']
                              .length > 50
                              ? role['workingDesc'].substring(0, 10) + '...'
                              : role['workingDesc'];

                          bool hasWorkingNote = role['workingNote'] != null &&
                              role['workingNote'].isNotEmpty;

                          IconData icon = hasWorkingNote
                              ? Icons.check_circle
                              : Icons.cancel;
                          Color iconColor = hasWorkingNote
                              ? Colors.red[900]!
                              : Colors.red[100]!;


                          bool hasAudioFile = role['workingDescFilePath'] != null && role['workingDescFilePath'] != '';
                          bool isAdmin = roleName == 'Admin';
                          return buildUserCard(
                            userFields: {
                              'Username': role['userName'],
                              'Date: ': role['workingDate'],
                              'Note ': role[''] ?? "",
                              'WorkingDesc': shortenedWorkingDesc,
                              'CreatedAt':role['createdAt'],
                            },
                            onDelete: () => _confirmDeleteRole(role['txnId']),
                            showView: true,
                            onView: () =>
                                _showFullDescription(role['workingDesc'], role['workingDate'],
                                    role['userName'],context),
                            trailingIcon: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                if (hasAudioFile)
                                  IconButton(
                                    icon: Icon(
                                      isPlayingMap[role['workingDescFilePath']] == true
                                          ? Icons.pause_circle
                                          : Icons.play_circle,
                                      color: isPlayingMap[role['workingDescFilePath']] == true
                                          ? Colors.red
                                          : Colors.green,
                                    ),
                                    onPressed: () {
                                      if (isPlayingMap[role['workingDescFilePath']] == true) {
                                        _stopAudio(role['workingDescFilePath']);
                                      } else {
                                        _playAudio(role['workingDescFilePath']);
                                      }
                                    },
                                  ),
                                if (isAdmin)
                                  IconButton(
                                    onPressed: () => _confirmDeleteRole(role['txnId']),
                                    icon: Icon(Icons.delete, color: Colors.red),
                                  ),
                              ],
                            ),
                            leadingIcon: Row(
                              children: [
                                IconButton(
                                  onPressed: () {
                                    if (hasWorkingNote) {
                                      _showWorkingNoteDialog(
                                          role['workingNote'],
                                          role['workingDate'],
                                          role['userName'],
                                          context
                                      );
                                    }
                                  },
                                  icon: Icon(
                                    icon,
                                    color: iconColor,
                                    size: 20,
                                  ),
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
  }}