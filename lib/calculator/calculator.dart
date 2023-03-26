import 'package:diet_designer/services/flutterfire.dart';
import 'package:diet_designer/login/login.dart';
import 'package:diet_designer/shared/shared.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

class Calculator extends StatefulWidget {
  const Calculator({super.key});

  @override
  State<Calculator> createState() => _CalculatorState();
}

class _CalculatorState extends State<Calculator> {
  final TextEditingController _ageFieldController = TextEditingController();
  final TextEditingController _heightFieldController = TextEditingController();
  final TextEditingController _weightFieldController = TextEditingController();
  String _gender = "woman";
  double _activity = 1;
  String _target = "reduce";

  @override
  Widget build(BuildContext context) {
    Row activitySlider = Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text("Activity:"),
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
    );

    Row genderRow = Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text("Gender:"),
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

    Row targetRow = Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text("Target:"),
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
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text("Calculator"),
        centerTitle: true,
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            children: [
              const Text("Enter your data:"),
              const SizedBox(height: 40),
              genderRow,
              const SizedBox(height: 20),
              TextInput(controller: _ageFieldController, labelText: "Age:"),
              const SizedBox(height: 20),
              TextInput(controller: _heightFieldController, labelText: "Height:"),
              const SizedBox(height: 20),
              TextInput(controller: _weightFieldController, labelText: "Weight:"),
              const SizedBox(height: 30),
              activitySlider,
              const SizedBox(height: 20),
              targetRow,
              const SizedBox(height: 40),
              FilledButton(
                onPressed: () {},
                child: const Text("Save"),
              ),
            ],
          ),
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
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(labelText),
        const SizedBox(width: 15),
        SizedBox(
          width: 200,
          child: TextField(
            controller: controller,
            decoration: const InputDecoration(border: UnderlineInputBorder()),
          ),
        )
      ],
    );
  }
}
