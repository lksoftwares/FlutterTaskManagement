import 'package:lktaskmanagementapp/packages/headerfiles.dart';
class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final double fontSize;
  final FontWeight fontWeight;
  final Color fontColor;
  final VoidCallback? onLogout;
  @override
  final Size preferredSize;

  CustomAppBar({
    Key? key,
    this.title = 'My App',
    this.fontSize = 26.0,
    this.fontWeight = FontWeight.bold,
    this.fontColor = Colors.white,
    this.onLogout,
  }) : preferredSize = Size.fromHeight(60.0),
        super(key: key);

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarColor: primaryColor,
      statusBarIconBrightness: Brightness.light,
    ));

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: SafeArea(
        left: true,
        right: true,
        bottom: true,
        top: true,
        child: AppBar(
          centerTitle: true,
          title: Text(
            title,
            style: TextStyle(
              fontSize: fontSize,
              fontWeight: fontWeight,
              color: fontColor,
            ),
          ),
          backgroundColor: primaryColor,
          actions: [
            if (onLogout != null)
              IconButton(
                icon: Icon(Icons.logout),
                onPressed: onLogout,
                color: Colors.white,
              ),
          ],
        ),
      ),
    );
  }
}
