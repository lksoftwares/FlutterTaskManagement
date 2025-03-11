import 'package:flutter/material.dart';

class MyRadioButton extends StatelessWidget {
  final String title;
  final int value;
  final int groupValue;
  final Function(int?) onChanged;

  const MyRadioButton({
    required this.title,
    required this.value,
    required this.groupValue,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return RadioListTile<int>(
      title: Text(title),
      value: value,
      groupValue: groupValue,
      onChanged: onChanged,
    );
  }
}

class RadiobuttonController extends StatefulWidget {
  @override
  _RadiobuttonControllerState createState() => _RadiobuttonControllerState();
}

class _RadiobuttonControllerState extends State<RadiobuttonController> {
  int _selectedValue = 1;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: Text('Radio Button')),
        body: Column(
          children: [
            MyRadioButton(
              title: 'Option 1',
              value: 1,
              groupValue: _selectedValue,
              onChanged: (int? value) {
                setState(() {
                  _selectedValue = value!;
                });
              },
            ),
            MyRadioButton(
              title: 'Option 2',
              value: 2,
              groupValue: _selectedValue,
              onChanged: (int? value) {
                setState(() {
                  _selectedValue = value!;
                });
              },
            ),
            MyRadioButton(
              title: 'Option 3',
              value: 3,
              groupValue: _selectedValue,
              onChanged: (int? value) {
                setState(() {
                  _selectedValue = value!;
                });
              },
            ),
            Text('Selected Value: $_selectedValue'),
          ],
        ),
      ),
    );
  }
}
