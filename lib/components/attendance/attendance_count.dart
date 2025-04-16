import 'package:lktaskmanagementapp/packages/headerfiles.dart';

class AttendanceCount extends StatefulWidget {
  const AttendanceCount({super.key});

  @override
  State<AttendanceCount> createState() => _AttendanceCountState();
}

class _AttendanceCountState extends State<AttendanceCount> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: "Attendance Count",
      ),
    );
  }
}
