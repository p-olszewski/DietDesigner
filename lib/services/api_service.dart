import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'package:diet_designer/models/meal.dart';
import 'package:diet_designer/models/user.dart';
import 'package:http/http.dart' as http;

import 'package:flutter_dotenv/flutter_dotenv.dart';

class APIService {
  APIService._instantiate();
  static final APIService instance = APIService._instantiate();
  static const String _baseUrl = 'api.spoonacular.com';
  static const String _path = '/recipes/complexSearch';
  final String apiKey = dotenv.env['SPOONACULAR_API_KEY']!;

  Future<List<Meal>?> fetchMeals(User user) async {
    Map<String, String> headers = {HttpHeaders.contentTypeHeader: 'application/json', 'x-api-key': apiKey};

    final Map<String, String> breakfastParameters = _getPersonalizedParameters(user, mealsNumber: 1, mealType: 'breakfast');
    Uri breakfastUri = Uri.https(_baseUrl, _path, breakfastParameters);

    final Map<String, String> restOfMealsParameters = _getPersonalizedParameters(user, mealsNumber: user.mealsNumber! - 1);
    Uri restOfMealsUri = Uri.https(_baseUrl, _path, restOfMealsParameters);

    try {
      final breakfastResponse = await http.get(breakfastUri, headers: headers);
      final restOfMealsResponse = await http.get(restOfMealsUri, headers: headers);
      if (breakfastResponse.statusCode == 200 && restOfMealsResponse.statusCode == 200) {
        List<Meal> meals = [];
        var breakfastData = jsonDecode(breakfastResponse.body);
        var restOfMealsData = jsonDecode(restOfMealsResponse.body);
        var breakfastResults = breakfastData['results'];
        var restOfMealsResults = restOfMealsData['results'];

        meals.add(Meal.fromJson(breakfastResults[0]));
        for (var meal in restOfMealsResults) {
          meals.add(Meal.fromJson(meal));
        }
        return meals;
      } else {
        throw Exception('Failed to load data: ${restOfMealsResponse.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to load data: $e');
    }
  }

  //TODO meal type distinction and validate meals number if user has a lot of calories (max meal kcal is less than 1000 kcal)
  Map<String, String> _getPersonalizedParameters(User user, {required int mealsNumber, String mealType = ''}) {
    final kcal = (user.calories! / user.mealsNumber!).round();
    final protein = (user.proteins! / user.mealsNumber!).round();
    Map<String, String> parameters;
    switch (mealType) {
      case 'breakfast':
        parameters = {
          'minCalories': (kcal - 150).toString(),
          'maxCalories': (kcal + 150).toString(),
          'offset': Random().nextInt(30).toString(),
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
