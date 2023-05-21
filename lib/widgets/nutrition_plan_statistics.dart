import 'package:diet_designer/models/nutrition_plan.dart';
import 'package:flutter/material.dart';

class NutritionPlanStatistics extends StatelessWidget {
  const NutritionPlanStatistics({
    Key? key,
    required this.nutritionPlan,
  }) : super(key: key);

  final NutritionPlan nutritionPlan;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 20),
        Row(
          children: [
            Text(
              'Nutrition plan summary',
              style: Theme.of(context).textTheme.titleMedium!.copyWith(fontWeight: FontWeight.bold),
            ),
          ],
        ),
        const Divider(),
        Row(
          children: [
            Expanded(
              child: _buildStatisticBox('Calories', '${nutritionPlan.calories.toStringAsFixed(0)} kcal'),
            ),
            Expanded(
              child: _buildStatisticBox('Proteins', '${nutritionPlan.proteins.toStringAsFixed(0)} g'),
            ),
          ],
        ),
        Row(
          children: [
            Expanded(
              child: _buildStatisticBox('Carbs', '${nutritionPlan.carbs.toStringAsFixed(0)} g'),
            ),
            Expanded(
              child: _buildStatisticBox('Fats', '${nutritionPlan.fats.toStringAsFixed(0)} g'),
            ),
          ],
        ),
        Row(
          children: [
            Expanded(
              child: _buildStatisticBox(
                  'Price', '${nutritionPlan.meals.fold(0.0, (sum, meal) => sum + meal.pricePerServing!).toStringAsFixed(2)} \$'),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStatisticBox(String label, String value) {
    return Column(
      children: [
        Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: Colors.grey.withOpacity(0.1),
          ),
          padding: const EdgeInsets.all(4.0),
          child: Text(
            label,
            textAlign: TextAlign.center,
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(4.0),
          child: Text(
            value,
            style: const TextStyle(color: Colors.grey),
          ),
        ),
      ],
    );
  }
}
