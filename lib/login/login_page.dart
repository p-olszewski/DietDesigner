import 'package:diet_designer/services/flutterfire.dart';
import 'package:diet_designer/calculator/calculator.dart';
import 'package:diet_designer/home/home_view.dart';
import 'package:diet_designer/registration/registration_page.dart';
import 'package:diet_designer/shared/custom_textformfield.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _emailField = TextEditingController();
  final TextEditingController _passwordField = TextEditingController();
  final TextEditingController _repeatedPasswordField = TextEditingController();

  @override
  Widget build(BuildContext context) {
    var screenWidth = MediaQuery.of(context).size.width;
    var screenHeight = MediaQuery.of(context).size.height;
    var widgetWidth = screenWidth / 1.3;

    return Scaffold(
      body: Container(
        width: screenWidth,
        height: screenHeight,
        decoration: BoxDecoration(color: Colors.green.shade500),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              "Sign in to",
              style: TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.w600),
            ),
            const Text(
              "DietDesigner",
              style: TextStyle(color: Colors.white, fontSize: 48, fontWeight: FontWeight.w100),
            ),
            SizedBox(height: screenHeight / 15),
            CustomTextFormField(controller: _emailField, labelText: "Email", hintText: "youremail@email.com", obscureText: false),
            SizedBox(height: screenHeight / 100),
            CustomTextFormField(controller: _passwordField, labelText: "Password", hintText: "password", obscureText: true),
            SizedBox(height: screenHeight / 20),
            SizedBox(height: screenHeight / 100),
            Container(
              width: widgetWidth / 1.3,
              height: 45,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(50.0),
                color: Colors.white,
              ),
              child: MaterialButton(
                onPressed: () async {
                  bool shouldRedirect = await signIn(_emailField.text, _passwordField.text);
                  if (shouldRedirect) {
                    Fluttertoast.showToast(msg: "Logged in");
                    bool calculatedCalories = await checkUserCalculatedCalories();
                    if (!mounted) return;
                    if (calculatedCalories) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const HomeView(),
                        ),
                      );
                    } else {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const Calculator(),
                        ),
                      );
                    }
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
