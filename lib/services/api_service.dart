import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'package:diet_designer/models/meal.dart';
import 'package:diet_designer/models/user.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import 'package:flutter_dotenv/flutter_dotenv.dart';

class APIService {
  APIService._instantiate();
  static final APIService instance = APIService._instantiate();
  static const String _baseUrl = 'api.spoonacular.com';
  static const String _path = '/recipes/complexSearch';
  final String apiKey = dotenv.env['SPOONACULAR_API_KEY']!;

  Future<List<Meal>?> getMealsFromAPI(User user) async {
    try {
      List<Meal> meals = [];
      List<Meal>? breakfastResults = (await _fetchMeals(user, mealsNumber: 1, mealType: 'breakfast'))?.cast<Meal>();
      List<Meal>? restOfMealsResults = (await _fetchMeals(user, mealsNumber: user.mealsNumber! - 1))?.cast<Meal>();
      if (breakfastResults == null || restOfMealsResults == null) return null;

      meals.add(breakfastResults[0]);
      for (var meal in restOfMealsResults) {
        meals.add(meal);
      }

      return meals;
    } catch (e) {
      debugPrint(e.toString());
      throw Exception('Failed to load data: $e');
    }
  }

  Future<List<dynamic>?> _fetchMeals(User user, {required int mealsNumber, String mealType = ''}) async {
    Map<String, String> headers = {HttpHeaders.contentTypeHeader: 'application/json', 'x-api-key': apiKey};
    Map<String, String> parameters = _getPersonalizedParameters(user, mealsNumber: mealsNumber, mealType: mealType);
    Uri uri = Uri.https(_baseUrl, _path, parameters);

    final response = await http.get(uri, headers: headers);
    if (response.statusCode == 200) {
      var data = jsonDecode(response.body);
      var responseResults = data['results'];
      List<Meal> meals = [];
      for (var meal in responseResults) {
        meals.add(Meal.fromJson(meal));
      }

      return meals;
    } else {
      throw Exception('Failed to load data: ${response.statusCode}');
    }
  }

  Map<String, String> _getPersonalizedParameters(User user, {required int mealsNumber, String mealType = ''}) {
    final kcal = (user.calories! / user.mealsNumber!).round();
    final protein = (user.proteins! / user.mealsNumber!).round();
    Map<String, String> parameters;
    switch (mealType) {
      case 'breakfast':
        parameters = {
          'minCalories': (kcal - 150).toString(),
          'maxCalories': (kcal + 150).toString(),
          'offset': Random().nextInt(20).toString(),
          'type': mealType,
        };
        break;
      default:
        parameters = {
          'minCalories': (kcal - 50).toString(),
          'maxCalories': (kcal + 50).toString(),
          'minProtein': (protein - 10).toString(),
          'maxProtein': (protein + 10).toString(),
          'offset': Random().nextInt(50).toString(),
        };
        break;
    }

    return {
      'number': mealsNumber.toString(),
      'addRecipeInformation': true.toString(),
      'addRecipeNutrition': true.toString(),
      'sort': 'random',
      ...parameters
    };
  }
}
