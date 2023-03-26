import 'package:animations/animations.dart';
import 'package:diet_designer/services/flutterfire.dart';
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
  int _key = 1;

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final widgetWidth = screenWidth / 1.3;
    const backgroundColor = Colors.green;
    const fontColor = Colors.white;

    return Scaffold(
      body: Container(
        width: screenWidth,
        height: screenHeight,
        color: backgroundColor,
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          transitionBuilder: (child, animation) => FadeThroughTransition(
            animation: animation,
            secondaryAnimation: Tween<double>(begin: 0, end: 0).animate(animation),
            child: child,
          ),
          child: Container(
            key: ValueKey<int>(_key),
            width: screenWidth,
            height: screenHeight,
            color: backgroundColor,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _isLoginPage
                    ? Column(
                        children: const [
                          Text(
                            "Sign in to",
                            style: TextStyle(fontSize: 24, color: fontColor),
                          ),
                          Logo(),
                        ],
                      )
                    : const Text(
                        "Create Account",
                        style: TextStyle(fontSize: 32, fontWeight: FontWeight.w600, color: fontColor),
                      ),
                SizedBox(height: screenHeight / 25),
                LoginTextFormField(
                    controller: _emailFieldController, labelText: "Email", hintText: "youremail@email.com", obscureText: false),
                SizedBox(height: screenHeight / 100),
                LoginTextFormField(controller: _passwordFieldController, labelText: "Password", hintText: "password", obscureText: true),
                SizedBox(height: screenHeight / 100),
                Visibility(
                  visible: !_isLoginPage,
                  child: LoginTextFormField(
                      controller: _repeatedPasswordFieldController, labelText: "Repeat password", hintText: "password", obscureText: true),
                ),
                SizedBox(height: screenHeight / 15),
                SizedBox(
                  width: widgetWidth / 1.3,
                  child: ElevatedButton(
                    onPressed: () async {
                      bool shouldRedirect = _isLoginPage
                          ? await signIn(_emailFieldController.text, _passwordFieldController.text)
                          : await signUp(_emailFieldController.text, _passwordFieldController.text, _repeatedPasswordFieldController.text);
                      if (shouldRedirect) {
                        Fluttertoast.showToast(msg: _isLoginPage ? "Logged in" : "Account created");
                        bool hasCalculatedCalories = await checkUserCalculatedCalories();
                        if (!mounted) return;
                        Navigator.pushNamed(context, hasCalculatedCalories ? '/' : '/calculator');
                      }
                    },
                    child: Text(_isLoginPage ? "Login" : "Register and login"),
                  ),
                ),
                TextButton(
                  onPressed: () => setState(() {
                    _isLoginPage = !_isLoginPage;
                    _emailFieldController.clear();
                    _passwordFieldController.clear();
                    _repeatedPasswordFieldController.clear();
                    FocusScope.of(context).unfocus();
                    _key = _isLoginPage ? 1 : 2;
                  }),
                  child: Text(
                    _isLoginPage ? "or go to registration page" : "or go back to the login page",
                    style: TextStyle(color: fontColor, fontWeight: FontWeight.w400),
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
