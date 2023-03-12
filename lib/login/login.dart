import 'package:diet_designer/services/flutterfire.dart';
import 'package:diet_designer/calculator/calculator.dart';
import 'package:diet_designer/home/home.dart';
import 'package:diet_designer/shared/shared.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  final TextEditingController _emailFieldController = TextEditingController();
  final TextEditingController _passwordFieldController = TextEditingController();
  final TextEditingController _repeatedPasswordFieldController = TextEditingController();
  bool _isLoginPage = true;

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
            _isLoginPage
                ? Column(
                    children: const [
                      Text(
                        "Sign in to",
                        style: TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.w600),
                      ),
                      Text(
                        "DietDesigner",
                        style: TextStyle(color: Colors.white, fontSize: 48, fontWeight: FontWeight.w100),
                      ),
                    ],
                  )
                : const Text(
                    "Create Account",
                    style: TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.w600),
                  ),
            SizedBox(height: screenHeight / 15),
            CustomTextFormField(controller: _emailFieldController, labelText: "Email", hintText: "youremail@email.com", obscureText: false),
            SizedBox(height: screenHeight / 100),
            CustomTextFormField(controller: _passwordFieldController, labelText: "Password", hintText: "password", obscureText: true),
            SizedBox(height: screenHeight / 100),
            Visibility(
              visible: !_isLoginPage,
              child: CustomTextFormField(
                  controller: _repeatedPasswordFieldController, labelText: "Repeat password", hintText: "password", obscureText: true),
            ),
            SizedBox(height: screenHeight / 15),
            Container(
              width: widgetWidth / 1.3,
              height: 45,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(50.0),
                color: Colors.white,
              ),
              child: MaterialButton(
                onPressed: () async {
                  bool shouldRedirect = _isLoginPage
                      ? await signIn(_emailFieldController.text, _passwordFieldController.text)
                      : await signUp(_emailFieldController.text, _passwordFieldController.text, _repeatedPasswordFieldController.text);
                  if (shouldRedirect) {
                    Fluttertoast.showToast(msg: _isLoginPage ? "Logged in" : "Account created");
                    bool calculatedCalories = await checkUserCalculatedCalories();
                    if (!mounted) return;
                    if (calculatedCalories) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const Home(),
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
                child: Text(_isLoginPage ? "Login" : "Register and login"),
              ),
            ),
            MaterialButton(
              onPressed: () => setState(() {
                _isLoginPage = !_isLoginPage;
                _emailFieldController.clear();
                _passwordFieldController.clear();
                _repeatedPasswordFieldController.clear();
                FocusScope.of(context).unfocus();
              }),
              child: Text(
                _isLoginPage ? "go to registration page" : "go back to the login page",
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w400),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
