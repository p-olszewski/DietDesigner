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

  Future<List<Meal>?> fetchMeals(User user) async {
    try {
      Map<String, String> headers = {HttpHeaders.contentTypeHeader: 'application/json', 'x-api-key': apiKey};
      List<Meal> meals = [];

      final breakfastParameters = _getPersonalizedParameters(user, mealsNumber: 1, mealType: 'breakfast');
      final restOfMealsParameters = _getPersonalizedParameters(user, mealsNumber: user.mealsNumber! - 1);

      final breakfastResponse = await _makeRequest(_baseUrl, _path, breakfastParameters, headers);
      final restOfMealsResponse = await _makeRequest(_baseUrl, _path, restOfMealsParameters, headers);

      var breakfastResults = breakfastResponse['results'];
      var restOfMealsResults = restOfMealsResponse['results'];

      meals.add(Meal.fromJson(breakfastResults[0]));
      for (var meal in restOfMealsResults) {
        meals.add(Meal.fromJson(meal));
      }

      return meals;
    } catch (e) {
      debugPrint(e.toString());
      throw Exception('Failed to load data: $e');
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
          'offset': Random().nextInt(50).toString(),
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

  Future<Map<String, dynamic>> _makeRequest(
    String baseUrl,
    String path,
    Map<String, String> parameters,
    Map<String, String> headers,
  ) async {
    Uri uri = Uri.https(baseUrl, path, parameters);
    final response = await http.get(uri, headers: headers);

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to load data: ${response.statusCode}');
    }
  }
}
