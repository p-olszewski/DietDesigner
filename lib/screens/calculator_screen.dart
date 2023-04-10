import 'package:diet_designer/models/user.dart';
import 'package:diet_designer/services/firestore.dart';
import 'package:diet_designer/shared/shared.dart';
import 'package:diet_designer/utils/enums.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class CalculatorScreen extends StatefulWidget {
  const CalculatorScreen({super.key});

  @override
  State<CalculatorScreen> createState() => _CalculatorScreenState();
}

class _CalculatorScreenState extends State<CalculatorScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _ageFieldController = TextEditingController();
  final TextEditingController _heightFieldController = TextEditingController();
  final TextEditingController _weightFieldController = TextEditingController();
  String _gender = Gender.male.name;
  double _activity = 3;
  String _target = Target.stay.name;
  double _mealsNumber = 5;

  @override
  void dispose() {
    _ageFieldController.dispose();
    _heightFieldController.dispose();
    _weightFieldController.dispose();
    super.dispose();
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      final age = int.tryParse(_ageFieldController.text);
      final height = int.tryParse(_heightFieldController.text);
      final weight = double.tryParse(_weightFieldController.text);

      final user = User(
        gender: _gender,
        age: age,
        height: height,
        weight: weight,
        activity: _activity.round(),
        target: _target,
        mealsNumber: _mealsNumber.round(),
      );
      user.calculateCaloriesAndMacronutrients();

      try {
        updateUserData(user);
        PopupMessenger.info("Data saved successfully");
      } catch (e) {
        PopupMessenger.error(e.toString());
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Calculator")),
      body: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 40),
                child: Text("Enter your data:", style: TextStyle(fontSize: 18)),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text("Gender:", style: TextStyle(fontWeight: FontWeight.bold)),
                  Radio(
                    value: Gender.female.name,
                    groupValue: _gender,
                    onChanged: (value) => setState(() => _gender = value!),
                  ),
                  Text(Gender.female.name),
                  Radio(
                    value: Gender.male.name,
                    groupValue: _gender,
                    onChanged: (value) => setState(() => _gender = value!),
                  ),
                  Text(Gender.male.name),
                ],
              ),
              _NumberInputField(
                controller: _ageFieldController,
                type: NumberInputFieldType.age,
              ),
              _NumberInputField(
                controller: _heightFieldController,
                type: NumberInputFieldType.height,
              ),
              _NumberInputField(
                controller: _weightFieldController,
                type: NumberInputFieldType.weight,
                isDecimal: true,
              ),
              Padding(
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
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text("Target:", style: TextStyle(fontWeight: FontWeight.bold)),
                  Radio(
                    value: Target.cut.name,
                    groupValue: _target,
                    onChanged: (value) => setState(() => _target = value!),
                  ),
                  Text(Target.cut.toString().split('.').last),
                  Radio(
                    value: Target.stay.name,
                    groupValue: _target,
                    onChanged: (value) => setState(() => _target = value!),
                  ),
                  Text(Target.stay.name),
                  Radio(
                    value: Target.gain.name,
                    groupValue: _target,
                    onChanged: (value) => setState(() => _target = value!),
                  ),
                  Text(Target.gain.name),
                ],
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text("Meals number:", style: TextStyle(fontWeight: FontWeight.bold)),
                    SizedBox(
                      width: 250,
                      child: Slider(
                        value: _mealsNumber,
                        onChanged: (value) => setState(() => _mealsNumber = value),
                        divisions: 4,
                        min: 2,
                        max: 6,
                        label: _mealsNumber.round().toString(),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              FilledButton(
                onPressed: () => _submitForm(),
                child: const Text("Save"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NumberInputField extends StatelessWidget {
  const _NumberInputField({
    required this.controller,
    required this.type,
    bool? isDecimal,
  });

  final TextEditingController controller;
  final NumberInputFieldType type;
  final bool isDecimal = false;

  @override
  Widget build(BuildContext context) {
    String labelText = '';
    String hintText = '';
    String? Function(String?) validator = (value) => null;

    switch (type) {
      case NumberInputFieldType.age:
        labelText = 'Age:';
        hintText = 'years';
        validator = _ageValidator;
        break;
      case NumberInputFieldType.weight:
        labelText = 'Weight:';
        hintText = 'kg';
        validator = _weightValidator;
        break;
      case NumberInputFieldType.height:
        labelText = 'Height:';
        hintText = 'cm';
        validator = _heightValidator;
        break;
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            labelText,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(width: 20),
          SizedBox(
            width: 200,
            child: TextFormField(
              controller: controller,
              decoration: InputDecoration(
                border: const UnderlineInputBorder(),
                hintText: hintText,
                hintStyle: TextStyle(fontSize: Theme.of(context).textTheme.labelLarge!.fontSize),
              ),
              keyboardType: isDecimal ? const TextInputType.numberWithOptions(decimal: true) : TextInputType.number,
              inputFormatters:
                  isDecimal ? [FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}'))] : [FilteringTextInputFormatter.digitsOnly],
              validator: validator,
            ),
          ),
        ],
      ),
    );
  }

  String? _ageValidator(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter your age';
    }
    final age = int.tryParse(value);
    if (age == null || age < 0 || age > 120) {
      return 'Please enter a valid age';
    }
    return null;
  }

  String? _heightValidator(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter your height';
    }
    final height = int.tryParse(value);
    if (height == null || height < 0 || height > 300) {
      return 'Please enter a valid height';
    }
    return null;
  }

  String? _weightValidator(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter your weight';
    }
    final weight = int.tryParse(value);
    if (weight == null || weight < 0 || weight > 500) {
      return 'Please enter a valid weight';
    }
    return null;
  }
}
