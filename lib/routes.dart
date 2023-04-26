import 'package:diet_designer/models/meal.dart';
import 'package:diet_designer/screens/calculator_screen.dart';
import 'package:diet_designer/screens/home_screen.dart';
import 'package:diet_designer/screens/login_screen.dart';
import 'package:diet_designer/screens/meal_details_screen.dart';
import 'package:diet_designer/screens/shopping_list_details_screen.dart';
import 'package:flutter/material.dart';

var appRoutes = {
  '/home': (context) => const HomeScreen(),
  '/login': (context) => const LoginScreen(),
  '/calculator': (context) => const CalculatorScreen(),
  '/meal_details': (context) {
    final Meal meal = ModalRoute.of(context)!.settings.arguments as Meal;
    return MealDetailsScreen(meal: meal);
  },
  '/shopping_list_details': (context) {
    final Map<String, dynamic> arguments = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
    final String listId = arguments['id'] as String;
    final String listTitle = arguments['title'] as String;
    return ShoppingListDetailsScreen(listId: listId, listTitle: listTitle);
  },
};
