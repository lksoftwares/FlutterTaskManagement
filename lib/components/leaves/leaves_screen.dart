
import 'package:lktaskmanagementapp/packages/headerfiles.dart';

class LeavesScreen extends StatefulWidget {
  const LeavesScreen({super.key});

  @override
  State<LeavesScreen> createState() => _LeavesScreenState();
}

class _LeavesScreenState extends State<LeavesScreen> {
  List<Map<String, dynamic>> leaves = [];
  String? selectedRoleName;
  bool isLoading = false;
  String? selectedLeaveStatus;
  String? roleName;

  @override
  void initState() {
    super.initState();
    fetchLeaves();
    _getRoleName();
  }

  List<Map<String, String>> leaveStatuses = [
    {"status": "approved"},
    {"status": "Reject"},
    {"status": "pending"}
  ];

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
    String endpoint = 'leave/GetAllLeave';

    if (roleName == 'Admin') {
      endpoint = 'leave/GetAllLeave';
    } else if (userId != null) {
      endpoint = 'leave/GetAllLeave?userId=$userId';
    }
    final response = await new ApiService().request(
      method: 'get',
      endpoint: endpoint,
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
    );
  }

  Future<void> _deleteLeave(int leaveId) async {
    final response = await new ApiService().request(
      method: 'post',
      endpoint: 'leave/deleteleave/$leaveId',
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
      endpoint: 'leave/EditLeave',
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

  Future<void> _fetchTodaysAbsents() async {
    final response = await new ApiService().request(
      method: 'get',
      endpoint: 'leave/GetAllLeave',
    );

    if (response['statusCode'] == 200) {
      List<dynamic> onLeaveData = response['apiResponse']['onLeave'];

      if (onLeaveData.isEmpty) {
        showToast(msg: 'All are present',backgroundColor: Colors.green);
      } else {
        showCustomAlertDialog(
          context,
          title: 'Today\'s Leaves',
          content: Container(
            height: 100,
            child: SingleChildScrollView(
              child: Column(
                children: [
                  for (var absent in onLeaveData)
                    Text(
                      absent['userName'] ?? 'N/A',
                      style: TextStyle(fontSize: 20),
                    ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Close'),
            ),
          ],
          titleHeight: 70
        );
      }
    } else {
      showToast(msg: 'Failed to fetch absentees');
    }
  }


  List<Map<String, dynamic>> getFilteredData() {
    return leaves.where((role) {
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
        title: 'Leaves',
        onLogout: () => AuthService.logout(context),
      ),
      body: RefreshIndicator(
        onRefresh: fetchLeaves,
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    TextButton(
                      onPressed: () async {
                        await _fetchTodaysAbsents();
                      },
                      child: Text(
                        "Click here to show today's absents",
                        style: TextStyle(color: Colors.red,fontSize: 17,fontWeight: FontWeight.bold),
                      ),
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
    );
  }
}