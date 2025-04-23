// import 'package:flutter/material.dart';
//
// import '../packages/headerfiles.dart';
//
// class FilterDialog extends StatelessWidget {
//   final List<String> taskStages;
//   final Function(List<String>) onStageSelected;
//   final Function(DateTimeRange?) onDateRangeSelected;
//   final Function(String) onUserSelected;
//   final List<Map<String, String>> users;
//   final DateTime? fromDate;
//   final DateTime? toDate;
//   final MultiSelectController<String> controller;
// final bool showStageDropdown;
// final bool showDatePicker;
// final bool showUserAutocomplete;
//
//   const FilterDialog({
//     Key? key,
//     required this.taskStages,
//     required this.onStageSelected,
//     required this.onDateRangeSelected,
//     required this.onUserSelected,
//     required this.users,
//     this.fromDate,
//     this.toDate,
//     required this.controller,
// this.showStageDropdown = true,
// this.showDatePicker = true,
// this.showUserAutocomplete = true,
//   }) : super(key: key);
//
//   @override
//   Widget build(BuildContext context) {
//     List<DropdownItem<String>> stageItems = taskStages
//         .map((stage) => DropdownItem(label: stage, value: stage))
//         .toList();
//
//     return  Column(
//         mainAxisSize: MainAxisSize.min,
//         children: [
//           Padding(
//             padding: const EdgeInsets.all(15.0),
//             child: Row(
//               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//               children: [
//                 MultiSelectDropdown(
//                   width: 275,
//                   items: stageItems,
//                   controller: controller, // Pass controller here
//                   hintText: 'Select Task Stage',
//                   onSelectionChange: (selectedItems) {
//                     onStageSelected(selectedItems);
//                   },
//                 ),
//                 IconButton(
//                   icon: Icon(Icons.date_range, size: 30, color: Colors.blue),
//                   onPressed: () async {
//                     final pickedDateRange = await showDateRangePicker(
//                       context: context,
//                       firstDate: DateTime(2025, DateTime.february),
//                       lastDate: DateTime(2025, DateTime.december),
//                       initialDateRange: fromDate != null && toDate != null
//                           ? DateTimeRange(start: fromDate!, end: toDate!)
//                           : null,
//                     );
//
//                     onDateRangeSelected(pickedDateRange);
//                   },
//                 ),
//                 SizedBox(height: 10),
//               ],
//             ),
//           ),
//           Autocomplete<String>(
//             optionsBuilder: (TextEditingValue textEditingValue) {
//               return users
//                   .where((user) => user['userName']!
//                   .toLowerCase()
//                   .contains(textEditingValue.text.toLowerCase()))
//                   .map((user) => user['userName'] as String)
//                   .toList();
//             },
//             onSelected: (String userName) {
//               onUserSelected(userName);
//             },
//             fieldViewBuilder: (context, controller, focusNode, onFieldSubmitted) {
//               return Container(
//                 width: 320,
//                 child: TextField(
//                   controller: controller,
//                   focusNode: focusNode,
//                   decoration: InputDecoration(
//                     labelText: 'Select User',
//                     border: OutlineInputBorder(
//                       borderRadius: BorderRadius.circular(10),
//                     ),
//                     prefixIcon: Icon(Icons.person),
//                   ),
//                   onChanged: (value) {
//                     if (value.isEmpty) {
//                       onUserSelected('');
//                     }
//                   },
//                 ),
//               );
//             },
//           ),
//         ],
//       );
//
//   }
// }
import 'package:flutter/material.dart';
import '../packages/headerfiles.dart'; // Replace with actual header if needed

class FilterDialog extends StatelessWidget {
  final List<String> taskStages;
  final Function(List<String>) onStageSelected;
  final Function(DateTimeRange?) onDateRangeSelected;
  final Function(String) onUserSelected;
  final List<Map<String, String>> users;
  final DateTime? fromDate;
  final DateTime? toDate;
  final MultiSelectController<String> controller;

  // Visibility flags
  final bool showStageDropdown;
  final bool showDatePicker;
  final bool showUserAutocomplete;

  const FilterDialog({
    Key? key,
    required this.taskStages,
    required this.onStageSelected,
    required this.onDateRangeSelected,
    required this.onUserSelected,
    required this.users,
    this.fromDate,
    this.toDate,
    required this.controller,
    this.showStageDropdown = true,
    this.showDatePicker = true,
    this.showUserAutocomplete = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    List<DropdownItem<String>> stageItems = taskStages
        .map((stage) => DropdownItem(label: stage, value: stage))
        .toList();

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Padding(
          padding: const EdgeInsets.all(15.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              if (showStageDropdown)
                MultiSelectDropdown(
                  width: 275,
                  items: stageItems,
                  controller: controller,
                  hintText: 'Select Task Stage',
                  onSelectionChange: (selectedItems) {
                    onStageSelected(selectedItems);
                  },
                ),
              if (showDatePicker)
                IconButton(
                  icon: Icon(Icons.date_range, size: 30, color: Colors.blue),
                  onPressed: () async {
                    final pickedDateRange = await showDateRangePicker(
                      context: context,
                      firstDate: DateTime(2025, DateTime.february),
                      lastDate: DateTime(2025, DateTime.december),
                      initialDateRange: fromDate != null && toDate != null
                          ? DateTimeRange(start: fromDate!, end: toDate!)
                          : null,
                    );

                    onDateRangeSelected(pickedDateRange);
                  },
                ),
              SizedBox(height: 10),
            ],
          ),
        ),
        if (showUserAutocomplete)
          Autocomplete<String>(
            optionsBuilder: (TextEditingValue textEditingValue) {
              return users
                  .where((user) => user['userName']!
                  .toLowerCase()
                  .contains(textEditingValue.text.toLowerCase()))
                  .map((user) => user['userName'] as String)
                  .toList();
            },
            onSelected: (String userName) {
              onUserSelected(userName);
            },
            fieldViewBuilder:
                (context, controller, focusNode, onFieldSubmitted) {
              return Container(
                width: 320,
                child: TextField(
                  controller: controller,
                  focusNode: focusNode,
                  decoration: InputDecoration(
                    labelText: 'Select User',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    prefixIcon: Icon(Icons.person),
                  ),
                  onChanged: (value) {
                    if (value.isEmpty) {
                      onUserSelected('');
                    }
                  },
                ),
              );
            },
          ),
      ],
    );
  }
}
