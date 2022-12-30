import 'dart:ui';

import 'package:diet_designer/net/flutterfire.dart';
import 'package:diet_designer/ui/home_view.dart';
import 'package:diet_designer/ui/registration_page.dart';
import 'package:flutter/material.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _emailField = TextEditingController();
  final TextEditingController _passwordField = TextEditingController();

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
              "Sign in to",
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 32,
                  fontWeight: FontWeight.w600),
            ),
            const Text(
              "DietDesigner",
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 48,
                  fontWeight: FontWeight.w100),
            ),
            SizedBox(height: screenHeight / 15),
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
                      await signIn(_emailField.text, _passwordField.text);
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
                child: const Text("Login"),
              ),
            ),
            MaterialButton(
              onPressed: () async {
                if (!mounted) return;
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const RegistrationPage(),
                  ),
                );
              },
              child: const Text(
                "or go to registration page",
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
