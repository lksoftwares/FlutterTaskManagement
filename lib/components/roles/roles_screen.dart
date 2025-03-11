//
// import 'package:flutter/material.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'package:syncfusion_flutter_datagrid/datagrid.dart';
// import 'package:syncfusion_flutter_core/theme.dart';
// import '../widgetmethods/alert_widget.dart';
// import '../widgetmethods/api_method.dart';
// import '../widgetmethods/appbar_method.dart';
// import '../widgetmethods/datagrid_class.dart';
// import '../widgetmethods/datagrid_controller.dart';
// import '../widgetmethods/logout _method.dart';
// import '../widgetmethods/no_data_found.dart';
// import '../widgetmethods/toast_method.dart';
//
// class RolesPage extends StatefulWidget {
//   const RolesPage({super.key});
//
//   @override
//   State<RolesPage> createState() => _RolesPageState();
// }
//
// class _RolesPageState extends State<RolesPage> {
//   List<Map<String, dynamic>> roles = [];
//   String? token;
//
//   TextEditingController _searchController = TextEditingController();
//   DataGridController _dataGridController = DataGridController();
//   bool isLoading = false;
//
//   List<ColumnConfig> getColumnsConfig() {
//     return [
//       ColumnConfig(
//         columnName: 'roleName ',
//         labelText: 'Role Name',
//         visible: true,
//       ),
//       ColumnConfig(
//         columnName: 'roleStatus ',
//         labelText: 'Role Status ',
//         visible: true,
//         columnWidthMode: ColumnWidthMode.auto,
//       ),
//       ColumnConfig(
//         columnName: 'createdAt ',
//         labelText: 'Created At',
//         visible: true,
//         columnWidthMode: ColumnWidthMode.auto,
//       ),
//       ColumnConfig(
//         columnName: 'updatedAt ',
//         labelText: 'Updated At ',
//         visible: true,
//         columnWidthMode: ColumnWidthMode.auto,
//       ),
//     ];
//   }
//
//   @override
//   void initState() {
//     super.initState();
//     _getToken().then((_) {
//       fetchRoles();
//     });
//   }
//
//   Future<void> _getToken() async {
//     SharedPreferences prefs = await SharedPreferences.getInstance();
//     setState(() {
//       token = prefs.getString('token');
//     });
//   }
//
//   Future<void> fetchRoles() async {
//     setState(() {
//       isLoading = true;
//     });
//
//     final response = await new ApiService().request(
//       method: 'get',
//       endpoint: 'Roles/GetAllRole',
//     );
//     print('Response: $response');
//     if (response['statusCode'] == 200 && response['apiResponse'] != null) {
//       setState(() {
//         roles = List<Map<String, dynamic>>.from(
//           response['apiResponse'].map((role) => {
//             'roleId': role['roleId'] ?? 0,
//             'roleName': role['roleName'] ?? 'Unknown Role',
//             'roleStatus': role['roleStatus'] ?? false,
//             'createdAt': role['createdAt'] ?? '',
//             'updatedAt': role['updatedAt'] ?? '',
//           }),
//         );
//       });
//     } else {
//       showToast(msg: response['message'] ?? 'Failed to load roles');
//     }
//     setState(() {
//       isLoading = false;
//     });
//   }
//
//   Future<void> _addRole(String roleName) async {
//     final response =await new ApiService().request(
//       method: 'post',
//       endpoint: 'Roles/SaveRole',
//       body: {
//         'roleName': roleName,
//       },
//     );
//
//     if (response.isNotEmpty && response['statusCode'] == 200) {
//       fetchRoles();
//       showToast(
//         msg: response['message'] ?? 'Role added successfully',
//         backgroundColor: Colors.green,
//       );
//       Navigator.pop(context);
//     }  else {
//       showToast(
//         msg: response['message'] ?? 'Failed to add role',
//       );
//     }
//   }
//
//   void _showAddRoleModal() {
//     String roleName = '';
//     InputDecoration inputDecoration = InputDecoration(
//       labelText: 'Role Name',
//       border: OutlineInputBorder(),
//     );
//
//     showCustomAlertDialog(
//       context,
//       title: 'Add Role',
//       content: TextField(
//         onChanged: (value) => roleName = value,
//         decoration: inputDecoration,
//       ),
//       actions: [
//         TextButton(
//           onPressed: () => Navigator.pop(context),
//           child: Text('Cancel'),
//         ),
//         ElevatedButton(
//           onPressed: () {
//             if (roleName.isEmpty) {
//               showToast(msg: 'Please fill in the role name');
//             } else {
//               _addRole(roleName);
//             }
//           },
//           child: Text('Add'),
//         ),
//       ],
//     );
//   }
//
//   void _confirmDeleteRole(int roleId) {
//     showCustomAlertDialog(
//       context,
//       title: 'Delete Role',
//       content: Text('Are you sure you want to delete this role?'),
//       actions: [
//         TextButton(
//           onPressed: () => Navigator.pop(context),
//           child: Text('Cancel'),
//         ),
//         ElevatedButton(
//           onPressed: () {
//             _deleteRole(roleId);
//             Navigator.pop(context);
//           },
//           child: Text('Delete'),
//         ),
//       ],
//     );
//   }
//
//   Future<void> _deleteRole(int roleId) async {
//
//     final response = await new ApiService().request(
//       method: 'delete',
//       endpoint: 'Roles/deleteRole/$roleId',
//     );
//     if (response['statusCode'] == 200) {
//       String message = response['message'] ?? 'Role deleted successfully';
//       showToast(msg: message, backgroundColor: Colors.green);
//       fetchRoles();
//     } else {
//       String message = response['message'] ?? 'Failed to delete role';
//       showToast(msg: message);
//     }
//   }
//
//   Future<void> _updateRole(int roleId, String roleName) async {
//     final response = await new ApiService().request(
//       method: 'post',
//       endpoint: 'Roles/SaveRole',
//       body: {
//         'roleId': roleId,
//         'roleName': roleName,
//         'updateFlag': true,
//       },
//     );
//
//     print('Update Response: $response');
//
//     if (response.isNotEmpty && response['statusCode'] == 200) {
//       fetchRoles();
//       showToast(
//         msg: response['message'] ?? 'Role updated successfully',
//         backgroundColor: Colors.green,
//       );
//       Navigator.pop(context);
//     } else {
//       showToast(
//         msg: response['message'] ?? 'Failed to update role',
//       );
//     }
//   }
//
//
//   void _showEditRoleModal(int roleId, String currentRoleName) {
//     TextEditingController _roleController =
//     TextEditingController(text: currentRoleName);
//
//     showCustomAlertDialog(
//       context,
//       title: 'Edit Role',
//       content: TextField(
//         controller: _roleController,
//         decoration: InputDecoration(
//           labelText: 'Role Name',
//           border: OutlineInputBorder(),
//         ),
//       ),
//       actions: [
//         TextButton(
//           onPressed: () => Navigator.pop(context),
//           child: Text('Cancel'),
//         ),
//         ElevatedButton(
//           onPressed: () {
//             if (_roleController.text.isEmpty) {
//               showToast(msg: 'Please enter a role name');
//             } else {
//               _updateRole(roleId, _roleController.text);
//             }
//           },
//           child: Text('Update'),
//         ),
//       ],
//     );
//   }
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: CustomAppBar(
//         title: 'Roles',
//         onLogout: () => AuthService.logout(context),
//       ),
//       body: SingleChildScrollView(
//         child: Padding(
//           padding: const EdgeInsets.all(8.0),
//           child: Column(
//             children: [
//               SizedBox(height: 20),
//               Row(
//                 mainAxisAlignment: MainAxisAlignment.end,
//                 children: [
//                   IconButton(
//                     icon: Icon(Icons.add, color: Colors.blue, size: 30),
//                     onPressed: _showAddRoleModal,
//                   ),
//                 ],
//               ),
//               SizedBox(height: 20),
//               if (isLoading)
//                 Center(child: CircularProgressIndicator())
//               else if (roles.isEmpty)
//                 NoDataFoundScreen()
//               else
//                 Column(
//                   children: [
//                     Container(
//                       height: 550,
//                       child: SfDataGridTheme(
//                         data: SfDataGridThemeData(
//                           headerHoverColor: Colors.yellow,
//                           rowHoverColor: Colors.blueAccent[100],
//                           gridLineColor: Colors.black,
//                           gridLineStrokeWidth: 1.0,
//                           headerColor: Colors.blueAccent[100],
//                         ),
//                         child: SfDataGrid(
//                           headerGridLinesVisibility: GridLinesVisibility.both,
//                           gridLinesVisibility: GridLinesVisibility.both,
//                           allowSorting: true,
//                           source: RoleDataSource(
//                             roles: roles,
//                             onEditRole: _showEditRoleModal,
//                             onDeleteRole: _confirmDeleteRole,
//                           ),
//                           columns: buildDataGridColumns(getColumnsConfig(),showDeleteColumn: true,showEditColumn: true),
//                           controller: _dataGridController,
//                         ),
//                       ),
//                     ),
//                   ],
//                 ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }
//
// class RoleDataSource extends DataGridSource {
//   final List<Map<String, dynamic>> roles;
//   final Function(int, String) onEditRole;
//   final Function(int roleId) onDeleteRole;
//
//   RoleDataSource({
//     required this.roles,
//     required this.onEditRole,
//     required this.onDeleteRole,
//   });
//
//   @override
//   List<DataGridRow> get rows => roles.map<DataGridRow>((role) {
//     return DataGridRow(cells: [
//       DataGridCell<String>(columnName: 'roleName', value: role['roleName']),
//       DataGridCell<int>(columnName: 'roleId', value: role['roleId']),
//       DataGridCell<bool>(columnName: 'roleStatus', value: role['roleStatus']),
//       DataGridCell<String>(columnName: 'createdAt', value: role['createdAt']),
//       DataGridCell<String>(columnName: 'updatedAt', value: role['updatedAt']),
//     ]);
//   }).toList();
//
//   @override
//   DataGridRowAdapter buildRow(DataGridRow row) {
//     final roleId = row.getCells()[1].value as int;
//     final roleName = row.getCells()[0].value as String;
//     final roleStatus = row.getCells()[2].value as bool;
//     final createdAt = row.getCells()[3].value as String;
//     final updatedAt = row.getCells()[4].value as String;
//
//     return DataGridRowAdapter(cells: [
//       Container(
//         padding: EdgeInsets.all(8.0),
//         alignment: Alignment.centerLeft,
//         child: Text(roleName),
//       ),
//       Container(
//         padding: EdgeInsets.all(8.0),
//         alignment: Alignment.centerLeft,
//         child: roleStatus
//             ? Icon(Icons.check_circle, color: Colors.green)
//             : Icon(Icons.cancel, color: Colors.red),
//       ),
//       Container(
//         padding: EdgeInsets.all(8.0),
//         alignment: Alignment.centerLeft,
//         child: Text(createdAt),
//       ),
//       Container(
//         padding: EdgeInsets.all(8.0),
//         alignment: Alignment.centerLeft,
//         child: Text(updatedAt),
//       ),
//       Container(
//         alignment: Alignment.center,
//         child: IconButton(
//           icon: Icon(Icons.edit, color: Colors.green),
//           onPressed: () {
//              onEditRole(roleId, roleName);
//           },
//         ),
//       ),
//       Container(
//         alignment: Alignment.center,
//         child: IconButton(
//           icon: Icon(Icons.delete, color: Colors.red),
//           onPressed: () {
//              onDeleteRole(roleId);
//           },
//         ),
//       ),
//     ]);
//   }
// }
import 'package:lktaskmanagementapp/packages/headerfiles.dart';

class RolesPage extends StatefulWidget {
  const RolesPage({super.key});

  @override
  State<RolesPage> createState() => _RolesPageState();
}

class _RolesPageState extends State<RolesPage> {
  List<Map<String, dynamic>> roles = [];
  String? token;

  bool isLoading = false;


  @override
  void initState() {
    super.initState();
    _getToken().then((_) {
      fetchRoles();
    });
  }

  Future<void> _getToken() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      token = prefs.getString('token');
    });
  }

  Future<void> fetchRoles() async {
    setState(() {
      isLoading = true;
    });

    final response = await new ApiService().request(
      method: 'get',
      endpoint: 'Roles/GetAllRole',
    );
    print('Response: $response');
    if (response['statusCode'] == 200 && response['apiResponse'] != null) {
      setState(() {
        roles = List<Map<String, dynamic>>.from(
          response['apiResponse'].map((role) => {
            'roleId': role['roleId'] ?? 0,
            'roleName': role['roleName'] ?? 'Unknown Role',
            'roleStatus': role['roleStatus'] ?? false,
            'createdAt': role['createdAt'] ?? '',
            'updatedAt': role['updatedAt'] ?? '',
          }),
        );
      });
    } else {
      showToast(msg: response['message'] ?? 'Failed to load roles');
    }
    setState(() {
      isLoading = false;
    });
  }

  Future<void> _addRole(String roleName) async {
    final response = await new ApiService().request(
      method: 'post',
      endpoint: 'Roles/AddRole',
      body: {
        'roleName': roleName,
      },
    );

    if (response.isNotEmpty && response['statusCode'] == 200) {
      fetchRoles();
      showToast(
        msg: response['message'] ?? 'Role added successfully',
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
    String roleName = '';
    InputDecoration inputDecoration = InputDecoration(
      labelText: 'Role Name',
      border: OutlineInputBorder(),
    );

    showCustomAlertDialog(
      context,
      title: 'Add Role',
      content: TextField(
        onChanged: (value) => roleName = value,
        decoration: inputDecoration,
      ),
      actions: [

        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.green,
          ),
          onPressed: () {
            if (roleName.isEmpty) {
              showToast(msg: 'Please fill in the role name');
            } else {
              _addRole(roleName);
            }
          },
          child: Text('Add',style: TextStyle(color: Colors.white),),
        ),
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text('Cancel'),
        ),
      ],
      titleHeight: 65,
    );
  }

  void _confirmDeleteRole(int roleId) {
    showCustomAlertDialog(
      context,
      title: 'Delete Role',
      content: Text('Are you sure you want to delete this role?'),
      actions: [

        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.red,
          ),
          onPressed: () {
            _deleteRole(roleId);
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

  Future<void> _deleteRole(int roleId) async {

    final response = await new ApiService().request(
      method: 'delete',
      endpoint: 'Roles/deleteRole/$roleId',
    );
    if (response['statusCode'] == 200) {
      String message = response['message'] ?? 'Role deleted successfully';
      showToast(msg: message, backgroundColor: Colors.green);
      fetchRoles();
    } else {
      String message = response['message'] ?? 'Failed to delete role';
      showToast(msg: message);
    }
  }

  Future<void> _updateRole(int roleId, String roleName) async {
    final response = await new ApiService().request(
      method: 'post',
      endpoint: 'Roles/EditRole',
      body: {
        'roleId': roleId,
        'roleName': roleName,
        'updateFlag': true,
      },
    );

    print('Update Response: $response');

    if (response.isNotEmpty && response['statusCode'] == 200) {
      fetchRoles();
      showToast(
        msg: response['message'] ?? 'Role updated successfully',
        backgroundColor: Colors.green,
      );
      Navigator.pop(context);
    } else {
      showToast(
        msg: response['message'] ?? 'Failed to update role',
      );
    }
  }


  void _showEditRoleModal(int roleId, String currentRoleName) {
    TextEditingController _roleController =
    TextEditingController(text: currentRoleName);

    showCustomAlertDialog(
      context,
      title: 'Edit Role',
      content: TextField(
        controller: _roleController,
        decoration: InputDecoration(
          labelText: 'Role Name',
          border: OutlineInputBorder(),
        ),
      ),
      actions: [

        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.green,
          ),
          onPressed: () {
            if (_roleController.text.isEmpty) {
              showToast(msg: 'Please enter a role name');
            } else {
              _updateRole(roleId, _roleController.text);
            }
          },
          child: Text('Update',style: TextStyle(color: Colors.white),),
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
        title: 'Roles',
        onLogout: () => AuthService.logout(context),
      ),
      body: RefreshIndicator(
        onRefresh: fetchRoles,
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
                else if (roles.isEmpty)
                  NoDataFoundScreen()
                else
                  Column(
                    children: roles.map((role) {
                      Map<String, dynamic> roleFields = {
                        'RoleName': role['roleName'],
                        '': role[''],
                        'Status': role['roleStatus'],
                        'CreatedAt': role['createdAt'],
                      };

                      return buildUserCard(
                        userFields: roleFields,
                        onEdit: () => _showEditRoleModal(role['roleId'], role['roleName']),
                        onDelete: () => _confirmDeleteRole(role['roleId']),
                        trailingIcon:
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            IconButton(onPressed: ()=>_showEditRoleModal(role['roleId'], role['roleName']),
                                icon: Icon(Icons.edit,color: Colors.green,)),
                            IconButton(onPressed: ()=>_confirmDeleteRole(role['roleId']),
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