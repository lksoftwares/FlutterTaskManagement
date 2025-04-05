import 'package:intl/intl.dart';
import 'package:lktaskmanagementapp/packages/headerfiles.dart';

class ShiftsScreen extends StatefulWidget {
  const ShiftsScreen({super.key});
  @override
  State createState() => _ShiftsScreenState();
}

class _ShiftsScreenState extends State {
  List<Map<String, dynamic>> shifts = [];
  String? selectedRoleName;
  bool isLoading = false;
  TextEditingController startTimeController = TextEditingController();
  TextEditingController endTimeController = TextEditingController();

  @override
  void initState() {
    super.initState();
    fetchShifts();

  }

  Future fetchShifts() async {
    setState(() {
      isLoading = true;
    });

    final response = await new ApiService().request(
        method: 'get', endpoint: 'shift/', tokenRequired: true);
    if (response['statusCode'] == 200 && response['apiResponse'] != null) {
      setState(() {
        shifts = List<Map<String, dynamic>>.from(
          response['apiResponse'].map((role) => {
            'shiftId': role['shiftId'] ?? 0,
            'shiftName': role['shiftName'] ?? 'Unknown shift',
            'startTime': role['startTime'] ?? "",
            'graceTime': role['graceTime'] ?? "",
            'shiftStatus': role['shiftStatus'] ?? false,
            'endTime': role['endTime'] ?? '',
            'createdAt': role['createdAt'] ?? '',
          }),
        );
      });
    } else {}
    setState(() {
      isLoading = false;
    });
  }
  void _showAddShiftModal() {
    String shiftName = '';
    String? startTime;
    String? endTime;
    int graceTime = 0;
    TextEditingController graceTimeController = TextEditingController();
    InputDecoration inputDecoration = InputDecoration(
      labelText: 'Shift Name',
      border: OutlineInputBorder(),
    );
    startTimeController.clear();
    endTimeController.clear();

    startTimeController.text = TimeUtils.getCurrentTime();
    endTimeController.text = TimeUtils.getCurrentTime();

    showCustomAlertDialog(
      context,
      title: 'Add Shift',
      content: Padding(
        padding: const EdgeInsets.all(15.0),
        child: Container(
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 15),
                TextField(
                  onChanged: (value) => shiftName = value,
                  decoration: inputDecoration,
                ),
                SizedBox(height: 20),
                TextField(
                  controller: graceTimeController,
                  onChanged: (value) {
                    graceTime = int.tryParse(value) ?? 0;
                  },
                  decoration: InputDecoration(
                    labelText: 'Grace Time (in minutes)',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
                ),
                SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: TextField(
                        controller: startTimeController,
                        readOnly: true,
                        decoration: InputDecoration(
                          border: OutlineInputBorder(),
                          hintText: "Select Start Time",
                          labelText: "Select Start Time",
                          suffixIcon: IconButton(
                            icon: Icon(Icons.access_time_filled_outlined, size: 25),
                            onPressed: () async {
                              String? selectedStartTime =
                              await TimePickerClass.selectTime(context, true);
                              if (selectedStartTime != null) {
                                setState(() {
                                  startTime = selectedStartTime;
                                  startTimeController.text = selectedStartTime;
                                });
                              }
                            },
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: TextField(
                        controller: endTimeController,
                        readOnly: true,
                        decoration: InputDecoration(
                          border: OutlineInputBorder(),
                          hintText: "Select End Time",
                          labelText: "Select End Time",
                          suffixIcon: IconButton(
                            icon: Icon(Icons.access_time_filled_outlined, size: 25),
                            onPressed: () async {
                              String? selectedEndTime =
                              await TimePickerClass.selectTime(context, false);
                              if (selectedEndTime != null) {
                                setState(() {
                                  endTime = selectedEndTime;
                                  endTimeController.text = selectedEndTime;
                                });
                              }
                            },
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
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
            } else if (startTimeController.text.isEmpty ||
                endTimeController.text.isEmpty) {
              showToast(msg: 'Please select both start and end times');
            } else if (graceTime == 0) {
              showToast(msg: 'Please enter grace time');
            } else {
              _addShift(
                  shiftName,
                  startTimeController.text,
                  endTimeController.text,
                  graceTime);
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

  Future _addShift(
      String shiftName, String startTime, String endTime, int? graceTime) async {
    final response = await new ApiService().request(
      method: 'post',
      endpoint: 'shift/create',
      body: {
        'shiftName': shiftName,
        'startTime': startTime,
        'endTime': endTime,
        'graceTime': graceTime,
      },
      tokenRequired: true,
    );
    print(graceTime);
    if (response['statusCode'] == 200) {
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
          child: Text(
            'Delete',
            style: TextStyle(color: Colors.white),
          ),
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

  Future _deleteShift(int shiftId) async {
    final response = await new ApiService().request(
        method: 'post', endpoint: 'shift/delete/$shiftId', tokenRequired: true);
    if (response['statusCode'] == 200) {
      String message = response['message'] ?? 'Shift deleted successfully';
      showToast(msg: message, backgroundColor: Colors.green);
      fetchShifts();
    } else {
      String message = response['message'] ?? 'Failed to delete Shift';
      showToast(msg: message);
    }
  }

  void _showEditShiftModal(int shiftId, String currentShiftName,
      String currentStartTime, String currentEndTime, int currentGraceTime, bool? shiftStatus) {
    TextEditingController _shiftNameController =
    TextEditingController(text: currentShiftName);
    TextEditingController _graceTimeController =
    TextEditingController(text: currentGraceTime.toString());
    bool? selectedStatus = shiftStatus;

    String? startTime = currentStartTime;
    String? endTime = currentEndTime;
    TextEditingController startTimeController = TextEditingController(text: startTime);
    TextEditingController endTimeController = TextEditingController(text: endTime);

    showCustomAlertDialog(
      context,
      title: 'Edit Shift',
      content: StatefulBuilder(
          builder: (context, setState) {
            return Padding(
              padding: const EdgeInsets.all(15.0),
              child: Container(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: 15),
                      TextField(
                        controller: _shiftNameController,
                        decoration: InputDecoration(
                          labelText: 'Shift Name',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      SizedBox(height: 20),
                      TextField(
                        controller: _graceTimeController,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          labelText: 'Grace Time (in minutes)',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      SizedBox(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: TextField(
                              controller: startTimeController,
                              readOnly: true,
                              decoration: InputDecoration(
                                border: OutlineInputBorder(),
                                hintText: "Select Start Time",
                                labelText: "Select Start Time",
                                suffixIcon: IconButton(
                                  icon: Icon(Icons.access_time_filled_outlined,
                                      size: 25),
                                  onPressed: () async {
                                    String? selectedStartTime =
                                    await TimePickerClass.selectTime(
                                        context, true);
                                    if (selectedStartTime != null) {
                                      setState(() {
                                        startTime = selectedStartTime;
                                        startTimeController.text =
                                            selectedStartTime;
                                      });
                                    }
                                  },
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: TextField(
                              controller: endTimeController,
                              readOnly: true,
                              decoration: InputDecoration(
                                border: OutlineInputBorder(),
                                hintText: "Select End Time",
                                labelText: "Select End Time",
                                suffixIcon: IconButton(
                                  icon: Icon(Icons.access_time_filled_outlined,
                                      size: 25),
                                  onPressed: () async {
                                    String? selectedEndTime =
                                    await TimePickerClass.selectTime(
                                        context, false);
                                    if (selectedEndTime != null) {
                                      setState(() {
                                        endTime = selectedEndTime;
                                        endTimeController.text =
                                            selectedEndTime;
                                      });
                                    }
                                  },
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 15),
                      Padding(
                        padding: const EdgeInsets.only(left: 80),
                        child: Wrap(
                          spacing: 10.0,
                          runSpacing: 4.0,
                          children: [
                            FilterChip(
                              label: Text(
                                'Active',
                                style: TextStyle(
                                  color: selectedStatus == true
                                      ? Colors.white
                                      : Colors
                                      .black,
                                ),
                              ),
                              selected: selectedStatus == true,
                              onSelected: (bool selected) {
                                setState(() {
                                  selectedStatus = true;
                                });
                              },
                              selectedColor: Colors.green,
                              backgroundColor: Colors.grey[200],
                              checkmarkColor: Colors.white,
                            ),
                            FilterChip(
                              label: Text(
                                'Deactive',
                                style: TextStyle(
                                  color: selectedStatus == false
                                      ? Colors.white
                                      : Colors
                                      .black,
                                ),
                              ),
                              selected: selectedStatus == false,
                              onSelected: (bool selected) {
                                setState(() {
                                  selectedStatus = false;
                                });
                              },
                              selectedColor: Colors.red,
                              backgroundColor: Colors.grey[200],
                              checkmarkColor: Colors.white,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }
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
              int? graceTime = int.tryParse(_graceTimeController.text);
              if (graceTime == null) {
                showToast(msg: 'Please enter a valid grace time');
              } else {
                _updateShift(shiftId, _shiftNameController.text, startTime!,
                    endTime!, graceTime, selectedStatus ?? false);
              }
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


  Future _updateShift(int shiftId, String shiftName, String startTime,
      String endTime, int graceTime,bool shiftStatus) async {
    final response = await new ApiService().request(
      method: 'post',
      endpoint: 'shift/update',
      body: {
        'shiftName': shiftName,
        'startTime': startTime,
        'endTime': endTime,
        'shiftId': shiftId,
        'shiftStatus': shiftStatus,
        'graceTime': graceTime.toString(),
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
                    // Autocomplete(
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
                        'ShiftStatus': shift['shiftStatus'],
                        'GraceTime': shift['graceTime'],
                        'StartTime': shift['startTime'],
                        'EndTime': shift['endTime'],
                        'CreatedAt': shift['createdAt'],
                      };

                      return buildUserCard(
                        userFields: {
                          'ShiftName': shift['shiftName'],
                          '': shift[''],
                          'ShiftStatus': shift['shiftStatus'],
                          'GraceTime': shift['graceTime'],
                          'StartTime': shift['startTime'],
                          'EndTime': shift['endTime'],
                          'CreatedAt': shift['createdAt'],
                        },
                        onEdit: () => _showEditShiftModal(
                            shift['shiftId'],
                            shift['shiftName'],
                            shift['startTime'],
                            shift['endTime'],
                            shift['graceTime'],
                          shift['shiftStatus']),
                      onDelete: () => _confirmDeleteShift(shift['shiftId']),
                        trailingIcon: Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            IconButton(
                                onPressed: () => _showEditShiftModal(
                                    shift['shiftId'],
                                    shift['shiftName'],
                                    shift['startTime'],
                                    shift['endTime'],
                                    shift['graceTime'],
                                    shift['shiftStatus']),

                                icon: Icon(
                                  Icons.edit,
                                  color: Colors.green,
                                )),
                            IconButton(
                                onPressed: () =>
                                    _confirmDeleteShift(shift['shiftId']),
                                icon: Icon(
                                  Icons.delete,
                                  color: Colors.red,
                                )),
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