
import 'package:lktaskmanagementapp/packages/headerfiles.dart';
class TeamScreen extends StatefulWidget {
  const TeamScreen({super.key});

  @override
  State<TeamScreen> createState() => _TeamScreenState();
}

class _TeamScreenState extends State<TeamScreen> {
  List<Map<String, dynamic>> teams = [];
  List<Map<String, dynamic>> teamMembers = [];
  bool isLoading = false;


  @override
  void initState() {
    super.initState();
    fetchTeams();

  }
  Future<void> fetchTeamMembers(int teamId) async {


    final response = await new ApiService().request(
      method: 'get',
      endpoint: 'teams/GetTeamMembers?teamId=$teamId',
        tokenRequired: true

    );

    if (response['statusCode'] == 200 && response['apiResponse'] != null) {
      setState(() {
        teamMembers = List<Map<String, dynamic>>.from(
          response['apiResponse'].map((member) => {
            'tmemberId': member['tmemberId'] ?? 0,
            'userId': member['userId'] ?? 0,
            'roleId': member['roleId'] ?? 0,
            'teamId': member['teamId'] ?? 0,
            'teamName': member['teamName'] ?? 'Unknown team',
            'createdAt': member['createdAt'] ?? '',
            'roleName': member['roleName'] ?? 'Unknown role',
            'userName': member['userName'] ?? 'Unknown user',
          }),
        );
      });
    } else {
      showToast(msg: response['message'] ?? 'Failed to load team members');
    }

    setState(() {
      isLoading = false;
    });
  }

  void _showTeamMembersModal(int teamId) {
    setState(() {
      teamMembers.clear();
    });

    fetchTeamMembers(teamId).then((_) {
      showCustomAlertDialog(
          context,
          title: 'Team Members',
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (isLoading)
                Center(child: CircularProgressIndicator())
              else if (teamMembers.isEmpty)
                Text('No members found')
              else
                Column(
                  children: teamMembers.map((member) {
                    return ListTile(
                      title: Text(member['userName']),
                      subtitle: Text('Role: ${member['roleName']}'),
                    );
                  }).toList(),
                ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Close'),
            ),
          ],
          titleHeight: 70
      );
    });
  }


  Future<void> fetchTeams() async {
    setState(() {
      isLoading = true;
    });

    final response = await new ApiService().request(
      method: 'get',
      endpoint: 'teams/',
        tokenRequired: true

    );
    print('Response: $response');
    if (response['statusCode'] == 200 && response['apiResponse'] != null) {
      setState(() {
        teams = List<Map<String, dynamic>>.from(
          response['apiResponse'].map((role) => {
            'teamId': role['teamId'] ?? 0,
            'teamName': role['teamName'] ?? 'Unknown team',
            'tmDescription': role['tmDescription'] ?? 'Unknown team',
            'createdAt': role['createdAt'] ?? '',
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
    }  else {
      showToast(
        msg: response['message'] ?? 'Failed to add role',
      );
    }
  }

  void _showAddRoleModal() {
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
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            onChanged: (value) => teamName = value,
            decoration: inputDecoration,
          ),
          SizedBox(height: 10),
          TextField(
            onChanged: (value) => tmDescription = value,
            decoration: descriptionDecoration,
          ),
        ],
      ),
      actions: [

        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.green,
          ),
          onPressed: () {
            if (teamName.isEmpty || tmDescription.isEmpty) {
              showToast(msg: 'Please fill in both fields');
            } else {
              _addTeam(teamName, tmDescription);
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


  void _confirmDeleteTeam(int teamId) {
    showCustomAlertDialog(
      context,
      title: 'Delete Team',
      content: Text('Are you sure you want to delete this team?'),
      actions: [

        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.red,
          ),
          onPressed: () {
            _deleteTeam(teamId);
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

    );
  }

  Future<void> _deleteTeam(int teamId) async {

    final response = await new ApiService().request(
      method: 'post',
      endpoint: 'teams/delete/$teamId',
        tokenRequired: true

    );
    if (response['statusCode'] == 200) {
      String message = response['message'] ?? 'Team deleted successfully';
      showToast(msg: message, backgroundColor: Colors.green);
      fetchTeams();
    } else {
      String message = response['message'] ?? 'Failed to delete Team';
      showToast(msg: message);
    }
  }

  Future<void> _updateTeam(int teamId, String teamName,String tmDescription) async {
    final response = await new ApiService().request(
      method: 'post',
      endpoint: 'teams/update',
      tokenRequired: true,
      body: {
        'teamId': teamId,
        'teamName': teamName,
        'tmDescription':tmDescription,
        'updateFlag': true,
      },
    );

    print('Update Response: $response');

    if (response.isNotEmpty && response['statusCode'] == 200) {
      fetchTeams();
      showToast(
        msg: response['message'] ?? 'Team updated successfully',
        backgroundColor: Colors.green,
      );
      Navigator.pop(context);
    } else {
      showToast(
        msg: response['message'] ?? 'Failed to update team',
      );
    }
  }


  void _showEditTeamModal(int teamId, String currentTeamName, String currentDescription) {
    TextEditingController _teamController = TextEditingController(text: currentTeamName);
    TextEditingController _descriptionController = TextEditingController(text: currentDescription);

    showCustomAlertDialog(
      context,
      title: 'Edit Team',
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _teamController,
            decoration: InputDecoration(
              labelText: 'Team Name',
              border: OutlineInputBorder(),
            ),
          ),
          SizedBox(height: 10),
          TextField(
            controller: _descriptionController,
            decoration: InputDecoration(
              labelText: 'Description',
              border: OutlineInputBorder(),
            ),
          ),
        ],
      ),
      actions: [

        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.green,
          ),
          onPressed: () {
            if (_teamController.text.isEmpty || _descriptionController.text.isEmpty) {
              showToast(msg: 'Please fill in both fields');
            } else {
              _updateTeam(teamId, _teamController.text, _descriptionController.text);
            }
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: 'Team',
        onLogout: () => AuthService.logout(context),
      ),
      body: RefreshIndicator(
        onRefresh: fetchTeams,
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: [
                SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    IconButton(
                      icon: Icon(Icons.add_circle, color: Colors.blue, size: 30),
                      onPressed: _showAddRoleModal,
                    ),
                  ],
                ),
                SizedBox(height: 20),
                if (isLoading)
                  Center(child: CircularProgressIndicator())
                else if (teams.isEmpty)
                  NoDataFoundScreen()
                else
                  Column(
                    children: teams.map((role) {
                      Map<String, dynamic> roleFields = {
                        'TeamName': role['teamName'],
                        '': role[''],
                        'Description': role['tmDescription'],
                        'CreatedAt': role['createdAt'],
                      };
                      return buildUserCard(
                        userFields: roleFields,
                        onEdit: () => _showEditTeamModal(role['teamId'], role['teamName'],role['tmDescription']),
                        onDelete: () => _confirmDeleteTeam(role['teamId']),
                        trailingIcon:
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            IconButton(onPressed: ()=>_showEditTeamModal(role['teamId'], role['teamName'],role['tmDescription']),
                                icon: Icon(Icons.edit,color: Colors.green,)),
                            IconButton(onPressed: ()=>_confirmDeleteTeam(role['teamId']),
                                icon: Icon(Icons.delete,color: Colors.red,)),
                            IconButton(
                                onPressed: () => _showTeamMembersModal(role['teamId']),
                                icon: Icon(
                                  Icons.visibility,
                                  color: Colors.blue,
                                )),
                          ],
                        ),
                      );
                    }).toList(),
                  )

              ],
            ),
          ),
        ),
      ),
    );
  }
}