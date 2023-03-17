import 'package:flutter/material.dart';

class CustomTextFormField extends StatelessWidget {
  const CustomTextFormField({
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
        style: const TextStyle(color: Colors.white),
        controller: controller,
        obscureText: obscureText,
        cursorColor: Theme.of(context).colorScheme.secondary,
        decoration: InputDecoration(
          labelStyle: const TextStyle(color: Colors.white),
          labelText: labelText,
          hintStyle: const TextStyle(color: Color.fromARGB(255, 213, 253, 179)),
          hintText: hintText,
          focusedBorder: UnderlineInputBorder(
            borderSide: BorderSide(color: Theme.of(context).colorScheme.secondary),
          ),
        ),
      ),
    );
  }
}
