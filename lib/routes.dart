import 'package:diet_designer/models/meal.dart';
import 'package:diet_designer/screens/account_details_screen.dart';
import 'package:diet_designer/screens/calculator_screen.dart';
import 'package:diet_designer/screens/contact_screen.dart';
import 'package:diet_designer/screens/friends_screen.dart';
import 'package:diet_designer/screens/home_screen.dart';
import 'package:diet_designer/screens/login_screen.dart';
import 'package:diet_designer/screens/meal_details_screen.dart';
import 'package:diet_designer/screens/shared_by_me_screen.dart';
import 'package:diet_designer/screens/shared_to_me_screen.dart';
import 'package:diet_designer/screens/shopping_list_details_screen.dart';
import 'package:flutter/material.dart';

var appRoutes = {
  '/home': (context) => const HomeScreen(),
  '/login': (context) => const LoginScreen(),
  '/meal_details': (context) {
    final Meal meal = ModalRoute.of(context)!.settings.arguments as Meal;
    return MealDetailsScreen(meal: meal);
  },
  '/shopping_list_details': (context) => const ShoppingListDetailsScreen(),
  '/account_details': (context) => const AccountDetailsScreen(),
  '/calculator': (context) => const CalculatorScreen(),
  '/shared_by_me': (context) => const SharedByMeScreen(),
  '/shared_to_me': (context) => const SharedToMeScreen(),
  '/friends': (context) => const FriendsScreen(),
  '/contact': (context) => const ContactScreen(),
};
