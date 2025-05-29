
import 'package:lktaskmanagementapp/packages/headerfiles.dart';

class BranchScreen extends StatefulWidget {
  const BranchScreen({super.key});

  @override
  State<BranchScreen> createState() => _BranchScreenState();
}

class _BranchScreenState extends State<BranchScreen> {

  List<Map<String, dynamic>> branches = [];
  String? selectedBranchName;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    fetchBranch();
  }

  Future<void> fetchBranch() async {
    setState(() {
      isLoading = true;
    });

    final response = await new ApiService().request(
      method: 'get',
      endpoint: 'branch/',
    );
    print('Response: $response');
    if (response['statusCode'] == 200 && response['apiResponse'] != null) {
      setState(() {
        branches = List<Map<String, dynamic>>.from(
          response['apiResponse'].map((role) => {
            'branchId': role['branchId'] ?? 0,
            'branchName': role['branchName'] ?? 'Unknown branchName',
            'branchDesc': role['branchDesc'] ?? 'Unknown branchdesc',
            'createdAt': role['createdAt'] ?? '',
            'updatedAt': role['updatedAt'] ?? '',
          }),
        );
      });
    } else {
      showToast(msg: response['message']);
    }
    setState(() {
      isLoading = false;
    });
  }

  Future<void> _addBranch(String branchName,String branchDesc) async {

    final response = await new ApiService().request(
      method: 'post',
      endpoint: 'branch/create',
      body: {
        'branchName': branchName,
        'branchDesc': branchDesc,
      },
    );

    if (response.isNotEmpty && response['statusCode'] == 200) {
      fetchBranch();
      showToast(
        msg: response['message'] ?? 'Branch added successfully',
        backgroundColor: Colors.green,
      );
      Navigator.pop(context);
    } else {
      showToast(
        msg: response['message'] ?? 'Failed to add Branch',
      );
    }
  }

  void _showAddBranchModal() {
    String branchName = '';
    String branchDesc = '';

    InputDecoration nameInputDecoration = InputDecoration(
      labelText: 'Branch Name',
      border: OutlineInputBorder(),
    );

    InputDecoration descInputDecoration = InputDecoration(
      labelText: 'Branch Description',
      border: OutlineInputBorder(),
    );

    showCustomAlertDialog(
      context,
      title: 'Add Branch',
      content: Padding(
        padding: const EdgeInsets.all(15.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              onChanged: (value) => branchName = value,
              decoration: nameInputDecoration,
            ),
            SizedBox(height: 15),
            TextField(
              onChanged: (value) => branchDesc = value,
              decoration: descInputDecoration,
              maxLines: 4,
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
            if (branchName.isEmpty) {
              showToast(msg: 'Please fill the Branch name');
            } else {
              _addBranch(branchName, branchDesc);
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


  void _confirmDeleteBranch(int branchId) {
    showCustomAlertDialog(
        context,
        title: 'Delete Branch',
        content: Text('Are you sure you want to delete this branch?'),
        actions: [

          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            onPressed: () {
              _deleteBranch(branchId);
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

  Future<void> _deleteBranch(int branchId) async {
    final response = await new ApiService().request(
        method: 'post',
        endpoint: 'branch/delete/$branchId'
    );
    if (response['statusCode'] == 200) {
      String message = response['message'] ?? 'Branch deleted successfully';
      showToast(msg: message, backgroundColor: Colors.green);
      fetchBranch();
    } else {
      String message = response['message'] ?? 'Failed to delete branch';
      showToast(msg: message);
    }
  }

  Future<void> _updateBranch(int branchId, String branchName, String branchDesc) async {

    final response = await new ApiService().request(
        method: 'post',
        endpoint: 'branch/update',
        body: {
          'branchId': branchId,
          'branchName': branchName,
          'branchDesc': branchDesc,
          'updateFlag': true,
        },
    );

    print('Update Response: $response');

    if (response.isNotEmpty && response['statusCode'] == 200) {
      fetchBranch();
      showToast(
        msg: response['message'] ?? 'Branch updated successfully',
        backgroundColor: Colors.green,
      );
      Navigator.pop(context);
    } else {
      showToast(
        msg: response['message'] ?? 'Failed to update branch',
      );
    }
  }


  void _showEditBranchModal(int branchId, String currentBranchName,String currentBranchDesc) {
    TextEditingController _branchNameController = TextEditingController(text: currentBranchName);
    TextEditingController _branchDescController = TextEditingController(text: currentBranchDesc);

    showCustomAlertDialog(
      context,
      title: 'Edit Branch',
      content: StatefulBuilder(
        builder: (context, setState) {
          return Padding(
            padding: const EdgeInsets.all(15.0),
            child: Column(
              children: [
                CustomTextField(
                  controller: _branchNameController,
                 label: "Branch Name",
                  hintText: "Enter Branch Name",
                ),
                SizedBox(height: 15),
                CustomTextField(
                  controller: _branchDescController,
                 label: "Branch Desc",
                  hintText: "Enter Branch Desc",
                  maxLines: 4,
                ),
                SizedBox(height: 15),
              ],
            ),
          );
        },
      ),
      actions: [
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.green,
          ),
          onPressed: () {
            if (_branchNameController.text.isEmpty) {
              showToast(msg: 'Please enter a branch name');
            } else {
              _updateBranch(branchId, _branchNameController.text,_branchDescController.text);
            }
          },
          child: Text(
            'Update',
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

  List<Map<String, dynamic>> getFilteredData() {
    return branches.where((role) {
      bool matchesRoleName = true;
      if (selectedBranchName != null && selectedBranchName!.isNotEmpty) {
        matchesRoleName = role['roleName'] == selectedBranchName;
      }
      return matchesRoleName;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: 'Branches',
        onLogout: () => AuthService.logout(context),
      ),
      body: RefreshIndicator(
        onRefresh: fetchBranch,
        child: SingleChildScrollView(
          child: StatefulBuilder(
              builder: (context, setState) {

                return Column(
                  children: [
                    SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        // Autocomplete<String>(
                        //   optionsBuilder: (TextEditingValue textEditingValue) {
                        //     return branches
                        //         .where((role) => role['roleName']!
                        //         .toLowerCase()
                        //         .contains(textEditingValue.text.toLowerCase()))
                        //         .map((role) => role['roleName'] as String)
                        //         .toList();
                        //   },
                        //   onSelected: (String roleName) {
                        //     setState(() {
                        //       selectedBranchName = roleName;
                        //     });
                        //     fetchBranch();
                        //   },
                        //   fieldViewBuilder: (context, controller, focusNode, onFieldSubmitted) {
                        //     return Container(
                        //       width: 280,
                        //       child: TextField(
                        //         controller: controller,
                        //         focusNode: focusNode,
                        //         decoration: InputDecoration(
                        //           labelText: 'Select Role',
                        //           border: OutlineInputBorder(
                        //             borderRadius: BorderRadius.circular(10),
                        //           ),
                        //           prefixIcon: Icon(Icons.person),
                        //         ),
                        //         onChanged: (value) {
                        //           if (value.isEmpty) {
                        //             setState(() {
                        //               selectedBranchName = null;
                        //             });
                        //             fetchBranch();
                        //           }
                        //         },
                        //       ),
                        //     );
                        //   },
                        // ),
                        IconButton(
                          icon: Icon(Icons.add_circle, color: Colors.blue, size: 30),
                          onPressed: _showAddBranchModal,
                        ),
                      ],
                    ),
                    SizedBox(height: 20),
                    if (isLoading)
                      Center(child: CircularProgressIndicator())
                    else if (branches.isEmpty)
                      NoDataFoundScreen()
                    else
                      Column(
                        children: getFilteredData().map((branch) {
                          Map<String, dynamic> branchFields = {
                            'Branch Name': branch['branchName'] ,
                            '': branch[''] ,
                            'Branch Desc': branch['branchDesc'] ,
                            'CreatedAt': branch['createdAt'] ,
                          };

                          return buildUserCard(
                            userFields: {
                              'Branch Name': branch['branchName'] ,
                              '': branch[''] ,
                              'Branch Desc': branch['branchDesc'] ,
                              'CreatedAt': branch['createdAt'] ,
                            },
                            onEdit: () => _showEditBranchModal(branch['branchId'], branch['branchName'],branch['branchDesc']),
                            onDelete: () => _confirmDeleteBranch(branch['branchId']),
                            trailingIcon:
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                IconButton(onPressed: ()=>_showEditBranchModal(branch['branchId'], branch['branchName'],branch['branchDesc']),
                                    icon: Icon(Icons.edit,color: Colors.green,)),
                                IconButton(onPressed: ()=>_confirmDeleteBranch(branch['branchId']),
                                    icon: Icon(Icons.delete,color: Colors.red,)),
                              ],
                            ),
                          );
                        }).toList(),
                      )
                  ],
                );
              }
          ),
        ),
      ),
    );
  }
}
