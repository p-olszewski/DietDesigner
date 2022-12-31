import 'package:diet_designer/net/flutterfire.dart';
import 'package:diet_designer/ui/home_view.dart';
import 'package:diet_designer/ui/login_page.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

class RegistrationPage extends StatefulWidget {
  const RegistrationPage({super.key});

  @override
  State<RegistrationPage> createState() => _RegistrationPageState();
}

class _RegistrationPageState extends State<RegistrationPage> {
  final TextEditingController _emailField = TextEditingController();
  final TextEditingController _passwordField = TextEditingController();
  final TextEditingController _repeatPasswordField = TextEditingController();

  @override
  Widget build(BuildContext context) {
    var screenWidth = MediaQuery.of(context).size.width;
    var screenHeight = MediaQuery.of(context).size.height;
    var widgetWidth = screenWidth / 1.3;

    return Scaffold(
      body: Container(
        width: screenWidth,
        height: screenHeight,
        decoration: const BoxDecoration(color: Colors.blueAccent),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              "Create Account",
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 32,
                  fontWeight: FontWeight.w600),
            ),
            SizedBox(height: screenHeight / 30),
            SizedBox(
              width: widgetWidth,
              child: TextFormField(
                style: const TextStyle(color: Colors.white),
                controller: _emailField,
                decoration: const InputDecoration(
                  labelStyle: TextStyle(color: Colors.white),
                  labelText: "Email",
                  hintStyle: TextStyle(
                    color: Color.fromARGB(255, 164, 200, 255),
                  ),
                  hintText: "youremail@email.com",
                ),
              ),
            ),
            SizedBox(height: screenHeight / 100),
            SizedBox(
              width: widgetWidth,
              child: TextFormField(
                obscureText: true,
                style: const TextStyle(color: Colors.white),
                controller: _passwordField,
                decoration: const InputDecoration(
                  labelStyle: TextStyle(color: Colors.white),
                  labelText: "Password",
                  hintStyle: TextStyle(
                    color: Color.fromARGB(255, 164, 200, 255),
                  ),
                  hintText: "password",
                ),
              ),
            ),
            SizedBox(height: screenHeight / 100),
            SizedBox(
              width: widgetWidth,
              child: TextFormField(
                obscureText: true,
                style: const TextStyle(color: Colors.white),
                controller: _repeatPasswordField,
                decoration: const InputDecoration(
                  labelStyle: TextStyle(color: Colors.white),
                  labelText: "Repeat Password",
                  hintStyle: TextStyle(
                    color: Color.fromARGB(255, 164, 200, 255),
                  ),
                  hintText: "password",
                ),
              ),
            ),
            SizedBox(height: screenHeight / 20),
            SizedBox(height: screenHeight / 100),
            Container(
              width: widgetWidth,
              height: 45,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(15.0),
                color: Colors.white,
              ),
              child: MaterialButton(
                onPressed: () async {
                  bool shouldRedirect =
                      await signUp(_emailField.text, _passwordField.text);
                  if (shouldRedirect) {
                    if (!mounted) return;
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const HomeView(),
                      ),
                    );
                  }
                },
                child: const Text("Register account"),
              ),
            ),
            MaterialButton(
              onPressed: () async {
                if (!mounted) return;
                Fluttertoast.showToast(msg: "Account created");
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const LoginPage(),
                  ),
                );
              },
              child: const Text(
                "or go back to login page",
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
