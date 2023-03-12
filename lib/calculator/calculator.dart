import 'package:diet_designer/services/flutterfire.dart';
import 'package:diet_designer/login/login_page.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

class Calculator extends StatefulWidget {
  const Calculator({super.key});

  @override
  State<Calculator> createState() => _CalculatorState();
}

class _CalculatorState extends State<Calculator> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("DietDesigner"),
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
                    builder: (context) => const LoginPage(),
                  ),
                );
              }
            },
            icon: const Icon(Icons.logout),
          )
        ],
      ),
      body: const Center(
        child: Text("Calculator page"),
      ),
    );
  }
}
