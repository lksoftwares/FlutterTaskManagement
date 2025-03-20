//
// import 'package:lktaskmanagementapp/packages/headerfiles.dart';
//
//
// class Menuswithsubmenu extends StatefulWidget {
//   const Menuswithsubmenu({super.key});
//
//   @override
//   State<Menuswithsubmenu> createState() => _MenuswithsubmenuState();
// }
//
// class _MenuswithsubmenuState extends State<Menuswithsubmenu> {
//   List<dynamic> menuData = [];
//   bool isLoading = true;
//   Map<String, Widget Function(BuildContext)> pageMap = {
//     'RolesPage': (context) => RolesPage(),
//     'UsersPage': (context) => UsersPage(),
//   };
//   @override
//   void initState() {
//     super.initState();
//     fetchMenuData();
//   }
//
//   Future<int?> _getRoleId() async {
//     SharedPreferences prefs = await SharedPreferences.getInstance();
//     return prefs.getInt('role_Id');
//   }
//
//
//   Future<void> fetchMenuData() async {
//     final roleId = await _getRoleId();
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
//     final response = await new ApiService().request(
//       method: 'GET',
//       endpoint: 'Permission/GetRoleBasedMenus/$roleId',
//     );
//
//     if (response['statusCode'] == 200) {
//       final data = response;
//
//       if (data['apiResponse'] == null || (data['apiResponse'] is List && data['apiResponse'].isEmpty)) {
//         showDialog(
//           context: context,
//           builder: (BuildContext context) {
//             return AlertDialog(
//               title: const Text('Error'),
//               content: Text(data['message'] ?? 'Error'),
//               actions: <Widget>[
//                 TextButton(
//                   onPressed: () {
//                     Navigator.of(context).pop();
//                     Navigator.pushReplacement(
//                       context,
//                       MaterialPageRoute(builder: (context) => LoginScreen()),
//                     );
//                   },
//                   child: const Text('OK'),
//                 ),
//               ],
//             );
//           },
//         );
//       } else {
//         setState(() {
//           menuData = data['apiResponse'];
//           isLoading = false;
//         });
//       }
//     } else {
//       setState(() {
//         isLoading = false;
//       });
//       throw Exception('Failed to load menu data');
//     }
//   }
//
//   Future<void> _savePermissionType(String permissionType) async {
//     SharedPreferences prefs = await SharedPreferences.getInstance();
//     await prefs.setString('selected_permission_type', permissionType);
//   }
//
//   Widget buildMenu(List<dynamic> menus) {
//     return ListView(
//       children: menus.map((menu) => buildMenuItem(menu)).toList(),
//     );
//   }
//
//   Widget buildMenuItem(Map<String, dynamic> menu) {
//     TextStyle menuTextStyle = TextStyle(
//       fontSize: 16,
//       fontWeight: FontWeight.w600,
//       color: Colors.white,
//     );
//
//     Color menuBackgroundColor = Colors.blueAccent;
//
//     String menuName = menu['menuName'] is String ? menu['menuName'] : 'Unknown Menu';
//     String pageName = menu['pageName'] is String ? menu['pageName'] : '';
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
//           if (menu['roles'] != null && menu['roles'].isNotEmpty) {
//             String permissionType = menu['roles'][0]['permissionType'] ?? 'default_permission';
//             _savePermissionType(permissionType);
//           }
//
//           if (pageName.isNotEmpty && pageMap.containsKey(pageName)) {
//             Navigator.push(
//               context,
//               MaterialPageRoute(
//                 builder: (context) => pageMap[pageName]!(context),
//               ),
//             );
//           }
//           else {
//             showDialog(
//               context: context,
//               builder: (BuildContext context) {
//                 return AlertDialog(
//                   title: const Text('Page Not Found'),
//                   content: Text('No page found for $menuName.'),
//                   actions: <Widget>[
//                     TextButton(
//                       onPressed: () {
//                         Navigator.of(context).pop();
//                       },
//                       child: const Text('OK'),
//                     ),
//                   ],
//                 );
//               },
//             );
//           }
//         },
//       );
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: CustomAppBar(
//         title: 'Menus',
//         onLogout: () => AuthService.logout(context),
//       ),
//       drawer: NavBar(),
//       body: isLoading
//           ? const Center(child: CircularProgressIndicator())
//           : RefreshIndicator(
//         onRefresh: fetchMenuData,
//         child: buildMenu(menuData),
//       ),
//
//     );
//   }
// }
//
// class SubmenuScreen extends StatelessWidget {
//   final String menuName;
//   const SubmenuScreen({super.key, required this.menuName});
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text(menuName),
//       ),
//       body: Center(
//         child: Text('You have selected: $menuName'),
//       ),
//     );
//   }
// }
