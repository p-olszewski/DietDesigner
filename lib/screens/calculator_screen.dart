import 'package:flutter/material.dart';

class CalculatorScreen extends StatefulWidget {
  const CalculatorScreen({super.key});

  @override
  State<CalculatorScreen> createState() => _CalculatorScreenState();
}

class _CalculatorScreenState extends State<CalculatorScreen> {
  final TextEditingController _ageFieldController = TextEditingController();
  final TextEditingController _heightFieldController = TextEditingController();
  final TextEditingController _weightFieldController = TextEditingController();
  String _gender = "woman";
  double _activity = 1;
  String _target = "reduce";

  @override
  Widget build(BuildContext context) {
    Padding activitySlider = Padding(
      padding: const EdgeInsets.symmetric(vertical: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text("Activity:", style: TextStyle(fontWeight: FontWeight.bold)),
          SizedBox(
            width: 250,
            child: Slider(
              value: _activity,
              onChanged: (value) => setState(() => _activity = value),
              divisions: 4,
              min: 1,
              max: 5,
              label: _activity.round().toString(),
            ),
          ),
        ],
      ),
    );

    Row genderRow = Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text("Gender:", style: TextStyle(fontWeight: FontWeight.bold)),
        Radio(
          value: 'woman',
          groupValue: _gender,
          onChanged: (value) => setState(() => _gender = value!),
        ),
        const Text("woman"),
        Radio(
          value: 'man',
          groupValue: _gender,
          onChanged: (value) => setState(() => _gender = value!),
        ),
        const Text("man"),
      ],
    );

    Padding targetRow = Padding(
      padding: const EdgeInsets.only(bottom: 40),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text("Target:", style: TextStyle(fontWeight: FontWeight.bold)),
          Radio(
            value: 'cut',
            groupValue: _target,
            onChanged: (value) => setState(() => _target = value!),
          ),
          const Text("cut"),
          Radio(
            value: 'stay',
            groupValue: _target,
            onChanged: (value) => setState(() => _target = value!),
          ),
          const Text("stay"),
          Radio(
            value: 'gain',
            groupValue: _target,
            onChanged: (value) => setState(() => _target = value!),
          ),
          const Text("gain"),
        ],
      ),
    );

    const headerText = Padding(
      padding: EdgeInsets.symmetric(vertical: 40),
      child: Text("Enter your data:", style: TextStyle(fontSize: 18)),
    );

    return Scaffold(
      appBar: AppBar(title: const Text("Calculator")),
      body: SingleChildScrollView(
        child: Column(
          children: [
            headerText,
            genderRow,
            TextInput(controller: _ageFieldController, labelText: "Age:"),
            TextInput(controller: _heightFieldController, labelText: "Height:"),
            TextInput(controller: _weightFieldController, labelText: "Weight:"),
            activitySlider,
            targetRow,
            FilledButton(
              onPressed: () {},
              child: const Text("Save"),
            ),
          ],
        ),
      ),
    );
  }
}

class TextInput extends StatelessWidget {
  const TextInput({
    super.key,
    required this.controller,
    required this.labelText,
  });

  final TextEditingController controller;
  final String labelText;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            labelText,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(width: 15),
          SizedBox(
            width: 200,
            child: TextField(
              controller: controller,
              decoration: const InputDecoration(border: UnderlineInputBorder()),
            ),
          )
        ],
      ),
    );
  }
}
