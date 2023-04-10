import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

class PopupMessenger {
  static void info(String message) {
    Fluttertoast.showToast(msg: message, backgroundColor: const Color.fromARGB(220, 46, 125, 50));
  }

  static void error(String message) {
    Fluttertoast.showToast(msg: message, backgroundColor: const Color.fromARGB(220, 198, 40, 40));
  }
}
