// import 'package:flutter/material.dart';
//
//
// class DropdownWidget extends StatelessWidget {
//   final List<String> items;
//   final String selectedValue;
//   final Function(String?) onChanged;
//
//   DropdownWidget({
//     required this.items,
//     required this.selectedValue,
//     required this.onChanged,
//   });
//   @override
//   Widget build(BuildContext context) {
//     return DropdownButton<String>(
//       value: selectedValue,
//       onChanged: onChanged,
//       items: items.map((String value) {
//         return DropdownMenuItem<String>(
//           value: value,
//           child: Text(value),
//         );
//       }).toList(),
//     );
//   }
// }
//
// class DropdownController extends StatefulWidget {
//   @override
//   _DropdownControllerState createState() => _DropdownControllerState();
// }
//
// class _DropdownControllerState extends State<DropdownController> {
//   String selectedItem = 'Item 1';
//
//   @override
//   Widget build(BuildContext context) {
//     List<String> dropdownItems = ['Item 1', 'Item 2', 'Item 3'];
//
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('Dropdown'),
//       ),
//       body: Center(
//         child: DropdownWidget(
//           items: dropdownItems,
//           selectedValue: selectedItem,
//           onChanged: (String? newValue) {
//             setState(() {
//               selectedItem = newValue!;
//             });
//           },
//         ),
//       ),
//     );
//   }
// }
//
// class Dropdown extends StatefulWidget {
//   const Dropdown({super.key});
//
//   @override
//   State<Dropdown> createState() => _DropdownState();
// }
// String selectedItems = 'Mango';
// class _DropdownState extends State<Dropdown> {
//   @override
//   Widget build(BuildContext context) {
//     List<String> fruits =['Mango', "apple" , "banana", "grapes"];
//     return Scaffold(
//       body: Center(
//         child: DropdownWidget(items: fruits, selectedValue: selectedItems, onChanged: (String? newValue){
//           setState(() {
//             selectedItems =newValue!;
//           });
//         }),
//       ),
//     );
//   }
// }
import 'package:flutter/material.dart';

class CustomDropdown<T extends Object> extends StatefulWidget {
  final List<T> options;
  final T? selectedOption;
  final String Function(T) displayValue;
  final void Function(T?) onChanged;
  final String labelText;
  final Icon? prefixIcon;
  final double? width;
  final double? minHeight;
  final double? maxHeight;

  const CustomDropdown({
    Key? key,
    required this.options,
    this.selectedOption,
    required this.displayValue,
    required this.onChanged,
    required this.labelText,
    this.prefixIcon,
    this.width,
    this.minHeight = 50,
    this.maxHeight = 200,
  }) : super(key: key);

  @override
  _CustomDropdownState<T> createState() => _CustomDropdownState<T>();
}

class _CustomDropdownState<T extends Object> extends State<CustomDropdown<T>> {
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  OverlayEntry? _overlayEntry;
  final LayerLink _layerLink = LayerLink();
  List<T> _filteredOptions = [];

  @override
  void initState() {
    super.initState();
    _controller.text = widget.selectedOption != null ? widget.displayValue(widget.selectedOption!) : '';
    _focusNode.addListener(_onFocusChange);
    _filteredOptions = widget.options;
  }

  @override
  void dispose() {
    _focusNode.removeListener(_onFocusChange);
    _focusNode.dispose();
    _controller.dispose();
    _overlayEntry?.remove();
    super.dispose();
  }

  void _onFocusChange() {
    if (_focusNode.hasFocus) {
      _showOverlay();
    } else {
      _hideOverlay();
    }
  }

  void _showOverlay() {
    _overlayEntry = _createOverlayEntry();
    Overlay.of(context).insert(_overlayEntry!);
  }

  void _hideOverlay() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }

  OverlayEntry _createOverlayEntry() {
    RenderBox renderBox = context.findRenderObject() as RenderBox;
    var size = renderBox.size;
    var offset = renderBox.localToGlobal(Offset.zero);
    double height = _filteredOptions.length * 55.0;
    height = height < widget.minHeight! ? widget.minHeight! : height;
    height = height > widget.maxHeight! ? widget.maxHeight! : height;

    return OverlayEntry(
      builder: (context) => Positioned(
        left: offset.dx,
        top: offset.dy + size.height + 5,
        width: widget.width ?? size.width,
        child: CompositedTransformFollower(
          link: _layerLink,
          showWhenUnlinked: false,
          offset: Offset(0.0, size.height + 5.0),
          child: Material(
            elevation: 4.0,
            child: Container(
              height: height,
              child: _filteredOptions.isEmpty
                  ? const SizedBox()
                  : ListView.builder(
                padding: EdgeInsets.zero,
                shrinkWrap: true,
                itemCount: _filteredOptions.length,
                itemBuilder: (context, index) {
                  final option = _filteredOptions[index];
                  return InkWell(
                    onTap: () {
                      widget.onChanged(option);
                      _controller.text = widget.displayValue(option);
                      _focusNode.unfocus();
                    },
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Text(widget.displayValue(option)),
                    ),
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return CompositedTransformTarget(
      link: _layerLink,
      child: GestureDetector(
        onTap: () {
          if (!_focusNode.hasFocus) {
            FocusScope.of(context).requestFocus(_focusNode);
          }
        },
        child: Container(
          width: widget.width,
          child: TextFormField(
            controller: _controller,
            focusNode: _focusNode,
            decoration: InputDecoration(
              labelText: widget.labelText,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              prefixIcon: widget.prefixIcon,
            ),
            onChanged: (value) {
              setState(() {
                _filteredOptions = widget.options
                    .where((option) =>
                    widget.displayValue(option).toLowerCase().contains(value.toLowerCase()))
                    .toList();

                if (value.isEmpty) {
                  widget.onChanged;
                  _filteredOptions = widget.options;
                  if (_overlayEntry != null) {
                    _overlayEntry?.remove();
                    _overlayEntry = _createOverlayEntry();
                    Overlay.of(context).insert(_overlayEntry!);
                  } else if (_focusNode.hasFocus) {
                    _showOverlay();
                  }
                } else {
                  if (_filteredOptions.isEmpty && value.isNotEmpty) {
                    _hideOverlay();
                  } else if (_overlayEntry == null && _focusNode.hasFocus) {
                    _showOverlay();
                  } else if (_overlayEntry != null) {
                    _overlayEntry?.remove();
                    _overlayEntry = _createOverlayEntry();
                    Overlay.of(context).insert(_overlayEntry!);
                  }
                }
              });
            },
          ),
        ),
      ),
    );
  }
}
