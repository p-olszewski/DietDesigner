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
  List<Meal>? _breakfastResults;
  List<Meal>? _restOfMealsResults;

  Future<Meal> getSimilarMealFromAPI(Meal meal, {String mealType = ''}) async {
    try {
      Map<String, String> headers = {HttpHeaders.contentTypeHeader: 'application/json', 'x-api-key': apiKey};
      Map<String, String> parameters = _getParameterForOneMeal(meal, mealType: mealType);
      Uri uri = Uri.https(_baseUrl, _path, parameters);

      final response = await http.get(uri, headers: headers);
      if (response.statusCode == 200) {
        var data = jsonDecode(response.body);
        var responseResults = data['results'];
        Meal similarMeal = Meal.fromJson(responseResults[0]);
        similarMeal.id = meal.id;
        return similarMeal;
      } else {
        throw Exception('Failed to load data: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint(e.toString());
      throw Exception('Failed to load data: $e');
    }
  }

  Future<List<Meal>?> getMealsFromAPI(User user) async {
    try {
      _breakfastResults = (await _fetchMeals(user, mealsNumber: 1, mealType: 'breakfast'))?.cast<Meal>();
      _restOfMealsResults = (await _fetchMeals(user, mealsNumber: user.mealsNumber! - 1))?.cast<Meal>();
      if (_breakfastResults == null || _restOfMealsResults == null) return null;

      List<Meal> allMeals = [];
      allMeals.add(_breakfastResults![0]);
      for (var meal in _restOfMealsResults!) {
        allMeals.add(meal);
      }
      return allMeals;
    } catch (e) {
      debugPrint(e.toString());
      throw Exception('Failed to load data: $e');
    }
  }

  Future<List<dynamic>?> _fetchMeals(User user, {required int mealsNumber, String mealType = ''}) async {
    Map<String, String> headers = {HttpHeaders.contentTypeHeader: 'application/json', 'x-api-key': apiKey};
    Map<String, String> parameters = _getParametersForAllMeals(user, mealsNumber: mealsNumber, mealType: mealType);
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

  Map<String, String> _getParametersForAllMeals(User user, {required int mealsNumber, String mealType = ''}) {
    int kcalPerMeal = (user.calories! / user.mealsNumber!).round();
    int proteinsPerMeal;
    int fatsPerMeal;

    Map<String, String> parameters;
    switch (mealType) {
      case 'breakfast':
        parameters = {
          'minProtein': '15',
          'minCalories': (kcalPerMeal - 150).toString(),
          'maxCalories': (kcalPerMeal + 150).toString(),
          'offset': Random().nextInt(20).toString(),
          'type': mealType,
        };
        break;
      default:
        int remainingKcal = (user.calories! - _breakfastResults![0].calories).round();
        int remainingProteins = (user.proteins! - _breakfastResults![0].proteins).round();
        kcalPerMeal = (remainingKcal / mealsNumber).round();
        proteinsPerMeal = (remainingProteins / mealsNumber).round();
        fatsPerMeal = (user.fats! / mealsNumber).round();
        parameters = {
          'minCalories': (kcalPerMeal - 50).toString(),
          'maxCalories': (kcalPerMeal + 50).toString(),
          'minProtein': (proteinsPerMeal - 10).toString(),
          'maxProtein': (proteinsPerMeal + 10).toString(),
          'maxFat': (fatsPerMeal + 10).toString(),
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

  Map<String, String> _getParameterForOneMeal(Meal meal, {String mealType = ''}) {
    Map<String, String> parameters;
    switch (mealType) {
      case 'breakfast':
        parameters = {
          'minProtein': '15',
          'minCalories': (meal.calories - 150).toString(),
          'maxCalories': (meal.calories + 150).toString(),
          'offset': Random().nextInt(10).toString(),
          'type': mealType,
        };
        break;
      default:
        parameters = {
          'minCalories': (meal.calories - 50).toString(),
          'maxCalories': (meal.calories + 50).toString(),
          'minProtein': (meal.proteins - 10).toString(),
          'maxProtein': (meal.proteins + 10).toString(),
          'offset': Random().nextInt(30).toString(),
        };
        break;
    }

    return {
      'number': '1',
      'addRecipeInformation': true.toString(),
      'addRecipeNutrition': true.toString(),
      ...parameters,
    };
  }
}
