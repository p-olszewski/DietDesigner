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

  Future<NutritionPlan?> getMeals(
      double kcal, double proteins, int mealsNumber) async {
    Map<String, String> headers = {
      HttpHeaders.contentTypeHeader: 'application/json',
      'x-api-key': apiKey
    };

    final Map<String, dynamic> parameters = {
      'minCalories': kcal - 50,
      'maxCalories': kcal + 50,
      'minProtein': proteins - 20,
      'maxProtein': proteins + 20,
      'minCarbs': 20,
      'number': mealsNumber,
      'offset': 60,
      'addRecipeInformation': true,
      'addRecipeNutrition': true,
    }.map((key, value) => MapEntry(key, value.toString()));

    // does not work but seems to be the correct way to do it
    // Uri uri = Uri.https(
    //   _baseUrl,
    //   '/recipes/complexSearch',
    //   parameters,
    // );

    Uri uri = Uri.parse(
      '$_baseUrl/recipes/complexSearch?${Uri(queryParameters: parameters).query}',
    );

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
