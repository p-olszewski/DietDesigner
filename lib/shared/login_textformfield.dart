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

    return SizedBox(
      width: widgetWidth,
      child: TextFormField(
        style: TextStyle(color: Theme.of(context).colorScheme.onPrimaryContainer),
        controller: controller,
        obscureText: obscureText,
        cursorColor: Theme.of(context).colorScheme.onPrimaryContainer,
        decoration: InputDecoration(
          labelStyle: TextStyle(color: Theme.of(context).colorScheme.onPrimaryContainer),
          labelText: labelText,
          hintStyle: const TextStyle(color: Color.fromARGB(255, 155, 207, 110)),
          hintText: hintText,
          focusedBorder: UnderlineInputBorder(
            borderSide: BorderSide(color: Theme.of(context).colorScheme.onPrimaryContainer),
          ),
          enabledBorder: UnderlineInputBorder(
            borderSide: BorderSide(color: Theme.of(context).colorScheme.onPrimaryContainer),
          ),
        ),
      ),
    );
  }
}
