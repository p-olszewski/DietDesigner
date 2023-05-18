import 'package:flutter/material.dart';

class LoginTextFormField extends StatelessWidget {
  const LoginTextFormField({
    Key? key,
    required this.controller,
    required this.labelText,
    required this.hintText,
    required this.obscureText,
  }) : super(key: key);

  final TextEditingController controller;
  final String labelText;
  final String hintText;
  final bool obscureText;

  @override
  Widget build(BuildContext context) {
    var screenWidth = MediaQuery.of(context).size.width;
    var widgetWidth = screenWidth / 1.3;
    Color mainColor = Theme.of(context).colorScheme.onPrimaryContainer;
    Color accentColor = Theme.of(context).colorScheme.primary;

    return SizedBox(
      width: widgetWidth,
      child: TextFormField(
        style: TextStyle(color: mainColor),
        controller: controller,
        obscureText: obscureText,
        cursorColor: mainColor,
        decoration: InputDecoration(
          labelStyle: TextStyle(color: mainColor),
          labelText: labelText,
          hintStyle: TextStyle(color: accentColor),
          hintText: hintText,
          focusedBorder: UnderlineInputBorder(
            borderSide: BorderSide(color: mainColor),
          ),
          enabledBorder: UnderlineInputBorder(
            borderSide: BorderSide(color: accentColor),
          ),
        ),
      ),
    );
  }
}
