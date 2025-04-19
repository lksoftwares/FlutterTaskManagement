import 'package:lktaskmanagementapp/packages/headerfiles.dart';

class ProjectsScreen extends StatefulWidget {
  const ProjectsScreen({super.key});

  @override
  State<ProjectsScreen> createState() => _ProjectsScreenState();
}

class _ProjectsScreenState extends State<ProjectsScreen> {
  List<Map<String, dynamic>> projects = [];
  List<Map<String, dynamic>> usersList = [];
  List<Map<String, dynamic>> teamsList = [];
  String? selectedTeamName;
  bool isLoading = false;
  DateTime? startDate;
  DateTime? endDate;
  int? userId;
  int? selectedTeamId;
  String? selectedStage;
  String? selectedStage2;
  @override
  void initState() {
    super.initState();
    _getUserId();
    _getData();
  }

  final _formKey = GlobalKey<FormState>();
  final controller = MultiSelectController<String>();
  List<String> projectStages = ['Completed', 'On Hold', 'Pending', 'Cancelled', 'In Progress'];
  Map<String, bool> selectedStages = {
    'Completed': false,
    'On Hold': false,
    'Pending': false,
    'Cancelled': false,
    'In Progress': false,
  };

  Future<void> _getUserId() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      userId = prefs.getInt('user_Id');
    });
  }

  Future<void> _getData() async {
    await fetchProjects();
    await fetchUsers();
    await fetchTeams();

  }

  Future<void> fetchUsers() async {
    final response = await new ApiService().request(
        method: 'get',
        endpoint: 'User/',
        tokenRequired: true

    );
    if (response['statusCode'] == 200 && response['apiResponse'] != null) {
      setState(() {
        usersList = List<Map<String, dynamic>>.from(response['apiResponse']);
      });
    } else {
      showToast(msg: 'Failed to load users');
    }
  }
  Future<void> fetchTeams() async {
    try {
      final response = await new ApiService().request(
          method: 'get',
          endpoint: 'teams/?status=1',
          tokenRequired: true
      );

      if (response['statusCode'] == 200 && response['apiResponse'] != null) {
        setState(() {
          teamsList = List<Map<String, dynamic>>.from(response['apiResponse']);
          print("Teams List Updated: $teamsList");
        });
      } else {
        print("Failed to load teams. Response: ${response['statusCode']}");
      }
    } catch (e) {
      print("Error while fetching teams: $e");
    }
  }

  Future<void> fetchProjects() async {
    setState(() {
      isLoading = true;
    });

    final response = await new ApiService().request(
        method: 'get',
        endpoint: 'projects/',
        tokenRequired: true
    );

    print('Response: $response');

    if (response['statusCode'] == 200 && response['apiResponse'] != null) {
      setState(() {
        projects = List<Map<String, dynamic>>.from(
          response['apiResponse']['projectList'].map((role) => {
            'projectId': role['projectId'] ?? 0,
            'teamId': role['teamId'] ?? 0,
            'teamName': role['teamName'] ?? 'Unknown teamName',
            'projectName': role['projectName'] ?? 'Unknown project',
            'projectDescription': role['projectDescription'] ?? 'Unknown desc',
            'createdByUserName': role['createdByUserName'] ?? '',
            'updateByUserName': role['updateByUserName'] ?? '',
            'createdAt': role['createdAt'] ?? '',
            'startDate': role['startDate'] ?? '',
            'endDate': role['endDate'] ?? '',
            'createdBy': role['createdBy'] ?? '',
            'updatedBy': role['updatedBy'] ?? '',
            'projectStatus': role['projectStatus'] ?? false,
            'projectStage': role['projectStage'] ?? '',
          }),
        );
      });
    } else {
      showToast(msg: response['message'] ?? 'Failed to load team');
    }

    setState(() {
      isLoading = false;
    });
  }

  Future<void> _addTeam(String teamName, String tmDescription) async {
    final response = await new ApiService().request(
      method: 'post',
      endpoint: 'teams/create',
      tokenRequired: true,
      body: {
        'teamName': teamName,
        'tmDescription': tmDescription,
      },
    );
    if (response.isNotEmpty && response['statusCode'] == 200) {
       fetchTeams();
      showToast(
        msg: response['message'] ?? 'Team added successfully',
        backgroundColor: Colors.green,
      );
      Navigator.pop(context);
    } else {
      showToast(
        msg: response['message'] ?? 'Failed to add Team',
      );
    }
  }

  void _showAddTeamModal() {
    String teamName = '';
    String tmDescription = '';
    InputDecoration inputDecoration = InputDecoration(
      labelText: 'Team Name',
      border: OutlineInputBorder(),
    );

    InputDecoration descriptionDecoration = InputDecoration(
      labelText: 'Description',
      border: OutlineInputBorder(),
    );

    showCustomAlertDialog(
      context,
      title: 'Add Team',
      content: Padding(
        padding: const EdgeInsets.all(15.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(height: 15),
            TextField(
              onChanged: (value) => teamName = value,
              decoration: inputDecoration,
            ),
            SizedBox(height: 15),
            TextField(
              onChanged: (value) => tmDescription = value,
              decoration: descriptionDecoration,
            ),
          ],
        ),
      ),
      actions: [
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.green,
          ),
          onPressed: () {
            if (teamName.isEmpty ) {
              showToast(msg: 'Please fill in both fields');
            } else {
              _addTeam(teamName, tmDescription);
              fetchTeams();
            }
          },
          child: Text(
            'Add',
            style: TextStyle(color: Colors.white),
          ),
        ),
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text('Cancel'),
        ),
      ],
      titleHeight: 65,
    );
  }

  void _showAddProjectModal() {
    setState(() {
      selectedTeamId == null;
    });
    String projectName = '';
    String projectDescription = '';
    DateTime startDate = DateTime.now();
    DateTime endDate = DateTime.now();
    TextEditingController startDateController = TextEditingController(text: DateformatddMMyyyy.formatDateddMMyyyy(startDate));
    TextEditingController endDateController = TextEditingController(text: DateformatddMMyyyy.formatDateddMMyyyy(endDate));
    String? selectedStage = 'Pending';
    fetchTeams();
    showCustomAlertDialog(
      context,
      title: 'Add Project',
      content: StatefulBuilder(
          builder: (context, setState) {
            return SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(15.0),
                child: Container(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextField(
                        onChanged: (value) => projectName = value,
                        decoration: InputDecoration(
                          labelText: 'Project Name',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      SizedBox(height: 15),
                      TextField(
                        onChanged: (value) => projectDescription = value,
                        decoration: InputDecoration(
                          labelText: 'Project Description',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      SizedBox(height: 15),
                      Row(
                        children: [
                          CustomDropdown<int>(
                            options: teamsList.map<int>((
                                team) => team['teamId'] as int).toList(),
                            selectedOption: selectedTeamId,
                            displayValue: (teamId) =>
                            teamsList.firstWhere((team) =>
                            team['teamId'] == teamId)['teamName'],
                            onChanged: (value) {
                              setState(() {
                                selectedTeamId = value;
                              });
                            },
                            labelText: 'Select Team',
                            width: 280,
                          ),
                          IconButton(onPressed: _showAddTeamModal, icon: Icon(Icons.add_circle,size: 30,
                            color: Colors.blue,))
                        ],
                      ),
                      SizedBox(height: 15),
                      CustomDropdown<String>(
                        options: [
                          'Pending',
                          'In Progress',
                          'Completed',
                          'On Hold',
                          'Cancelled'
                        ],
                        selectedOption: selectedStage,
                        displayValue: (priority) => priority,
                        onChanged: (value) {
                          setState(() {
                            selectedStage = value;
                          });
                        },
                        labelText: 'Select Stage',
                      ),
                      SizedBox(height: 15),

                      GestureDetector(
                        onTap: () async {
                          DateTime? picked = await showDatePicker(
                            context: context,
                            initialDate: startDate,
                            firstDate: DateTime(2000),
                            lastDate: DateTime(2101),
                          );
                          if (picked != null) {
                            setState(() {
                              startDate = picked;
                              startDateController.text =
                                  DateformatddMMyyyy.formatDateddMMyyyy(startDate);
                            });
                          }
                        },
                        child: AbsorbPointer(
                          child: TextField(
                            controller: startDateController,
                            decoration: InputDecoration(
                              labelText: 'Start Date',
                              border: OutlineInputBorder(),
                                suffixIcon: Icon(Icons.calendar_month)
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: 15),
                      GestureDetector(
                        onTap: () async {
                          DateTime? picked = await showDatePicker(
                            context: context,
                            initialDate: endDate,
                            firstDate: DateTime(2000),
                            lastDate: DateTime(2101),
                          );
                          if (picked != null) {
                            setState(() {
                              endDate = picked;
                              endDateController.text =
                                  DateformatddMMyyyy.formatDateddMMyyyy(endDate);
                            });
                          }
                        },
                        child: AbsorbPointer(
                          child: TextField(
                            controller: endDateController,
                            decoration: InputDecoration(
                              labelText: 'End Date',
                              border: OutlineInputBorder(),
                                suffixIcon: Icon(Icons.calendar_month)
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }
       ),
      actions: [
        ElevatedButton(
          style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
          onPressed: () {
            if (projectName.isEmpty  || userId == null || startDate == null || endDate == null) {
              showToast(msg: 'Please fill in all fields');
              return;
            }
            _addProject(projectName, projectDescription, userId!, userId!, selectedTeamId!, startDate!, endDate!);
          },
          child: Text('Add', style: TextStyle(color: Colors.white)),
        ),
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text('Cancel'),
        ),
      ],
      titleHeight: 65,
    );
  }

  Future<void> _addProject(String projectName, String projectDescription, int createdBy, int updatedBy,  int teamId,DateTime startDate, DateTime endDate) async {
    final response = await new ApiService().request(
      method: 'post',
      endpoint: 'projects/create',
      tokenRequired: true,

      body: {
        'projectName': projectName,
        'projectDescription': projectDescription,
        'createdBy': createdBy,
        'updatedBy': updatedBy,
        'projectStage': selectedStage,
        'teamId': teamId,
        'startDate': startDate.toIso8601String(),
        'endDate': endDate.toIso8601String(),
      },
    );

    if (response['statusCode'] == 200) {
      showToast(msg: response['message'] ?? 'Project created successfully',
          backgroundColor: Colors.green);
      Navigator.pop(context);
      fetchProjects();
    } else {
      showToast(msg: response['message'] ?? 'Failed to create Project');
    }
  }

  void _confirmDeleteProject(int projectId) {
    showCustomAlertDialog(
      context,
      title: 'Delete Project',
      content: Text('Are you sure you want to delete this Project?'),
      actions: [

        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.red,
          ),
          onPressed: () {
            _deleteProject(projectId);
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

  Future<void> _deleteProject(int projectId) async {

    final response = await new ApiService().request(
        method: 'post',
        endpoint: 'projects/Delete/$projectId',
        tokenRequired: true


    );
    if (response['statusCode'] == 200) {
      String message = response['message'] ?? ' deleted successfully';
      showToast(msg: message, backgroundColor: Colors.green);
      fetchProjects();
    } else {
      String message = response['message'] ?? 'Failed to delete Project';
      showToast(msg: message);
    }
  }
  void _showEditProjectModal(Map<String, dynamic> project) {
    TextEditingController projectNameController = TextEditingController(text: project['projectName']);
    TextEditingController projectDescriptionController = TextEditingController(text: project['projectDescription']);
    DateTime startDate = DateTime.parse(project['startDate']);
    DateTime endDate = DateTime.parse(project['endDate']);
    TextEditingController startDateController = TextEditingController(text: DateformatddMMyyyy.formatDateddMMyyyy(startDate));
    TextEditingController endDateController = TextEditingController(text: DateformatddMMyyyy.formatDateddMMyyyy(endDate));
     int? selectedTeamId = project['teamId'];
    bool? selectedStatus = project['projectStatus'];
    selectedStage = project['projectStage'];
    showCustomAlertDialog(
      context,
      title: 'Edit Project',
      content: StatefulBuilder(
          builder: (context, setState) {
            return SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(15.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: projectNameController,
                      decoration: InputDecoration(
                        labelText: 'Project Name',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    SizedBox(height: 15),
                    TextField(
                      controller: projectDescriptionController,
                      decoration: InputDecoration(
                        labelText: 'Project Description',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    SizedBox(height: 15),
                    CustomDropdown<int>(
                      options: teamsList.map<int>((team) => team['teamId'] as int).toList(),
                      selectedOption: selectedTeamId,
                      displayValue: (teamId) => teamsList.firstWhere((team) => team['teamId'] == teamId)['teamName'],
                      onChanged: (value) {
                        setState(() {
                          selectedTeamId = value;
                        });
                      },
                      labelText: 'Select Team',
                    ),
                    SizedBox(height: 15),


                    CustomDropdown<String>(
                      options: [
                        'Pending',
                        'In Progress',
                        'Completed',
                        'On Hold',
                        'Cancelled'
                      ],
                      displayValue: (status) => status,
                      selectedOption: selectedStage,
                      onChanged: (value) {
                        setState(() {
                          selectedStage = value;
                        });
                      },
                      labelText: 'Select Status',
                    ),
                    SizedBox(height: 15),

                    GestureDetector(
                      onTap: () async {
                        DateTime? picked = await showDatePicker(
                          context: context,
                          initialDate: startDate,
                          firstDate: DateTime(2000),
                          lastDate: DateTime(2101),
                        );
                        if (picked != null) {
                          setState(() {
                            startDate = picked;
                            startDateController.text = DateformatddMMyyyy
                                .formatDateddMMyyyy(startDate);
                          });
                        }
                      },
                      child: AbsorbPointer(
                        child: TextField(
                          controller: startDateController,
                          decoration: InputDecoration(
                            labelText: 'Start Date',
                            border: OutlineInputBorder(),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 15),
                    GestureDetector(
                      onTap: () async {
                        DateTime? picked = await showDatePicker(
                          context: context,
                          initialDate: endDate,
                          firstDate: DateTime(2000),
                          lastDate: DateTime(2101),
                        );
                        if (picked != null) {
                          setState(() {
                            endDate = picked;
                            endDateController.text = DateformatddMMyyyy
                                .formatDateddMMyyyy(endDate);
                          });
                        }
                      },
                      child: AbsorbPointer(
                        child: TextField(
                          controller: endDateController,
                          decoration: InputDecoration(
                            labelText: 'End Date',
                            border: OutlineInputBorder(),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 10),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Status:',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                        Transform.scale(
                          scale: 1.3,
                          child: Switch(
                            value: selectedStatus ?? false,
                            onChanged: (bool value) {
                              setState(() {
                                selectedStatus = value;
                              });
                            },
                            activeColor: Colors.green,
                            inactiveThumbColor: Colors.red,
                            inactiveTrackColor: Colors.red[200],
                          ),
                        ),

                      ],
                    ),
                  ],
                ),
              ),
            );
          }
      ),
      actions: [
        ElevatedButton(
          style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
          onPressed: () {
            if (projectNameController.text.isEmpty  || startDate == null || endDate == null) {
              showToast(msg: 'Please fill in all fields');
              return;
            }
            _updateProject(
              project['projectId'],
              projectNameController.text,
              projectDescriptionController.text,
              userId!,
              userId!,
              selectedTeamId!,
              startDate,
              endDate,
              selectedStatus ?? false
            );
          },
          child: Text('Update', style: TextStyle(color: Colors.white)),
        ),
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text('Cancel'),
        ),
      ],
      titleHeight: 65,
    );
  }
  Future<void> _updateProject(int projectId, String projectName, String projectDescription, int createdBy, int updatedBy, int teamId, DateTime startDate, DateTime endDate,bool projectStatus) async {
    final response = await ApiService().request(
      method: 'post',
      endpoint: 'projects/update',
      tokenRequired: true,
      body: {
        'projectId': projectId,
        'projectName': projectName,
        'projectDescription': projectDescription,
        'createdBy': createdBy,
        'updatedBy': updatedBy,
        'teamId': teamId,
        'projectStatus': projectStatus,
        'projectStage': selectedStage,
        'startDate': startDate.toIso8601String(),
        'endDate': endDate.toIso8601String(),
        'updateFlag': true,
      },
    );

    if (response['statusCode'] == 200) {
      showToast(msg: 'Project updated successfully', backgroundColor: Colors.green);
      fetchProjects();
      Navigator.pop(context);
    } else {
      showToast(msg: response['message'] ?? 'Failed to update project');
    }
  }
  List<Map<String, dynamic>> getFilteredData() {
    if (selectedStages.values.every((value) => !value)) {
      return projects;
    }
    return projects.where((project) {
      bool matchesStage = false;
      if (selectedStages.isNotEmpty) {
        matchesStage = selectedStages[project['projectStage']] ?? false;
      }
      return matchesStage;
    }).toList();
  }


  @override
  Widget build(BuildContext context) {
    List<DropdownItem<String>> stageItems = projectStages
        .map((stage) => DropdownItem(label: stage, value: stage))
        .toList();
    return Scaffold(
      appBar: CustomAppBar(
        title: 'Projects',
        onLogout: () => AuthService.logout(context),
      ),
      body: RefreshIndicator(
        onRefresh: fetchProjects,
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  SizedBox(height: 15),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      MultiSelectDropdown(
                        width: 290,
                        items: stageItems,
                        controller: controller,
                        hintText: 'Select Project Stage(s)',
                        onSelectionChange: (selectedItems) {
                          setState(() {
                            selectedStages = {
                              for (var stage in projectStages)
                                stage: selectedItems.contains(stage),
                            };
                          });
                          fetchProjects();
                        },
                      ),
                      IconButton(
                        icon: Icon(Icons.add_circle, color: Colors.blue, size: 30),
                        onPressed: _showAddProjectModal,
                      ),
                    ],
                  ),
                  SizedBox(height: 10),
                  if (isLoading)
                    Center(child: CircularProgressIndicator())
                  else if (projects.isEmpty)
                    NoDataFoundScreen()
                  else if (getFilteredData().isEmpty)
                      NoDataFoundScreen()
                    else
                      Column(
                        children: getFilteredData().map((role) {
                          return buildUserCard(
                            userFields: {
                              'ProjectName': role['projectName'],
                              '': role[''],
                              'Projectdesc': role['projectDescription'],
                              'TeamName': role['teamName'],
                              'ProjectStatus': role['projectStatus'],
                              'ProjectStage': role['projectStage'] ,
                              'CreatedBy': role['createdByUserName'],
                              'UpdatedBy': role['updateByUserName'],
                              'StartDate': role['startDate'] != null
                                  ? DateformatddMMyyyy.formatDateddMMyyyy(DateTime.parse(role['startDate']))
                                  : 'Not Set',
                              'EndDate': role['endDate'] != null
                                  ? DateformatddMMyyyy.formatDateddMMyyyy(DateTime.parse(role['endDate']))
                                  : 'Not Set',
                              'CreatedAt': role['createdAt'],
                            },
                            onEdit: () => _showEditProjectModal(role),
                            onDelete: () => _confirmDeleteProject(role['projectId']),
                            trailingIcon: Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                IconButton(
                                  onPressed: () => _showEditProjectModal(role),
                                  icon: Icon(Icons.edit, color: Colors.green),
                                ),
                                IconButton(
                                  onPressed: () => _confirmDeleteProject(role['projectId']),
                                  icon: Icon(Icons.delete, color: Colors.red),
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                      ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
