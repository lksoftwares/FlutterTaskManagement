import 'package:lktaskmanagementapp/packages/headerfiles.dart';

class AssignShifts extends StatefulWidget {
  const AssignShifts({super.key});

  @override
  State<AssignShifts> createState() => _AssignShiftsState();
}

class _AssignShiftsState extends State<AssignShifts> {
  List<Map<String, dynamic>> users = [];
  List<Map<String, dynamic>> shifts = [];
  int? selectedShiftId;
  String? selectedRoleName;
  bool isLoading = false;
  String? selectedLeaveStatus;
  String? roleName;
  String? selectedUserName;
  String? selectedShiftName;


  @override
  void initState() {
    super.initState();
    fetchUsers();
    fetchShifts();
  }

  Future<void> fetchUsers() async {
    final response = await new ApiService().request(
        method: 'get',
        endpoint: 'User/?status=1',
        tokenRequired: true
    );
    if (response['statusCode'] == 200 && response['apiResponse'] != null) {
      setState(() {
        users = List<Map<String, dynamic>>.from(
          response['apiResponse'].map((shift) =>
          {
            'shiftId': shift['shiftId'] ?? 0,
            'userId': shift['userId'] ?? 0,
            'shiftName': shift['shiftName'] ?? null,
            'userName': shift['userName'] ?? '',
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
  Future<void> fetchShifts() async {
    setState(() {
      isLoading = true;
    });

    final response = await new ApiService().request(
        method: 'get',
        endpoint: 'shift/?status=1',
        tokenRequired: true
    );
    print('Response: $response');
    if (response['statusCode'] == 200 && response['apiResponse'] != null) {
      setState(() {
        shifts = List<Map<String, dynamic>>.from(
          response['apiResponse'].map((role) => {
            'shiftId': role['shiftId'] ?? 0,
            'shiftName': role['shiftName'] ?? 'Unknown shift',

          }),
        );
      });
    } else {
    }
    setState(() {
      isLoading = false;
    });
  }

  void _editShift(Map<String, dynamic> shift) {
    if (shift['shiftName'] == null || shift['shiftName'] == '') {
      selectedShiftId = null;
    } else {
      selectedShiftId = shift['shiftId'];
    }

    showCustomAlertDialog(
      context,
      title: 'Edit Shift',
      content: StatefulBuilder(
        builder: (context, setState) {
          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(height: 10,),
              CustomDropdown<int>(
                options: shifts.map<int>((user) => user['shiftId'] as int).toList(),
                selectedOption: selectedShiftId,
                displayValue: (userId) {
                  if (userId == null) {
                    return '';
                  }
                  return shifts.firstWhere((user) => user['shiftId'] == userId)['shiftName'] ?? '';
                },
                onChanged: (value) {
                  setState(() {
                    selectedShiftId = value;
                  });
                },
                labelText: 'Select Shift',
              ),
            ],
          );
        },
      ),
      actions: [
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.green,
          ),
          onPressed: () async {
            if (selectedShiftId != null) {
              await updateUserShift(shift['userId'], selectedShiftId!);
              Navigator.of(context).pop();
              fetchUsers();
            } else {
              showToast(msg: 'Please select a shift');
            }
          },
          child: Text('Update', style: TextStyle(color: Colors.white)),
        ),
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: Text('Cancel'),
        ),
      ],
      titleHeight: 80,
        isFullScreen: false,
        additionalTitleContent: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('UserName : ${shift['userName']}',style: TextStyle(fontSize: 16,color: Colors.white),),
            ],
          )
      );
   }
  // void _editShift(Map<String, dynamic> shift) {
  //   if (shift['shiftName'] == null || shift['shiftName'] == '') {
  //     selectedShiftId = null;
  //   } else {
  //     selectedShiftId = shift['shiftId'];
  //   }
  //
  //   showCustomAlertDialog(
  //     context,
  //     title: 'Edit Shift',
  //     content: StatefulBuilder(
  //       builder: (context, setState) {
  //         return Column(
  //           mainAxisSize: MainAxisSize.min,
  //           children: [
  //             SizedBox(height: 10,),
  //             CustomDropdown<int>(
  //               options: shifts.map<int>((user) => user['shiftId'] as int).toList(),
  //               selectedOption: selectedShiftId,
  //               displayValue: (userId) {
  //                 if (userId == null) {
  //                   return 'No Shift';
  //                 }
  //                 return shifts.firstWhere((user) => user['shiftId'] == userId)['shiftName'] ?? 'Unknown Shift';
  //               },
  //               onChanged: (value) {
  //                 setState(() {
  //                   selectedShiftId = value;
  //                 });
  //               },
  //               labelText: 'Select Shift',
  //             ),
  //           ],
  //         );
  //       },
  //     ),
  //     actions: [
  //       ElevatedButton(
  //         style: ElevatedButton.styleFrom(
  //           backgroundColor: Colors.green,
  //         ),
  //         onPressed: () async {
  //           if (selectedShiftId != null) {
  //             await updateUserShift(shift['userId'], selectedShiftId!);
  //             Navigator.of(context).pop();
  //             fetchUsers();
  //           } else {
  //             showToast(msg: 'Please select a shift');
  //           }
  //         },
  //         child: Text('Update', style: TextStyle(color: Colors.white)),
  //       ),
  //       TextButton(
  //         onPressed: () {
  //           Navigator.of(context).pop();
  //         },
  //         child: Text('Cancel'),
  //       ),
  //     ],
  //     titleHeight: 80,
  //     additionalTitleContent: Row(
  //       mainAxisAlignment: MainAxisAlignment.center,
  //       children: [
  //         Text('UserName : ${shift['userName']}', style: TextStyle(fontSize: 16, color: Colors.white)),
  //       ],
  //     ),
  //   );
  // }

  Future<void> updateUserShift(int userId, int shiftId) async {
    setState(() {
      isLoading = true;
    });
    final response = await new ApiService().request(
      method: 'post',
      endpoint: 'User/update',
      tokenRequired: true,
      isMultipart: true,
      body: {
        'userId': userId,
        'shiftId': shiftId,
        'updateFlag': true,
      },
    );

    if (response['statusCode'] == 200 ) {
      showToast(
        msg: response['message'] ?? 'Shift updated successfully',
        backgroundColor: Colors.green,
      );
      fetchUsers();
    } else {
      showToast(msg: response['message'] ?? 'Failed to update shift');
    }

    setState(() {
      isLoading = false;
    });
  }
  List<Map<String, dynamic>> getFilteredData() {
    return users.where((shift) {
      bool matchesshiftName = true;
      if (selectedShiftName != null && selectedShiftName!.isNotEmpty) {
        matchesshiftName = shift['shiftName'] == selectedShiftName;
      }

      return matchesshiftName;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: 'Assign Shift',
        onLogout: () => AuthService.logout(context),
      ),
      body: RefreshIndicator(
        onRefresh: fetchUsers,
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: [
                SizedBox(height: 15,),
                Row(
                  children: [
                    Autocomplete<String>(
                      optionsBuilder: (TextEditingValue textEditingValue) {
                        return shifts
                            .where((shift) => shift['shiftName']!
                            .toLowerCase()
                            .contains(textEditingValue.text.toLowerCase()))
                            .map((shift) => shift['shiftName'] as String)
                            .toList();
                      },
                      onSelected: (String shiftName) {
                        setState(() {
                          selectedShiftName = shiftName;
                        });
                        fetchUsers();
                      },
                      fieldViewBuilder: (context, controller, focusNode, onFieldSubmitted) {
                        return Container(
                          width: 320,
                          child: TextField(
                            controller: controller,
                            focusNode: focusNode,
                            decoration: InputDecoration(
                              labelText: 'Select Shift',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              prefixIcon: Icon(Icons.schedule),
                            ),
                            onChanged: (value) {
                              if (value.isEmpty) {
                                setState(() {
                                  selectedShiftName = null;
                                });
                                fetchUsers();
                              }
                            },
                          ),
                        );
                      },
                    ),
                  ],
                ),
                SizedBox(height: 15,),
                if (isLoading)
                  Center(child: CircularProgressIndicator())
                else
                  if (users.isEmpty)
                    NoDataFoundScreen()
                  else
                    if (getFilteredData().isEmpty)
                      NoDataFoundScreen()
                  else
                    Column(
                      children: getFilteredData().map((shift) {
                        Map<String, dynamic> userFields = {
                          'UserName': shift['userName'],
                          '': shift[''],
                          'ShiftName': shift['shiftName']?? "No Shift",
                        };
                        return buildUserCard(
                          userFields: {
                            'UserName': shift['userName'],
                            '': shift[''],
                            'ShiftName': shift['shiftName']?? "No Shift",
                          },
                          leadingIcon: Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              IconButton(
                                onPressed: () =>
                                    _editShift(shift),
                                icon: Icon(Icons.work_history_rounded,
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