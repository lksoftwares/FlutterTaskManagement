
import 'package:lktaskmanagementapp/packages/headerfiles.dart';

class DashboardScreen extends StatefulWidget {
  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> with SingleTickerProviderStateMixin {
  List<Map<String, dynamic>> users = [];
  bool isLoading = false;
  String userName = "";
  int totalPending = 0;
  int totalViewCount = 0;
  String? roleName;
  int todayPresentCount = 0;
  Map<String, int> stageCounts = {};
  Map<String, int> taskStatusCounts = {};
  int totalTasks = 0;
  List<Map<String, dynamic>> totalWorkingDaysList = [];

  @override
  void initState() {
    super.initState();
    _loadUserData();
    _fetchLeaveData();
    _fetchWorkingData();
    fetchWorkingDays();
    _fetchProjectData();
    _fetchAttendanceData();
_fetchTask();

  }
  Future<void> _loadUserData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      userName = prefs.getString('user_Name') ?? "Guest";
      roleName = prefs.getString('role_Name') ?? "Guest";

    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  void _navigateAndRefreshWorking() async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => DailyWorkingStatus()),
    );
    await _fetchWorkingData();
  }
  void _navigateAndRefreshLeaves() async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => LeavesScreen()),
    );
    await _fetchLeaveData();
  }

  void _navigateAndRefreshTask() async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => TasksScreen()),
    );
    await _fetchTask();
  }
  Future<void> _fetchLeaveData() async {
    setState(() {
      isLoading = true;
    });
    final apiService = ApiService();
    final response = await apiService.request(
      method: 'GET',
      endpoint: 'leave/',
      tokenRequired: true
    );
    if (response['statusCode'] == 200) {
      setState(() {
        totalPending = response['apiResponse']['totalPending'];
        isLoading = false;
      });
    } else {
      setState(() {
        isLoading = false;
      });
    }
  }
  Future<void> _fetchAttendanceData() async {
    setState(() {
      isLoading = true;
    });

    final apiService = ApiService();
    final response = await apiService.request(
      method: 'GET',
      endpoint: 'attendance/',  // replace with actual endpoint
      tokenRequired: true,
    );

    if (response['statusCode'] == 200) {
      setState(() {
        todayPresentCount = response['apiResponse']['todayPresentCount'] ?? 0;
        isLoading = false;
      });
    } else {
      setState(() {
        isLoading = false;
      });
      showToast(msg: response['message'] ?? 'Failed to fetch attendance');
    }
  }

  Future<void> _fetchData() async {
    await _fetchWorkingData();
    await _fetchLeaveData();
    await _fetchProjectData();
    await fetchWorkingDays;
    if (taskStatusCounts['open'] != null && taskStatusCounts['open']! >= 0) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Total Task Pending',style: TextStyle(fontWeight: FontWeight.w900),),
                Icon(Icons.pending_actions,size: 25,color: Colors.orange,)
              ],
            ),
            content: Text('There are ${taskStatusCounts['open']} open tasks that need attention.'),
            actions: <Widget>[
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: Text('Close'),
              ),
            ],
          );
        },
      );
    }
  }

  Future<void> fetchWorkingDays() async {
    setState(() {
      isLoading = true;
    });
    SharedPreferences prefs = await SharedPreferences.getInstance();
    int? userId = prefs.getInt('user_Id');

    if (userId != null) {
      final response = await new ApiService().request(
          method: 'get',
          endpoint: 'Working/?userId=$userId',
          tokenRequired: true
      );
      if (response['statusCode'] == 200 && response['apiResponse'] != null) {
        setState(() {
          totalWorkingDaysList = List<Map<String, dynamic>>.from(
            response['apiResponse']['totalWorkingDaysList'].map((data) => {
              'txnId': data['txnId']?? 0,
              'totalDaysInMonth': data['totalDaysInMonth'],
              'totalWorkingDays': data['totalWorkingDays'],
            }),
          );
        });
      } else {
        showToast(msg: response['message'] ?? 'Failed to load working days');
      }
    } else {
      showToast(msg: 'User ID not found in SharedPreferences');
    }

    setState(() {
      isLoading = false;
    });
  }


  Future<void> _fetchWorkingData() async {
    final apiService = ApiService();
    final response = await apiService.request(
      method: 'GET',
      endpoint: 'working/',
        tokenRequired: true
    );
    if (response['statusCode'] == 200) {
      setState(() {
        totalViewCount = response['apiResponse']['viewsCount'];
      });
    } else {
      setState(() {
        totalViewCount = 0;
      });
    }
  }

  Future<void> _fetchProjectData() async {
    setState(() {
      isLoading = true;
    });
    final apiService = ApiService();
    final response = await apiService.request(
      method: 'GET',
      endpoint: 'projects/',
      tokenRequired: true,
    );
    if (response['statusCode'] == 200) {
      setState(() {
        stageCounts = Map<String, int>.from(response['apiResponse']['stageCounts']);
        isLoading = false;
        print(stageCounts);
      });
    } else if (response['errorCode']== 401) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => LoginScreen()),
      );
      showToast(msg: response['message'] ?? 'Failed');
    }else {
      setState(() {
        isLoading = false;
      });
      showToast(msg: response['message'] ?? 'Failed');
    }
  }

  Future<void> _fetchTask() async {
    setState(() {
      isLoading = true;
    });
    SharedPreferences prefs = await SharedPreferences.getInstance();
    int? userId = prefs.getInt('user_Id');
    roleName = prefs.getString('role_Name');
    String endpoint = 'tasks/';
    if (roleName == 'Admin') {
      endpoint = 'tasks/';
    } else if (userId != null) {
      endpoint = 'tasks/?userId=$userId';
    }
    final response = await new ApiService().request(
      method: 'GET',
      endpoint: endpoint,
      tokenRequired: true,
    );
    if (response['statusCode'] == 200) {
      setState(() {
        taskStatusCounts = Map<String, int>.from(response['apiResponse']['taskStatusCounts']);
        totalTasks = response['apiResponse']['totalTasks'];
        isLoading = false;
        print(taskStatusCounts);
      });
    } else {
      setState(() {
        isLoading = false;
      });
      showToast(msg: response['message'] ?? 'Failed');
    }
  }
  Widget buildCard(
      String title,
      IconData icon,
      Color color, {
        Widget? destinationScreen,
        String? extraText,
        Widget? content,
        double fontSize = 15,
        Color? titleBgColor,
      }) {
    return GestureDetector(
      onTap: () {
        if (destinationScreen != null) {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => destinationScreen),
          );
        } else {
          showToast(msg: "No screen provided.");
        }
      },
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            width: 200,
            height: 97,
            child: Card(
              elevation: 5,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              color: color,
              child: Column(
                children: [
                  Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: titleBgColor ?? Colors.blue,
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(10),
                      ),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 2.0),
                    child: Text(
                      title,
                      style: TextStyle(
                        fontSize: fontSize,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),

                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          if (extraText != null)
                            Text(
                              extraText,
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          if (content != null) content,
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }


  Future<void> _fetchTodaysAbsents() async {
    final response = await new ApiService().request(
      method: 'get',
      endpoint: 'leave/',
        tokenRequired: true

    );

    if (response['statusCode'] == 200) {
      List<dynamic> onLeaveData = response['apiResponse']['onLeave'];

      if (onLeaveData.isEmpty) {
        showToast(msg: 'All are present', backgroundColor: Colors.green);
      } else {
        showCustomAlertDialog(
          context,
          title: 'Today\'s Absentees',
          content: Container(
            height: 270,
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  for (var absent in onLeaveData)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 5.0),
                      child: Card(
                        elevation: 5,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        color: Colors.blue[50],
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Center(
                                child: Text(
                                  absent['userName'] ?? 'N/A',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.blue[700],
                                  ),
                                ),
                              ),
                              SizedBox(height: 8),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    "From:",
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.blue[700],
                                    ),
                                  ),
                                  Text(
                                    absent['leaveFrom'] ?? 'N/A',
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: Colors.blue[600],
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 8),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    "To:",
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.blue[700],
                                    ),
                                  ),
                                  Text(
                                    absent['leaveTo'] ?? 'N/A',
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: Colors.blue[600],
                                    ),
                                  ),
                                ],
                              ),

                            ],
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                'Close',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.blue[700],
                ),
              ),
            ),
          ],
          titleHeight: 70,
        );
      }
    } else {
      showToast(msg: 'Failed to fetch absentees');
    }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: NavBar(),
      appBar: CustomAppBar(
        title: "Dashboard",
        onLogout: () => AuthService.logout(context),
      ),
      body: RefreshIndicator(
        onRefresh: _fetchData,
        child: Column(
          children: [
            Stack(
              children: [
                ClipPath(
                  child: Container(
                    height: 35,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [primaryColor, primaryColor.withOpacity(0.8)],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                    ),
                  ),
                ),
                Positioned(
                  right: 15,
                  child: Stack(
                    children: [
                      IconButton(
                        icon: Icon(Icons.pending_actions, size: 25, color: Colors.white),
                        onPressed: () {
                          if (taskStatusCounts['open'] != null) {
                            _navigateAndRefreshTask();
                          } else {
                            showToast(msg: "No 'Open' tasks available.");
                          }
                        },
                      ),
                      if (taskStatusCounts['open'] != null)
                        Positioned(
                          top: 0,
                          right: 0,
                          child: Container(
                            padding: EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: Colors.red,
                              shape: BoxShape.circle,
                            ),
                            constraints: BoxConstraints(minWidth: 21, minHeight: 21),
                            child: Center(
                              child: Text(
                                '${taskStatusCounts['open']}',
                                style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
                if (roleName == "Admin")
                  Positioned(
                    right: 55,
                    child: Stack(
                      children: [
                        IconButton(
                          icon: Icon(Icons.task, size: 25, color: Colors.white),
                          onPressed: () {
                            if (totalViewCount > 0) {
                              _navigateAndRefreshWorking();
                            }
                          },
                        ),
                        if (totalViewCount > -1)
                          Positioned(
                            top: 0,
                            right: 0,
                            child: Container(
                              padding: EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                color: Colors.blue,
                                shape: BoxShape.circle,
                              ),
                              constraints: BoxConstraints(minWidth: 19, minHeight: 19),
                              child: Center(
                                child: Text(
                                  '$totalViewCount',
                                  style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                if (roleName == "Admin")
                  Positioned(
                    right: 85,
                    child: IconButton(
                      icon: Icon(Icons.person, size: 25, color: Colors.white),
                      onPressed: () async {
                        await _fetchTodaysAbsents();
                      },
                    ),
                  ),
                if (roleName == "Admin")
                  Positioned(
                    right: 125,
                    child: Stack(
                      children: [
                        IconButton(
                          icon: Icon(Icons.notifications_rounded, size: 25, color: Colors.white),
                          onPressed: () {
                            if (totalPending > 0) {
                              _navigateAndRefreshLeaves();
                            } else {
                              showToast(msg: "No Pending Leaves found");
                            }
                          },
                        ),

                        if (totalPending > -1)
                          Positioned(
                            top: 0,
                            right: 0,
                            child: Container(
                              padding: EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                color: Colors.red,
                                shape: BoxShape.circle,
                              ),
                              constraints: BoxConstraints(minWidth: 21, minHeight: 21),
                              child: Center(
                                child: Text(
                                  '$totalPending',
                                  style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ),
                          ),
                       ],
                    ),
                  ),
              ],
            ),
            Expanded(
              child: Stack(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      image: DecorationImage(
                        image: AssetImage("images/dashboard.jpg"),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  // Padding(
                  //   padding: const EdgeInsets.only(top: 585.5),
                  //   child: Container(
                  //     decoration: BoxDecoration(
                  //       image: DecorationImage(
                  //         image: AssetImage("images/bg.jpg"),
                  //       ),
                  //     ),
                  //   ),
                  // ),
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Expanded(child: buildCard(
                              "WORKING DAYS",
                              Icons.calendar_month,
                              titleBgColor: Colors.green[100]!,
                              Colors.green[300]!,
                              destinationScreen: Workingdayslist(),
                              content: Padding(
                                padding: const EdgeInsets.only(top: 0.0),
                                child: Column(
                                  children: [
                                    if (totalWorkingDaysList.isNotEmpty)
                                      for (var workingData in totalWorkingDaysList)
                                        Padding(
                                          padding: const EdgeInsets.symmetric(vertical: 5.0),
                                          child: Row(
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            children: [
                                              Text(
                                                '${workingData['totalWorkingDays']} / ${workingData['totalDaysInMonth']}',
                                                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                                              ),
                                            ],
                                          ),
                                        ),
                                  ],
                                ),
                              ),
                            )),
                            Expanded(child: buildCard(
                              "PROJECT STAGE",
                              Icons.check_circle,
                              Colors.grey[400]!,
                              titleBgColor: Colors.grey[200]!,

                              destinationScreen: ProjectsScreen(),
                              extraText: null,
                              content: Padding(
                                padding: const EdgeInsets.only(top: 0.0),
                                child: Column(
                                  children: [
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                      children: [
                                        Row(
                                          children: [
                                            Icon(Icons.hourglass_bottom_outlined, color: Colors.yellow, size: 20),
                                            SizedBox(height: 8),
                                            Text(
                                              '${stageCounts['Pending'] ?? 0}',
                                              style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white),
                                            ),
                                          ],
                                        ),
                                        Row(
                                          children: [
                                            Icon(Icons.change_circle_rounded, color: Colors.blue, size: 20),
                                            SizedBox(height: 8),
                                            Text(
                                              ' ${stageCounts['In Progress'] ?? 0}',
                                              style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                    SizedBox(height: 5,),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                      children: [
                                        Row(
                                          children: [
                                            Icon(Icons.pause_circle, color: Colors.deepOrangeAccent, size: 20),
                                            SizedBox(height: 8),
                                            Text(
                                              ' ${stageCounts['On Hold'] ?? 0}',
                                              style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white),
                                            ),
                                          ],
                                        ),
                                        Row(
                                          children: [
                                            Icon(Icons.cancel, color: Colors.red, size: 20),
                                            SizedBox(height: 8,width: 4,),
                                            Text(
                                              '${stageCounts['Cancelled'] ?? 0}',
                                              style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            )),
                          ],
                        ),
                        SizedBox(height: 13,),
                        Row(
                          children: [
                            Expanded(child: buildCard(
                              "TOTAL TASKS",
                              Icons.task,
                              titleBgColor: Colors.blue[100]!,

                              Colors.blue[200]!,
                              destinationScreen: TasksScreen(),
                              content: Padding(
                                padding: const EdgeInsets.only(top: 0.0),
                                child: Column(
                                  children: [
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                      children: [
                                        Row(
                                          children: [
                                            Icon(Icons.hourglass_bottom_outlined, color: Colors.yellow, size: 20),
                                            SizedBox(height: 8),
                                            Text(
                                              '${taskStatusCounts['open'] ?? 0}',
                                              style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white),
                                            ),
                                          ],
                                        ),
                                        Row(
                                          children: [
                                            Icon(Icons.change_circle_rounded, color: Colors.blue, size: 20),
                                            SizedBox(height: 8),
                                            Text(
                                              ' ${taskStatusCounts['in-Progress'] ?? 0}',
                                              style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                    SizedBox(height: 7),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                      children: [
                                        Row(
                                          children: [
                                            Icon(Icons.check_circle, color: Colors.green, size: 20),
                                            SizedBox(height: 8),
                                            Text(
                                              ' ${taskStatusCounts['completed'] ?? 0}',
                                              style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white),
                                            ),
                                          ],
                                        ),
                                        Row(
                                          children: [
                                            Icon(Icons.cancel, color: Colors.red, size: 20),
                                            SizedBox(height: 8,width: 4,),
                                            Text(
                                              '${taskStatusCounts['Cancelled'] ?? 0}',
                                              style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            )),
                            Expanded(
                              child: buildCard(
                                "TODAY ATTENDANCE",
                                Icons.how_to_reg,
                                titleBgColor: Colors.pink[100]!,
                                destinationScreen: AttendanceScreen(),
                                Colors.pink[300]!,
                                extraText: null,
                                content: Padding(
                                  padding: const EdgeInsets.only(top: 0.0),
                                  child: Column(
                                    children: [
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                        children: [
                                          Row(
                                            children: [
                                              Icon(Icons.how_to_reg, color: Colors.yellow, size: 25),
                                              SizedBox(height: 8),
                                              Text(
                                                '$todayPresentCount',
                                                style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.white),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    )

                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
