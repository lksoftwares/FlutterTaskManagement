import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:lktaskmanagementapp/packages/headerfiles.dart';

class MenuRolePage extends StatefulWidget {
  @override
  _MenuRolePageState createState() => _MenuRolePageState();
}

class _MenuRolePageState extends State<MenuRolePage> {
  late Future<List<Menu>> menus;
  String? token;
  List<dynamic> roles = [];
  int? selectedRoleId;
  int? selectedPermissionId;
  int? selectedMenuId;
  List<Map<String, dynamic>> selectedPermissions = [];

  @override
  void initState() {
    super.initState();
    _clearRoleIdIfNeeded();
    menus = fetchMenus();
    _fetchRoles();
  }

  Future<void> _clearRoleIdIfNeeded() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove('selectedRoleId');
  }

  Future<void> _fetchRoles() async {
    final response = await new ApiService().request(
      method: 'GET',
      endpoint: 'Roles/GetAllRole',
    );

    if (response['statusCode'] == 200) {
      setState(() {
        roles = response['apiResponse'] ?? [];
      });
    } else {
      showToast(msg: response['message'] ?? 'Failed to fetch roles');
    }
  }

  Future<List<Menu>> fetchMenus() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    int? savedRoleId = prefs.getInt('selectedRoleId');
    print(savedRoleId);

    String endpoint = savedRoleId == null
        ? 'menus/getmenus'
        : 'menus/getmenus/$savedRoleId';

    final response = await new ApiService().request(
      method: 'GET',
      endpoint: endpoint,
    );

    if (response['statusCode'] == 200) {
      List<Menu> menuList = [];
      if (response['apiResponse'] != null) {
        for (var menu in response['apiResponse']) {
          menuList.add(Menu.fromJson(menu));
        }
      }
      return menuList;
    } else {
      String errorMessage = response['message'] ?? 'Failed to fetch menus';
      showToast(msg: errorMessage);
      throw Exception(errorMessage);

    }
  }

  Future<void> _sendPermissions() async {
    if (selectedPermissions.isEmpty) {
      showToast(
        msg: 'Select values from the dropdown before adding',
        backgroundColor: Colors.orange,
      );
      return;
    }
    final url = Uri.parse('${Config.apiUrl}RoleMenuPermission/AddMenuRolePermission');
    final body = jsonEncode(selectedPermissions);

    try {
      final response = await http.post(
        url,
        body: body,
        headers: {'Content-Type': 'application/json'},
      );
      print('Request Body: $body');
      if (response.statusCode == 200) {
        var responseBody = jsonDecode(response.body);
        String successMessage = responseBody['message'] ?? 'Permissions added successfully';

        showToast(
          msg: successMessage,
          backgroundColor: Colors.green,
        );
      } else {
        var responseBody = jsonDecode(response.body);
        String errorMessage = responseBody['message'] ?? 'Failed to add permissions';
        showToast(
          msg: errorMessage,
        );
      }
    } catch (e) {
      print("Error: $e");
      showToast(
        msg: 'Error: $e',
      );
    }
  }

  Future<void> resetPermissions() async {
    List<Menu>? menuList = await menus;
    setState(() {
      selectedPermissionId = null;
      selectedPermissions.clear();
      if (menuList != null) {
        for (var menu in menuList) {
          menu.roles.clear();
        }
      }
    });
    showToast(
      msg: 'Permissions reset successfully',
      backgroundColor: Colors.blueAccent,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: 'Menus',
        onLogout: () => AuthService.logout(context),
      ),
      body: Column(
        children: [
          SizedBox(height: 20),
          DropdownButtonFormField<int>(
            value: selectedRoleId,
            decoration: InputDecoration(
              labelText: 'Select Role',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              prefixIcon: Icon(Icons.group),
            ),
            items: roles.isNotEmpty
                ? roles.map<DropdownMenuItem<int>>((role) {
              return DropdownMenuItem<int>(
                value: role['roleId'],
                child: Text(role['roleName']),
              );
            }).toList()
                : [],
            onChanged: (value) async {
              setState(() {
                selectedRoleId = value;
              });
              SharedPreferences prefs = await SharedPreferences.getInstance();
              if (value != null) {
                await prefs.setInt('selectedRoleId', value);
              }
              menus = fetchMenus();
            },
            hint: Text('Select Role'),
          ),

          SizedBox(height: 40),
          Expanded(
            child: FutureBuilder<List<Menu>>(
              future: menus,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return Center(child: Text('No menus available.'));
                } else {
                  return ListView.builder(
                    itemCount: snapshot.data!.length,
                    itemBuilder: (context, index) {
                      return buildMenu(snapshot.data![index]);
                    },
                  );
                }
              },
            ),
          ),
          Row(
            children: [
              IconButton(
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        title: Text('Reset Permissions'),
                        content: Text('Are you sure you want to reset all permissions?'),
                        actions: <Widget>[
                          TextButton(
                            onPressed: () => Navigator.of(context).pop(),
                            child: Text('Cancel'),
                          ),
                          TextButton(
                            onPressed: () async {
                              Navigator.of(context).pop();
                              await menus.then((menuList) {
                                setState(() {
                                  selectedPermissionId = null;
                                  selectedPermissions.clear();
                                  for (var menu in menuList) {
                                    menu.roles.clear();
                                  }
                                });
                              });
                              Fluttertoast.showToast(
                                  msg: 'Permissions have been reset.',
                                  toastLength: Toast.LENGTH_SHORT,
                                  gravity: ToastGravity.BOTTOM,
                                  timeInSecForIosWeb: 1,
                                  backgroundColor: Colors.blueAccent,
                                  textColor: Colors.white,
                                  fontSize: 16.0
                              );
                            },
                            child: Text('Reset'),
                          ),
                        ],
                      );
                    },
                  );
                },
                icon: Icon(Icons.refresh, size: 40, color: Colors.orange),
              ),
              SizedBox(width: 245),
              IconButton(
                onPressed: _sendPermissions,
                icon: Icon(Icons.add, color: Colors.blueAccent, size: 40),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget buildMenu(Menu menu) {
    if (menu.subMenus.isEmpty || menu.subMenus.every((submenu) => submenu.menuName.isEmpty)) {
      return ListTile(
        title: Row(
          children: [
            Expanded(child: Text(menu.menuName)),
            SubmenuPermissionDropdown(
              menu: menu,
              onPermissionSelected: (permissionId) {
                setState(() {
                  selectedPermissionId = permissionId;
                });
              },
              onMenuSelected: (menuId) {
                setState(() {
                  selectedMenuId = menuId;
                  if (selectedRoleId != null && selectedPermissionId != null) {
                    selectedPermissions.add({
                      'roleId': selectedRoleId,
                      'menuId': selectedMenuId,
                      'permissionId': selectedPermissionId,
                    });
                  }
                });
              },
            ),
          ],
        ),
      );
    } else {
      return ExpansionTile(
        key: Key(menu.menuName),
        title: Text(menu.menuName),
        children: [
          ...menu.subMenus.map<Widget>((submenu) {
            return buildSubMenuWithPermission(submenu);
          }).toList(),
        ],
      );
    }
  }

  Widget buildSubMenuWithPermission(Menu submenu) {
    if (submenu.subMenus.isEmpty || submenu.subMenus.every((subSubMenu) => subSubMenu.menuName.isEmpty)) {
      return ListTile(
        title: Row(
          children: [
            Expanded(child: Text(submenu.menuName)),
            SubmenuPermissionDropdown(
              menu: submenu,
              onPermissionSelected: (permissionId) {
                setState(() {
                  selectedPermissionId = permissionId;
                });
              },
              onMenuSelected: (menuId) {
                setState(() {
                  selectedMenuId = menuId;
                  if (selectedRoleId != null && selectedPermissionId != null) {
                    selectedPermissions.add({
                      'roleId': selectedRoleId,
                      'menuId': selectedMenuId,
                      'permissionId': selectedPermissionId,
                    });
                  }
                });
              },
            ),
          ],
        ),
      );
    } else {
      return ExpansionTile(
        key: Key(submenu.menuName),
        title: Text(submenu.menuName),
        children: [
          ...submenu.subMenus.map<Widget>((subSubMenu) {
            return buildSubMenuWithPermission(subSubMenu);
          }).toList(),
        ],
      );
    }
  }
}

class Menu {
  final String menuName;
  final int menuID;
  final List<Role> roles;
  final List<Menu> subMenus;

  Menu({
    required this.menuName,
    required this.menuID,
    required this.roles,
    required this.subMenus,
  });

  factory Menu.fromJson(Map<String, dynamic> json) {
    var subMenusList = json['submenu'] as List? ?? [];
    List<Menu> subMenus = subMenusList.map((item) => Menu.fromJson(item)).toList();

    var rolesList = json['roles'] as List? ?? [];
    List<Role> roles = rolesList.map((item) => Role.fromJson(item)).toList();

    return Menu(
      menuName: json['menuName'] ?? '',
      menuID: json['menuID'] != null
          ? (json['menuID'] is int ? json['menuID'] : int.tryParse(json['menuID'].toString()) ?? 0)
          : 0,
      roles: roles,
      subMenus: subMenus,
    );
  }
}

class Role {
  final int roleId;
  final String roleName;
  final String permissionType;

  Role({required this.roleId, required this.roleName, required this.permissionType});

  factory Role.fromJson(Map<String, dynamic> json) {
    return Role(
      roleId: json['roleId'] is int ? json['roleId'] : 0,
      roleName: json['roleName'] ?? '',
      permissionType: json['permissionType'] ?? '',
    );
  }
}

class Permission {
  final String permissionType;
  final int permissionId;

  Permission({required this.permissionType, required this.permissionId});
}

class SubmenuPermissionDropdown extends StatefulWidget {
  final Menu menu;
  final Function(int) onPermissionSelected;
  final Function(int) onMenuSelected;

  const SubmenuPermissionDropdown({
    Key? key,
    required this.menu,
    required this.onPermissionSelected,
    required this.onMenuSelected,
  }) : super(key: key);

  @override
  _SubmenuPermissionDropdownState createState() =>
      _SubmenuPermissionDropdownState();
}

class _SubmenuPermissionDropdownState extends State<SubmenuPermissionDropdown> {
  String? selectedPermission;
  List<Permission> permissionTypes = [];

  @override
  void initState() {
    super.initState();
    fetchPermissionTypes();
  }

  Future<void> fetchPermissionTypes() async {
    try {
      final response = await http.get(
        Uri.parse('${Config.apiUrl}permission/getallpermission'),
      );

      if (response.statusCode == 200) {
        var data = json.decode(response.body);
        if (data['isSuccess']) {
          List<Permission> fetchedPermissions = [];
          var apiResponse = data['apiResponse'] as List;
          for (var permission in apiResponse) {
            fetchedPermissions.add(Permission(
              permissionType: permission['permissionType'] ?? 'Unknown',
              permissionId: permission['permissionId'] ?? 0,
            ));
          }

          setState(() {
            permissionTypes = fetchedPermissions;
            if (widget.menu.roles.isNotEmpty &&
                widget.menu.roles[0].permissionType.isNotEmpty) {
              selectedPermission = widget.menu.roles[0].permissionType;
            } else {
              selectedPermission = fetchedPermissions.isNotEmpty
                  ? fetchedPermissions[0].permissionType
                  : 'Unknown';
            }
          });
        }
      }
    } catch (e) {
      print("Error fetching permission types: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        DropdownButton<Permission>(
          value: selectedPermission == null
              ? null
              : permissionTypes.firstWhere(
                (permission) =>
            permission.permissionType == selectedPermission,
            orElse: () => permissionTypes.isNotEmpty
                ? permissionTypes[0]
                : Permission(permissionType: 'Select', permissionId: 0),
          ),
          hint: Text('Select'),
          onChanged: (Permission? newValue) {
            setState(() {
              if (newValue == null) {
                selectedPermission = null;
                widget.onPermissionSelected(0);
                widget.onMenuSelected(widget.menu.menuID);
              } else {
                selectedPermission = newValue.permissionType;
                widget.onPermissionSelected(newValue.permissionId);
                widget.onMenuSelected(widget.menu.menuID);
              }
            });
          },
          items: [
            DropdownMenuItem<Permission>(
              value: null,
              child: Text('Select'),
            ),
            ...permissionTypes.map<DropdownMenuItem<Permission>>((Permission permission) {
              return DropdownMenuItem<Permission>(
                value: permission,
                child: Text(permission.permissionType),
              );
            }).toList(),
          ],
        ),
      ],
    );
  }
}
