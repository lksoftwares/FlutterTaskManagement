import 'package:lktaskmanagementapp/packages/headerfiles.dart';
class LeaveForm extends StatefulWidget {
  const LeaveForm({super.key});

  @override
  State<LeaveForm> createState() => _LeaveFormState();
}

class _LeaveFormState extends State<LeaveForm> {
  DateTime? fromDate;
  DateTime? toDate;
  final TextEditingController descriptionController = TextEditingController();
  final TextEditingController fromDateController = TextEditingController();
  final TextEditingController toDateController = TextEditingController();
  final TextEditingController remarksController = TextEditingController();

  Future<void> _selectDate(BuildContext context, bool isFromDate) async {
    DateTime initialDate = DateTime.now();
    DateTime lastDate = DateTime(initialDate.year + 1, initialDate.month, initialDate.day);

    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: initialDate,
      lastDate: lastDate,
    );
    if (pickedDate != null) {
      setState(() {
        String formattedDate = Dateformat4.formatWorkingDate4(pickedDate);
        if (isFromDate) {
          fromDate = pickedDate;
          fromDateController.text = formattedDate;
        } else {
          toDate = pickedDate;
          toDateController.text = formattedDate;
        }
      });
    }
  }

  Future<int> calculateDays(DateTime? from, DateTime? to) async {
    if (from != null && to != null) {
      return to.difference(from).inDays + 1;
    }
    return 0;
  }

  Future<int> getUserIdFromSharedPreferences() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getInt('user_Id') ?? 0;
  }

  Future<void> applyLeave() async {
    if (fromDate == null || toDate == null || descriptionController.text.isEmpty) {
      showToast(msg: "Please fill in all the required fields.");
      return;
    }

    int userId = await getUserIdFromSharedPreferences();
    int days = await calculateDays(fromDate, toDate);
    String formattedFromDate = Dateformat3.formatWorkingDate3(fromDate ?? DateTime.now());
    String formattedToDate = Dateformat3.formatWorkingDate3(toDate ?? DateTime.now());

    Map<String, dynamic> body = {
      "leaveStatus": "pending",
      "remarks": remarksController.text,
      "userId": userId,
      "leaveFrom": formattedFromDate,
      "leaveTo": formattedToDate,
      "reason": descriptionController.text,
      "days": days.toString(),
    };

    final response = await ApiService().request(
      method: 'POST',
      endpoint: "leave/AddLeave",
      body: body,
    );
print("hdvfhdvfh$body");
    if (response['statusCode'] == 200) {
      _showSuccessDialog(response['message'] ?? 'Leave applied');

    } else {
      showToast(
        msg: response['message'] ?? 'Failed to apply leave',
      );
    }
  }
  void _showSuccessDialog(String message) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.check_circle, color: Colors.green, size: 80),
              SizedBox(height: 10),
              Text(
                ' Success',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 10),
              Text(
                'Your Leave has been applied successfully.',
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: Text('OK', style: TextStyle(color: Colors.white)),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: 'Apply Leave',
        onLogout: () => AuthService.logout(context),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Container(
            padding: EdgeInsets.all(16.0),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.black),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('From Date:', style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold)),
                GestureDetector(
                  onTap: () => _selectDate(context, true),
                  child: AbsorbPointer(
                    child: CustomTextField(
                      controller: fromDateController,
                      label: 'Enter From Date',
                      hintText: 'Enter From Date',
                      suffixIcon: Icon(Icons.calendar_month),
                    ),
                  ),
                ),
                SizedBox(height: 16),
                Text('To Date:', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                GestureDetector(
                  onTap: () => _selectDate(context, false),
                  child: AbsorbPointer(
                    child: CustomTextField(
                      controller: toDateController,
                      label: 'Enter To Date',
                      hintText: 'Enter To Date',
                      suffixIcon: Icon(Icons.calendar_month),
                    ),
                  ),
                ),
                SizedBox(height: 16),
                Text('Reason for Leave:', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                CustomTextField(
                  controller: descriptionController,
                  label: 'Enter the reason for leave',
                  hintText: 'Enter the reason for leave',
                  maxLines: 4,
                ),
                SizedBox(height: 16),
                Text('Remarks:', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                CustomTextField(
                  controller: remarksController,
                  label: 'Remarks',
                  hintText: 'Remarks',
                  maxLines: 2,
                ),
                SizedBox(height: 24),
                Center(
                  child: CustomButton(
                    buttonText: 'Apply Leave',
                    onPressed: applyLeave,
                    color: primaryColor,
                    width: 200,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
