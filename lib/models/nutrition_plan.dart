import 'package:diet_designer/models/meal.dart';
import 'package:diet_designer/utils/utils.dart';

class NutritionPlan {
  final List<Meal> meals;
  final double calories;
  final double carbs;
  final double fats;
  final double proteins;
  String date;
  String name;
  final String uid;
  List<String> sharedUsers;
  bool isFavorite = false;

  NutritionPlan(this.meals, this.date, this.uid, {this.sharedUsers = const []})
      : calories = meals.fold(0, (sum, meal) => sum + meal.calories),
        carbs = meals.fold(0, (sum, meal) => sum + meal.carbs),
        fats = meals.fold(0, (sum, meal) => sum + meal.fats),
        proteins = meals.fold(0, (sum, meal) => sum + meal.proteins),
        name = formatDate(date);

  Map<String, dynamic> toJson() => {
        'calories': double.parse(calories.toStringAsFixed(2)),
        'carbs': double.parse(carbs.toStringAsFixed(2)),
        'fats': double.parse(fats.toStringAsFixed(2)),
        'proteins': double.parse(proteins.toStringAsFixed(2)),
        'date': date,
        'uid': uid,
        'shared_users': sharedUsers,
        'isFavorite': isFavorite,
        'name': name,
      };

  NutritionPlan.fromJson(Map<String, dynamic> json, this.meals)
      : calories = json['calories'],
        carbs = json['carbs'],
        fats = json['fats'],
        proteins = json['proteins'],
        date = json['date'],
        uid = json['uid'],
        sharedUsers = List<String>.from(json['shared_users']),
        isFavorite = json['isFavorite'],
        name = json['name'];
}
