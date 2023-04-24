import 'package:diet_designer/models/meal.dart';
import 'package:flutter/material.dart';

class MealDetailsScreen extends StatelessWidget {
  final Meal meal;

  const MealDetailsScreen({Key? key, required this.meal}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Meal details'),
      ),
      body: Column(
        children: [
          Hero(
            tag: 'meal',
            child: Container(
              width: double.infinity,
              height: 200,
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: NetworkImage(meal.image),
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      meal.title,
                      style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Calories: ${meal.calories.round()} kcal\nProteins: ${meal.proteins.round()}g\nFats: ${meal.fats.round()}g\nCarbs: ${meal.carbs.round()}g',
                      style: const TextStyle(fontSize: 16),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      "Steps:",
                      style: TextStyle(fontSize: 16),
                    ),
                    ...meal.steps!.asMap().entries.map((entry) {
                      final index = entry.key + 1;
                      final step = entry.value;
                      return Text(
                        '$index. $step',
                        style: const TextStyle(fontSize: 16),
                      );
                    }).toList(),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
