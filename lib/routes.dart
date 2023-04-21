import 'package:diet_designer/screens/calculator_screen.dart';
import 'package:diet_designer/screens/main_screen.dart';
import 'package:diet_designer/screens/login_screen.dart';

var appRoutes = {
  '/home': (context) => const MainScreen(),
  '/login': (context) => const LoginScreen(),
  '/calculator': (context) => const CalculatorScreen(),
};
