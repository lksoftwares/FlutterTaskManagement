import 'package:flutter/material.dart';

class LoadingButton extends StatelessWidget {
  final bool isLoading;
  final VoidCallback onPressed;
  final String label;
  final Color backgroundColor;
  final EdgeInsets padding;

  const LoadingButton({
    Key? key,
    required this.isLoading,
    required this.onPressed,
    required this.label,
    this.backgroundColor = Colors.green,
    this.padding = const EdgeInsets.symmetric(horizontal: 40, vertical: 12),
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: backgroundColor,
        padding: padding,
      ),
      onPressed: isLoading ? null : onPressed,
      child: isLoading
          ? SizedBox(
        height: 16,
        width: 16,
        child: CircularProgressIndicator(
          strokeWidth: 2,
          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
        ),
      )
          : Text(
        label,
        style: TextStyle(color: Colors.white),
      ),
    );
  }
}
