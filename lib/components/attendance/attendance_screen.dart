import 'package:geolocator/geolocator.dart';
import 'package:intl/intl.dart';
import 'package:lktaskmanagementapp/packages/headerfiles.dart';

class AttendanceScreen extends StatefulWidget {
  @override
  _AttendanceScreenState createState() => _AttendanceScreenState();
}

class _AttendanceScreenState extends State<AttendanceScreen> {
  bool isFiltering = false;
  String? checkInTime;
  String? checkOutTime;
  List<Map<String, dynamic>> attendance = [];
  bool isLoading = false;
  String? holidayName;
  String? currentLocation = '';
  List<Map<String, dynamic>> combinedData = [];
  String? username = '';
  String? userRole = '';
  bool showHolidayCheckbox = false;
  String? roleName;
  DateTime? fromDate;
  List<Map<String, dynamic>> holidays = [];
  DateTime? toDate;
  bool hasCheckedIn = false;
  bool hasCheckedOut = false;
  bool attendanceOnHoliday = false;
  bool isAttendanceSectionVisible = false;
  List<Map<String, dynamic>> usersList = [];
  List<Map<String, dynamic>> attendanceCountPerUser = [];
  DateTime? countStartDate;
  DateTime? countEndDate;
  int? selectedUserId;
  String? selectedUserName;


  @override
  void initState() {
    super.initState();
    final currentDate = DateTime.now();
    fromDate = DateTime(currentDate.year, currentDate.month, currentDate.day);
    toDate = fromDate;
    fetchUserData();
    fetchAttendance();
    fetchUsers();
    fetchHoliday();
  }
  Future<void> fetchUsers() async {
    final response = await new ApiService().request(
        method: 'get',
        endpoint: 'User/?status=1',
        tokenRequired: true

    );
    if (response['statusCode'] == 200 && response['apiResponse'] != null) {
      setState(() {
        usersList = List<Map<String, dynamic>>.from(response['apiResponse']);
      });
    } else {
      print("Failed to load users");
    }
  }
  Future<void> saveAttendanceState() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool('hasCheckedIn', hasCheckedIn);
    await prefs.setBool('hasCheckedOut', hasCheckedOut);
  }
  void toggleAttendanceSection() {
    setState(() {
      isAttendanceSectionVisible = !isAttendanceSectionVisible;
    });
  }
  Future<void> fetchHoliday() async {
    setState(() {
      isLoading = true;
    });

    final response = await new ApiService().request(
        method: 'get',
        endpoint: 'holidays/',
        tokenRequired: true
    );
    print('Response: $response');
    if (response['statusCode'] == 200 && response['apiResponse'] != null) {
      setState(() {
        holidays = List<Map<String, dynamic>>.from(
          response['apiResponse'].map((holiday) =>

          {
            'holidayId': holiday['holidayId'] ?? 0,
            'holidayName': holiday['holidayName'] ?? 'Unknown name',
            'holidayDate': holiday['holidayDate'] ?? 'Unknown date',
          }),

        );
      });
      checkIfTodayIsHoliday();
    } else {
      print('Failed to load holidays');
    }
    setState(() {
      isLoading = false;
    });
  }

  void checkIfTodayIsHoliday() {
    DateTime today = DateTime.now();
    for (var holiday in holidays) {
      String holidayDateString = holiday['holidayDate'];
      try {
        DateTime holidayDate = DateFormat('yyyy-MM-dd').parse(holidayDateString);
        if (today.year == holidayDate.year &&
            today.month == holidayDate.month && today.day == holidayDate.day) {
          setState(() {
            showHolidayCheckbox = true;
            holidayName = holiday['holidayName'];
          });
          return;
        }
      } catch (e) {
        print("Error parsing holiday date: $e");
      }
    }
    setState(() {
      showHolidayCheckbox = false;
      holidayName = null;
    });
  }

  Future<void> fetchUserData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      username = prefs.getString('user_Name') ?? 'No User';
      userRole = prefs.getString('role_Name') ?? 'No Role';
    });
  }

  Map<dynamic, List<Map<String, dynamic>>> getFilteredData() {
    List<Map<String, dynamic>> filteredAttendance = attendance.where((role) {
      bool matchesDate = true;
      if (fromDate != null && toDate != null) {
        DateTime inTime = _parseDate(role['inDateTime']);
        matchesDate = (inTime.isAtSameMomentAs(fromDate!) ||
            inTime.isAfter(fromDate!)) &&
            (inTime.isAtSameMomentAs(toDate!) ||
                inTime.isBefore(toDate!));
      }
      return matchesDate;
    }).toList();

    var groupedData = groupBy(filteredAttendance, (item) => item['userName']);
    return groupedData;
  }

  DateTime _parseDate(String dateStr) {
    return DateformatddMMyyyy.parseDateddMMyyyy(dateStr);
  }

  void _showDatePicker() {
    showDateRangePicker(
      context: context,
      firstDate: DateTime(2025, DateTime.january),
      lastDate: DateTime(2025, DateTime.december),
      initialDateRange: fromDate != null && toDate != null
          ? DateTimeRange(start: fromDate!, end: toDate!)
          : null,
    ).then((pickedDateRange) {
      if (pickedDateRange != null) {
        setState(() {
          fromDate = pickedDateRange.start;
          toDate = pickedDateRange.end;
          isFiltering = true;
        });
        fetchAttendance();
      }
    });
  }

  Future<void> getCurrentLocation() async {
    LocationPermission permission = await Geolocator.requestPermission();
    if (permission == LocationPermission.always ||
        permission == LocationPermission.whileInUse) {
      Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);
      print('Current location: Latitude: ${position
          .latitude}, Longitude: ${position.longitude}');

      List<Placemark> placemarks = await placemarkFromCoordinates(
          position.latitude, position.longitude);
      if (placemarks.isNotEmpty) {
        Placemark placemark = placemarks.first;
        currentLocation = '${placemark.street}, ${placemark.locality}';
        print('Address: $currentLocation');
      } else {
        print('No address found');
      }
    } else {
      print('Location permission not granted');
    }
  }
  Future<void> markAttendanceCheckin(String inOutFlag,
      String inLocation) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    int userId = prefs.getInt('user_Id') ?? 0;

    if (userId != 0) {
      setState(() {
        isLoading = true;
      });
      final response = await new ApiService().request(
        method: 'post',
        endpoint: 'attendance/MarkAttendnace',
        tokenRequired: true,
        body: {
          'userId': userId,
          'inOutFlag': inOutFlag,
          'inLocation': inLocation,
          'attendanceOnHoliday': attendanceOnHoliday,
        },
      );
      if (response['statusCode'] >= 200 && response['statusCode'] < 400) {
        if (showHolidayCheckbox && !attendanceOnHoliday) {
          showToast(
            msg: response['message'] ?? '',
          );
          setState(() {
            isLoading = false;
          });
          return;
        }
        showToast(
            msg: response['message'] ?? 'Added', backgroundColor: Colors.green);
        setState(() {
          hasCheckedIn = true;
          hasCheckedOut = false;
        });
        await saveAttendanceState();

      } else {
        showToast(msg: response['message'] ?? 'Failed to mark attendance');
      }

      setState(() {
        isLoading = false;
      });
    } else {
      showToast(msg: 'User not logged in');
    }
  }

  Future<void> markAttendanceCheckout(String inOutFlag,
      String outLocation) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    int userId = prefs.getInt('user_Id') ?? 0;

    if (userId != 0) {
      setState(() {
        isLoading = true;
      });

      final response = await new ApiService().request(
        method: 'post',
        endpoint: 'attendance/MarkAttendnace',
        tokenRequired: true,

        body: {
          'userId': userId,
          'inOutFlag': inOutFlag,
          'outLocation': outLocation,
        },
      );

      if (response['statusCode'] >= 200 && response['statusCode'] < 400) {
        showToast(
            msg: response['message'] ?? 'Added', backgroundColor: Colors.green);
        setState(() {
          hasCheckedIn = false;
          hasCheckedOut = true;
        });
        await saveAttendanceState();
      } else {
        showToast(msg: response['message'] ?? 'Failed to mark attendance');
      }

      setState(() {
        isLoading = false;
      });
    } else {
      showToast(msg: 'User not logged in');
    }
  }

  Future<void> fetchAttendance() async {
    setState(() {
      isLoading = true;
    });
    SharedPreferences prefs = await SharedPreferences.getInstance();
    int? userId = prefs.getInt('user_Id');
    String roleName = prefs.getString('role_Name') ?? "";

    String endpoint = 'attendance/';

    if (roleName == 'Admin') {
      endpoint = 'attendance/';
    } else if (userId != null) {
      endpoint = 'attendance/?userId=$userId';
    }

    final response = await new ApiService().request(
      method: 'get',
      endpoint: endpoint,
      tokenRequired: true,
    );

    setState(() {
      isLoading = false;
    });

    if (response['statusCode'] == 200) {
      if (response['apiResponse'] != null) {
        setState(() {
          attendance = List<Map<String, dynamic>>.from(
            response['apiResponse']['attendanceData'].map((member) => {
              'atTxnId': member['atTxnId'] ?? 0,
              'inDateTime': member['inDateTime'] ?? "----/----/-------- --:--",
              'userId': member['userId'] ?? 0,
              'outDateTime': member['outDateTime'] ?? "----/----/-------- --:--",
              'userName': member['userName'] ?? 'Unknown user',
              'inLocation': member['inLocation'] ?? '',
              'outLocation': member['outLocation'] ?? null,
              'dailyWorkingHour': member['dailyWorkingHour'] ?? '',
            }),
          );
          attendanceCountPerUser = List<Map<String, dynamic>>.from(
            response['apiResponse']['attendanceCountPerUser'] ?? [],
          );
        });
      } else {
        setState(() {
          attendance = [];
          attendanceCountPerUser = [];
        });
      }
    } else {
      showToast(msg: response['message'] ?? 'Failed to fetch attendance');
    }
  }

  List<Map<String, dynamic>> getFilteredAttendanceData() {
    if (selectedUserName == null || selectedUserName!.isEmpty) return attendanceCountPerUser;

    return attendanceCountPerUser.where((record) =>
    record['userName'] == selectedUserName).toList();
  }

  void _showAttendanceCountDialog() async {
    selectedUserName = null;
    countStartDate = null;
    countEndDate = null;

    await fetchAttendanceCountData(reset: true);

    TextEditingController _userController = TextEditingController();

    showCustomAlertDialog(
      context,
      title: "Attendance Count",
      content: StatefulBuilder(
        builder: (BuildContext context, StateSetter setStateDialog) {
          return SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(height: 20),
                Row(
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(left: 15.0),
                      child: SizedBox(
                        width: 280,
                        child: Autocomplete<String>(
                          optionsBuilder: (TextEditingValue textEditingValue) {
                            return usersList
                                .where((user) => user['userName']!
                                .toLowerCase()
                                .contains(textEditingValue.text.toLowerCase()))
                                .map((user) => user['userName'] as String)
                                .toList();
                          },
                          onSelected: (String userName) async {
                            setStateDialog(() {
                              selectedUserName = userName;
                              _userController.text = userName;
                            });
                            await fetchAttendanceCountData();
                            setStateDialog(() {});
                          },
                          fieldViewBuilder: (context, controller, focusNode, onFieldSubmitted) {
                            // Sync the controller only once when selectedUserName is null
                            if (selectedUserName == null && controller.text.isNotEmpty) {
                              WidgetsBinding.instance.addPostFrameCallback((_) {
                                controller.clear();
                              });
                            }

                            return TextField(
                              controller: controller,
                              focusNode: focusNode,
                              decoration: InputDecoration(
                                labelText: 'Select User',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                prefixIcon: Icon(Icons.person),
                              ),
                              onChanged: (value) async {
                                if (value.isEmpty) {
                                  setStateDialog(() {
                                    selectedUserName = null;
                                  });
                                  await fetchAttendanceCountData();
                                  setStateDialog(() {});
                                }
                              },
                            );
                          },
                        ),
                      ),
                    ),
                    IconButton(
                      icon: Icon(Icons.filter_alt_outlined, color: Colors.blue, size: 30),
                      onPressed: () async {
                        DateTimeRange? pickedRange = await showDateRangePicker(
                          context: context,
                          firstDate: DateTime(2023),
                          lastDate: DateTime(2025, 12),
                        );
                        if (pickedRange != null) {
                          setStateDialog(() {
                            countStartDate = pickedRange.start;
                            countEndDate = pickedRange.end;
                          });
                          await fetchAttendanceCountData();
                          setStateDialog(() {});
                        }
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                SizedBox(
                  width: double.maxFinite,
                  child: attendanceCountPerUser.isEmpty
                      ? Center(
                    child: Padding(
                      padding: const EdgeInsets.only(top: 80.0),
                      child: Text(
                        "No data found",
                        style: TextStyle(fontSize: 25, color: Colors.grey),
                      ),
                    ),
                  )
                      : buildAttendanceCountList(),
                ),
              ],
            ),
          );
        },
      ),
      actions: [
        TextButton(
          child: Text("Close"),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ],
      isFullScreen: true,
      titleHeight: 60,
    );
  }



  Future<void> fetchAttendanceCountData({bool reset = false}) async {
    setState(() => isLoading = true);

    String endpoint = 'attendance/';
    if (!reset && countStartDate != null && countEndDate != null) {
      String formattedStart = DateFormat('yyyy-MM-dd').format(countStartDate!);
      String formattedEnd = DateFormat('yyyy-MM-dd').format(countEndDate!);
      endpoint = 'attendance/?startDate=$formattedStart&endDate=$formattedEnd';
    }

    final response = await ApiService().request(
      method: 'get',
      endpoint: endpoint,
      tokenRequired: true,
    );

    setState(() => isLoading = false);

    if (response['statusCode'] == 200 && response['apiResponse'] != null) {
      setState(() {
        attendanceCountPerUser = List<Map<String, dynamic>>.from(
          response['apiResponse']['attendanceCountPerUser'] ?? [],
        );
        combinedData = List<Map<String, dynamic>>.from(
          response['apiResponse']['combinedData'] ?? [],
        );
      });
    }
    else {
      showToast(msg: response['message'] ?? 'Failed to fetch data');
    }
  }

  Map<String, List<Map<String, dynamic>>> groupAttendanceByUser(List<Map<String, dynamic>> data) {
    Map<String, List<Map<String, dynamic>>> groupedData = {};
    for (var item in data) {
      String userName = item['userName'] ?? 'Unknown';
      if (!groupedData.containsKey(userName)) {
        groupedData[userName] = [];
      }
      groupedData[userName]!.add(item);
    }
    return groupedData;
  }
  bool isCountFilteringActive() {
    return countStartDate != null && countEndDate != null;
  }
  String formatDateRange(String? range) {
    if (range == null || !range.contains(' to ')) return '';
    try {
      final parts = range.split(' to ');
      final start = DateFormat('yyyy-MM-dd').parse(parts[0]);
      final end = DateFormat('yyyy-MM-dd').parse(parts[1]);

      final formattedStart = DateFormat('dd-MM-yyyy').format(start);
      final formattedEnd = DateFormat('dd-MM-yyyy').format(end);

      return '$formattedStart to $formattedEnd';
    } catch (e) {
      return range;
    }
  }

  Widget buildAttendanceCountList() {
    final filteredData = getFilteredAttendanceData();
    final groupedData = groupAttendanceByUser(filteredData);

    if (isCountFilteringActive()) {
      final filteredCombined = selectedUserName == null
          ? combinedData
          : combinedData
          .where((user) => user['userName'] == selectedUserName)
          .toList();
      return ListView.builder(
        shrinkWrap: true,
        physics: NeverScrollableScrollPhysics(),
        itemCount: groupedData.length,
        itemBuilder: (context, index) {
          String userName = groupedData.keys.elementAt(index);
          List<Map<String, dynamic>> userRecords = groupedData[userName]!;
          final user = filteredCombined[index];
          return Card(
            elevation: 4,
            margin: EdgeInsets.symmetric(vertical: 10, horizontal: 12),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            color: Colors.blue.shade50,

            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Center(
                        child: Text(
                          userName,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 22,
                            color: Colors.indigo.shade800,
                          ),

                        ),
                      ),

                      Text(
                        "${user['totalPresent'] ?? 0} / ${user['totalDaysInRange'] ?? 0}",
                        style: TextStyle(
                            color: Colors.black87,
                            fontWeight: FontWeight.bold,
                            fontSize: 16),
                      ),
                    ],
                  ),


                  ListView.builder(
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    itemCount: userRecords.length,
                    itemBuilder: (context, idx) {
                      final record = userRecords[idx];
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(record['monthName'] ?? '',
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                      color: Colors.indigo.shade900)),
                              Text("📅 ${formatDateRange(record['range'])}",
                                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),

                            ],
                          ),
                          SizedBox(height: 14),

                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text("✅ P",
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold, fontSize: 16)),
                              Text("❌ AB ",
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold, fontSize: 16)),
                              Text("📝 L",
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold, fontSize: 16)),
                              Text("📆 H",
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold, fontSize: 16)),
                            ],
                          ),
                          SizedBox(height: 4),

                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text("${record['totalPresent'] ?? 0}/${record['totalDaysInRange'] ?? 0}",
                                  style: TextStyle(color: Colors.green, fontSize: 16)),
                              Text("${record['absentDays'] ?? 0}",
                                  style: TextStyle(color: Colors.redAccent, fontSize: 16)),
                              Text("${record['totalLeaves'] ?? 0}",
                                  style: TextStyle(color: Colors.blueGrey, fontSize: 16)),
                              Text("${record['totalHolidays'] ?? 0}",
                                  style: TextStyle(color: Colors.teal, fontSize: 16)),
                            ],
                          ),
                          SizedBox(height: 8),
                          Divider(color: Colors.black,),
                          SizedBox(height: 8),

                        ],
                      );
                    },
                  ),
                ],
              ),
            ),
          );
        },
      );
    }

    List<Map<String, dynamic>> allRecords = [];

    for (var entry in groupedData.entries) {
      String userName = entry.key;
      for (var record in entry.value) {
        record['userName'] = userName;
        allRecords.add(record);
      }
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      itemCount: allRecords.length,
      itemBuilder: (context, index) {
        final record = allRecords[index];

        return Padding(
          padding: const EdgeInsets.all(8.0),
          child: Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.blue.shade50,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Text(
                    record['userName'] ?? '',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 22,
                      color: Colors.indigo.shade800,
                    ),
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(record['monthName'] ?? '',
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: Colors.indigo.shade900)),
                    Text("📅 ${formatDateRange(record['range'])}",
                        style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),

                  ],
                ),
                SizedBox(height: 14),

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text("✅ P",
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 16)),
                    Text("❌ AB ",
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 16)),
                    Text("📝 L",
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 16)),
                    Text("📆 H",
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 16)),
                  ],
                ),
                SizedBox(height: 4),

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text("${record['totalPresent'] ?? 0}/${record['totalDaysInRange'] ?? 0}",
                        style: TextStyle(color: Colors.green, fontSize: 16)),
                    Text("${record['absentDays'] ?? 0}",
                        style: TextStyle(color: Colors.redAccent, fontSize: 16)),
                    Text("${record['totalLeaves'] ?? 0}",
                        style: TextStyle(color: Colors.blueGrey, fontSize: 16)),
                    Text("${record['totalHolidays'] ?? 0}",
                        style: TextStyle(color: Colors.teal, fontSize: 16)),
                  ],
                ),
                SizedBox(height: 8),
              ],
            )
          ),
        );
      },
    );
  }


  Widget buildAttendanceCard(String date, String? inTime, String? outTime,
      String inLocation, String outLocation, String dailyWorkingHour,
      String userName) {
    String formattedDate = Dateformat.formatWorkingDate(date);
    return Container(
      margin: isFiltering
          ? const EdgeInsets.symmetric(vertical: 0)
          : const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!isFiltering)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: primaryColor,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(12),
                  topRight: Radius.circular(12),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "$formattedDate ${dailyWorkingHour != '00:00' ? '($dailyWorkingHour)' : ''}",
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 17,
                    ),
                  ),
                  if (!isFiltering)
                    Text(
                      userName,
                      style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 17),
                    ),
                ],
              ),
            ),
          const SizedBox(height: 8),
          if (isFiltering)
            Center(
              child: Text(
                "Working Hours: $dailyWorkingHour",
                style: const TextStyle(
                  color: textColor,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ),
          const SizedBox(height: 0),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(left: 37.0),
                        child: Icon(Icons.login, color: Colors.green),
                      ),
                    ],
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 23.0),
                    child: const Text(
                      "Check In",
                      style: TextStyle(
                          color: textColor,
                          fontWeight: FontWeight.bold,
                          fontSize: 14),
                    ),
                  ),
                  Text(
                    inTime ?? "--:--",
                    style: const TextStyle(color: textColor),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    inLocation.isNotEmpty ? inLocation : "No Location",
                    style: const TextStyle(color: textColor),
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(right: 39.0),
                    child: Icon(Icons.logout_outlined, color: Colors.red),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(right: 22.0),
                    child: const Text(
                      "Check Out",
                      style: TextStyle(
                          color: textColor,
                          fontWeight: FontWeight.bold,
                          fontSize: 14),
                    ),
                  ),
                  Text(
                    outTime ?? "--:--",
                    style: const TextStyle(color: textColor),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    outLocation.isNotEmpty ? outLocation : "No Location",
                    style: const TextStyle(color: textColor),
                  ),
                ],
              ),
            ],
          ),
          if(isFiltering)
            const Divider(
              color: Colors.grey,
              thickness: 0.7,

            ),
        ],
      ),
    );
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: "Attendance",
        onLogout: () => AuthService.logout(context),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                InformationMethod(),
                SizedBox(width: 15,),
                IconButton(
                  icon: Icon(
                    isAttendanceSectionVisible ? Icons.arrow_upward : Icons.arrow_downward,
                    color: Colors.teal,
                    size: 30,
                  ),
                  onPressed: toggleAttendanceSection,
                ),
                IconButton(
                  icon: Icon(
                      Icons.filter_alt_outlined, color: Colors.blue, size: 30),
                  onPressed: _showDatePicker,
                ),
                IconButton(
                  icon: Icon(Icons.info_outline, color: Colors.orange, size: 28),
                  onPressed: _showAttendanceCountDialog,
                ),
              ],
            ),
            if (isAttendanceSectionVisible)

              Row(
                children: [
                  Row(
                    children: [
                      const SizedBox(width: 16),
                      Padding(
                        padding: const EdgeInsets.only(right: 12.0),
                        child: Text(
                          "Mark Attendance",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      if (!attendance.any((record) =>
                      record['outLocation'] == null))
                        SliderButton(
                          action: () async {
                            await getCurrentLocation();
                            if (currentLocation != null) {
                              await markAttendanceCheckin("intime",
                                  currentLocation!);
                              await fetchAttendance();
                            }
                            return false;
                          },
                          label: Text(
                            "Check In",
                            style: TextStyle(
                              color: textColor2,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          icon: Icon(Icons.login, color: Colors.green),
                          width: 125,
                          height: 40,
                          shimmer: false,
                          buttonSize: 40,
                          backgroundColor: Colors.green,
                        ),
                      if (attendance.any((record) =>
                      record['outLocation'] == null))
                        SliderButton(
                          action: () async {
                            await getCurrentLocation();
                            if (currentLocation != null) {
                              await markAttendanceCheckout("outtime",
                                  currentLocation!);
                              await fetchAttendance();
                            }
                            return false;
                          },
                          label: Text(
                            "Check Out",
                            style: TextStyle(
                              fontSize: 12,
                              color: textColor2,
                              fontWeight: FontWeight.bold,
                            ),
                          ),

                          icon: Icon(Icons.logout_outlined, color: Colors.red),
                          width: 125,
                          height: 40,
                          shimmer: false,
                          buttonSize: 40,
                          backgroundColor: Colors.red,
                        ),
                    ],
                  ),
                  if (showHolidayCheckbox)

                    Row(
                      children: [
                        Checkbox(
                          value: attendanceOnHoliday,
                          onChanged: (value) {
                            setState(() {
                              attendanceOnHoliday = value!;
                            });
                          },
                        ),

                      ],
                    )
                ],
              ),
            SizedBox(height: 10,),
            if (showHolidayCheckbox)
              Row(
                children: [
                  Text("Today is $holidayName holiday. Want to Work?",
                      style: TextStyle(fontSize: 15)),
                ],
              ),

            if (isAttendanceSectionVisible)
              Divider(color: Colors.black),
            Expanded(
              child: ListView.builder(
                itemCount: getFilteredData().length,
                itemBuilder: (context, index) {
                  var groupedAttendance = getFilteredData();
                  String userName = groupedAttendance.keys.toList()[index];
                  var userAttendance = groupedAttendance[userName]!;
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if(isFiltering)
                        SizedBox(height: 15,),
                      if(isFiltering)
                        Container(
                          height: 45,
                          width: double.infinity,
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: primaryColor,
                            borderRadius: const BorderRadius.only(
                              topLeft: Radius.circular(12),
                              topRight: Radius.circular(12),
                            ),
                          ),
                          child:
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                userName,
                                style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 17
                                ),
                              ),
                            ],
                          ),
                        ),

                      ListView.builder(
                        shrinkWrap: true,
                        physics: NeverScrollableScrollPhysics(),
                        itemCount: userAttendance.length,
                        itemBuilder: (context, index) {
                          var attendanceRecord = userAttendance[index];
                          String inTime = attendanceRecord['inDateTime'] ?? "--:--";
                          String outTime = attendanceRecord['outDateTime'] ?? "--:--";
                          return buildAttendanceCard(
                            attendanceRecord['inDateTime'] ?? '--/--/---- --:--',
                            inTime,
                            outTime,
                            attendanceRecord['inLocation'] ?? '',
                            attendanceRecord['outLocation'] ?? 'No location',
                            attendanceRecord['dailyWorkingHour'] ?? '',
                            attendanceRecord['userName'] ?? '',
                          );
                        },
                      ),
                    ],
                  );
                },
              ),
            )
          ],
        ),
      ),
    );
  }
}