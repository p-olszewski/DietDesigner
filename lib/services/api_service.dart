import 'dart:io';
import 'package:http/http.dart' as http;

import 'package:diet_designer/models/nutrition_plan.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class APIService {
  APIService._instantiate();
  static final APIService instance = APIService._instantiate();
  static const String _baseUrl = 'https://api.spoonacular.com';
  final String apiKey = dotenv.env['SPOONACULAR_API_KEY']!;

  Future<NutritionPlan?> getNutritionPlan(double kcal, double proteins,
      double carbs, double fats, int mealsNumber) async {
    Map<String, String> headers = {
      HttpHeaders.contentTypeHeader: 'application/json',
      'x-api-key': apiKey,
    };

    final Map<String, String> parameters = {
      'minCalories': kcal - 100,
      'maxCalories': kcal + 100,
      'minProtein': proteins - 10,
      'maxProtein': proteins + 10,
      'minFats': fats - 10,
      'maxFats': fats + 10,
      'number': mealsNumber,
      'minCarbs': 20,
      'offset': 60,
      'addRecipeInformation': true,
      'addRecipeNutrition': true,
    }.map(
      (key, value) => MapEntry(key, value.toString()),
    );

    Uri uri = Uri.https(
      _baseUrl,
      '/recipes/complexSearch',
      parameters,
    );

    debugPrint(uri.toString());
    try {
      final response = await http.get(uri, headers: headers);
      if (response.statusCode == 200) {
        debugPrint(response.body);
        return null;
      } else {
        throw Exception('Failed to load data');
      }
    } catch (e) {
      debugPrint(e.toString());
      throw Exception('Failed to load data');
    }
  }
}
