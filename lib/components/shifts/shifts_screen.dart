import 'package:lktaskmanagementapp/packages/headerfiles.dart';

class ShiftsScreen extends StatefulWidget {
  const ShiftsScreen({super.key});

  @override
  State<ShiftsScreen> createState() => _ShiftsScreenState();
}

class _ShiftsScreenState extends State<ShiftsScreen> {
  List<Map<String, dynamic>> shifts = [];
  String? selectedRoleName;
  bool isLoading = false;


  @override
  void initState() {
    super.initState();
    fetchShifts();
  }

  Future<void> fetchShifts() async {
    setState(() {
      isLoading = true;
    });

    final response = await new ApiService().request(
      method: 'get',
      endpoint: 'shift/',
      tokenRequired: true
    );
    if (response['statusCode'] == 200 && response['apiResponse'] != null) {
      setState(() {
        shifts = List<Map<String, dynamic>>.from(
          response['apiResponse'].map((role) => {
            'shiftId': role['shiftId'] ?? 0,
            'shiftName': role['shiftName'] ?? 'Unknown shift',
            'startTime': role['startTime'] ?? "",
            'endTime': role['endTime'] ?? '',
            'createdAt': role['createdAt'] ?? '',
          }),
        );
      });
    } else {
    }
    setState(() {
      isLoading = false;
    });
  }

  void _showAddShiftModal() {
    String shiftName = '';
    String? startTime;
    String? endTime;

    InputDecoration inputDecoration = InputDecoration(
      labelText: 'Shift Name',
      border: OutlineInputBorder(),
    );

    showCustomAlertDialog(
      context,
      title: 'Add Shift',
      content: Container(
        height: 200,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              onChanged: (value) => shiftName = value,
              decoration: inputDecoration,
            ),
            SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Start Time: ',style: TextStyle(fontSize: 17,fontWeight: FontWeight.bold),),
                IconButton(
                  icon: Icon(Icons.access_time_filled_outlined,size: 25,),
                  onPressed: () async {
                    String? selectedStartTime = await TimePickerClass.selectTime(context, true);
                    setState(() {
                      startTime = selectedStartTime;
                    });
                  },
                ),
                if (startTime != null) Text('$startTime'),
              ],
            ),
            SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,

              children: [
                Text('End Time: ',style: TextStyle(fontSize: 17,fontWeight: FontWeight.bold),),
                IconButton(
                  icon: Icon(Icons.access_time_filled_outlined,size: 25,),
                  onPressed: () async {
                    String? selectedEndTime = await TimePickerClass.selectTime(context, false);
                    setState(() {
                      endTime = selectedEndTime;
                    });
                  },
                ),
                if (endTime != null) Text('$endTime'),
              ],
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
            if (shiftName.isEmpty) {
              showToast(msg: 'Please fill in the shift name');
            } else if (startTime == null || endTime == null) {
              showToast(msg: 'Please select both start and end times');
            } else {
              _addShift(shiftName, startTime!, endTime!);
            }
          },
          child: Text('Add', style: TextStyle(color: Colors.white)),
        ),
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text('Cancel'),
        ),
      ],
      titleHeight: 65,
    );
  }

  Future<void> _addShift(String shiftName, String startTime, String endTime) async {
    final response = await new ApiService().request(
      method: 'post',
      endpoint: 'shift/create',
      body: {
        'shiftName': shiftName,
        'startTime': startTime,
        'endTime': endTime,
      },
      tokenRequired: true,
    );

    if (response.isNotEmpty && response['statusCode'] == 200) {
      fetchShifts();
      showToast(
        msg: response['message'] ?? 'Shift added successfully',
        backgroundColor: Colors.green,
      );
      Navigator.pop(context);
    } else {
      showToast(
        msg: response['message'] ?? 'Failed to add shift',
      );
    }
  }


  void _confirmDeleteShift(int shiftId) {
    showCustomAlertDialog(
      context,
      title: 'Delete Shift',
      content: Text('Are you sure you want to delete this shift?'),
      actions: [

        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.red,
          ),
          onPressed: () {
            _deleteShift(shiftId);
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

  Future<void> _deleteShift(int shiftId) async {

    final response = await new ApiService().request(
        method: 'post',
        endpoint: 'shift/delete/$shiftId',
        tokenRequired: true
    );
    if (response['statusCode'] == 200) {
      String message = response['message'] ?? 'Shift deleted successfully';
      showToast(msg: message, backgroundColor: Colors.green);
      fetchShifts();
    } else {
      String message = response['message'] ?? 'Failed to delete Shift';
      showToast(msg: message);
    }
  }

  void _showEditShiftModal(int shiftId, String currentShiftName, String currentStartTime, String currentEndTime) {
    TextEditingController _shiftNameController = TextEditingController(text: currentShiftName);
    String? startTime = currentStartTime;
    String? endTime = currentEndTime;
    showCustomAlertDialog(
      context,
      title: 'Edit Shift',
      content: Container(
        height: 250,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _shiftNameController,
              decoration: InputDecoration(
                labelText: 'Shift Name',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Start Time: ', style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold)),
                IconButton(
                  icon: Icon(Icons.access_time_filled_outlined, size: 25),
                  onPressed: () async {
                    String? selectedStartTime = await TimePickerClass.selectTime(context, true, initialTime: startTime);
                    setState(() {
                      startTime = selectedStartTime;
                    });
                  },
                ),
                if (startTime != null) Text('$startTime'),
              ],
            ),
            SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('End Time: ', style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold)),
                IconButton(
                  icon: Icon(Icons.access_time_filled_outlined, size: 25),
                  onPressed: () async {
                    String? selectedEndTime = await TimePickerClass.selectTime(context, false, initialTime: endTime);
                    setState(() {
                      endTime = selectedEndTime;
                    });
                  },
                ),
                if (endTime != null) Text('$endTime'),
              ],
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
            if (_shiftNameController.text.isEmpty) {
              showToast(msg: 'Please enter the shift name');
            } else if (startTime == null || endTime == null) {
              showToast(msg: 'Please select time');
            } else {
              _updateShift(shiftId, _shiftNameController.text, startTime!, endTime!);
            }
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


  Future<void> _updateShift(int shiftId, String shiftName, String startTime, String endTime) async {
    final response = await new ApiService().request(
      method: 'post',
      endpoint: 'shift/update',
      body: {
        'shiftName': shiftName,
        'startTime': startTime,
        'endTime': endTime,
        'shiftId': shiftId,
        'updateflag': true,
      },
      tokenRequired: true,
    );

    if (response.isNotEmpty && response['statusCode'] == 200) {
      fetchShifts();
      showToast(
        msg: response['message'] ?? 'Shift updated successfully',
        backgroundColor: Colors.green,
      );
      Navigator.pop(context);
    } else {
      showToast(
        msg: response['message'] ?? 'Failed to update shift',
      );
    }
  }


  List<Map<String, dynamic>> getFilteredData() {
    return shifts.where((role) {
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
        title: 'Shifts',
        onLogout: () => AuthService.logout(context),
      ),
      body: RefreshIndicator(
        onRefresh: fetchShifts,
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
                    //     return shifts
                    //         .where((role) => role['roleName']!
                    //         .toLowerCase()
                    //         .contains(textEditingValue.text.toLowerCase()))
                    //         .map((role) => role['roleName'] as String)
                    //         .toList();
                    //   },
                    //   onSelected: (String roleName) {
                    //     setState(() {
                    //       selectedRoleName = roleName;
                    //     });
                    //     fetchShifts();
                    //   },
                    //   fieldViewBuilder: (context, controller, focusNode, onFieldSubmitted) {
                    //     return Container(
                    //       width: 280,
                    //       child: TextField(
                    //         controller: controller,
                    //         focusNode: focusNode,
                    //         decoration: InputDecoration(
                    //           labelText: 'Select Role',
                    //           border: OutlineInputBorder(
                    //             borderRadius: BorderRadius.circular(10),
                    //           ),
                    //           prefixIcon: Icon(Icons.person),
                    //         ),
                    //         onChanged: (value) {
                    //           if (value.isEmpty) {
                    //             setState(() {
                    //               selectedRoleName = null;
                    //             });
                    //             fetchShifts();
                    //           }
                    //         },
                    //       ),
                    //     );
                    //   },
                    // ),
                    IconButton(
                      icon: Icon(Icons.add_circle, color: Colors.blue, size: 30),
                      onPressed: _showAddShiftModal,
                    ),
                  ],
                ),

                SizedBox(height: 20),
                if (isLoading)
                  Center(child: CircularProgressIndicator())
                else if (shifts.isEmpty)
                  NoDataFoundScreen()
                else
                  Column(
                    children: getFilteredData().map((shift) {
                      Map<String, dynamic> roleFields = {
                        'ShiftName': shift['shiftName'],
                        '': shift[''],
                        'StartTime': shift['startTime'],
                        'EndTime': shift['endTime'],
                        'CreatedAt': shift['createdAt'],
                      };

                      return buildUserCard(
                        userFields: {
                          'ShiftName': shift['shiftName'],
                          '': shift[''],
                          'StartTime': shift['startTime'],
                          'EndTime': shift['endTime'],
                          'CreatedAt': shift['createdAt'],
                        },
                        onEdit: () => _showEditShiftModal(shift['shiftId'], shift['shiftName'], shift['startTime'], shift['endTime']),
                        onDelete: () => _confirmDeleteShift(shift['shiftId']),
                        trailingIcon:
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            IconButton(onPressed: ()=>_showEditShiftModal(shift['shiftId'], shift['shiftName'], shift['startTime'], shift['endTime']),
                                icon: Icon(Icons.edit,color: Colors.green,)),
                            IconButton(onPressed: ()=>_confirmDeleteShift(shift['shiftId']),
                                icon: Icon(Icons.delete,color: Colors.red,)),

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