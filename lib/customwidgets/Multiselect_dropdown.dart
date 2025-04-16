import 'package:flutter/cupertino.dart';
import 'package:lktaskmanagementapp/packages/headerfiles.dart';


class MultiSelectDropdown extends StatelessWidget {
  final List<DropdownItem<String>> items;
  final MultiSelectController<String> controller;
  final String hintText;
  final bool enabled;
  final bool searchEnabled;
  final void Function(List<String>) onSelectionChange;
  final double width;

  const MultiSelectDropdown({
    Key? key,
    required this.items,
    required this.controller,
    required this.hintText,
    this.enabled = true,
    this.searchEnabled = true,
    required this.onSelectionChange,
     this.width = 200.0,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      child: MultiDropdown<String>(
        items: items,
        controller: controller,
        enabled: enabled,
        searchEnabled: searchEnabled,
        chipDecoration: const ChipDecoration(
          wrap: false,
          runSpacing: 4.0,
          spacing: 8.0,
        ),
        fieldDecoration: FieldDecoration(
          hintText: hintText,
          hintStyle: const TextStyle(color: Colors.black87),
          prefixIcon: const Icon(CupertinoIcons.arrow_2_circlepath),
          showClearIcon: false,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Colors.grey),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Colors.black87),
          ),
        ),

        dropdownItemDecoration: DropdownItemDecoration(
          selectedIcon: const Icon(Icons.check_box, color: Colors.green),
          disabledIcon: Icon(Icons.lock, color: Colors.grey.shade300),
        ),
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Please select at least one stage';
          }
          return null;
        },
        onSelectionChange: onSelectionChange,
      ),
    );
  }
}