

import 'package:lktaskmanagementapp/packages/headerfiles.dart';

class InternshipScreen extends StatefulWidget {
  const InternshipScreen({super.key});

  @override
  State<InternshipScreen> createState() => _InternshipScreenState();
}

class _InternshipScreenState extends State<InternshipScreen> {
  List<Map<String, dynamic>> internship = [];
  String? selectedRoleName;
  bool isLoading = false;
  DateTime? internshipStartDate;
  DateTime? internshipEndDate;
  final _startDateController = TextEditingController();
  final _endDateController = TextEditingController();
  DateTime? birthDate;
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _genderController = TextEditingController();
  final _collegeController = TextEditingController();
  final _classController = TextEditingController();
  final _addressController = TextEditingController();
  final _mobileController = TextEditingController();
  final _dobController = TextEditingController();

  @override
  void initState() {
    super.initState();
    fetchStudents();
  }

  Future<void> fetchStudents() async {
    setState(() {
      isLoading = true;
    });

    final response = await new ApiService().request(
      method: 'get',
      endpoint: 'InternshipStudent/',
    );
    print('Response: $response');
    if (response['statusCode'] == 200 && response['apiResponse'] != null) {
      setState(() {
        internship = List<Map<String, dynamic>>.from(
          response['apiResponse'].map((role) => {
            'studId': role['studId'] ?? 0,
            'studName': role['studName'] ?? 'Unknown Name',
            'studEmail': role['studEmail'] ?? 'Unknown email',
            'mobileNo': role['mobileNo'] ?? '',
            'gender': role['gender'] ?? 'Unknown gender',
            'dob': role['dob'] ?? null,
            'collegeName': role['collegeName'] ?? '',
            'branch': role['branch'] ?? '',
            'internshipStartDate': role['internshipStartDate'] ?? null,
            'internshipEndDate': role['internshipEndDate'] ?? null,
            'studAddress': role['studAddress'] ?? "",
            'registrationDate': role['registrationDate'] ?? null,
            'createdAt': role['createdAt'] ?? null,
            'internshipStatus': role['internshipStatus'] ?? null,
          }),
        );
      });
    } else {
      showToast(msg: response['message'] ?? 'Failed to load Students');
    }
    setState(() {
      isLoading = false;
    });
  }


  void _confirmDeleteStud(int studId) {
    showCustomAlertDialog(
        context,
        title: 'Delete Student',
        content: Text('Are you sure you want to delete this student?'),
        actions: [

          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            onPressed: () {
              _deleteStudents(studId);
              Navigator.pop(context);
            },
            child: Text('Delete',style: TextStyle(color: Colors.white),),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
        ],
        titleHeight: 65,
        isFullScreen: false
    );

  }

  Future<void> _deleteStudents(int studId) async {

    final response = await new ApiService().request(
        method: 'post',
        endpoint: 'InternshipStudent/delete/$studId'
    );
    if (response['statusCode'] == 200) {
      String message = response['message'] ?? 'Student deleted successfully';
      showToast(msg: message, backgroundColor: Colors.green);
      fetchStudents();
    } else {
      String message = response['message'] ?? 'Failed to delete student';
      showToast(msg: message);
    }
  }
  Future<void> submitInternshipForm() async {
    if (_nameController.text.isEmpty || _emailController.text.isEmpty || _mobileController.text.isEmpty) {
      showToast(msg: "Please fill in all the required fields.");
      return;
    }
    String? formattedBirthDate;
    if (birthDate != null) {
      formattedBirthDate = DateformatyyyyMMdd.formatDateyyyyMMdd(birthDate!);
    }

    Map<String, dynamic> requestBody = {
      "studName": _nameController.text.trim(),
      "studEmail": _emailController.text.trim(),
      "mobileNo": _mobileController.text.trim(),
      "gender": _genderController.text.trim(),
      "dob": formattedBirthDate,
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
        showToast(msg: response['message'] ?? 'Internship applied', backgroundColor: Colors.green);
        Navigator.pop(context);
        fetchStudents();
      } else {
        showToast(msg: 'Submission Failed: ${response['message']}');
      }
    } catch (e) {
      showToast(msg: 'Error: $e');
    }
  }


  void _addInternshipStudent() {
    _nameController.clear();
    _emailController.clear();
    _mobileController.clear();
    _genderController.clear();
    _collegeController.clear();
    _classController.clear();
    _addressController.clear();
    setState(() {
      birthDate ==null;
    });

    showCustomAlertDialog(
      context,
      title: 'Add Student',
      content: Stack(
        children: [
          Container(
            width: double.infinity,
            height: MediaQuery.of(context).size.height,
            child: Image.asset(
              'images/internship.png',
              fit: BoxFit.cover,
            ),
          ),
          SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: Column(
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
                    SizedBox(height: 10),
                    Container(
                      width: 320,
                      child: TextField(
                        controller: _dobController,
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
                              _dobController.text = DateformatddMMyyyy.formatDateddMMyyyy(birthDate!);
                            });
                          } else {
                            setState(() {
                              birthDate = null;
                              _dobController.clear();
                            });
                          }
                        },
                        decoration: const InputDecoration(
                          labelText: 'Select DOB',
                          border: OutlineInputBorder(),
                          suffixIcon: Icon(Icons.calendar_month),
                        ),
                      ),
                    ),
SizedBox(height: 10,),
                    CustomTextField(
                      controller: _collegeController,
                      label: "College Name",
                      hintText: "Enter college name",
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
                      width: 200,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
      titleHeight: 65,
      actions: [],
    );
  }


  Future<void> updateInternshipStudent(int studId) async {
    if (_nameController.text.isEmpty || _emailController.text.isEmpty || _mobileController.text.isEmpty) {
      showToast(msg: "Please fill in all the required fields.");
      return;
    }

    String? formattedBirthDate;
    String? formattedStartDate;
    String? formattedEndDate;

    if (birthDate != null) {
      formattedBirthDate = DateformatyyyyMMdd.formatDateyyyyMMdd(birthDate!);
    }
    if (internshipStartDate != null) {
      formattedStartDate = DateformatyyyyMMdd.formatDateyyyyMMdd(internshipStartDate!);
    }
    if (internshipEndDate != null) {
      formattedEndDate = DateformatyyyyMMdd.formatDateyyyyMMdd(internshipEndDate!);
    }

    Map<String, dynamic> requestBody = {
      "studId": studId,
      "studName": _nameController.text.trim(),
      "studEmail": _emailController.text.trim(),
      "mobileNo": _mobileController.text.trim(),
      "gender": _genderController.text.trim(),
      "dob": formattedBirthDate,
      "collegeName": _collegeController.text.trim(),
      "branch": _classController.text.trim(),
      "studAddress": _addressController.text.trim(),
      "internshipStartDate": formattedStartDate,
      "internshipEndDate": formattedEndDate,
      "internshipStatus": "pending",
      "updateFlag":true

    };

    try {
      final response = await ApiService().request(
        method: 'POST',
        endpoint: 'InternshipStudent/update',
        body: requestBody,
      );

      if (response['statusCode'] == 200) {
        showToast(msg: response['message'] ?? 'Student updated successfully', backgroundColor: Colors.green);
        Navigator.pop(context);
        fetchStudents();
      } else {
        showToast(msg: 'Update Failed: ${response['message']}');
      }
    } catch (e) {
      showToast(msg: 'Error: $e');
    }
  }

  void _showEditStudentDialog(Map<String, dynamic> studentData) {
    _nameController.text = studentData['studName'] ?? '';
    _emailController.text = studentData['studEmail'] ?? '';
    _mobileController.text = studentData['mobileNo'] ?? '';
    _genderController.text = studentData['gender'] ?? '';
    _collegeController.text = studentData['collegeName'] ?? '';
    _classController.text = studentData['branch'] ?? '';
    _addressController.text = studentData['studAddress'] ?? '';
    _dobController.text = studentData['dob'] ?? '';
    _startDateController.text = studentData['internshipStartDate'] ?? '';
    _endDateController.text = studentData['internshipEndDate'] ?? '';

    showCustomAlertDialog(
      context,
      title: 'Edit Student',
      content: Stack(
        children: [
          Container(
            width: double.infinity,
            height: MediaQuery.of(context).size.height,
            child: Image.asset(
              'images/internship.png',
              fit: BoxFit.cover,
            ),
          ),
          SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: Column(
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
                    SizedBox(height: 10),
                    Container(
                      width: 320,
                      child: TextField(
                        controller: _dobController,
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
                              _dobController.text =
                                  DateformatddMMyyyy.formatDateddMMyyyy(birthDate!);
                            });
                          } else {
                            setState(() {
                              birthDate = null;
                              _dobController.clear();
                            });
                          }
                        },
                        decoration: const InputDecoration(
                          labelText: 'Select DOB',
                          border: OutlineInputBorder(),
                          suffixIcon: Icon(Icons.calendar_month),
                        ),
                      ),
                    ),

                    SizedBox(height: 10),
                    CustomTextField(
                      controller: _collegeController,
                      label: "College Name",
                      hintText: "Enter college name",
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
                    SizedBox(height: 10),
                    Container(
                      width: 320,
                      child: TextField(
                        controller: _startDateController,
                        readOnly: true,
                        onTap: () async {
                          DateTime? pickedDate = await showDatePicker(
                            context: context,
                            initialDate: internshipStartDate ?? DateTime.now(),
                            firstDate: DateTime(2000),
                            lastDate: DateTime(2101),
                          );
                          if (pickedDate != null) {
                            setState(() {
                              internshipStartDate = pickedDate;
                              _startDateController.text = DateformatddMMyyyy
                                  .formatDateddMMyyyy(internshipStartDate!);
                            });
                          }
                        },
                        decoration: const InputDecoration(
                          labelText: 'Internship Start Date',
                          border: OutlineInputBorder(),
                          suffixIcon: Icon(Icons.calendar_month),
                        ),
                      ),
                    ),
                    SizedBox(height: 10),
                    Container(
                      width: 320,
                      child: TextField(
                        controller: _endDateController,
                        readOnly: true,
                        onTap: () async {
                          DateTime? pickedDate = await showDatePicker(
                            context: context,
                            initialDate: internshipEndDate ?? DateTime.now(),
                            firstDate: DateTime(2000),
                            lastDate: DateTime(2101),
                          );
                          if (pickedDate != null) {
                            setState(() {
                              internshipEndDate = pickedDate;
                              _endDateController.text = DateformatddMMyyyy
                                  .formatDateddMMyyyy(internshipEndDate!);
                            });
                          }
                        },
                        decoration: const InputDecoration(
                          labelText: 'Internship End Date',
                          border: OutlineInputBorder(),
                          suffixIcon: Icon(Icons.calendar_month),
                        ),
                      ),
                    ),
                    SizedBox(height: 20),
                    CustomButton(
                      buttonText: 'Update',
                      onPressed: () {
                        updateInternshipStudent(studentData['studId']);
                      },
                      color: primaryColor,
                      width: 200,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
      titleHeight: 65,
      actions: [],
    );
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: 'Students',
        onLogout: () => AuthService.logout(context),
      ),
      body: RefreshIndicator(
        onRefresh: fetchStudents,
        child: SingleChildScrollView(
          child: StatefulBuilder(
              builder: (context, setState) {
                return Column(
                  children: [
                    SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        IconButton(
                          icon: Icon(
                              Icons.add_circle, color: Colors.blue, size: 30),
                          onPressed: _addInternshipStudent
                        ),
                      ],
                    ),

                    SizedBox(height: 20),
                    if (isLoading)
                      Center(child: CircularProgressIndicator())
                    else if (internship.isEmpty)
                      NoDataFoundScreen()
                    else
                      Column(
                        children: internship.map((role) {
                          Map<String, dynamic> studFields = {
                            'StudentName': role['studName'],
                            '': role[''],
                            'Status': role['internshipStatus'],
                            'StudentEmail': role['studEmail'] ,
                            'MobileNo': role['mobileNo'] ,
                            'Gender': role['gender'],
                            'D.O.B': role['dob'],
                            'CollegeName': role['collegeName'] ,
                            'Branch': role['branch'] ,
                            'Address': role['studAddress'],
                            'RegisterDate': role['registrationDate'] ,
                            'StartDate': role['internshipStartDate'] ?? "--/--/----",
                            'EndDate': role['internshipEndDate'] ?? "--/--/----",
                          };

                          return buildUserCard(
                            userFields: studFields,
                              onDelete: () => _confirmDeleteStud(role['studId']),
                            onEdit: () => _showEditStudentDialog(role),

                            trailingIcon:
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                IconButton(onPressed: ()=>_showEditStudentDialog(role),
                                    icon: Icon(Icons.edit,color: Colors.green,)),
                                IconButton(onPressed: ()=>_confirmDeleteStud(role['studId']),
                                    icon: Icon(Icons.delete,color: Colors.red,)),

                              ],
                            ),
                          );
                        }).toList(),
                      )

                  ],
                );}
          ),
        ),
      ),
    );
  }
}