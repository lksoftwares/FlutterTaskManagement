import 'package:lktaskmanagementapp/packages/headerfiles.dart';

class MenuScreen extends StatefulWidget {
  const MenuScreen({super.key});

  @override
  State<MenuScreen> createState() => _MenuScreenState();
}

class _MenuScreenState extends State<MenuScreen> {
  List<Map<String, dynamic>> _menuData = [];
  List<Map<String, dynamic>> _filteredMenuData = [];
  List<Map<String, dynamic>> _allMenus = [];
  String? _selectedMenuName;
  int? _selectedParentMenuId;
  final TextEditingController _menuNameController = TextEditingController();
  final TextEditingController _pageNameController = TextEditingController();
  final TextEditingController _searchController = TextEditingController();
  int? _selectedMenuId;
  File? _selectedImage;
  bool isLoading = false;


  Future<void> _fetchMenuData() async {

    setState(() {
      isLoading = true;
    });
    final response = await new ApiService().request(
      method: 'get',
      endpoint: 'Menus/',
        tokenRequired: true

    );
    if (response['statusCode'] == 200 && response['isSuccess']) {
      setState(() {
        _menuData = List<Map<String, dynamic>>.from(response['apiResponse'].map((item) {
          return {
            'menuId': item['menuId'],
            'menuName': item['menuName'],
            'iconPath': item['iconPath'],
            'pageName': item['pageName'],
            'subMenus': item['subMenus'] ?? [],
          };
        }).toList());
        _filteredMenuData = List<Map<String, dynamic>>.from(_menuData);
        _allMenus = List<Map<String, dynamic>>.from(response['apiResponse']);
      });
    } else {
      showToast(
        msg: response['message'] ?? 'Failed to load menus',
      );
    }

    setState(() {
      isLoading = false;
    });
  }


  void _filterMenuData(String query) {
    final filteredMenus = _menuData.where((menu) {
      final menuName = menu['menuName'].toLowerCase();
      final searchQuery = query.toLowerCase();
      return menuName.contains(searchQuery);
    }).toList();

    setState(() {
      _filteredMenuData = filteredMenus;
    });
  }

  void _showMenuDialog({int? menuId, String? currentName, String? currentImage}) {
    _menuNameController.text = currentName ?? '';
    _pageNameController.text = '';
    _selectedMenuId = menuId;
    _selectedImage = null;
    _selectedMenuName = null;
    _selectedParentMenuId = 0;

    if (menuId != null) {
      final selectedMenu = _allMenus.firstWhere((menu) => menu['menuId'] == menuId);
      _selectedParentMenuId = selectedMenu['parentId'];

      _pageNameController.text = selectedMenu['pageName']?.isNotEmpty == true
          ? selectedMenu['pageName']!
          : '';

      if (_selectedParentMenuId != 0) {
        _selectedMenuName = _allMenus.firstWhere(
                (menu) => menu['menuId'] == _selectedParentMenuId)['menuName'];
      }
    }

    showCustomAlertDialog(
      context,
      title: menuId == null ? 'Add Menu' : 'Edit Menu',
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _menuNameController,
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Enter Menu Name',
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _pageNameController,
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Enter Page Name',
              ),
            ),
            const SizedBox(height: 8),
            CustomDropdown<String>(
              options: _allMenus.map((menu) => menu['menuName'] as String).toList(),
              selectedOption: _selectedMenuName,
              displayValue: (menu) => menu,
              onChanged: (String? newValue) {
                setState(() {
                  _selectedMenuName = newValue;

                  if (newValue == 'No Parent') {
                    _selectedParentMenuId = 0;
                  } else {
                    if (newValue != null) {
                      _selectedParentMenuId = _allMenus.firstWhere(
                              (menu) => menu['menuName'] == newValue)['menuId'];
                    }
                  }
                });
              },
              labelText: 'Select Parent Menu',
              prefixIcon: Icon(Icons.menu),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ElevatedButton.icon(
                  onPressed: _pickImage,
                  icon: Icon(Icons.image),
                  label: Text('Select Image'),
                ),
                const SizedBox(width: 8),
                if (_selectedImage != null)
                  Image.file(
                    _selectedImage!,
                    height: 55,
                    width: 55,
                    fit: BoxFit.cover,
                  )
                else if (currentImage != null)
                  Image.network(
                    currentImage,
                    height: 55,
                    width: 55,
                    fit: BoxFit.cover,
                  ),
              ],
            ),
          ],
        ),
      ),
      actions: [
        ElevatedButton(
          style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
          onPressed: () {
            final menuName = _menuNameController.text.trim();
            final pageName = _pageNameController.text.trim();

            if (menuName.isEmpty) {
              showToast(
                msg: 'Menu Name cannot be empty',
              );
              return;
            }
            if (menuId == null) {
              _addMenu(menuName, pageName, _selectedImage, _selectedParentMenuId);
            } else {
              _updateMenu(menuId!, menuName, pageName, _selectedImage, _selectedParentMenuId);
            }
          },
          child: Text(menuId == null ? 'Add' : 'Update', style: TextStyle(color: Colors.white)),
        ),
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
            _menuNameController.clear();
            _pageNameController.clear();
            setState(() {
              _selectedImage = null;
            });
          },
          child: Text('Cancel'),
        ),
      ],
      titleHeight: 70,
    );
  }


  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _selectedImage = File(pickedFile.path);
      });
    }
  }

  Future<void> _addMenu(String menuName, String pageName, File? imageFile, int? parentMenuId) async {
    try {
      Map<String, dynamic> body = {
        'menuName': menuName,
        'pageName': pageName.isNotEmpty ? pageName : '',
        'parentId': parentMenuId?.toString() ?? '',
      };

      Map<String, File> files = {};
      if (imageFile != null) {
        files['iconFile'] = imageFile;
      }
      final response = await ApiService().request(
        method: 'POST',
        endpoint: 'Menus/create',
        body: body,
        isMultipart: true,
        tokenRequired: true,
        files: files,
      );
      if (response['statusCode'] == 200 || response['statusCode'] == 201) {
        Navigator.of(context).pop();
        _fetchMenuData();
        showToast(
          msg: response['message'] ?? 'Menu added successfully',
          backgroundColor: Colors.green,
        );
      } else {
        showToast(
          msg: response['message'] ?? 'Failed to add menu',
        );
      }
    } catch (e) {
      showToast(msg: 'Error: $e');
    }
  }

  Future<void> _updateMenu(int menuId, String menuName, String pageName, File? imageFile, int? parentMenuId) async {
    try {
      Map<String, dynamic> body = {
        'menuId': menuId.toString(),
        'menuName': menuName,
        'pageName': pageName.isNotEmpty ? pageName : '',
        'parentId': parentMenuId?.toString() ?? '',
        'orderNo': '0',
        'updateFlag': 'true',
      };

      Map<String, File> files = {};
      if (imageFile != null) {
        files['iconFile'] = imageFile;
      }

      final response = await ApiService().request(
        method: 'POST',
        endpoint: 'Menus/update',
        body: body,
        isMultipart: true,
        files: files,
          tokenRequired: true

      );

      if (response['statusCode'] == 200 || response['statusCode'] == 201) {
        Navigator.of(context).pop();
        _fetchMenuData();
        showToast(
          msg: response['message'] ?? 'Menu updated successfully',
          backgroundColor: Colors.green,
        );
      } else {
        showToast(
          msg: response['message'] ?? 'Failed to update menu',
        );
      }
    } catch (e) {
      showToast(msg: 'Error: $e');
    }
  }


  void _showDeleteConfirmationDialog(int menuId) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Delete Menu'),
          content: Text('Are you sure you want to delete this menu?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                _deleteMenu(menuId);
                Navigator.of(context).pop();
              },
              child: Text('Delete'),
            ),
          ],
        );
      },
    );
  }
  Future<void> _deleteMenu(int menuId) async {
    final response = await ApiService().request(
      method: 'post',
      endpoint: 'Menus/delete/$menuId',
        tokenRequired: true

    );

    if (response['statusCode'] == 200) {
      _fetchMenuData();
      showToast(
        msg: response['message'] ?? 'Menu deleted successfully',
        backgroundColor: Colors.green,
      );
    } else {
      showToast(
        msg: response['message'] ?? 'Failed to delete menu',
      );
    }
  }


  @override
  void initState() {
    super.initState();
    _fetchMenuData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: 'Menus',
        onLogout: () => AuthService.logout(context),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: [
              SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    width: 280,
                    child: TextField(
                      controller: _searchController,
                      decoration: InputDecoration(
                        labelText: 'Search by MenuName',
                        prefixIcon: Icon(Icons.search),
                        border: OutlineInputBorder(),
                      ),
                      onChanged: (query) {
                        _filterMenuData(query);
                      },
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.add_circle, color: Colors.blue, size: 30),
                    onPressed: () => _showMenuDialog(),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              if (isLoading)
                Center(child: CircularProgressIndicator())
              else if (_filteredMenuData.isEmpty)
               NoDataFoundScreen()
                //Center(child: CircularProgressIndicator())
              else SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: DataTable(
                    columns: const [
                      DataColumn(label: Text('Icon', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold))),
                      DataColumn(label: Text('MenuName', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold))),
                      DataColumn(label: Text('Edit', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold))),
                      DataColumn(label: Text('Delete', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold))),
                    ],
                    rows: _filteredMenuData.map((item) {
                      return DataRow(cells: [
                        DataCell(
                          CircleAvatar(
                            radius: 20,
                            backgroundImage: item['iconPath'] != null
                                ? NetworkImage(item['iconPath'])
                                : null,
                            child: item['iconPath'] == null
                                ? Icon(Icons.image_not_supported, size: 24)
                                : null,
                          ),
                        ),
                        DataCell(Text(item['menuName'])),
                        DataCell(Row(
                          children: [
                            IconButton(
                              icon: Icon(Icons.edit, color: Colors.green),
                              onPressed: () => _showMenuDialog(
                                menuId: item['menuId'],
                                currentName: item['menuName'],
                                currentImage: item['iconPath'],
                              ),
                            ),
                          ],
                        )),
                        DataCell(Row(
                          children: [
                            IconButton(
                              icon: Icon(Icons.delete, color: Colors.red),
                              onPressed: () => _showDeleteConfirmationDialog(item['menuId']),
                            ),
                          ],
                        )),
                      ]);
                    }).toList(),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
