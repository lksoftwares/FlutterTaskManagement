import 'package:lktaskmanagementapp/packages/headerfiles.dart';

class CustomCheckbox extends StatelessWidget {
  final bool value;
  final ValueChanged<bool?> onChanged;
  final String label;

  const CustomCheckbox({
    Key? key,
    required this.value,
    required this.onChanged,
    required this.label,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Checkbox(
          value: value,
          onChanged: onChanged,
        ),
        Text(
          label,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
      ],
    );
  }
}

class CheckboxForm extends StatefulWidget {
  @override
  _CheckboxFormState createState() => _CheckboxFormState();
}

class _CheckboxFormState extends State<CheckboxForm> {
  bool isChecked1 = false;
  bool isChecked2 = false;
  bool isChecked3 = false;

  void printCheckboxValues() {
    print('Checkbox 1: $isChecked1');
    print('Checkbox 2: $isChecked2');
    print('Checkbox 3: $isChecked3');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(' Checkboxes'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CustomCheckbox(
              value: isChecked1,
              onChanged: (value) {
                setState(() {
                  isChecked1 = value ?? false;
                });
              },
              label: 'Checkbox 1',
            ),
            CustomCheckbox(
              value: isChecked2,
              onChanged: (value) {
                setState(() {
                  isChecked2 = value ?? false;
                });
              },
              label: 'Checkbox 2',
            ),
            CustomCheckbox(
              value: isChecked3,
              onChanged: (value) {
                setState(() {
                  isChecked3 = value ?? false;
                });
              },
              label: 'Checkbox 3',
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: printCheckboxValues,
              child: const Text('Print Checkbox Values'),
            ),
          ],
        ),
      ),
    );
  }
}

class CheckboxController extends StatefulWidget {
  const CheckboxController({super.key});

  @override
  State<CheckboxController> createState() => _CheckboxControllerState();
}

class _CheckboxControllerState extends State<CheckboxController> {
  bool isChecked5 =false;
  bool isChecked6 = false;
  bool isChecked7 =false;

  void printCheckboxValues() {
    print('Checkbox 1: $isChecked5');
    print('Checkbox 2: $isChecked6');
    print('Checkbox 3: $isChecked7');
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [

            CustomCheckbox(value: isChecked5, onChanged: (value){
              setState(() {
                isChecked5 = value ?? false;
              });
            }, label: "checkbox5"),
            CustomCheckbox(value: isChecked6, onChanged: (value){
              setState(() {
                isChecked6=value?? false;
              });
            }, label: "checkbox6"),
            CustomCheckbox(value: isChecked7, onChanged: (value){
              setState(() {
                isChecked7=value??false;
              });
            }, label: "checkbox7"),
            ElevatedButton(
              onPressed: printCheckboxValues,
              child: const Text('Print Checkbox Values'),
            ),
          ],
        ),
      ),
    );
  }
}
