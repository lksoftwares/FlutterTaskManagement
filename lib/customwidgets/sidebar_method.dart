import 'package:flutter/material.dart';

Widget buildListTile(IconData icon, String title, String route, BuildContext context) {
  return ListTile(
    leading: Icon(icon, color: Colors.black),
    title: Text(
      title,
      style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold,fontSize: 17),
    ),
    onTap: () {
      Navigator.pushNamed(context, route);
    },
  );
}
