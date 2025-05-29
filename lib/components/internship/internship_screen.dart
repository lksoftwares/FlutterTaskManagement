import 'package:lktaskmanagementapp/packages/headerfiles.dart';
import 'package:intl/intl.dart';
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
  bool _showRemarksField = false;
  DateTime? birthDate;
  final _formKey = GlobalKey<FormState>();
  final FocusNode _nameFocus = FocusNode();
  final FocusNode _emailFocus = FocusNode();
  final FocusNode _mobileFocus = FocusNode();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _genderController = TextEditingController();
  final _dayssController = TextEditingController();
  final _remarksController = TextEditingController();
  final _collegeController = TextEditingController();
  final _classController = TextEditingController();
  final _addressController = TextEditingController();
  final _startDateController = TextEditingController();
  final _endDateController = TextEditingController();
  final _mobileController = TextEditingController();
  final _dobController = TextEditingController();
  List<String> internshipStatusOptions = ['pending', 'join','not Interested'];
  String? internshipStatus;
  List<String> genderOptions = ['Male', 'Female'];
  String? selectedGender;
  final controller = MultiSelectController<String>();
  List<String> studentStages = ['pending', 'join','not Interested'];
  List<Map<String, dynamic>> branch = [];
  int? selectedBranchId;
  int? userId;
  DateTime? fromDate;
  DateTime? toDate;
  Map<String, bool> selectedStages = {
    'pending': true,
    'join': false,
    'not Interested': false
  };

  @override
  void initState() {
    super.initState();
    fetchStudents();
    fetchBranch();
    _getUserId();
  }

  Future<void> _getUserId() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      userId = prefs.getInt('user_Id');
    });
  }

  Future<void> fetchBranch() async {
    final response = await new ApiService().request(
      method: 'get',
      endpoint: 'branch/',
    );

    if (response['statusCode'] == 200 && response['apiResponse'] != null) {
      setState(() {
        branch = List<Map<String, dynamic>>.from(response['apiResponse']);
      });
    } else {
      print('Failed to load branch');
    }
  }
  Future<void> fetchStudents() async {
    setState(() {
      isLoading = true;
    });
    final response = await new ApiService().request(
      method: 'get',
      endpoint: 'InternshipStudent/',
    );
    if (response['statusCode'] == 200 && response['apiResponse'] != null) {
      setState(() {
        internship = List<Map<String, dynamic>>.from(
          response['apiResponse']['studentList'].map((role) => {
            'studId': role['studId'] ?? 0,
            'studName': role['studName'] ?? 'Unknown Name',
            'studEmail': role['studEmail'] ?? 'Unknown email',
            'mobileNo': role['mobileNo'] ?? '',
            'gender': role['gender'] ?? 'Unknown gender',
            'dob': role['dob'] ?? null,
            'branchId': role['branchId'] ?? 0,
            'collegeName': role['collegeName'] ?? '',
            'branchName': role['branchName'] ?? '',
            'internshipStartDate': role['internshipStartDate'] ?? null,
            'studAddress': role['studAddress'] ?? "",
            'registrationDate': role['registrationDate'] ?? null,
            'createdAt': role['createdAt'] ?? null,
            'internshipStatus': role['internshipStatus'] ?? null,
            'internshipDays': role['internshipDays'] ?? "",
            'remarks': role['remarks'] ?? "N/A",
          }),
        );
      });
    } else {
      print('Failed to load Students');
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
    if (!_formKey.currentState!.validate()) {
      return;
    }
    if(selectedBranchId == null){
      showToast(msg: "Please select Branch");
      return;
    }
    String? formattedBirthDate;
    if (birthDate != null) {
      formattedBirthDate = DateformatyyyyMMdd.formatDateyyyyMMdd(birthDate!);
    }
    String? formattedStartDate;
    if (internshipStartDate != null) {
      formattedStartDate = DateformatyyyyMMdd.formatDateyyyyMMdd(internshipStartDate!);
    }
    Map<String, dynamic> requestBody = {
      "studName": _nameController.text.trim(),
      "studEmail": _emailController.text.trim(),
      "mobileNo": _mobileController.text.trim(),
      "gender": selectedGender,
      "dob": formattedBirthDate,
      "collegeName": _collegeController.text.trim(),
      "branchId": selectedBranchId,
      "studAddress": _addressController.text.trim(),
      "remarks": _remarksController.text.trim(),
      "internshipStatus": "pending",
      "internshipStartDate": formattedStartDate,
      "internshipDays": _dayssController.text.trim().isEmpty ? 0 : int.parse(_dayssController.text.trim()),
      "userId": userId
    };
    print(_dayssController.text.trim());
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
        showToast(msg: ' ${response['message']}');
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
    _dobController.clear();
    _dayssController.clear();

    setState(() {
      birthDate == null;
      selectedBranchId== null;
      _showRemarksField = false;
    });
    selectedGender = "Male";
    selectedBranchId = null;

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
          StatefulBuilder(
              builder: (context, setState) {
                return SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        children: [
                          CustomTextField(
                            controller: _collegeController,
                            label: "College Name",
                            hintText: "Enter college name",
                          ),
                          SizedBox(height: 5,),
                          CustomDropdown<int>(
                            options: branch.map<int>((branch) => branch['branchId'] as int).toList(),
                            selectedOption: selectedBranchId,
                            displayValue: (branchId) => branch.firstWhere((branch) => branch['branchId'] == branchId)['branchName'],
                            onChanged: (value) {
                              setState(() {
                                selectedBranchId = value;
                                final selectedBranch = branch.firstWhere((b) => b['branchId'] == value);
                                _showRemarksField = (selectedBranch['branchName'] == 'Others');
                              });
                            },
                            labelText: 'Select branch',
                          ),
                          if (_showRemarksField)
                            Column(
                              children: [
                                CustomTextField(
                                  controller: _remarksController,
                                  label: "Remarks",
                                  hintText: "Please specify other branch",
                                  validator: (value) {
                                    if (_showRemarksField && (value == null || value.trim().isEmpty)) {
                                      return "Remarks are required for 'Others' branch";
                                    }
                                    return null;
                                  },
                                ),
                              ],
                            ),

                          SizedBox(height: 10,),
                          CustomTextField(
                            controller: _dayssController,
                            label: "Internship Days",
                            hintText: "Enter Internship Days",
                            keyboardType: TextInputType.phone,

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
                                  initialDate: internshipStartDate ??
                                      DateTime.now(),
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
                                labelText: 'Tentative Start Date',
                                border: OutlineInputBorder(),
                                suffixIcon: Icon(Icons.calendar_month),
                              ),
                            ),
                          ),
                          CustomTextField(
                            controller: _nameController,
                            focusNode: _nameFocus,
                            label: "Name",
                            hintText: "Enter your name",
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                Future.delayed(Duration.zero, () {
                                  FocusScope.of(context).requestFocus(_nameFocus);
                                });
                                return "Name is required";
                              }
                              return null;
                            },
                          ),
                          CustomTextField(
                            controller: _addressController,
                            label: "Address",
                            hintText: "Enter address",
                            maxLines: 2,
                          ),
                          Container(
                            width: 320,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(" Select Gender", style: TextStyle(
                                    fontSize: 16, fontWeight: FontWeight.w500)),
                                Row(
                                  children: genderOptions.map((gender) {
                                    return Expanded(
                                      child: RadioListTile<String>(
                                        title: Text(gender,
                                            style: TextStyle(fontSize: 17)),
                                        value: gender,
                                        groupValue: selectedGender,
                                        onChanged: (value) {
                                          setState(() {
                                            selectedGender = value!;
                                            _genderController.text = value;
                                          });
                                        },
                                        contentPadding: EdgeInsets.zero,
                                        dense: true,
                                        visualDensity: VisualDensity.compact,
                                      ),
                                    );
                                  }).toList(),
                                ),
                              ],
                            ),
                          ),

                          CustomTextField(
                            controller: _mobileController,
                            focusNode: _mobileFocus,
                            label: "Mobile Number",
                            hintText: "Enter mobile number",
                            keyboardType: TextInputType.phone,
                            maxLines: 1,
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                Future.delayed(Duration.zero, () {
                                  FocusScope.of(context).requestFocus(_mobileFocus);
                                });
                                return "Mobile number is required";
                              } else if (value.trim().length != 10) {
                                return "Mobile number must be 10 digits";
                              }
                              return null;
                            },
                            onChanged: (val) {
                              final cleaned = val.replaceAll(RegExp(r'[^0-9]'), '');
                              if (cleaned.length > 10) {
                                _mobileController.text = cleaned.substring(0, 10);
                                _mobileController.selection = TextSelection.fromPosition(
                                  TextPosition(offset: _mobileController.text.length),
                                );
                              }
                            },
                          ),

                          CustomTextField(
                            controller: _emailController,
                            focusNode: _emailFocus,
                            label: "Student Email",
                            hintText: "Enter student email",
                            keyboardType: TextInputType.emailAddress,
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
                                        DateformatddMMyyyy.formatDateddMMyyyy(
                                            birthDate!);
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
                );
              } ),
        ],
      ),
      titleHeight: 65,
      actions: [],
    );
  }

  Future<void> updateInternshipStudent(int studId) async {
    if (!_formKey.currentState!.validate()) {
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
      "gender": selectedGender,
      "dob": formattedBirthDate,
      "collegeName": _collegeController.text.trim(),
      "branchId": selectedBranchId,
      "studAddress": _addressController.text.trim(),
      "internshipStartDate": formattedStartDate,
      //"internshipEndDate": formattedEndDate,
      "remarks": _remarksController.text.trim(),
      "internshipDays": _dayssController.text.trim().isEmpty ? 0 : int.parse(_dayssController.text.trim()),
      "userId": userId,
      "internshipStatus": internshipStatus,
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
    selectedGender = studentData['gender'] ?? '';
    _collegeController.text = studentData['collegeName'] ?? '';
    selectedBranchId = studentData['branchId'];
    _addressController.text = studentData['studAddress'] ?? '';
    _dobController.text = studentData['dob'] ?? '';
    _startDateController.text = studentData['internshipStartDate'] ?? '';
    _endDateController.text = studentData['internshipEndDate'] ?? '';
    _dayssController.text = studentData['internshipDays']?.toString() ?? '';
    internshipStatus = studentData['internshipStatus'] ?? 'pending';
    final selectedBranch = branch.firstWhere(
            (b) => b['branchId'] == selectedBranchId,
        orElse: () => {'branchName': ''}
    );
    _showRemarksField = (selectedBranch['branchName'] == 'Others');
    _remarksController.text = studentData['remarks'] ?? '';
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
          StatefulBuilder(
              builder: (context, setState) {
                return SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        children: [
                          CustomTextField(
                            controller: _collegeController,
                            label: "College Name",
                            hintText: "Enter college name",
                          ),
                          SizedBox(height: 5,),
                          CustomDropdown<int>(
                            options: branch.map<int>((branch) => branch['branchId'] as int).toList(),
                            selectedOption: selectedBranchId,
                            displayValue: (branchId) => branch.firstWhere((branch) => branch['branchId'] == branchId)['branchName'],
                            onChanged: (value) {
                              setState(() {
                                selectedBranchId = value;
                                final newSelectedBranch = branch.firstWhere((b) => b['branchId'] == value);
                                _showRemarksField = (newSelectedBranch['branchName'] == 'Others');
                                if (!_showRemarksField) {
                                  _remarksController.clear();
                                }
                              });
                            },
                            labelText: 'Select Branch',
                          ),
                          if (_showRemarksField)
                            Column(
                              children: [
                                SizedBox(height: 10),
                                CustomTextField(
                                  controller: _remarksController,
                                  label: "Remarks",
                                  hintText: "Please specify other branch",
                                  validator: (value) {
                                    if (_showRemarksField && (value == null || value.trim().isEmpty)) {
                                      return "Remarks are required for 'Others' branch";
                                    }
                                    return null;
                                  },
                                ),
                              ],
                            ),
                          CustomTextField(
                            controller: _dayssController,
                            label: "Internship Days",
                            hintText: "Enter Internship Days",
                            keyboardType: TextInputType.phone,

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
                                  initialDate: internshipStartDate ??
                                      DateTime.now(),
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
                                labelText: 'Tentative Start Date',
                                border: OutlineInputBorder(),
                                suffixIcon: Icon(Icons.calendar_month),
                              ),
                            ),
                          ),

                          CustomTextField(
                            controller: _nameController,
                            focusNode: _nameFocus,
                            label: "Name",
                            hintText: "Enter your name",
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                Future.delayed(Duration.zero, () {
                                  FocusScope.of(context).requestFocus(_nameFocus);
                                });
                                return "Name is required";
                              }
                              return null;
                            },
                          ),
                          SizedBox(height: 5,),
                          CustomTextField(
                            controller: _addressController,
                            label: "Address",
                            hintText: "Enter address",
                            maxLines: 2,
                          ),
                          Container(
                            width: 320,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(" Select Gender", style: TextStyle(
                                    fontSize: 16, fontWeight: FontWeight.w500)),
                                Row(
                                  children: genderOptions.map((gender) {
                                    return Expanded(
                                      child: RadioListTile<String>(
                                        title: Text(gender,
                                            style: TextStyle(fontSize: 17)),
                                        value: gender,
                                        groupValue: selectedGender,
                                        onChanged: (value) {
                                          setState(() {
                                            selectedGender = value!;
                                            _genderController.text = value;
                                          });
                                        },
                                        contentPadding: EdgeInsets.zero,
                                        dense: true,
                                        visualDensity: VisualDensity.compact,
                                      ),
                                    );
                                  }).toList(),
                                ),
                              ],
                            ),
                          ),
                          CustomTextField(
                            controller: _mobileController,
                            focusNode: _mobileFocus,
                            label: "Mobile Number",
                            hintText: "Enter mobile number",
                            keyboardType: TextInputType.phone,
                            maxLines: 1,
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                Future.delayed(Duration.zero, () {
                                  FocusScope.of(context).requestFocus(_mobileFocus);
                                });
                                return "Mobile number is required";
                              } else if (value.trim().length != 10) {
                                return "Mobile number must be 10 digits";
                              }
                              return null;
                            },
                            onChanged: (val) {
                              final cleaned = val.replaceAll(RegExp(r'[^0-9]'), '');
                              if (cleaned.length > 10) {
                                _mobileController.text = cleaned.substring(0, 10);
                                _mobileController.selection = TextSelection.fromPosition(
                                  TextPosition(offset: _mobileController.text.length),
                                );
                              }
                            },
                          ),

                          CustomTextField(
                            controller: _emailController,
                            focusNode: _emailFocus,
                            label: "Student Email",
                            hintText: "Enter student email",
                            keyboardType: TextInputType.emailAddress,

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
                                        DateformatddMMyyyy.formatDateddMMyyyy(
                                            birthDate!);
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
                          CustomDropdown<String>(
                            width: 320,
                            options: internshipStatusOptions,
                            selectedOption: internshipStatus,
                            displayValue: (status) =>
                            status[0].toUpperCase() + status.substring(1),
                            onChanged: (newValue) {
                              setState(() {
                                internshipStatus = newValue;
                              });
                            },
                            labelText: 'Internship Status',
                          ),

                          // SizedBox(height: 10),
                          // Container(
                          //   width: 320,
                          //   child: TextField(
                          //     controller: _endDateController,
                          //     readOnly: true,
                          //     onTap: () async {
                          //       DateTime? pickedDate = await showDatePicker(
                          //         context: context,
                          //         initialDate: internshipEndDate ?? DateTime.now(),
                          //         firstDate: DateTime(2000),
                          //         lastDate: DateTime(2101),
                          //       );
                          //       if (pickedDate != null) {
                          //         setState(() {
                          //           internshipEndDate = pickedDate;
                          //           _endDateController.text = DateformatddMMyyyy
                          //               .formatDateddMMyyyy(internshipEndDate!);
                          //         });
                          //       }
                          //     },
                          //     decoration: const InputDecoration(
                          //       labelText: 'Internship End Date',
                          //       border: OutlineInputBorder(),
                          //       suffixIcon: Icon(Icons.calendar_month),
                          //     ),
                          //   ),
                          // ),

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
                );
              }
          ),
        ],
      ),
      titleHeight: 65,
      actions: [],
    );
  }
  DateTime _parseDate(String dateStr) {
    try {
      return DateFormat('dd-MM-yyyy').parse(dateStr);
    } catch (e) {
      print("Error parsing date: $e");
      return DateTime(2000);
    }
  }
  List<Map<String, dynamic>> getFilteredData() {
    return internship.where((student) {
      final status = student['internshipStatus']?.toString().toLowerCase() ?? '';
      final matchesStage = selectedStages[status] ?? false;

      bool matchesDate = true;

      if (fromDate != null && toDate != null) {
        DateTime workingDate = _parseDate(student['internshipStartDate']);
        matchesDate = (workingDate.isAtSameMomentAs(fromDate!) ||
            workingDate.isAfter(fromDate!)) &&
            (workingDate.isAtSameMomentAs(toDate!) ||
                workingDate.isBefore(toDate!));
      }

      bool stageCondition = selectedStages.containsValue(true) ? matchesStage : status == 'pending';

      return stageCondition && matchesDate;
    }).toList();
  }

  void _showDatePicker() {
    showDateRangePicker(
      context: context,
      firstDate: DateTime(2025,DateTime.february),
      lastDate: DateTime(2025,DateTime.december),
      initialDateRange: fromDate != null && toDate != null
          ? DateTimeRange(start: fromDate!, end: toDate!)
          : null,
    ).then((pickedDateRange) {
      if (pickedDateRange != null) {
        setState(() {
          fromDate = pickedDateRange.start;
          toDate = pickedDateRange.end;
        });
      }
    });
  }
  @override
  Widget build(BuildContext context) {
    List<DropdownItem<String>> stageItems = studentStages
        .map((stage) => DropdownItem(label: stage, value: stage))
        .toList();
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
                        MultiSelectDropdown(
                          width: 250,
                          items: stageItems,
                          controller: controller,
                          hintText: 'Select Stage',
                          onSelectionChange: (selectedItems) {
                            setState(() {
                              selectedStages = {
                                for (var stage in studentStages)
                                  stage: selectedItems.contains(stage),
                              };
                            });
                            fetchStudents();
                          },
                        ),
                        IconButton(
                          icon: Icon(
                              Icons.filter_alt_outlined, color: Colors.blue, size: 30),
                          onPressed: _showDatePicker,
                        ),
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
                    else if (getFilteredData().isEmpty)
                      NoDataFoundScreen()
                    else
                      Column(
                        children: getFilteredData().map((role) {
                          Map<String, dynamic> studFields = {
                            'Student Name': role['studName'],
                            '': role[''],
                            'Status': role['internshipStatus'],
                            'Email': role['studEmail'] ,
                            'MobileNo': role['mobileNo'] ,
                            'Gender': role['gender'],
                            'D.O.B': role['dob']?? "--/--/----",
                            'CollegeName': role['collegeName'] ,
                            'Branch': role['branchName'] ?? '',
                            'remarks': role['remarks'] ?? "N/A",
                            'Address': role['studAddress'],
                            'RegisterDate': role['registrationDate'] ,
                            'StartDate': role['internshipStartDate'] ,
                            'InternshipDays': role['internshipDays'] ,
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
