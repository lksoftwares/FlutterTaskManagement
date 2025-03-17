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
            height: 1000,
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
                buildListTile(Icons.note_alt_outlined, 'Leaves', '/leaves', context),
                buildListTile(Icons.menu, 'Menus', '/menus', context),
                buildListTile(Icons.lock_open, 'Permissions', '/permissions', context),
                buildListTile(Icons.lock_open, 'MenuRole', '/menurole', context),
                buildListTile(Icons.note_alt_sharp, 'Apply Leave', '/leaveform', context),
                buildListTile(Icons.lock, 'Change Password', '/changepassword', context),

              ],
            ),
          ),
        ],
      ),
    );
  }
}
// import 'package:lktaskmanagementapp/packages/headerfiles.dart';
//
// class NavBar extends StatefulWidget {
//   @override
//   State<NavBar> createState() => _NavBarState();
// }
//
// class _NavBarState extends State<NavBar> {
//   String username = 'no user';
//   String role = 'No Role';
//   String userImage = '';
//   List<dynamic> menuData = [];
//   bool isLoading = true;
//
//   @override
//   void initState() {
//     super.initState();
//     _loadUserData();
//     _fetchMenuData();
//   }
//
//   _loadUserData() async {
//     SharedPreferences prefs = await SharedPreferences.getInstance();
//     setState(() {
//       username = prefs.getString('user_Name') ?? 'no user';
//       role = prefs.getString('role_Name') ?? 'No Role';
//       userImage = prefs.getString('user_image') ?? '';
//     });
//   }
//
//   _fetchMenuData() async {
//     SharedPreferences prefs = await SharedPreferences.getInstance();
//     final roleId = prefs.getInt('role_Id');
//
//     if (roleId == null) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text('Role ID not found')),
//       );
//       setState(() {
//         isLoading = false;
//       });
//       return;
//     }
//
//     final response = await new ApiService().request(
//       method: 'GET',
//       endpoint: 'Permission/GetRoleBasedMenus/$roleId',
//     );
//
//     if (response['statusCode'] == 200) {
//       setState(() {
//         menuData = response['apiResponse'];
//         isLoading = false;
//       });
//     } else {
//       setState(() {
//         isLoading = false;
//       });
//       throw Exception('Failed to load menu data');
//     }
//   }
//
//   Widget buildMenuItem(Map<String, dynamic> menu) {
//     TextStyle menuTextStyle = TextStyle(
//       fontSize: 16,
//       fontWeight: FontWeight.w600,
//       color: Colors.white,
//     );
//
//     Color menuBackgroundColor = primaryColor;
//
//     String menuName = menu['menuName'] ?? 'Unknown Menu';
//     String pageName = menu['pageName'] ?? '';
//     String? menuIcon = menu['icon'];
//
//     if (menu['subMenus'] != null && menu['subMenus'].isNotEmpty) {
//       return ExpansionTile(
//         title: Container(
//           padding: const EdgeInsets.all(5.0),
//           decoration: BoxDecoration(
//             color: menuBackgroundColor,
//             borderRadius: BorderRadius.circular(8.0),
//           ),
//           child: Row(
//             children: [
//               menuIcon != null && menuIcon.isNotEmpty
//                   ? CircleAvatar(
//                 radius: 20,
//                 backgroundImage: NetworkImage(menuIcon),
//               )
//                   : CircleAvatar(radius: 20, backgroundColor: Colors.grey),
//               const SizedBox(width: 12),
//               Text(
//                 menuName,
//                 style: menuTextStyle,
//               ),
//             ],
//           ),
//         ),
//         children: menu['subMenus'] is List
//             ? (menu['subMenus'] as List)
//             .map<Widget>((submenu) => buildMenuItem(submenu))
//             .toList()
//             : [],
//       );
//     } else {
//       return ListTile(
//         contentPadding: EdgeInsets.only(left: 16.0, right: 8.0),
//         title: Container(
//           padding: const EdgeInsets.all(5.0),
//           decoration: BoxDecoration(
//             color: menuBackgroundColor,
//             borderRadius: BorderRadius.circular(8.0),
//           ),
//           child: Row(
//             children: [
//               menuIcon != null && menuIcon.isNotEmpty
//                   ? CircleAvatar(
//                 radius: 20,
//                 backgroundImage: NetworkImage(menuIcon),
//               )
//                   : CircleAvatar(radius: 20, backgroundColor: Colors.grey),
//               const SizedBox(width: 12),
//               Text(
//                 menuName,
//                 style: menuTextStyle,
//               ),
//             ],
//           ),
//         ),
//         onTap: () {
//           if (pageName.isNotEmpty) {
//             Navigator.pushNamed(context, pageName);
//           }
//         },
//       );
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Drawer(
//       backgroundColor: primaryColor,
//       child: ListView(
//         padding: EdgeInsets.zero,
//         children: [
//           Padding(
//             padding: const EdgeInsets.only(top: 35.0),
//             child: Column(
//               children: [
//                 Row(
//                   children: [
//                     Padding(
//                       padding: const EdgeInsets.only(left: 20.0),
//                       child: Image.asset(
//                         'images/Logo.png',
//                         width: 70,
//                         height: 70,
//                       ),
//                     ),
//                     SizedBox(width: 10),
//                     Padding(
//                       padding: const EdgeInsets.only(left: 20.0),
//                       child: Column(
//                         children: [
//                           Text(
//                             'Welcome!',
//                             style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: textColor2),
//                           ),
//                           Row(
//                             children: [
//                               Text(
//                                 ' ${username}',
//                                 style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color:textColor2),
//                               ),
//                               Text(
//                                 ' (${role})',
//                                 style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color:textColor2),
//                               ),
//                             ],
//                           ),
//                         ],
//                       ),
//                     ),
//                   ],
//                 ),
//               ],
//             ),
//           ),
//           Container(
//             height: 800,
//             color: Colors.grey[200],
//             child: isLoading
//                 ? const Center(child: CircularProgressIndicator())
//                 : ListView(
//               children: menuData.map((menu) => buildMenuItem(menu)).toList(),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
