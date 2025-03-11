import 'package:flutter/material.dart';

class CustomTextField extends StatefulWidget {
  final TextEditingController controller;
  final String label;
  final String hintText;
  final bool obscureText;
  final TextInputType keyboardType;
  final double width;
  final Icon? prefixIcon;
  final Icon? suffixIcon;
  final VoidCallback? onSuffixIconPressed;

  CustomTextField({
    Key? key,
    required this.controller,
    required this.label,
    this.hintText = '',
    this.obscureText = false,
    this.keyboardType = TextInputType.text,
    this.width = 320.0,
    this.prefixIcon,
    this.suffixIcon,
    this.onSuffixIconPressed,
  }) : super(key: key);

  @override
  _CustomTextFieldState createState() => _CustomTextFieldState();
}

class _CustomTextFieldState extends State<CustomTextField> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Container(
        width: widget.width,
        child: TextField(
          controller: widget.controller,
          obscureText: widget.obscureText,
          keyboardType: widget.keyboardType,
          decoration: InputDecoration(
            labelText: widget.label,
            hintText: widget.hintText,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8.0),
            ),
            prefixIcon: widget.prefixIcon,
            suffixIcon: widget.suffixIcon != null
                ? IconButton(
              icon: widget.suffixIcon!,
              onPressed: widget.onSuffixIconPressed,
            )
                : null,
          ),
        ),
      ),
    );
  }
}
