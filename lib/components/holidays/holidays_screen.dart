
import 'package:intl/intl.dart';
import 'package:lktaskmanagementapp/packages/headerfiles.dart';

class HolidaysScreen extends StatefulWidget {
  const HolidaysScreen({super.key});

  @override
  State<HolidaysScreen> createState() => _HolidaysScreenState();
}

class _HolidaysScreenState extends State<HolidaysScreen> {
  List<Map<String, dynamic>> holidays = [];
  String? selectedRoleName;
  bool isLoading = false;
  DateTime? dueDate;
  String holidayName = '';
  String Description = '';
  DateTime? fromDate;
  DateTime? toDate;
  @override
  void initState() {
    super.initState();
    fetchHoliday();
  }


  Future<void> fetchHoliday() async {
    setState(() {
      isLoading = true;
    });

    final response = await new ApiService().request(
      method: 'get',
      endpoint: 'holidays',
    );
    print('Response: $response');
    if (response['statusCode'] == 200 && response['apiResponse'] != null) {
      setState(() {
        holidays = List<Map<String, dynamic>>.from(
          response['apiResponse'].map((holiday) =>
          {
            'holidayId': holiday['holidayId'] ?? 0,
            'holidayDate': holiday['holidayDate'] ?? 'Unknown date',
            'holidayName': holiday['holidayName'] ?? "unknown holiday",
            'description': holiday['description'] ?? "unknown desc",
            'createdAt': holiday['createdAt'] ?? '',
            'updatedAt': holiday['updatedAt'] ?? '',
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

  Future<void> _addHoliday() async {
    final response = await new ApiService().request(
      method: 'post',
      endpoint: 'holidays/create',
      body: {
        'holidayName': holidayName,
        'description': Description,
        'holidayDate': dueDate?.toIso8601String(),
      },
    );
    if (response.isNotEmpty && response['statusCode'] == 200) {
      fetchHoliday();
      showToast(
        msg: response['message'] ?? 'Holiday added successfully',
        backgroundColor: Colors.green,
      );
      Navigator.pop(context);
    } else {
      showToast(
        msg: response['message'] ?? 'Failed to add Holiday',
      );
    }
  }

  Future<void> _showAddHolidayModal() async {
    setState(() {
      dueDate = null;
    });

    showCustomAlertDialog(
      context,
      title: 'Add Holiday',
      content: StatefulBuilder(
        builder: (context, setState) {
          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextField(
                  onChanged: (value) => holidayName = value,
                  decoration: InputDecoration(
                    labelText: 'Holiday Name',
                    border: OutlineInputBorder(),
                  ),
                ),
                SizedBox(height: 10),
                TextField(
                  onChanged: (value) => Description = value,
                  decoration: InputDecoration(
                    labelText: ' Description',
                    border: OutlineInputBorder(),
                  ),
                ),
                SizedBox(height: 10),

                SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      dueDate != null
                          ? DateformatddMMyyyy.formatDateddMMyyyy(dueDate!)
                          : 'Select Holiday Date:',
                      style: TextStyle(fontSize: 19),
                    ),
                    IconButton(
                      onPressed: () async {
                        DateTime? pickedDate = await showDatePicker(
                          context: context,
                          initialDate: dueDate ?? DateTime.now(),
                          firstDate: DateTime(2000),
                          lastDate: DateTime(2101),
                        );
                        if (pickedDate != null) {
                          setState(() {
                            dueDate = pickedDate;
                            print(dueDate);
                          });
                        }
                      },
                      icon: Icon(Icons.calendar_month, size: 34),
                    ),
                  ],
                )

              ],
            ),
          );
        },
      ),
      actions: [
        ElevatedButton(
          onPressed: _addHoliday,
          style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
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

  void _confirmDeleteHoliday(int holidayId) {
    showCustomAlertDialog(
      context,
      title: 'Delete Holiday',
      content: Text('Are you sure you want to delete this holiday?'),
      actions: [

        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.red,
          ),
          onPressed: () {
            _deleteHoliday(holidayId);
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

  Future<void> _deleteHoliday(int holidayId) async {
    final response = await new ApiService().request(
      method: 'post',
      endpoint: 'holidays/delete/$holidayId',
    );
    if (response['statusCode'] == 200) {
      String message = response['message'] ?? 'Holiday deleted successfully';
      showToast(msg: message, backgroundColor: Colors.green);
      fetchHoliday();
    } else {
      String message = response['message'] ?? 'Failed to delete Holiday';
      showToast(msg: message);
    }
  }

  Future<void> _updateHoliday(int holidayId) async {

    final response = await new ApiService().request(
      method: 'post',
      endpoint: 'holidays/update',
      body: {
        'holidayId': holidayId,
        'holidayName': holidayName,
        'description': Description,
        'holidayDate': dueDate?.toIso8601String(),
        'updateFlag': true,
      },
    );
    if (response['statusCode'] == 200) {
      showToast(msg: response['message'] ?? 'Task updated successfully', backgroundColor: Colors.green);
      Navigator.pop(context);
      fetchHoliday();
    } else {
      showToast(msg: response['message'] ?? 'Failed to update task');
    }
  }


  Future<void> _showEditHolidayModal(int holidayId) async {
    Map<String, dynamic> holidayToEdit = holidays.firstWhere((holiday) => holiday['holidayId'] == holidayId);
    holidayName = holidayToEdit['holidayName'] ?? '';
    Description = holidayToEdit['description'] ?? '';
    String dueDateString = holidayToEdit['holidayDate'] ?? '';
    dueDate = DateFormat('yyyy-MM-dd').parse(dueDateString);
    showCustomAlertDialog(
      context,
      title: 'Edit Holiday',
      content: StatefulBuilder(
        builder: (context, setState) {
          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextField(
                  controller: TextEditingController(text: holidayName),
                  onChanged: (value) => holidayName = value,
                  decoration: InputDecoration(
                    labelText: 'Holiday Name',
                    border: OutlineInputBorder(),
                  ),
                ),
                SizedBox(height: 10),
                TextField(
                  controller: TextEditingController(text: Description),
                  onChanged: (value) => Description = value,
                  decoration: InputDecoration(
                    labelText: 'Description',
                    border: OutlineInputBorder(),
                  ),
                ),

                SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      dueDate != null
                          ? DateformatddMMyyyy.formatDateddMMyyyy(dueDate!)
                          : 'Select Holiday Date:',style: TextStyle(fontSize: 19),
                    ),
                    IconButton(
                      onPressed: () async {
                        DateTime? pickedDate = await showDatePicker(
                          context: context,
                          initialDate: dueDate ?? DateTime.now(),
                          firstDate: DateTime(2025),
                          lastDate: DateTime(2028),
                        );
                        if (pickedDate != null) {
                          setState(() {
                            dueDate = pickedDate;
                            print(dueDate);
                          });
                        }
                      },
                      icon: Icon(Icons.calendar_month, size: 34),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
      actions: [
        ElevatedButton(
          onPressed: () {
            _updateHoliday(holidayId);
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
    );
  }
  List<Map<String, dynamic>> getFilteredData() {
    return holidays.where((role) {
      bool matchesDate = true;
      if (fromDate != null && toDate != null) {
        DateTime inTime = _parseDate(role['holidayDate']);
        matchesDate = (inTime.isAtSameMomentAs(fromDate!) ||
            inTime.isAfter(fromDate!)) &&
            (inTime.isAtSameMomentAs(toDate!) ||
                inTime.isBefore(toDate!));
      }
      return matchesDate;
    }).toList();
  }

  DateTime _parseDate(String dateStr) {
    try {
      return DateFormat('yyyy-MM-dd').parse(dateStr);
    } catch (e) {
      print("Error parsing date: $e");
      return DateTime(2000);
    }
  }

  void _showDatePicker() {
    showDateRangePicker(
      context: context,
      firstDate: DateTime(2025, DateTime.february),
      lastDate: DateTime(2025, DateTime.june),
      initialDateRange: fromDate != null && toDate != null
          ? DateTimeRange(start: fromDate!, end: toDate!)
          : null,
    ).then((pickedDateRange) {
      if (pickedDateRange != null) {
        setState(() {
          fromDate = pickedDateRange.start;
          toDate = pickedDateRange.end;
        });
        fetchHoliday();
      }
    });
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: 'Holidays',
        onLogout: () => AuthService.logout(context),
      ),
      body: RefreshIndicator(
        onRefresh: fetchHoliday,
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: [
                SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    IconButton(
                      icon: Icon(
                          Icons.filter_alt_outlined, color: Colors.blue, size: 30),
                      onPressed: _showDatePicker,
                    ),
                    IconButton(
                      icon: Icon(
                          Icons.add_circle, color: Colors.blue, size: 30),
                      onPressed: _showAddHolidayModal,
                    ),
                  ],
                ),
                SizedBox(height: 20),
                if (isLoading)
                  Center(child: CircularProgressIndicator())
                else
                  if (holidays.isEmpty)
                    NoDataFoundScreen()
                  else
                    if (getFilteredData().isEmpty)
                      NoDataFoundScreen()
                  else
                    Column(
                      children: getFilteredData().map((holiday) {
                        DateTime holidayDate = DateTime.parse(
                            holiday['holidayDate']);
                        String formattedDate = DateformatddMMyyyy.formatDateddMMyyyy(holidayDate);
                        Map<String, dynamic> holidayFields = {
                          'HolidayName': holiday['holidayName'],
                          '': holiday[''],
                          'Description': holiday['description'],
                          'HolidayDate':formattedDate,
                          'CreatedAt': holiday['createdAt'],
                          'UpdatedAt': holiday['updatedAt'],
                        };

                        return buildUserCard(
                          userFields: {
                            'HolidayName': holiday['holidayName'],
                            '': holiday[''],
                            'Description': holiday['description'],
                            'HolidayDate':formattedDate,
                            'CreatedAt': holiday['createdAt'],
                            'UpdatedAt': holiday['updatedAt'],
                          },
                          onEdit: () => _showEditHolidayModal(holiday['taskId']),
                          onDelete: () =>
                              _confirmDeleteHoliday(holiday['holidayId']),
                          trailingIcon: Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              IconButton(onPressed: ()=>_showEditHolidayModal(holiday['holidayId']),
                                  icon: Icon(Icons.edit,color: Colors.green,)),
                              IconButton(
                                onPressed: () =>
                                    _confirmDeleteHoliday(holiday['holidayId']),
                                icon: Icon(Icons.delete, color: Colors.red),
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