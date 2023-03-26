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
    return Scaffold(
      appBar: AppBar(
        title: const Text("DietDesigner"),
        centerTitle: true,
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            onPressed: () async {
              bool shouldRedirect = await signOut();
              if (shouldRedirect) {
                if (!mounted) return;
                Fluttertoast.showToast(msg: "Logged out");
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const Login(),
                  ),
                );
              }
            },
            icon: const Icon(Icons.logout),
          )
        ],
      ),
      body: Center(
        child: Column(
          children: [
            const SizedBox(height: 40),
            const Text("Enter your data:"),
            const SizedBox(height: 40),
            Row(
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
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text("Age:"),
                const SizedBox(width: 15),
                SizedBox(
                  width: 200,
                  child: TextField(
                    controller: _ageFieldController,
                    decoration: const InputDecoration(border: UnderlineInputBorder()),
                  ),
                )
              ],
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text("Height:"),
                const SizedBox(width: 15),
                SizedBox(
                  width: 200,
                  child: TextField(
                    controller: _heightFieldController,
                    decoration: const InputDecoration(border: UnderlineInputBorder()),
                  ),
                )
              ],
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text("Weight:"),
                const SizedBox(width: 15),
                SizedBox(
                  width: 200,
                  child: TextField(
                    controller: _weightFieldController,
                    decoration: const InputDecoration(border: UnderlineInputBorder()),
                  ),
                )
              ],
            ),
            const SizedBox(height: 30),
            Row(
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
            ),
            const SizedBox(height: 20),
            Row(
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
            ),
            const SizedBox(height: 40),
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
