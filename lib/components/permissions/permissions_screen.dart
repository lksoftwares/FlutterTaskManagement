
import 'package:lktaskmanagementapp/packages/headerfiles.dart';
class PermissionsScreen extends StatefulWidget {
  const PermissionsScreen({super.key});

  @override
  State<PermissionsScreen> createState() => _PermissionsScreenState();
}

class _PermissionsScreenState extends State<PermissionsScreen> {
  List<Map<String, dynamic>> permissions = [];
  bool isLoading = false;


  @override
  void initState() {
    super.initState();
    fetchpermissions();

  }
  Future<void> fetchpermissions() async {


    final response = await new ApiService().request(
      method: 'get',
      endpoint: 'permission/',
        tokenRequired: true

    );

    if (response['statusCode'] == 200 && response['apiResponse'] != null) {
      setState(() {
        permissions = List<Map<String, dynamic>>.from(
          response['apiResponse'].map((member) => {
            'permissionId': member['permissionId'] ?? 0,
            'permissionType': member['permissionType'] ?? "Unknown permission",
            'createdAt': member['createdAt'] ?? '',

          }),
        );
      });
    } else {
      showToast(msg: response['message'] ?? 'Failed to load permissions');
    }

    setState(() {
      isLoading = false;
    });
  }


  Future<void> _addPermissions(String permissionType) async {
    final response = await new ApiService().request(
      method: 'post',
      endpoint: 'permission/create',
      tokenRequired: true,
      body: {
        'permissionType': permissionType,
      },
    );

    if (response.isNotEmpty && response['statusCode'] == 200) {
      fetchpermissions();
      showToast(
        msg: response['message'] ?? 'permission added successfully',
        backgroundColor: Colors.green,
      );
      Navigator.pop(context);
    }  else {
      showToast(
        msg: response['message'] ?? 'Failed to add permission',
      );
    }
  }

  void _showAddPermissionModal() {
    String permissionType = '';

    InputDecoration inputDecoration = InputDecoration(
      labelText: 'Permission Name',
      border: OutlineInputBorder(),
    );

    showCustomAlertDialog(
      context,
      title: 'Add Permission',
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            onChanged: (value) => permissionType = value,
            decoration: inputDecoration,
          ),
          SizedBox(height: 10),

        ],
      ),
      actions: [

        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.green,
          ),
          onPressed: () {
            if (permissionType.isEmpty) {
              showToast(msg: 'Please fill permissionType');
            } else {
              _addPermissions(permissionType);
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
isFullScreen: false
    );
  }


  void _confirmDeletePermission(int permissionId) {
    showCustomAlertDialog(
      context,
      title: 'Delete Permission',
      content: Text('Are you sure you want to delete this Permission?'),
      actions: [

        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.red,
          ),
          onPressed: () {
            _deletePermission(permissionId);
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

  Future<void> _deletePermission(int permissionId) async {

    final response = await new ApiService().request(
      method: 'post',
      endpoint: 'permission/delete/$permissionId',
        tokenRequired: true

    );
    if (response['statusCode'] == 200) {
      String message = response['message'] ?? 'Permission deleted successfully';
      showToast(msg: message, backgroundColor: Colors.green);
      fetchpermissions();
    } else {
      String message = response['message'] ?? 'Failed to delete Permission';
      showToast(msg: message);
    }
  }

  Future<void> _updateTeamPermissiom(int permissionId, String permissionType) async {
    final response = await new ApiService().request(
      method: 'post',
      endpoint: 'permission/update',
      tokenRequired: true,
      body: {
        'permissionId': permissionId,
        'permissionType': permissionType,
        'updateFlag': true,
      },
    );

    print('Update Response: $response');

    if (response.isNotEmpty && response['statusCode'] == 200) {
      fetchpermissions();
      showToast(
        msg: response['message'] ?? 'Permission updated successfully',
        backgroundColor: Colors.green,
      );
      Navigator.pop(context);
    } else {
      showToast(
        msg: response['message'] ?? 'Failed to update Permission',
      );
    }
  }


  void _showEditPermissionModal(int permissionId, String currentpermissionType) {
    TextEditingController _permissionController = TextEditingController(text: currentpermissionType);

    showCustomAlertDialog(
      context,
      title: 'Edit Permission',
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _permissionController,
            decoration: InputDecoration(
              labelText: 'Team Name',
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
            if (_permissionController.text.isEmpty ) {
              showToast(msg: 'Please fill in both fields');
            } else {
              _updateTeamPermissiom(permissionId, _permissionController.text);
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
        isFullScreen: false

    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: 'Permissions',
        onLogout: () => AuthService.logout(context),
      ),
      body: RefreshIndicator(
        onRefresh: fetchpermissions,
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
                      onPressed: _showAddPermissionModal,
                    ),
                  ],
                ),
                SizedBox(height: 20),
                if (isLoading)
                  Center(child: CircularProgressIndicator())
                else if (permissions.isEmpty)
                  NoDataFoundScreen()
                else
                  Column(
                    children: permissions.map((perm) {
                      Map<String, dynamic> permFields = {
                        'PermissionType': perm['permissionType'],
                        '': perm[''],
                        'CreatedAt': perm['createdAt'],
                      };
                      return buildUserCard(
                        userFields: permFields,
                        onEdit: () => _showEditPermissionModal(perm['permissionId'], perm['permissionType']),
                        onDelete: () => _confirmDeletePermission(perm['permissionId']),
                        trailingIcon:
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            IconButton(onPressed: ()=>_showEditPermissionModal(perm['permissionId'], perm['permissionType']),
                                icon: Icon(Icons.edit,color: Colors.green,)),
                            IconButton(onPressed: ()=>_confirmDeletePermission(perm['permissionId']),
                                icon: Icon(Icons.delete,color: Colors.red,)),

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