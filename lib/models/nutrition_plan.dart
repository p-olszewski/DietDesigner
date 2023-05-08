import 'package:diet_designer/models/meal.dart';

class NutritionPlan {
  final List<Meal> meals;
  final double calories;
  final double carbs;
  final double fats;
  final double proteins;
  final String date;
  final String uid;

  NutritionPlan(this.meals, this.date, this.uid)
      : calories = meals.fold(0, (sum, meal) => sum + meal.calories),
        carbs = meals.fold(0, (sum, meal) => sum + meal.carbs),
        fats = meals.fold(0, (sum, meal) => sum + meal.fats),
        proteins = meals.fold(0, (sum, meal) => sum + meal.proteins);

  Map<String, dynamic> toJson() => {
        'calories': double.parse(calories.toStringAsFixed(2)),
        'carbs': double.parse(carbs.toStringAsFixed(2)),
        'fats': double.parse(fats.toStringAsFixed(2)),
        'proteins': double.parse(proteins.toStringAsFixed(2)),
        'date': date,
        'uid': uid,
      };
}
