import 'package:intl/intl.dart';
import 'package:lktaskmanagementapp/packages/headerfiles.dart';

class UserlogsPage extends StatefulWidget {
  const UserlogsPage({super.key});

  @override
  State<UserlogsPage> createState() => _UserlogsPageState();
}

class _UserlogsPageState extends State<UserlogsPage> {
  List<Map<String, dynamic>> userlogs = [];
  String? token;
  bool isLoading = false;
  String? selectedUserName;
  DateTime? fromDate;
  DateTime? toDate;
  List<Map<String, dynamic>> users = [];

  @override
  void initState() {
    super.initState();
    final currentDate = DateTime.now();
    fromDate = DateTime(currentDate.year, currentDate.month, currentDate.day);
    toDate = fromDate;
    _getData();
    _getsharedpref();
  }

  Future<void> _getData() async {
    await fetchUserlogs();
    await fetchUsers();
  }
  Future<void> _getsharedpref() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      token = prefs.getString('token');

    });
  }
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

  Future<void> fetchUserlogs() async {
    setState(() {
      isLoading = true;
    });

    SharedPreferences prefs = await SharedPreferences.getInstance();
    int? userId = prefs.getInt('user_Id');
    String roleName = prefs.getString('role_Name') ?? "";
    String endpoint = 'User/GetUserLogs';

    if (roleName == 'Admin') {
      endpoint = 'User/GetUserLogs';
    } else if (userId != null) {
      endpoint = 'User/GetUserLogs?userId=$userId';
    }
    final response = await new ApiService().request(
      method: 'get',
      endpoint: endpoint,
      tokenRequired: true
    );
    print(response);
    if (response['statusCode'] == 200 && response['apiResponse'] != null) {
      setState(() {
        userlogs = List<Map<String, dynamic>>.from(
          response['apiResponse'].map((role) => {
            'logId': role['logId'] ?? 0,
            'deviceId': role['deviceId'] ?? 'Unknown device',
            'ipAddress': role['ipAddress'] ?? 'Unknown ip',
            'loginTime': role['loginTime'] ?? '',
            'roleName': role['roleName'] ?? 'Unknown role',
            'userName': role['userName'] ?? 'Unknown user',
            'userEmail': role['userEmail'] ?? 'UnknownEmail',
          }),
        );
      });
    } else {
      showToast(msg: response['message'] ?? 'Failed to load userlogs');
    }
    setState(() {
      isLoading = false;
    });
  }

  Map<String, List<Map<String, dynamic>>> groupLogsByUser() {
    Map<String, List<Map<String, dynamic>>> groupedLogs = {};

    for (var log in getFilteredData()) {
      String userName = log['userName'];
      if (!groupedLogs.containsKey(userName)) {
        groupedLogs[userName] = [];
      }
      groupedLogs[userName]!.add(log);
    }

    return groupedLogs;
  }

  List<Map<String, dynamic>> getFilteredData() {
    return userlogs.where((role) {
      bool matchesUserName = true;
      bool matchesDate = true;
      if (selectedUserName != null && selectedUserName!.isNotEmpty) {
        matchesUserName = role['userName'] == selectedUserName;
      }
      if (fromDate != null && toDate != null) {
        DateTime loginTime = _parseDate(role['loginTime']);
        matchesDate = (loginTime.isAtSameMomentAs(fromDate!) ||
            loginTime.isAfter(fromDate!)) &&
            (loginTime.isAtSameMomentAs(toDate!) ||
                loginTime.isBefore(toDate!));
      }
      return matchesUserName && matchesDate;
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
        fetchUserlogs();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    Map<String, List<Map<String, dynamic>>> groupedLogs = groupLogsByUser();

    return Scaffold(
      appBar: CustomAppBar(
        title: 'User Logs',
        onLogout: () => AuthService.logout(context),
      ),
      body: RefreshIndicator(
        onRefresh: fetchUserlogs,
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: [
                SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Autocomplete<String>(
                      optionsBuilder: (TextEditingValue textEditingValue) {
                        return users
                            .where((user) => user['userName']!
                            .toLowerCase()
                            .contains(textEditingValue.text.toLowerCase()))
                            .map((user) => user['userName'] as String)
                            .toList();
                      },
                      onSelected: (String userName) {
                        setState(() {
                          selectedUserName = userName;
                        });
                        fetchUserlogs();
                      },
                      fieldViewBuilder: (context, controller, focusNode, onFieldSubmitted) {
                        return Container(
                          width: 280,
                          child: TextField(
                            controller: controller,
                            focusNode: focusNode,
                            decoration: InputDecoration(
                              labelText: 'Select User',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              prefixIcon: Icon(Icons.person),
                            ),
                            onChanged: (value) {
                              if (value.isEmpty) {
                                setState(() {
                                  selectedUserName = null;
                                });
                                fetchUserlogs();
                              }
                            },
                          ),
                        );
                      },
                    ),
                    IconButton(
                      icon: Icon(
                          Icons.filter_alt_outlined, color: Colors.blue, size: 30),
                      onPressed: _showDatePicker,
                    ),
                    SizedBox(width: 10),
                  ],
                ),
                SizedBox(height: 20),
                if (isLoading)
                  Center(child: CircularProgressIndicator())
                else if (userlogs.isEmpty)
                  NoDataFoundScreen()
                else if (getFilteredData().isEmpty)
                    NoDataFoundScreen()
                else
                  Column(
                    children: groupedLogs.entries.map((entry) {
                      String userName = entry.key;
                      List<Map<String, dynamic>> logs = entry.value;
                      Map<String, dynamic> userInfo = {
                        'Username': '$userName (${logs.first['roleName']})',
                        '': '',
                        'Email': logs.first['userEmail'],
                      };
                      return buildUserCard(
                        userFields: userInfo,
                        additionalContent: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: logs.map((log) {
                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                SizedBox(height: 20,),
                                Row(
                                  children: [
                                    Text(
                                      'Login Time         : ',
                                      style: AppTextStyle.boldTextStyle(),
                                    ),
                                    Text(
                                      '${log['loginTime']}',
                                      style: AppTextStyle.regularTextStyle(),
                                    ),
                                  ],
                                ),
                                SizedBox(height: 7,),
                                Row(
                                  children: [
                                    Text(
                                      'IP Address         : ',
                                      style: AppTextStyle.boldTextStyle(),
                                    ),
                                    Text(
                                      '${log['ipAddress']}',
                                      style: AppTextStyle.regularTextStyle(),
                                    ),
                                  ],
                                ),
                                SizedBox(height: 7,),

                                Row(
                                  children: [
                                    Text(
                                      'Device Id            : ',
                                      style: AppTextStyle.boldTextStyle(),
                                    ),
                                    Expanded(
                                      child: Text(
                                        '${log['deviceId']}',
                                        style: AppTextStyle.regularTextStyle(),
                                        softWrap: true,
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(height: 5),

                                Divider(color: Colors.grey,),
                                SizedBox(height: 5),
                              ],
                            );
                          }).toList(),
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
