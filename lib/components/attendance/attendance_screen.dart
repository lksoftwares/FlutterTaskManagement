import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:intl/intl.dart';
import 'package:lktaskmanagementapp/packages/headerfiles.dart';

class AttendanceScreen extends StatefulWidget {
  @override
  _AttendanceScreenState createState() => _AttendanceScreenState();
}

class _AttendanceScreenState extends State<AttendanceScreen> {
  String? checkInTime;
  String? checkOutTime;
  List<Map<String, dynamic>> attendance = [];
  bool isLoading = false;
  String? currentLocation = '';
  String? userName = '';
  String? userRole = '';
  bool hasCheckedIn = false;
  bool hasCheckedOut = false;
  String? roleName;
  DateTime? fromDate;
  DateTime? toDate;

  @override
  void initState() {
    super.initState();
    final currentDate = DateTime.now();
    fromDate = DateTime(currentDate.year, currentDate.month, currentDate.day);
    toDate = fromDate;
    fetchUserData();
    fetchAttendance();
    loadAttendanceState();
  }

  Future<void> fetchUserData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      userName = prefs.getString('user_Name') ?? 'No User';
      userRole = prefs.getString('role_Name') ?? 'No Role';
    });
  }

  Future<void> loadAttendanceState() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      hasCheckedIn = prefs.getBool('hasCheckedIn') ?? false;
      hasCheckedOut = prefs.getBool('hasCheckedOut') ?? false;
    });
  }

  Future<void> saveAttendanceState() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool('hasCheckedIn', hasCheckedIn);
    await prefs.setBool('hasCheckedOut', hasCheckedOut);
  }

  List<Map<String, dynamic>> getFilteredData() {
    return attendance.where((role) {
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
  }

  DateTime _parseDate(String dateStr) {
    try {
      return DateFormat('dd-MM-yyyy').parse(dateStr);
    } catch (e) {
      print("Error parsing date: $e");
      return DateTime(2000);
    }
  }

  void _showDatePicker() {
    showDateRangePicker(
      context: context,
      firstDate: DateTime(2025, DateTime.february),
      lastDate: DateTime(2025, DateTime.april),
      initialDateRange: fromDate != null && toDate != null
          ? DateTimeRange(start: fromDate!, end: toDate!)
          : null,
    ).then((pickedDateRange) {
      if (pickedDateRange != null) {
        setState(() {
          fromDate = pickedDateRange.start;
          toDate = pickedDateRange.end;
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
      print('Current location: Latitude: ${position.latitude}, Longitude: ${position.longitude}');

      List<Placemark> placemarks = await placemarkFromCoordinates(position.latitude, position.longitude);
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

  Future<void> markAttendanceCheckin(String inOutFlag, String inLocation) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    int userId = prefs.getInt('user_Id') ?? 0;

    if (userId != 0) {
      setState(() {
        isLoading = true;
      });

      final response = await new ApiService().request(
        method: 'post',
        endpoint: 'attendance/MarkAttendnace',
        body: {
          'userId': userId,
          'inOutFlag': inOutFlag,
          'inLocation': inLocation,
        },
      );

      if (response['statusCode'] >= 200 && response['statusCode'] < 400) {
        showToast(msg: response['message'] ?? 'Added', backgroundColor: Colors.green);
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

  Future<void> markAttendanceCheckout(String inOutFlag, String outLocation) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    int userId = prefs.getInt('user_Id') ?? 0;

    if (userId != 0) {
      setState(() {
        isLoading = true;
      });

      final response = await new ApiService().request(
        method: 'post',
        endpoint: 'attendance/MarkAttendnace',
        body: {
          'userId': userId,
          'inOutFlag': inOutFlag,
          'outLocation': outLocation,
        },
      );

      if (response['statusCode'] >= 200 && response['statusCode'] < 400) {
        showToast(msg: response['message'] ?? 'Added', backgroundColor: Colors.green);
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
    String endpoint = 'attendance/GetAttendance';

    if (roleName == 'Admin') {
      endpoint = 'attendance/GetAttendance';
    } else if (userId != null) {
      endpoint = 'attendance/GetAttendance?userId=$userId';
    }
    final response = await new ApiService().request(
      method: 'get',
      endpoint: endpoint,
    );

    if (response['statusCode'] == 200 && response['apiResponse'] != null) {
      setState(() {
        attendance = List<Map<String, dynamic>>.from(
          response['apiResponse'].map((member) => {
            'atTxnId': member['atTxnId'] ?? 0,
            'inDateTime': member['inDateTime'] ?? "----/----/-------- --:--",
            'userId': member['userId'] ?? 0,
            'outDateTime': member['outDateTime'] ?? "----/----/-------- --:--",
            'userName': member['userName'] ?? 'Unknown user',
            'inLocation': member['inLocation'] ?? '',
            'outLocation': member['outLocation'] ?? 'Unknown location',
            'dailyWorkingHour': member['dailyWorkingHour'] ?? '',

          }),
        );
      });
      print("123456$response");
    } else {
      showToast(msg: response['message'] ?? 'Failed to load attendance data');
    }

    setState(() {
      isLoading = false;
    });
  }

  Widget buildAttendanceCard(String date, String? inTime, String? outTime,
      String inLocation, String outLocation,String dailyWorkingHour) {
    String formattedDate = Dateformat.formatWorkingDate(date);
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
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
              children: [
                Text(
                  formattedDate,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 17
                    ,
                  ),
                ),
            Text(
              "${dailyWorkingHour}",
              style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 17
              )),
              ],
            ),

          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(left: 37.0),
                    child: Icon(Icons.login, color: Colors.green),
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
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                InformationMethod(),
                IconButton(
                  icon: Icon(
                      Icons.filter_alt_outlined, color: Colors.blue, size: 30),
                  onPressed: _showDatePicker,
                ),
              ],
            ),

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
                    if (!hasCheckedIn)
                      SliderButton(
                        action: () async {
                          await getCurrentLocation();
                          if (currentLocation != null) {
                            await markAttendanceCheckin("intime", currentLocation!);
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
                        width: 142,
                        height: 40,
                        shimmer: false,
                        buttonSize: 40,
                        backgroundColor: Colors.green,
                      ),

                    if (hasCheckedIn && !hasCheckedOut)
                      SliderButton(
                        action: () async {
                          await getCurrentLocation();
                          if (currentLocation != null) {
                            await markAttendanceCheckout("outtime", currentLocation!);
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
                        width: 140,
                        height: 40,
                        shimmer: false,
                        buttonSize: 40,
                        backgroundColor: Colors.red,
                      ),

                  ],
                ),
              ],
            ),
            Divider(color: Colors.black),
            isLoading
                ? Center(child: CircularProgressIndicator())
                : getFilteredData().isEmpty
                ? Center(child: NoDataFoundScreen())
                : Expanded(
              child: ListView.builder(
                itemCount: getFilteredData().length,
                itemBuilder: (context, index) {
                  var attendanceRecord = getFilteredData()[index];
                  String inTime = attendanceRecord['inDateTime'] ?? "--:--";
                  String outTime = attendanceRecord['outDateTime'] ?? "--:--";
                  return buildAttendanceCard(
                    attendanceRecord['inDateTime'] ?? '--/--/---- --:--',
                    inTime,
                    outTime,
                    attendanceRecord['inLocation'] ?? '',
                    attendanceRecord['outLocation'] ?? 'No location',
                    attendanceRecord ['dailyWorkingHour'] ?? '',

                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
