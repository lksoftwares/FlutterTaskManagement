
import 'package:lktaskmanagementapp/packages/headerfiles.dart';

class DashboardScreen extends StatefulWidget {
  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<Offset> _animation;
  List<Map<String, dynamic>> users = [];
  bool isLoading = false;
  String userName = "";
  int totalPending = 0;
  int totalViewCount = 0;
  bool loadmenu = false;
  String? roleName;


  @override
  void initState() {
    super.initState();
    _loadUserData();
    _fetchLeaveData();
    _fetchWorkingData();
    loadmenu == false;






    _animationController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 500),
    );

    _animation = Tween<Offset>(
      begin: Offset.zero,
      end: Offset(0.1, 0),
    ).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.elasticOut,
      ),
    );
  }
  Future<void> _loadUserData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      userName = prefs.getString('user_Name') ?? "Guest";
      roleName = prefs.getString('role_Name') ?? "Guest";

    });
  }
   _load()  {

      print("loadmenunewscreen$loadmenu");
        setState(() {
          loadmenu = true;
          print("isLoading$loadmenu");
        });

  }
  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _startShaking() {
    if (totalPending > 0 && totalViewCount>0) {
      _animationController.repeat(reverse: true);
    } else {
      _animationController.stop();
    }
  }

  Future<void> _fetchLeaveData() async {
    setState(() {
      isLoading = true;
    });
    final apiService = ApiService();
    final response = await apiService.request(
      method: 'GET',
      endpoint: 'leave/GetAllLeave',
    );
    if (response['statusCode'] == 200) {
      setState(() {
        totalPending = response['apiResponse']['totalPending'];
        isLoading = false;
      });
      _startShaking();
    } else {
      setState(() {
        isLoading = false;
      });
    }
  }
  Future<void> _fetchWorkingData() async {
    final apiService = ApiService();
    final response = await apiService.request(
      method: 'GET',
      endpoint: 'working/GetWorking',
    );
    if (response['statusCode'] == 200) {
      setState(() {
        totalViewCount = response['apiResponse']['viewsCount'];
      });
      _startShaking();

    } else {
      setState(() {
        totalViewCount = 0;
      });
    }
  }
  Widget buildCard(String title, IconData icon, Color color, {Widget? destinationScreen}) {
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
      child: Card(
        elevation: 5,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        color: color,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 37, color: Colors.white),
              SizedBox(height: 20),
              Text(
                title,
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: NavBar(loadmenu), onDrawerChanged: !loadmenu ? _load() : null,
      appBar: CustomAppBar(
        title: "Dashboard",
        onLogout: () => AuthService.logout(context),
      ),
      body: RefreshIndicator(
        onRefresh: _fetchLeaveData,
        child: Column(
          children: [
            Stack(
              children: [
                ClipPath(
                  clipper: BackgroundClipper(),
                  child: Container(
                    height: 80,
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
                  left: 0,
                  right: 0,
                  child: Column(
                    children: [
                      Image.asset(
                        'images/Logo.png',
                        width: 90,
                        height: 90,
                      ),
                    ],
                  ),
                ),
                if (roleName == "Admin")
                  Positioned(
                    right: 15,
                    child: Stack(
                      children: [
                        SlideTransition(
                          position: _animation,
                          child: IconButton(
                            icon: Icon(Icons.notifications_rounded, size: 32, color: Colors.white),
                            onPressed: () {
                              if (totalPending > 0) {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (context) => LeavesScreen()),
                                );
                              } else {
                                showToast(msg: "No Pending Leaves found");
                              }
                            },
                          ),
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
                              constraints: BoxConstraints(
                                minWidth: 21,
                                minHeight: 21,
                              ),
                              child: Center(
                                child: Text(
                                  '$totalPending',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                  ),
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
                  right: 70,
                  child: Stack(
                    children: [
                      SlideTransition(
                        position: _animation,
                        child: IconButton(
                          icon: Icon(Icons.task, size: 32, color: Colors.white),
                          onPressed: () {
                            if(totalViewCount>0) {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => DailyWorkingStatus()),
                              );
                            }
                          },
                        ),
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
                            constraints: BoxConstraints(
                              minWidth: 21,
                              minHeight: 21,
                            ),
                            child: Center(
                              child: Text(
                                '$totalViewCount',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                ),
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
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: GridView.count(
                  crossAxisCount: 2,
                  children: [
                    buildCard("WORKING DAYS", Icons.calendar_month, Colors.blue[300]!, destinationScreen: Workingdayslist()),
                    buildCard("Card 2", Icons.check_circle, Colors.green[300]!),
                    buildCard("Card 3", Icons.check_circle, Colors.deepPurple[300]!),
                    buildCard("Card 4", Icons.check_circle, Colors.pink[300]!),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class BackgroundClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    Path path = Path();
    path.lineTo(0, size.height - 50);
    path.quadraticBezierTo(
        size.width / 2, size.height, size.width, size.height - 50);
    path.lineTo(size.width, 0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}
