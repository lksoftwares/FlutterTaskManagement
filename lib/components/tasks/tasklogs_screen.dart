import 'package:lktaskmanagementapp/packages/headerfiles.dart';

class TasklogsScreen extends StatefulWidget {
  const TasklogsScreen({super.key});

  @override
  State<TasklogsScreen> createState() => _TasklogsScreenState();
}


class _TasklogsScreenState extends State<TasklogsScreen> {
  List<Map<String, dynamic>> tasklogs = [];
  bool isLoading = false;


  @override
  void initState() {
    super.initState();

    fetchTaskLogs();
  }

  Future<void> fetchTaskLogs() async {
    setState(() {
      isLoading = true;
    });

    final response = await new ApiService().request(
      method: 'get',
      endpoint: 'tasks/GetAllTaskLogs',
        tokenRequired: true

    );
    print('Response: $response');
    if (response['statusCode'] == 200 && response['apiResponse'] != null) {
      setState(() {
        tasklogs = List<Map<String, dynamic>>.from(
          response['apiResponse'].map((logs) => {
            'taskLogsId': logs['taskLogsId'] ?? 0,
            'taskId': logs['taskId'] ?? 0,
            'oldStatus': logs['oldStatus'] ?? "",
            'newStatus': logs['newStatus'] ?? '',
            'oldPriority': logs['oldPriority'] ?? '',
            'newPriority': logs['newPriority'] ?? '',
            'taskTitle': logs['taskTitle'] ?? "unknown title",
            'changedByUser': logs['changedByUser'] ?? "unknown user",
            'oldAssignedToUser': logs['oldAssignedToUser'] ?? "unknown user",
            'newAssignedToUser': logs['newAssignedToUser'] ?? "unknown user",
            'createdAt': logs['createdAt'] ?? '',
            'updatedAt': logs['updatedAt'] ?? '',
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

  //
  //
  // void _confirmDeleteTaskLogs(int taskLogsId) {
  //   showCustomAlertDialog(
  //     context,
  //     title: 'Delete Task Logs',
  //     content: Text('Are you sure you want to delete this log?'),
  //     actions: [
  //
  //       ElevatedButton(
  //         style: ElevatedButton.styleFrom(
  //           backgroundColor: Colors.red,
  //         ),
  //         onPressed: () {
  //           _deleteTaskLogs(taskLogsId);
  //           Navigator.pop(context);
  //         },
  //         child: Text('Delete',style: TextStyle(color: Colors.white),),
  //       ),
  //       TextButton(
  //         onPressed: () => Navigator.pop(context),
  //         child: Text('Cancel'),
  //       ),
  //     ],
  //     titleHeight: 65,
  //   );
  // }
  //
  // Future<void> _deleteTaskLogs(int taskLogsId) async {
  //   final response = await new ApiService().request(
  //     method: 'post',
  //     endpoint: '/$taskLogsId',
  //       tokenRequired: true
  //
  //   );
  //   if (response['statusCode'] == 200) {
  //     String message = response['message'] ?? 'Role deleted successfully';
  //     showToast(msg: message, backgroundColor: Colors.green);
  //     fetchTaskLogs();
  //   } else {
  //     String message = response['message'] ?? 'Failed to delete role';
  //     showToast(msg: message);
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: 'Task Logs',
        onLogout: () => AuthService.logout(context),
      ),
      body: RefreshIndicator(
        onRefresh: fetchTaskLogs,
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: [
                SizedBox(height: 20),
                if (isLoading)
                  Center(child: CircularProgressIndicator())
                else if (tasklogs.isEmpty)
                  NoDataFoundScreen()
                else
                  Column(
                    children: tasklogs.map((logs) {
                      Map<String, dynamic> logsFields = {
                        'TaskTitle': logs['taskTitle'],
                        '': logs[''],
                        'OldStatus': logs['oldStatus'] ,
                        'NewStatus': logs['newStatus'],
                        'OldPriority': logs['oldPriority'],
                        'NewPriority': logs['newPriority'],
                        'ChangedBy': logs['changedByUser'],
                        'OldAssigned': logs['oldAssignedToUser'],
                        'Newassigned': logs['newAssignedToUser'],
                        'CreatedAt': logs['createdAt'],
                        'UpdatedAt': logs['updatedAt'],
                      };

                      return buildUserCard(
                        userFields: logsFields,
                        //onDelete: () => _confirmDeleteTaskLogs(logs['taskLogsId']),
                        trailingIcon:
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            //
                            // IconButton(onPressed: ()=>_confirmDeleteTaskLogs(logs['taskLogsId']),
                            //     icon: Icon(Icons.delete,color: Colors.red,)),

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