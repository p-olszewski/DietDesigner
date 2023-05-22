import 'package:animations/animations.dart';
import 'package:diet_designer/models/user.dart';
import 'package:diet_designer/providers/auth_provider.dart';
import 'package:diet_designer/providers/date_provider.dart';
import 'package:diet_designer/providers/user_data_provider.dart';
import 'package:diet_designer/services/firestore_service.dart';
import 'package:diet_designer/shared/shared.dart';
import 'package:diet_designer/widgets/login_textformfield.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailFieldController = TextEditingController();
  final TextEditingController _passwordFieldController =
      TextEditingController();
  final TextEditingController _repeatedPasswordFieldController =
      TextEditingController();
  bool _isLoginPage = true;
  int _key = 1;

  @override
  Widget build(BuildContext context) {
    final containerWidth = MediaQuery.of(context).size.width / 1.1;
    final containerHeight = MediaQuery.of(context).size.height / 1.3;
    final widgetWidth = containerWidth / 1.3;
    final backgroundColor = Theme.of(context).colorScheme.primary;
    final innerBackgroundColor = Theme.of(context).colorScheme.surface;
    final fontColor = Theme.of(context).colorScheme.onPrimaryContainer;

    return Scaffold(
      backgroundColor: backgroundColor,
      body: SafeArea(
        child: Center(
          child: Container(
            width: containerWidth,
            height: containerHeight,
            decoration: BoxDecoration(
              color: innerBackgroundColor,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.5),
                  spreadRadius: 5,
                  blurRadius: 7,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              transitionBuilder: (child, animation) => FadeThroughTransition(
                animation: animation,
                secondaryAnimation:
                    Tween<double>(begin: 0, end: 0).animate(animation),
                child: child,
              ),
              child: Container(
                key: ValueKey<int>(_key),
                width: containerWidth - 20,
                height: containerHeight - 120,
                color: innerBackgroundColor,
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      const SizedBox(height: 14),
                      _isLoginPage
                          ? Column(
                              children: [
                                Text(
                                  "Sign in to",
                                  style:
                                      TextStyle(fontSize: 24, color: fontColor),
                                ),
                                const Logo(),
                              ],
                            )
                          : Text(
                              "Create Account",
                              style: TextStyle(
                                  fontSize: 32,
                                  fontWeight: FontWeight.w600,
                                  color: fontColor),
                            ),
                      SizedBox(height: containerHeight / 16),
                      LoginTextFormField(
                          controller: _emailFieldController,
                          labelText: "Email",
                          hintText: "youremail@email.com",
                          obscureText: false),
                      SizedBox(height: containerHeight / 100),
                      LoginTextFormField(
                          controller: _passwordFieldController,
                          labelText: "Password",
                          hintText: "password",
                          obscureText: true),
                      SizedBox(height: containerHeight / 100),
                      Visibility(
                        visible: !_isLoginPage,
                        child: LoginTextFormField(
                            controller: _repeatedPasswordFieldController,
                            labelText: "Repeat password",
                            hintText: "password",
                            obscureText: true),
                      ),
                      SizedBox(height: containerHeight / 10),
                      SizedBox(
                        width: widgetWidth / 1.5,
                        height: 40,
                        child: FilledButton(
                          onPressed: loginOrRegisterUser,
                          child: Text(
                              _isLoginPage ? "Login" : "Register and login"),
                        ),
                      ),
                      SizedBox(height: containerHeight / 100),
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
                          _isLoginPage
                              ? "or go to registration page"
                              : "or go back to the login page",
                          style: TextStyle(
                              color: fontColor, fontWeight: FontWeight.w400),
                        ),
                      ),
                      SizedBox(height: containerHeight / 9),
                      const Logo(fontSize: 16),
                      const Text(
                        "© 2023 Przemysław Olszewski",
                        style: TextStyle(fontSize: 10, color: Colors.grey),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  void loginOrRegisterUser() async {
    final authProvider = context.read<AuthProvider>();
    bool shouldRedirect = _isLoginPage
        ? await authProvider.signIn(
            _emailFieldController.text,
            _passwordFieldController.text,
          )
        : await authProvider.signUp(
            _emailFieldController.text,
            _passwordFieldController.text,
            _repeatedPasswordFieldController.text,
          );
    if (shouldRedirect) {
      bool hasCalculatedCalories =
          await checkUserHasCalculatedData(authProvider.uid!);
      await setProviders(authProvider.uid!);
      if (!mounted) return;
      if (!hasCalculatedCalories) {
        Navigator.pushReplacementNamed(context, '/account_edit');
        PopupMessenger.error('You have no calculated data, please fill it in');
      } else {
        Navigator.pushReplacementNamed(context, '/home');
      }
    }
  }

  Future setProviders(String uid) async {
    User? user = await getUserData(uid);
    if (!mounted) return;
    context.read<DateProvider>().setDate(DateTime.now());
    context.read<UserDataProvider>().setUser(user!);
  }
}
