import 'package:diet_designer/models/meal.dart';
import 'package:flutter/material.dart';

class MealDetailsScreen extends StatelessWidget {
  final Meal meal;

  const MealDetailsScreen({Key? key, required this.meal}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SizedBox(
        height: double.infinity,
        width: double.infinity,
        child: Stack(
          fit: StackFit.loose,
          children: [
            Hero(
              tag: 'meal',
              child: AspectRatio(
                aspectRatio: 4 / 3,
                child: Container(
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      image: NetworkImage(meal.image),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ),
            ),
            DraggableScrollableSheet(
              initialChildSize: 0.7,
              minChildSize: 0.7,
              builder: (context, scrollController) {
                return SafeArea(
                  child: Container(
                    width: MediaQuery.of(context).size.width,
                    padding: const EdgeInsets.only(left: 28.0, top: 28, right: 28.0, bottom: 0),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(40.0),
                        topRight: Radius.circular(40.0),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          spreadRadius: 1,
                          blurRadius: 6,
                          offset: const Offset(1, 1),
                        ),
                      ],
                    ),
                    child: SingleChildScrollView(
                      controller: scrollController,
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
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
