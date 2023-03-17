import 'package:diet_designer/calculator/calculator.dart';
import 'package:diet_designer/home/home.dart';
import 'package:diet_designer/login/login.dart';

var appRoutes = {
  '/': (context) => const Home(),
  '/login': (context) => const Login(),
  '/calculator': (context) => const Calculator(),
};
