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
    final Map<String, String> parameters = _getPersonalizedParameters(user);
    Uri uri = Uri.https(_baseUrl, _path, parameters);

    try {
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
    } catch (e) {
      throw Exception('Failed to load data: $e');
    }
  }

  Map<String, String> _getPersonalizedParameters(User user) {
    int mealsNumber = user.mealsNumber!;
    int kcal = (user.calories! / mealsNumber).round();
    int protein = (user.proteins! / mealsNumber).round();
    return {
      'minCalories': (kcal - 50).toString(),
      'maxCalories': (kcal + 50).toString(),
      'minProtein': (protein - 10).toString(),
      'maxProtein': (protein + 10).toString(),
      'number': mealsNumber.toString(),
      'offset': Random().nextInt(50).toString(),
      'addRecipeInformation': true.toString(),
      'addRecipeNutrition': true.toString(),
      'sort': 'random',
    };
  }
}
