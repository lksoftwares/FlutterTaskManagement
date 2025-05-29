//
// import 'package:lktaskmanagementapp/components/menus/rolebasedmenu.dart';
// import 'package:lktaskmanagementapp/packages/headerfiles.dart';
//
// class NavBar extends StatefulWidget {
//
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
//   Future<void> _savePermissionType(String permissionType) async {
//     SharedPreferences prefs = await SharedPreferences.getInstance();
//     await prefs.setString('permissiontype', permissionType);
//   }
//
//
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
//     } else if (response['statusCode'] == 404) {
//       String errorMessage = response['message'] ?? 'Failed to load menu data';
//       showToast(msg: errorMessage);
//       setState(() {
//         isLoading = false;
//       });
//     } else {
//       setState(() {
//         isLoading = false;
//       });
//       throw Exception(response['message'] ?? 'Failed to load menu data');
//     }
//   }
//
//   Map<String, Widget Function(BuildContext)> pageMap = {
//     'UsersPage': (context) => UsersPage(),
//     'RolesPage': (context) => RolesPage(),
//     'UserroleScreen': (context) => UserroleScreen(),
//     'MenuRolePage': (context) => MenuRolePage(),
//     'UserlogsPage': (context) => UserlogsPage(),
//     'Changepassword': (context) => Changepassword(),
//     'ProjectsScreen': (context) => ProjectsScreen(),
//     'TeamScreen': (context) => TeamScreen(),
//     'TeamMembersScreen': (context) => TeamMembersScreen(),
//     'DailyWorkingStatus': (context) => DailyWorkingStatus(),
//     'AttendanceScreen': (context) => AttendanceScreen(),
//     'LeavesScreen': (context) => LeavesScreen(),
//     'MenuScreen': (context) => MenuScreen(),
//     'PermissionScreen': (context) => PermissionsScreen(),
//     'LoginScreen': (context) => LoginScreen(),
//     'TasksScreen': (context) => TasksScreen(),
//
//
//   };
//
//   Widget buildMenuItem(Map<String, dynamic> menu) {
//     TextStyle menuTextStyle = TextStyle(
//       fontSize: 16,
//       fontWeight: FontWeight.w600,
//       color: Colors.black,
//     );
//
//     String menuName = menu['menuName'] ?? 'Unknown Menu';
//     String pageName = menu['pageName'] ?? '';
//     String? menuIcon = menu['icon'];
//
//     if (menu['subMenus'] != null && menu['subMenus'].isNotEmpty) {
//       return Theme(
//
//         data: Theme.of(context).copyWith(dividerColor: Colors.grey),
//         child: ExpansionTile(
//           title: Container(
//             decoration: BoxDecoration(
//               borderRadius: BorderRadius.circular(8.0),
//             ),
//             child: Row(
//               children: [
//                 menuIcon != null && menuIcon.isNotEmpty
//                     ? CircleAvatar(
//                   radius: 20,
//                   backgroundImage: NetworkImage(menuIcon),
//                 )
//                     : CircleAvatar(radius: 20, backgroundColor: Colors.grey),
//                 const SizedBox(width: 12),
//                 Text(
//                   menuName,
//                   style: menuTextStyle,
//                 ),
//               ],
//             ),
//           ),
//           children: menu['subMenus'] is List
//               ? (menu['subMenus'] as List)
//               .map<Widget>((submenu) => buildMenuItem(submenu))
//               .toList()
//               : [],
//         ),
//       );
//     }
//
//     else {
//       return SingleChildScrollView(
//         child: ListTile(
//           title: Container(
//             decoration: BoxDecoration(
//               borderRadius: BorderRadius.circular(8.0),
//             ),
//             child: Row(
//               children: [
//                 menuIcon != null && menuIcon.isNotEmpty
//                     ? CircleAvatar(
//                   radius: 20,
//                   backgroundImage: NetworkImage(menuIcon),
//                 )
//                     : CircleAvatar(radius: 20, backgroundColor: Colors.grey),
//                 const SizedBox(width: 12),
//                 Text(
//                   menuName,
//                   style: menuTextStyle,
//                 ),
//               ],
//             ),
//           ),
//           onTap: () {
//             if (menu['roles'] != null && menu['roles'].isNotEmpty) {
//               String permissionType = menu['roles'][0]['permissionType'] ?? 'default_permission';
//               _savePermissionType(permissionType);
//             }
//             if (pageName.isNotEmpty && pageMap.containsKey(pageName)) {
//               Navigator.push(
//                 context,
//                 MaterialPageRoute(
//                   builder: (context) => pageMap[pageName]!(context),
//                 ),
//               );
//             }
//             else {
//               showDialog(
//                 context: context,
//                 builder: (BuildContext context) {
//                   return AlertDialog(
//                     title: const Text('Page Not Found'),
//                     content: Text('No page found for $menuName.'),
//                     actions: <Widget>[
//                       TextButton(
//                         onPressed: () {
//                           Navigator.of(context).pop();
//                         },
//                         child: const Text('OK'),
//                       ),
//                     ],
//                   );
//                 },
//               );
//             }
//           },
//         ),
//       );
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Drawer(
//       backgroundColor: primaryColor,
//       child: ListView(
//         children: [
//           Column(
//             children: [
//               Row(
//                 children: [
//                   Padding(
//                     padding: const EdgeInsets.only(left: 20.0),
//                     child: Image.asset(
//                       'images/Logo.png',
//                       width: 70,
//                       height: 70,
//                     ),
//                   ),
//                   SizedBox(width: 10),
//                   Padding(
//                     padding: const EdgeInsets.only(left: 20.0),
//                     child: Column(
//                       children: [
//                         Text(
//                           'Welcome!',
//                           style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: textColor2),
//                         ),
//                         Row(
//                           children: [
//                             Text(
//                               ' ${username}',
//                               style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color:textColor2),
//                             ),
//                             Text(
//                               ' (${role})',
//                               style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color:textColor2),
//                             ),
//                           ],
//                         ),
//                       ],
//                     ),
//                   ),
//                 ],
//               ),
//             ],
//           ),
//           Padding(
//             padding: const EdgeInsets.all(0.0),
//             child: Container(
//               height: MediaQuery.of(context).size.height - AppBar().preferredSize.height - kToolbarHeight,
//               color: Colors.grey[200],
//               child: isLoading
//                   ? const Center(child: CircularProgressIndicator())
//                   : ListView(
//                 children: menuData.map((menu) => buildMenuItem(menu)).toList(),
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }

import 'package:lktaskmanagementapp/components/menus/rolebasedmenu.dart';
import 'package:lktaskmanagementapp/packages/headerfiles.dart';

class MenuDataHolder {
  static final MenuDataHolder _instance = MenuDataHolder._internal();
  factory MenuDataHolder() => _instance;
  MenuDataHolder._internal();

  List<dynamic> menuData = [];
  bool isMenuDataLoaded = false;
}

class NavBar extends StatefulWidget {
  @override
  State<NavBar> createState() => _NavBarState();
}

class _NavBarState extends State<NavBar> {
  String username = 'no user';
  String role = 'No Role';
  String userImage = '';
  bool isLoading = true;
  List<dynamic> menuData = [];


  @override
  void initState() {
    super.initState();
    _loadUserData();
    if (!MenuDataHolder().isMenuDataLoaded) {
      _fetchNewData();
    } else {
      setState(() {
        isLoading = false;
      });
    }
  }


  _loadUserData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      username = prefs.getString('user_Name') ?? 'no user';
      role = prefs.getString('role_Name') ?? 'No Role';
      userImage = prefs.getString('user_image') ?? '';
    });
  }

  Future<void> _savePermissionType(String permissionType) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('permissiontype', permissionType);
  }

  _fetchMenuData() async {
    if (MenuDataHolder().isMenuDataLoaded) {
      setState(() {
        isLoading = false;
      });
      return;
    }

    SharedPreferences prefs = await SharedPreferences.getInstance();
    final roleId = prefs.getInt('role_Id');
    if (roleId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Role ID not found')),
      );
      setState(() {
        isLoading = false;
      });
      return;
    }

    final response = await ApiService().request(
      method: 'GET',
      endpoint: 'Permission/GetRoleBasedMenus/$roleId',
      tokenRequired: true
    );

    if (response['statusCode'] == 200) {
      setState(() {
        MenuDataHolder().menuData = response['apiResponse'];
        MenuDataHolder().isMenuDataLoaded = true;
        isLoading = false;
      });
      print(response);
    } else if (response['statusCode'] == 404) {
      String errorMessage = response['message'] ?? 'Failed to load menu data';
      showToast(msg: errorMessage);
      setState(() {
        isLoading = false;
      });
    } else {
      setState(() {
        isLoading = false;
      });
      throw Exception(response['message'] ?? 'Failed to load menu data');
    }
  }

  Map<String, Widget Function(BuildContext)> pageMap = {
    'UsersPage': (context) => UsersPage(),
    'RolesPage': (context) => RolesPage(),
    'UserroleScreen': (context) => UserroleScreen(),
    'MenuRolePage': (context) => MenuRolePage(),
    'UserlogsPage': (context) => UserlogsPage(),
    'Changepassword': (context) => Changepassword(),
    'ProjectsScreen': (context) => ProjectsScreen(),
    'TeamScreen': (context) => TeamScreen(),
    'TeamMembersScreen': (context) => TeamMembersScreen(),
    'DailyWorkingStatus': (context) => DailyWorkingStatus(),
    'AttendanceScreen': (context) => AttendanceScreen(),
    'LeavesScreen': (context) => LeavesScreen(),
    'MenuScreen': (context) => MenuScreen(),
    'PermissionScreen': (context) => PermissionsScreen(),
    'LoginScreen': (context) => LoginScreen(),
    'TasksScreen': (context) => TasksScreen(),
    'AssigntaskScreen': (context) => AssigntaskScreen(),
    'HolidaysScreen': (context) => HolidaysScreen(),
    'TasklogsScreen': (context) => TasklogsScreen(),
    'TaskscommentsScreen': (context) => TaskscommentsScreen(),
    'ShiftsScreen': (context) => ShiftsScreen(),
    'AssignShifts': (context) => AssignShifts(),
    'TeammemberroleScreen': (context) => TeammemberroleScreen(),
    'InternshipScreen': (context) => InternshipScreen(),
    'BranchScreen': (context) => BranchScreen(),


  };

  Widget buildMenuItem(Map<String, dynamic> menu) {
    TextStyle menuTextStyle = TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.w600,
      color: Colors.black,
    );

    String menuName = menu['menuName'] ?? 'Unknown Menu';
    String pageName = menu['pageName'] ?? '';
    String? menuIcon = menu['icon'];

    if (menu['subMenus'] != null && menu['subMenus'].isNotEmpty) {
      return Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.grey),
        child: ExpansionTile(
          title: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8.0),
            ),
            child: Row(
              children: [
                menuIcon != null && menuIcon.isNotEmpty
                    ? CircleAvatar(
                  radius: 20,
                  backgroundImage: NetworkImage(menuIcon),
                )
                    : CircleAvatar(radius: 20, backgroundColor: Colors.grey),
                const SizedBox(width: 12),
                Text(
                  menuName,
                  style: menuTextStyle,
                ),
              ],
            ),
          ),
          children: menu['subMenus'] is List
              ? (menu['subMenus'] as List)
              .map<Widget>((submenu) => buildMenuItem(submenu))
              .toList()
              : [],
        ),
      );
    } else {
      return SingleChildScrollView(
        child: ListTile(
          title: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8.0),
            ),
            child: Row(
              children: [
                menuIcon != null && menuIcon.isNotEmpty
                    ? CircleAvatar(
                  radius: 20,
                  backgroundImage: NetworkImage(menuIcon),
                )
                    : CircleAvatar(radius: 20, backgroundColor: Colors.grey),
                const SizedBox(width: 12),
                Text(
                  menuName,
                  style: menuTextStyle,
                ),
              ],
            ),
          ),
          onTap: () {
            if (menu['roles'] != null && menu['roles'].isNotEmpty) {
              String permissionType = menu['roles'][0]['permissionType'] ??
                  'default_permission';
              _savePermissionType(permissionType);
            }
            if (pageName.isNotEmpty && pageMap.containsKey(pageName)) {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => pageMap[pageName]!(context),
                ),
              );
            } else {
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    title: const Text('Page Not Found'),
                    content: Text('No page found for $menuName.'),
                    actions: <Widget>[
                      TextButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                        child: const Text('OK'),
                      ),
                    ],
                  );
                },
              );
            }
          },
        ),
      );
    }
  }
  _fetchNewData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final roleId = prefs.getInt('role_Id');

    if (roleId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Role ID not found')),
      );
      setState(() {
        isLoading = false;
      });
      return;
    }

    final response = await ApiService().request(
      method: 'GET',
      endpoint: 'Permission/GetRoleBasedMenus/$roleId',
        tokenRequired: true

    );

    if (response['statusCode'] == 200) {
      setState(() {
        MenuDataHolder().menuData = response['apiResponse'];
        MenuDataHolder().isMenuDataLoaded = true;
        isLoading = false;
      });
    } else if (response['statusCode'] == 404) {
      String errorMessage = response['message'] ?? 'Failed to load menu data';
      showToast(msg: errorMessage);
      setState(() {
        isLoading = false;
      });
    } else {
      setState(() {
        isLoading = false;
      });
      throw Exception(response['message'] ?? 'Failed to load menu data');
    }
  }


  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: primaryColor,
      child: ListView(
        children: [
          Column(
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
                          style: TextStyle(fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: textColor2),
                        ),
                        Row(
                          children: [
                            Text(
                              ' ${username}',
                              style: TextStyle(fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: textColor2),
                            ),
                            Text(
                              ' (${role})',
                              style: TextStyle(fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: textColor2),
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
          Padding(
            padding: const EdgeInsets.all(0.0),
            child: Container(
              height: MediaQuery
                  .of(context)
                  .size
                  .height - AppBar().preferredSize.height - kToolbarHeight,
              color: Colors.grey[200],
              child: isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : RefreshIndicator(
                onRefresh: () async {
                  setState(() {
                    MenuDataHolder().isMenuDataLoaded = false;
                    isLoading = true;
                  });

                  await _fetchNewData();
                },
                child: ListView(
                  children: MenuDataHolder()
                      .menuData
                      .map((menu) => buildMenuItem(menu))
                      .toList(),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}