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
      body: SingleChildScrollView(
        child: Column(
          children: [
            Hero(
              tag: 'meal',
              child: Container(
                width: double.infinity,
                height: 300,
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: NetworkImage(meal.image),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),
            Padding(
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
                      'Calories: ${meal.calories.round()} kcal\nProteins: ${meal.proteins.round()}g\nFats: ${meal.fats.round()}g\nCarbs: ${meal.carbs.round()}g\nReady in: ${meal.readyInMinutes} min\nServings: ${meal.servings}\nPrice per serving: ${meal.pricePerServing}\$'),
                  const SizedBox(height: 16),
                  const Text(
                    "Dish types:",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  ...meal.dishTypes!.map((dishType) {
                    return Text(dishType);
                  }).toList(),
                  const SizedBox(height: 16),
                  const Text(
                    "Ingredients:",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  ...meal.ingredients!.map((ingredient) {
                    return Text('${ingredient['amount']} ${ingredient['unit']} ${ingredient['name']}');
                  }).toList(),
                  const SizedBox(height: 16),
                  const Text(
                    "Steps:",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  ...meal.steps!.asMap().entries.map((entry) {
                    final index = entry.key + 1;
                    final step = entry.value;
                    return Text('$index. $step');
                  }).toList(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
