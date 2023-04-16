import 'dart:io';
import 'package:diet_designer/shared/popup_messenger.dart';
import 'package:http/http.dart' as http;

import 'package:diet_designer/models/nutrition_plan.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class APIService {
  APIService._instantiate();
  static final APIService instance = APIService._instantiate();
  static const String _baseUrl = 'api.spoonacular.com';
  static const String _path = '/recipes/complexSearch';
  final String apiKey = dotenv.env['SPOONACULAR_API_KEY']!;

  Future<NutritionPlan?> fetchMeals(
      double kcal, double proteins, int mealsNumber) async {
    Map<String, String> headers = {
      HttpHeaders.contentTypeHeader: 'application/json',
      'x-api-key': apiKey
    };

    final Map<String, String> parameters = {
      'minCalories': kcal - 50,
      'maxCalories': kcal + 50,
      'minProtein': proteins - 20,
      'maxProtein': proteins + 20,
      'minCarbs': 20,
      'number': mealsNumber,
      'offset': 60,
      'addRecipeInformation': true,
      'addRecipeNutrition': true,
    }.map(
      (key, value) => MapEntry(key, value.toString()),
    );

    Uri uri = Uri.https(
      _baseUrl,
      _path,
      parameters,
    );

    try {
      final response = await http.get(uri, headers: headers);
      if (response.statusCode == 200) {
        PopupMessenger.info(
            'Successfully loaded ${response.body.length} B of data!');
        debugPrint(response.body);
        return null;
      } else {
        PopupMessenger.error('Failed to load data');
        throw Exception('Failed to load data');
      }
    } catch (e) {
      debugPrint(e.toString());
      PopupMessenger.error('Failed to load data');
      throw Exception('Failed to load data');
    }
  }
}
