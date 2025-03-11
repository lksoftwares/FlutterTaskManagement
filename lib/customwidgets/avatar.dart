import 'package:avatar_glow/avatar_glow.dart';
import 'package:flutter/material.dart';

class Avatar extends StatefulWidget {
  const Avatar({super.key});

  @override
  State<Avatar> createState() => _AvatarState();
}

class _AvatarState extends State<Avatar> {
  @override
  Widget build(BuildContext context) {
    return AvatarGlow(
      glowColor: Colors.green,
      duration: Duration(milliseconds: 2000),
      repeat: true,
      startDelay: Duration(milliseconds: 1000),
      child: Icon(
        Icons.mic,
        color: Color(0xFF005296),
        size: 40,
      ),
    );

  }
}
