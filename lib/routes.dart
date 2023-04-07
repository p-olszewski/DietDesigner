import 'package:diet_designer/screens/calculator_screen.dart';
import 'package:diet_designer/screens/home_screen.dart';
import 'package:diet_designer/screens/login_screen.dart';

var appRoutes = {
  '/': (context) => const HomeScreen(),
  '/login': (context) => const LoginScreen(),
  '/calculator': (context) => const CalculatorScreen(),
};
