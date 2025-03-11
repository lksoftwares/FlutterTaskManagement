import 'package:lktaskmanagementapp/packages/headerfiles.dart';

class DashboardScreen extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: NavBar(
        
      ),
      appBar: CustomAppBar(
        title: 'Dashboard',
        onLogout: () => AuthService.logout(context),
      ),

    );
  }
}
