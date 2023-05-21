import 'package:diet_designer/models/user.dart';
import 'package:diet_designer/providers/auth_provider.dart';
import 'package:diet_designer/providers/user_data_provider.dart';
import 'package:diet_designer/services/firestore_service.dart';
import 'package:diet_designer/shared/shared.dart';
import 'package:diet_designer/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

class AccountEditScreen extends StatefulWidget {
  const AccountEditScreen({super.key});

  @override
  State<AccountEditScreen> createState() => _AccountEditScreenState();
}

class _AccountEditScreenState extends State<AccountEditScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _firstnameController = TextEditingController();
  final TextEditingController _lastnameController = TextEditingController();
  final TextEditingController _ageFieldController = TextEditingController();
  final TextEditingController _heightFieldController = TextEditingController();
  final TextEditingController _weightFieldController = TextEditingController();
  String _gender = Gender.male.name;
  int _activity = 3;
  String _target = targetList[1];
  double _mealsNumber = 5;

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      final uid = context.read<AuthProvider>().uid!;
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
        updateUserData(uid, user);
        PopupMessenger.info("Data saved successfully");
      } catch (e) {
        PopupMessenger.error(e.toString());
      } finally {
        Navigator.pushReplacementNamed(context, '/home');
      }
    }
  }

  Future<void> _checkUserData() async {
    final uid = context.read<AuthProvider>().uid!;
    final hasData = await checkUserHasCalculatedData(uid);
    if (hasData) {
      final user = await getUserData(uid);
      if (user == null) return;

      setState(() {
        _firstnameController.text = user.firstname!;
        _lastnameController.text = user.lastname!;
        _ageFieldController.text = user.age.toString();
        _heightFieldController.text = user.height.toString();
        _weightFieldController.text = user.weight.toString();
        _gender = user.gender!;
        _activity = user.activity!;
        _target = user.target!;
        _mealsNumber = user.mealsNumber!.toDouble();
      });
    }
  }

  @override
  void dispose() {
    _ageFieldController.dispose();
    _heightFieldController.dispose();
    _weightFieldController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _checkUserData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Enter your data"),
      ),
      body: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40),
            child: Column(
              children: [
                const SizedBox(height: 40),
                _InputRow(
                  label: 'Firstname:',
                  input: TextField(
                    controller: _firstnameController,
                    decoration: inputDecoration(context),
                  ),
                ),
                _InputRow(
                  label: 'Lastname:',
                  input: TextField(
                    controller: _lastnameController,
                    decoration: inputDecoration(context),
                  ),
                ),
                const _Divider(),
                _InputRow(
                  label: 'Gender:',
                  input: Row(
                    children: [
                      Radio(
                        value: Gender.female.name,
                        groupValue: _gender,
                        onChanged: (value) => setState(() => _gender = value!),
                      ),
                      Text(Gender.female.name),
                      const SizedBox(width: 10),
                      Radio(
                        value: Gender.male.name,
                        groupValue: _gender,
                        onChanged: (value) => setState(() => _gender = value!),
                      ),
                      Text(Gender.male.name),
                    ],
                  ),
                ),
                _InputRow(
                  label: 'Age (y):',
                  input: _NumberInputField(
                    controller: _ageFieldController,
                    type: NumberInputFieldType.age,
                  ),
                ),
                _InputRow(
                  label: 'Height (cm):',
                  input: _NumberInputField(
                    controller: _heightFieldController,
                    type: NumberInputFieldType.height,
                  ),
                ),
                _InputRow(
                  label: 'Weight (kg):',
                  input: _NumberInputField(
                    controller: _weightFieldController,
                    type: NumberInputFieldType.weight,
                    isDecimal: true,
                  ),
                ),
                const _Divider(),
                _InputRow(
                  label: 'Activity:',
                  input: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    child: DropdownButton(
                      value: _activity,
                      onChanged: (value) => setState(() => _activity = value!.round()),
                      items: const [
                        DropdownMenuItem(
                          value: 1,
                          child: Text(
                            '1 - Sedentary lifestyle',
                            style: TextStyle(fontSize: 14),
                          ),
                        ),
                        DropdownMenuItem(
                          value: 2,
                          child: Text(
                            '2 - Lightly active',
                            style: TextStyle(fontSize: 14),
                          ),
                        ),
                        DropdownMenuItem(
                          value: 3,
                          child: Text(
                            '3 - Moderately active',
                            style: TextStyle(fontSize: 14),
                          ),
                        ),
                        DropdownMenuItem(
                          value: 4,
                          child: Text(
                            '4 - Very active',
                            style: TextStyle(fontSize: 14),
                          ),
                        ),
                        DropdownMenuItem(
                          value: 5,
                          child: Text(
                            '5 - Extra active',
                            style: TextStyle(fontSize: 14),
                          ),
                        ),
                      ],
                      underline: const SizedBox(height: 0),
                      isExpanded: true,
                    ),
                  ),
                ),
                _InputRow(
                  label: 'Target:',
                  input: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    child: DropdownButton(
                      value: _target,
                      onChanged: (value) => setState(() => _target = value!),
                      items: [
                        DropdownMenuItem(
                          value: Target.cut.name,
                          child: const Text(
                            'cut - lose weight',
                            style: TextStyle(fontSize: 14),
                          ),
                        ),
                        DropdownMenuItem(
                          value: Target.stay.name,
                          child: const Text(
                            'stay - maintain weight',
                            style: TextStyle(fontSize: 14),
                          ),
                        ),
                        DropdownMenuItem(
                          value: Target.gain.name,
                          child: const Text(
                            'gain - increase in weight',
                            style: TextStyle(fontSize: 14),
                          ),
                        ),
                      ],
                      underline: const SizedBox(height: 0),
                      isExpanded: true,
                    ),
                  ),
                ),
                _InputRow(
                  label: 'Meals number:',
                  input: Row(
                    children: [
                      Slider(
                        value: _mealsNumber,
                        onChanged: (value) => setState(() => _mealsNumber = value),
                        divisions: 3,
                        min: 3,
                        max: 6,
                      ),
                      Text(_mealsNumber.round().toString()),
                    ],
                  ),
                ),
                const SizedBox(height: 40),
                SizedBox(
                  width: 70,
                  height: 40,
                  child: FilledButton(
                    onPressed: () async {
                      _submitForm();
                      final updatedUser = await getUserData(context.read<AuthProvider>().uid!);
                      if (updatedUser == null) return;
                      if (!mounted) return;
                      context.read<UserDataProvider>().setUser(updatedUser);
                    },
                    child: const Text("Save"),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _Divider extends StatelessWidget {
  const _Divider();

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 16),
      width: 100,
      height: 1,
      color: Colors.grey.shade200,
    );
  }
}

class _InputRow extends StatelessWidget {
  const _InputRow({
    required this.label,
    required this.input,
  });
  final String label;
  final Widget input;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Flexible(
              flex: 1,
              fit: FlexFit.tight,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 10),
                    child: Text(
                      label.toUpperCase(),
                      style: Theme.of(context).textTheme.labelMedium!.copyWith(color: Colors.grey),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 20),
            Flexible(
              flex: 2,
              fit: FlexFit.tight,
              child: Container(
                height: 54,
                decoration: input is Row
                    ? null
                    : BoxDecoration(
                        color: Colors.white,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.5),
                            spreadRadius: 1,
                            blurRadius: 2,
                            offset: const Offset(0, 1),
                          ),
                        ],
                        borderRadius: BorderRadius.circular(4),
                      ),
                child: input,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
      ],
    );
  }
}

class _NumberInputField extends StatelessWidget {
  const _NumberInputField({
    required this.controller,
    required this.type,
    this.isDecimal = false,
  });

  final TextEditingController controller;
  final NumberInputFieldType type;
  final bool isDecimal;

  @override
  Widget build(BuildContext context) {
    String? Function(String?) validator = (value) => null;

    switch (type) {
      case NumberInputFieldType.age:
        validator = _ageValidator;
        break;
      case NumberInputFieldType.weight:
        validator = _weightValidator;
        break;
      case NumberInputFieldType.height:
        validator = _heightValidator;
        break;
    }

    return TextFormField(
      controller: controller,
      decoration: inputDecoration(context),
      keyboardType: isDecimal ? const TextInputType.numberWithOptions(decimal: true) : TextInputType.number,
      inputFormatters:
          isDecimal ? [FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}'))] : [FilteringTextInputFormatter.digitsOnly],
      validator: validator,
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
    final weight = double.tryParse(value);
    if (weight == null || weight < 0 || weight > 500) {
      return 'Please enter a valid weight';
    }
    return null;
  }
}

InputDecoration inputDecoration(BuildContext context) {
  return InputDecoration(
    focusedBorder: OutlineInputBorder(
      borderSide: BorderSide(color: Theme.of(context).colorScheme.primary),
    ),
    enabledBorder: const OutlineInputBorder(
      borderSide: BorderSide(color: Colors.transparent),
    ),
  );
}

Map<String, int> activityMap = {
  '1. Negligible - No exercise, sedentary work, school': 1,
  '2. Very low - Exercise once a week, light work': 2,
  '3. Moderate - Exercise twice a week (moderate intensity)': 3,
  '4. High - Heavy training several times a week': 4,
  '5. Very high - At least 4 intense workouts per week, physical work': 5,
};

List<String> targetList = [
  Target.cut.name,
  Target.stay.name,
  Target.gain.name,
];
