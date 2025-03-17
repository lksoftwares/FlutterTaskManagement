

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
          response['apiResponse']["leaves"].map((role) => {
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

  Future<void> _deleteLeave(int leaveId) async {

    final response = await new ApiService().request(
      method: 'delete',
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
  Future<void> _editLeaveStatus(int leaveId, String currentLeaveStatus) async {
    setState(() {
      selectedLeaveStatus = currentLeaveStatus;
    });

    showCustomAlertDialog(
      context,
      title: 'Edit Leave Status',
      content: Container(
        height: 100,
        child: Column(
          children: [
            Container(
              width: 300,
              height: 60,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey),
              ),
              child: DropdownButton<String>(
                value: selectedLeaveStatus,
                items: leaveStatuses.map((statusData) {
                  return DropdownMenuItem<String>(
                    value: statusData['status'],
                    child: Text(statusData['status'] ?? ""),
                  );
                }).toList(),
                onChanged: (newStatus) {
                  setState(() {
                    selectedLeaveStatus = newStatus;
                  });
                },
                isExpanded: true,
                icon: Icon(Icons.arrow_drop_down),
                iconSize: 30,
              )

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
            _updateLeaveStatus(leaveId, selectedLeaveStatus);
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


  Future<void> _updateLeaveStatus(int leaveId, String? newLeaveStatus) async {
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
        'updateFlag': true,
      },
    );

    if (response['statusCode'] == 200) {
      showToast(
        msg: response['message'] ?? 'Leave status updated successfully',
        backgroundColor: Colors.green,
      );      fetchLeaves();
    } else {
      showToast(msg: response['message'] ?? 'Failed to update leave status');
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
                SizedBox(height: 20),
                if (isLoading)
                  Center(child: CircularProgressIndicator())
                else if (leaves.isEmpty)
                  NoDataFoundScreen()
                else
                  Column(
                    children: getFilteredData().map((leave) {
                      bool isAdmin = roleName == 'Admin';
                      return buildUserCard(
                        userFields: {
                          'UserName': leave['userName'],
                          '': leave[''],
                          'LeaveStatus': leave['leaveStatus'],
                          'ApplyDate': leave['leaveApplyDate'],
                          'LeaveFrom': leave['leaveFrom'],
                          'LeaveTo': leave['leaveTo'],
                          'Reason': leave['reason'],
                          'Days': leave['days'],
                          'Remarks': leave['remarks'],
                          'CreatedAt': leave['createdAt'],
                        },
                        onDelete: () => _confirmDeleteLeave(leave['leaveId']),
                        trailingIcon:  IconButton(
                          onPressed: () =>
                              _confirmDeleteLeave(leave['leaveId']),
                          icon: Icon(Icons.delete, color: Colors.red),
                        ),
                        leadingIcon: Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            if (isAdmin)
                            IconButton(
                              onPressed: () => _editLeaveStatus(
                                  leave['leaveId'], leave['leaveStatus']),
                              icon: Icon(Icons.pending_actions,color: Colors.green,),
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
