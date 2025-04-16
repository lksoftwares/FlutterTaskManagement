import 'package:lktaskmanagementapp/packages/headerfiles.dart';

class LeavesScreen extends StatefulWidget {
  const LeavesScreen({super.key});

  @override
  State<LeavesScreen> createState() => _LeavesScreenState();
}

class _LeavesScreenState extends State<LeavesScreen> {
  List<Map<String, dynamic>> leaves = [];
  List<Map<String, dynamic>> users = [];
  String? selectedRoleName;
  bool isLoading = false;
  String? selectedLeaveStatus;
  String? roleName;
  String? selectedUserName;

  @override
  void initState() {
    super.initState();
     fetchLeaves();
    _getRoleName();
     fetchUsers();
  }

  final _formKey = GlobalKey<FormState>();
  final controller = MultiSelectController<String>();
  List<String> leaveStages = ['approved', 'Reject', 'Pending'];

  Map<String, bool> selectedStages = {
    'approved': false,
    'Reject': false,
    'Pending': true,
  };

  List<Map<String, String>> leaveStatuses = [
    {"status": "approved"},
    {"status": "Reject"},
    {"status": "Pending"}
  ];
  Future<void> fetchUsers() async {
    final response = await new ApiService().request(
        method: 'get',
        endpoint: 'User/',
        tokenRequired: true
    );
    if (response['statusCode'] == 200 && response['apiResponse'] != null) {
      setState(() {
        users = List<Map<String, dynamic>>.from(response['apiResponse']);
      });

    } else {
      showToast(msg: response['message'] ?? 'Failed to load users');
    }
  }
  Future<void> _getRoleName() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      roleName = prefs.getString('role_Name');
    });
  }

  Future<void> fetchLeaves() async {
    setState(() {
      isLoading = true;
    });

    SharedPreferences prefs = await SharedPreferences.getInstance();
    int? userId = prefs.getInt('user_Id');
    String roleName = prefs.getString('role_Name') ?? "";
    String endpoint = 'leave/';

    if (roleName == 'Admin') {
      endpoint = 'leave/';
    } else if (userId != null) {
      endpoint = 'leave/?userId=$userId';
    }
    final response = await new ApiService().request(
      method: 'get',
      endpoint: endpoint,
        tokenRequired: true

    );
    print('Response: $response');
    if (response['statusCode'] == 200 && response['apiResponse'] != null) {
      setState(() {
        leaves = List<Map<String, dynamic>>.from(
          response['apiResponse']["leaves"].map((role) =>
          {
            'leaveId': role['leaveId'] ?? 0,
            'leaveStatus': role['leaveStatus'] ?? false,
            'remarks': role['remarks'] ?? "no remarks",
            'leaveFrom': role['leaveFrom'] ?? '',
            'leaveTo': role['leaveTo'] ?? '',
            'createdAt': role['createdAt'] ?? '',
            'leaveApplyDate': role['leaveApplyDate'] ?? '',
            'reason': role['reason'] ?? '',
            'days': role['days'] ?? '',
            'userName': role['userName'] ?? '',
          }),
        );
      });
    } else {
      showToast(msg: response['message'] ?? 'Failed to load leaves');
    }
    setState(() {
      isLoading = false;
    });
  }

  void _confirmDeleteLeave(int leaveId) {
    showCustomAlertDialog(
      context,
      title: 'Delete Leave',
      content: Text('Are you sure you want to delete this Leave?'),
      actions: [

        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.red,
          ),
          onPressed: () {
            _deleteLeave(leaveId);
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

  Future<void> _deleteLeave(int leaveId) async {
    final response = await new ApiService().request(
      method: 'post',
      endpoint: 'leave/delete/$leaveId',
        tokenRequired: true

    );
    if (response['statusCode'] == 200) {
      String message = response['message'] ?? 'Leave deleted successfully';
      showToast(msg: message, backgroundColor: Colors.green);
      fetchLeaves();
    } else {
      String message = response['message'] ?? 'Failed to delete Leave';
      showToast(msg: message);
    }
  }

  Future<void> _editLeaveStatus(int leaveId, String currentLeaveStatus,
      String currentRemarks) async {
    TextEditingController remarksController = TextEditingController(
        text: currentRemarks);
    setState(() {
      selectedLeaveStatus = currentLeaveStatus;
    });

    showCustomAlertDialog(
      context,
      title: 'Edit Leave Status',
      content: Container(
        height: 200,
        child: Column(
          children: [
            SizedBox(height: 20),
            CustomDropdown<String>(
              options: leaveStatuses
                  .map((statusData) => statusData['status']!)
                  .toList(),
              selectedOption: selectedLeaveStatus,
              displayValue: (status) => status,
              onChanged: (newStatus) {
                setState(() {
                  selectedLeaveStatus = newStatus;
                });
              },
              labelText: 'Select Leave Status',
              width: 300,
            ),
            SizedBox(height: 10),
            CustomTextField(
              controller: remarksController,
              label: 'Remarks',
              hintText: 'Remarks',
              maxLines: 2,
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
            _updateLeaveStatus(
                leaveId, selectedLeaveStatus, remarksController.text);
            Navigator.pop(context);
          },
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

  Future<void> _updateLeaveStatus(int leaveId, String? newLeaveStatus,
      String newRemarks) async {
    if (newLeaveStatus == null) {
      showToast(msg: "Please select a leave status.");
      return;
    }

    final response = await new ApiService().request(
      method: 'post',
      endpoint: 'leave/Update',
      tokenRequired: true,
      body: {
        'leaveId': leaveId,
        'leaveStatus': newLeaveStatus,
        'remarks': newRemarks,
        'updateFlag': true,
      },
    );

    if (response['statusCode'] == 200) {
      showToast(
        msg: response['message'] ?? 'Leave status updated successfully',
        backgroundColor: Colors.green,
      );
      fetchLeaves();
    } else {
      showToast(msg: response['message'] ?? 'Failed to update leave status');
    }
  }

  List<Map<String, dynamic>> getFilteredData() {
    if (selectedStages.values.every((value) => !value)) {
      return leaves.where((leave) => leave['leaveStatus'] == 'Pending').toList();
    }

    return leaves.where((leave) {
      bool matchesStage = selectedStages[leave['leaveStatus']] ?? false;
      return matchesStage;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    List<DropdownItem<String>> stageItems = leaveStages
        .map((stage) => DropdownItem(label: stage, value: stage))
        .toList();
    return Scaffold(
      appBar: CustomAppBar(
        title: 'Leaves',
        onLogout: () => AuthService.logout(context),
      ),
      body: RefreshIndicator(
        onRefresh: fetchLeaves,
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  SizedBox(height: 15,),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      MultiSelectDropdown(
                        width: 290,
                        items: stageItems,
                        controller: controller,
                        hintText: 'Select Leave Status',
                        onSelectionChange: (selectedItems) {
                          setState(() {
                            selectedStages = {
                              for (var stage in leaveStages)
                                stage: selectedItems.contains(stage),
                            };
                          });
                          fetchLeaves();
                        },
                      ),
                      IconButton(
                        icon: Icon(
                            Icons.add_circle, color: Colors.blue, size: 30),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => LeaveForm(),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                  SizedBox(height: 10),
                  if (isLoading)
                    Center(child: CircularProgressIndicator())
                  else
                    if (leaves.isEmpty)
                      NoDataFoundScreen()
                    else
                      if (getFilteredData().isEmpty)
                        NoDataFoundScreen()
                    else
                      Column(
                        children: getFilteredData().map((leave) {
                          bool isAdmin = roleName == 'Admin';
                          Widget leaveStatusWidget = Text(
                            leave['leaveStatus'] ?? 'Pending',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: leave['leaveStatus'] == 'approved'
                                  ? Colors.green
                                  : leave['leaveStatus'] == 'Reject'
                                  ? Colors.red
                                  : Colors.black,
                              fontSize: leave['leaveStatus'] == 'approved'
                                  ? 18.0
                                  : leave['leaveStatus'] == 'Reject'
                                  ? 18.0
                                  : 14.0,
                            ),
                          );
                          return buildUserCard(
                            userFields: {
                              'UserName': leave['userName'],
                              '': leave[''],

                              'LeaveStatus': leaveStatusWidget,
                              'ApplyDate': leave['leaveApplyDate'],
                              'LeaveFrom': Text(
                                leave['leaveFrom'] ?? 'N/A',
                                style: TextStyle(fontWeight: FontWeight.w900),
                              ),
                              'LeaveTo': Text(
                                leave['leaveTo'] ?? 'N/A',
                                style: TextStyle(fontWeight: FontWeight.w900),
                              ),
                              'Reason': leave['reason'],
                              'Days': leave['days'],
                              'Remarks': leave['remarks'],
                              'CreatedAt': leave['createdAt'],
                            },
                            onDelete: () => _confirmDeleteLeave(leave['leaveId']),
                            trailingIcon: IconButton(
                              onPressed: () =>
                                  _confirmDeleteLeave(leave['leaveId']),
                              icon: Icon(Icons.delete, color: Colors.red),
                            ),
                            leadingIcon: Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                if (isAdmin)
                                  IconButton(
                                    onPressed: () =>
                                        _editLeaveStatus(
                                            leave['leaveId'],
                                            leave['leaveStatus'],
                                            leave['remarks']),
                                    icon: Icon(Icons.pending_actions,
                                        color: Colors.green, size: 30),
                                  ),
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
      ),
    );
  }
}