import 'package:lktaskmanagementapp/packages/headerfiles.dart';

class Workingdayslist extends StatefulWidget {
  const Workingdayslist({super.key});

  @override
  State<Workingdayslist> createState() => _WorkingdayslistState();
}

class _WorkingdayslistState extends State<Workingdayslist> {
  List<Map<String, dynamic>> totalWorkingDaysList = [];
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    fetchWorkingDays();
  }

  Future<void> fetchWorkingDays() async {
    setState(() {
      isLoading = true;
    });

    SharedPreferences prefs = await SharedPreferences.getInstance();
    int? userId = prefs.getInt('user_Id');
    String roleName = prefs.getString('role_Name') ?? "";
    String endpoint = 'Working/';
    if (roleName == 'Admin') {
      endpoint = 'Working/';
    } else if (userId != null) {
      endpoint = 'Working/?userId=$userId';
    }
    final response = await ApiService().request(
      method: 'get',
      endpoint: endpoint,
      tokenRequired: true,
    );

    print('Response: $response');

    if (response['statusCode'] == 200 && response['apiResponse'] != null) {
      setState(() {
        totalWorkingDaysList = List<Map<String, dynamic>>.from(
          response['apiResponse']['totalWorkingDaysList'].map((data) => {
            'txnId': data['txnId'] ?? 0,
            'userName': data['userName']??"",
            'totalDaysInMonth': data['totalDaysInMonth'],
            'totalWorkingDays': data['totalWorkingDays'],
          }),
        );
      });
    } else {
      showToast(msg: response['message'] ?? 'Failed to load working days');
    }

    setState(() {
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: 'Working Days',
        onLogout: () => AuthService.logout(context),
      ),
      body: RefreshIndicator(
        onRefresh: fetchWorkingDays,
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: [
                if (isLoading)
                  Center(child: CircularProgressIndicator())
                else if (totalWorkingDaysList.isEmpty)
                  NoDataFoundScreen()
                else
                  Column(
                    children: totalWorkingDaysList.map((days) {
                      Map<String, dynamic> roleFields = {
                        'UserName': days['userName'],
                        '': days[''],
                        'DaysinMonth': days['totalDaysInMonth'],
                        'WorkingDays': days['totalWorkingDays'],
                      };

                      return buildUserCard(
                        userFields: roleFields,
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
