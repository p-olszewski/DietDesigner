import 'package:diet_designer/models/meal.dart';

class NutritionPlan {
  final List<Meal> meals;
  final double calories;
  final double carbs;
  final double fats;
  final double proteins;

  NutritionPlan(this.meals)
      : calories = meals.fold(0, (sum, meal) => sum + meal.calories),
        carbs = meals.fold(0, (sum, meal) => sum + meal.carbs),
        fats = meals.fold(0, (sum, meal) => sum + meal.fats),
        proteins = meals.fold(0, (sum, meal) => sum + meal.proteins);

  Map<String, dynamic> toJson() => {
        // 'meals': meals.map((meal) => meal.toJson()).toList(),
        'calories': calories,
        'carbs': carbs,
        'fats': fats,
        'proteins': proteins,
      };
}
