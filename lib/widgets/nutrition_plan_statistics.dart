import 'package:diet_designer/models/nutrition_plan.dart';
import 'package:flutter/material.dart';

class NutritionPlanStatistics extends StatelessWidget {
  const NutritionPlanStatistics({
    super.key,
    required this.nutritionPlan,
  });

  final NutritionPlan nutritionPlan;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 20),
        const SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('Calories'),
            Text('${nutritionPlan.calories.toStringAsFixed(0)} kcal'),
          ],
        ),
        const SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('Proteins'),
            Text('${nutritionPlan.proteins.toStringAsFixed(0)} g'),
          ],
        ),
        const SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('Carbs'),
            Text('${nutritionPlan.carbs.toStringAsFixed(0)} g'),
          ],
        ),
        const SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('Fats'),
            Text('${nutritionPlan.fats.toStringAsFixed(0)} g'),
          ],
        ),
      ],
    );
  }
}
