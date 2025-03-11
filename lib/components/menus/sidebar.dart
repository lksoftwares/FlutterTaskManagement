import 'package:lktaskmanagementapp/packages/headerfiles.dart';

class NavBar extends StatefulWidget {
  @override
  State<NavBar> createState() => _NavBarState();
}

class _NavBarState extends State<NavBar> {
  String username = 'no user';
  String role = 'No Role';
  String userImage = '';

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  _loadUserData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      username = prefs.getString('user_Name') ?? 'no user';
      role = prefs.getString('role_Name') ?? 'No Role';
      userImage = prefs.getString('user_image') ?? '';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: primaryColor,
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 35.0),
            child: Column(
              children: [
                Row(
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(left: 20.0),
                      child: Image.asset(
                        'images/Logo.png',
                        width: 70,
                        height: 70,
                      ),
                    ),
                    SizedBox(width: 10),

                    Padding(
                      padding: const EdgeInsets.only(left: 20.0),
                      child: Column(
                        children: [
                          Text(
                            'Welcome!',
                            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: textColor2),
                          ),
                          Row(
                            children: [
                              Text(
                                ' ${username}',
                                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color:textColor2),
                              ),
                              Text(
                                ' (${role})',
                                style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: textColor2),
                              ),
                            ],
                          ),

                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Container(
            height: 800,
            color: Colors.grey[200],
            child: Column(
              children: [
                buildListTile(Icons.people_alt_rounded, 'Roles', '/roles', context),
                buildListTile(Icons.person, 'Users', '/users', context),
                buildListTile(Icons.supervised_user_circle_outlined, 'User Roles', '/userrole', context),
                buildListTile(Icons.task, 'Working Status', '/status', context),
                buildListTile(Icons.group, 'Team', '/team', context),
                buildListTile(Icons.emoji_people, 'Team Members', '/teammember', context),
                buildListTile(Icons.note_alt_outlined, 'Projects', '/project', context),
                buildListTile(Icons.login_sharp, 'User Logs', '/userlogs', context),
                buildListTile(Icons.calendar_month, 'Working Days', '/workingdays', context),
                buildListTile(Icons.calendar_today, 'Attendance', '/attendance', context),

              ],
            ),
          ),
        ],
      ),
    );
  }
}
