//
// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:get/get.dart';
// import 'package:get/get_core/src/get_main.dart';
// import 'package:vehiclemanagement/components/permissions/permission_page.dart';
// import 'package:vehiclemanagement/components/menus/menu_page.dart';
// import '../menus/menuswithsubmenu.dart';
// import '../permissions/permission_bloc.dart';
//
// class BottomNavBar extends StatelessWidget {
//   final int currentIndex;
//   final BuildContext context;
//   final Function(int) onItemTapped;
//
//   const BottomNavBar({
//     Key? key,
//     required this.currentIndex,
//     required this.context,
//     required this.onItemTapped,
//   }) : super(key: key);
//
//   void _onItemTapped(int index) {
//     onItemTapped(index);
//
//     switch (index) {
//       case 0:
//         Get.to(Menuswithsubmenu());
//         break;
//       case 1:
//         Navigator.push(
//           context,
//           MaterialPageRoute(builder: (context) => BlocProvider<PermissionBloc>(
//             create: (_) => PermissionBloc(),
//             child: PermissionPage(),
//           )),
//         );
//
//         break;
//
//       case 2:
//         Get.to(MenuPage());
//
//         break;
//       default:
//         break;
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return BottomNavigationBar(
//       type: BottomNavigationBarType.fixed,
//       currentIndex: currentIndex,
//       onTap: _onItemTapped,
//       items: const [
//         BottomNavigationBarItem(
//           icon: Icon(Icons.home,size: 30),
//           label: 'Home',
//         ),
//         BottomNavigationBarItem(
//           icon: Icon(Icons.verified_user_rounded,size: 30,),
//           label: 'Permissions',
//         ),
//         BottomNavigationBarItem(
//           icon: Icon(Icons.car_repair,size: 30),
//           label: 'Menus',
//         ),
//       ],
//     );
//   }
// }
//
// // import 'package:flutter/material.dart';
// // import 'package:flutter_bloc/flutter_bloc.dart';
// // import 'package:get/get.dart';
// // import 'package:get/get_core/src/get_main.dart';
// // import 'package:vehiclemanagement/components/permissions/permission_page.dart';
// //
// // import 'package:vehiclemanagement/components/menus/menu_page.dart';
// // import '../menus/menuswithsubmenu.dart';
// // import '../permissions/permission_bloc.dart';
// //
// // class BottomNavBar extends StatelessWidget {
// //   final int currentIndex;
// //   final BuildContext context;
// //   final Function(int) onItemTapped;
// //
// //   const BottomNavBar({
// //     Key? key,
// //     required this.currentIndex,
// //     required this.context,
// //     required this.onItemTapped,
// //   }) : super(key: key);
// //
// //   void _onItemTapped(int index) {
// //     onItemTapped(index);
// //
// //     switch (index) {
// //       case 0:
// //         Get.toNamed('/home');
// //         break;
// //       case 1:
// //         Get.toNamed('/roles');
// //         break;
// //       case 2:
// //         Get.toNamed('/menus');
// //         break;
// //       default:
// //         break;
// //     }
// //   }
// //   @override
// //   Widget build(BuildContext context) {
// //     return BottomNavigationBar(
// //       type: BottomNavigationBarType.fixed,
// //       currentIndex: currentIndex,
// //       onTap: _onItemTapped,
// //       items: const [
// //         BottomNavigationBarItem(
// //           icon: Icon(Icons.home,size: 30),
// //           label: 'Home',
// //         ),
// //         BottomNavigationBarItem(
// //           icon: Icon(Icons.people,size: 30,),
// //           label: 'Roles',
// //         ),
// //         BottomNavigationBarItem(
// //           icon: Icon(Icons.car_repair,size: 30),
// //           label: 'Menus',
// //         ),
// //         // BottomNavigationBarItem(
// //         //   icon: Icon(Icons.menu,size: 30),
// //         //   label: 'Menus',
// //         // ),
// //         // BottomNavigationBarItem(
// //         //   icon: Icon(Icons.menu,size: 30),
// //         //   label: 'NEw',
// //         // ),
// //       ],
// //     );
// //   }
// // }
