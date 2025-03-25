import 'package:flutter/material.dart';

class CustomButton extends StatelessWidget {
  final String buttonText;
  final VoidCallback onPressed;
  final Color color;
  final double width;
  final double height;

  const CustomButton({
    Key? key,
    required this.buttonText,
    required this.onPressed,
    this.color = Colors.blue,
    this.width = double.infinity,
    this.height = 50.0,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
       backgroundColor: color,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        child: Text(
          buttonText,
          style: TextStyle(fontSize: 18, color: Colors.white),
        ),
      ),
    );
  }
}




class CustomIconButton extends StatefulWidget {
  final IconData icon;
  final Color color;
  final String badgeText;
  final VoidCallback onPressed;
  final Animation<Offset>? animation;

  CustomIconButton({
    required this.icon,
    required this.color,
    required this.badgeText,
    required this.onPressed,
    this.animation,  // Animation is now optional
  });

  @override
  _CustomIconButtonState createState() => _CustomIconButtonState();
}

class _CustomIconButtonState extends State<CustomIconButton> {
  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        widget.animation != null
            ? SlideTransition(
          position: widget.animation!,
          child: IconButton(
            icon: Icon(widget.icon, size: 25, color: widget.color),
            onPressed: widget.onPressed,
          ),
        )
            : IconButton(
          icon: Icon(widget.icon, size: 25, color: widget.color),
          onPressed: widget.onPressed,
        ),
        if (widget.badgeText.isNotEmpty)
          Positioned(
            top: 0,
            right: 0,
            child: Container(
              padding: EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: Colors.red,
                shape: BoxShape.circle,
              ),
              constraints: BoxConstraints(
                minWidth: 21,
                minHeight: 21,
              ),
              child: Center(
                child: Text(
                  widget.badgeText,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ),
      ],
    );
  }
}
