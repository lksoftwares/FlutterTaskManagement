import 'package:lktaskmanagementapp/packages/headerfiles.dart';
class AppRoutes {
  static Map<String, WidgetBuilder> getRoutes() {
    return {
      '/': (context) => SplashScreen(),
      '/login': (context) => LoginScreen(),
      '/roles': (context) => RolesPage(),
      '/users': (context) => UsersPage(),
      '/userrole': (context) => UserroleScreen(),
      '/status': (context) => DailyWorkingStatus(),
      '/team': (context) => TeamScreen(),
      '/teammember': (context) => TeamMembersScreen(),
      '/project': (context) => ProjectsScreen(),
      '/userlogs': (context) => UserlogsPage(),
      '/workingdays': (context) => Workingdayslist(),
      '/attendance': (context) => AttendanceScreen(),


    };
  }
}