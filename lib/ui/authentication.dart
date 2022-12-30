import 'package:diet_designer/net/flutterfire.dart';
import 'package:diet_designer/ui/home_view.dart';
import 'package:flutter/material.dart';

class Authentication extends StatefulWidget {
  const Authentication({super.key});

  @override
  State<Authentication> createState() => _AuthenticationState();
}

class _AuthenticationState extends State<Authentication> {
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
        decoration: const BoxDecoration(color: Colors.blue),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              "Welcome to Diet Designer!",
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 32,
                  fontWeight: FontWeight.bold),
            ),
            SizedBox(height: screenHeight / 10),
            SizedBox(
              width: widgetWidth,
              child: TextFormField(
                style: const TextStyle(color: Colors.white),
                controller: _emailField,
                decoration: const InputDecoration(
                  labelStyle: TextStyle(color: Colors.white),
                  labelText: "Email",
                  hintStyle: TextStyle(color: Colors.white),
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
                  hintStyle: TextStyle(color: Colors.white),
                  hintText: "Enter your password",
                ),
              ),
            ),
            SizedBox(height: screenHeight / 20),
            Container(
              width: widgetWidth,
              height: 45,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(15.0),
                color: Colors.white,
              ),
              child: MaterialButton(
                onPressed: () async {
                  bool shouldNavigate =
                      await signUp(_emailField.text, _passwordField.text);
                  if (shouldNavigate) {
                    if (!mounted) return;
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const HomeView(),
                      ),
                    );
                  }
                },
                child: const Text("Register"),
              ),
            ),
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
                  bool shouldNavigate =
                      await signIn(_emailField.text, _passwordField.text);
                  if (shouldNavigate) {
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
          ],
        ),
      ),
    );
  }
}
