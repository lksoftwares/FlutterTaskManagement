import 'package:lktaskmanagementapp/packages/headerfiles.dart';


class InternshipForm extends StatefulWidget {
  const InternshipForm({Key? key}) : super(key: key);

  @override
  State<InternshipForm> createState() => _InternshipFormState();
}

class _InternshipFormState extends State<InternshipForm> {

  DateTime? startDate;
  DateTime? endDate;
  DateTime? birthDate;
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _genderController = TextEditingController();
  final _collegeController = TextEditingController();
  final _classController = TextEditingController();
  final _addressController = TextEditingController();
  final _mobileController = TextEditingController();


  Future<void> submitInternshipForm() async {
    if ( _nameController.text.isEmpty || _emailController.text.isEmpty || _mobileController.text.isEmpty) {
      showToast(msg: "Please fill in all the required fields.");
      return;
    }

    Map<String, dynamic> requestBody = {
      "studName": _nameController.text.trim(),
      "studEmail": _emailController.text.trim(),
      "mobileNo": _mobileController.text.trim(),
      "gender": _genderController.text.trim(),
      "dob": DateformatddMMyyyy.formatDateddMMyyyy(birthDate ?? DateTime.now()),
      "collegeName": _collegeController.text.trim(),
      "branch": _classController.text.trim(),
      "studAddress": _addressController.text.trim(),
      "internshipStatus": "pending",
    };

    try {
      final response = await ApiService().request(
        method: 'POST',
        endpoint: 'InternshipStudent/create',
        body: requestBody,
      );

      if (response['statusCode'] == 200) {
        _showSuccessDialog(response['message'] ?? 'internship applied');
        _nameController.clear();
        _emailController.clear();
        _mobileController.clear();
        _genderController.clear();
        _collegeController.clear();
        _classController.clear();
        _addressController.clear();
        setState(() {
          birthDate = null;
        });
      } else {
        showToast(msg: 'Submission Failed: ${response['message']}');
      }
    } catch (e) {
      showToast(msg: 'Error: $e');
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
                'Your Internship Form has been Submitted Successfully.',
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => InternshipScreen()),
                  );
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
        title: "Internship Form",
        onLogout: () => AuthService.logout(context),
      ),
      body: Stack(
        children: [
          Container(
            width: double.infinity,
            height: MediaQuery.of(context).size.height,
            child: Image.asset(
              'images/internship.png',
              fit: BoxFit.cover,
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Form(
              key: _formKey,
              child: ListView(
                children: [
                  CustomTextField(
                    controller: _nameController,
                    label: "Student Name",
                    hintText: "Enter student name",
                  ),
                  CustomTextField(
                    controller: _emailController,
                    label: "Student Email",
                    hintText: "Enter student email",
                  ),
                  CustomTextField(
                    controller: _mobileController,
                    label: "Mobile Number",
                    hintText: "Enter mobile number",
                    keyboardType: TextInputType.phone,
                  ),
                  CustomTextField(
                    controller: _genderController,
                    label: "Gender",
                    hintText: "Enter your gender",
                  ),
                  SizedBox(height: 10,),
                  TextField(
                    controller: TextEditingController(
                      text: birthDate != null
                          ? DateformatddMMyyyy.formatDateddMMyyyy(birthDate!)
                          : DateformatddMMyyyy.formatDateddMMyyyy(
                          DateTime.now()),
                    ),
                    readOnly: true,
                    onTap: () async {
                      DateTime? pickedDate = await showDatePicker(
                        context: context,
                        initialDate: birthDate ?? DateTime.now(),
                        firstDate: DateTime(2000),
                        lastDate: DateTime(2101),
                      );
                      if (pickedDate != null) {
                        setState(() {
                          birthDate = pickedDate;
                        });
                      }
                    },
                    decoration: const InputDecoration(
                      labelText: 'Select DOB',
                      border: OutlineInputBorder(),
                      suffixIcon: Icon(Icons.calendar_month),
                    ),
                  ),
                  CustomTextField(
                    controller: _collegeController,
                    label: "College Name",
                    hintText: "Enter college name",
                    maxLines: 2,
                  ),
                  CustomTextField(
                    controller: _classController,
                    label: "Branch",
                    hintText: "Enter branch",
                  ),
                  CustomTextField(
                    controller: _addressController,
                    label: "Address",
                    hintText: "Enter address",
                    maxLines: 2,
                  ),

                   SizedBox(height: 20),
                  CustomButton(
                    buttonText: 'Submit',
                    onPressed: submitInternshipForm,
                    color: primaryColor,
                    width: 100,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}