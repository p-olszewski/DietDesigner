import 'package:diet_designer/models/meal.dart';
import 'package:flutter/material.dart';

class MealDetailsScreen extends StatefulWidget {
  final Meal meal;

  const MealDetailsScreen({Key? key, required this.meal}) : super(key: key);

  @override
  State<MealDetailsScreen> createState() => _MealDetailsScreenState();
}

class _MealDetailsScreenState extends State<MealDetailsScreen> {
  bool isFavourite = false;

  void _addToFavourites() {
    setState(() => isFavourite = !isFavourite);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.loose,
        children: [
          MealDetailsPhoto(meal: widget.meal),
          MealDetailsData(meal: widget.meal),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _addToFavourites(),
        child: Icon(
          isFavourite ? Icons.favorite : Icons.favorite_border,
        ),
      ),
    );
  }
}

class MealDetailsPhoto extends StatelessWidget {
  const MealDetailsPhoto({super.key, required this.meal});

  final Meal meal;

  @override
  Widget build(BuildContext context) {
    return Hero(
      tag: 'meal',
      child: Stack(
        fit: StackFit.loose,
        children: [
          Container(
            height: 400,
            decoration: BoxDecoration(
              image: DecorationImage(
                image: NetworkImage(meal.image),
                fit: BoxFit.cover,
              ),
            ),
          ),
          Positioned(
            top: 40,
            left: 24,
            child: Container(
              width: 45,
              height: 45,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    spreadRadius: 1,
                    blurRadius: 2,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: const BackButton(),
            ),
          ),
        ],
      ),
    );
  }
}

class MealDetailsData extends StatelessWidget {
  const MealDetailsData({super.key, required this.meal});

  final Meal meal;

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.6,
      minChildSize: 0.6,
      maxChildSize: 0.90,
      builder: (context, scrollController) {
        return SafeArea(
          child: Stack(
            fit: StackFit.loose,
            children: [
              Container(
                width: MediaQuery.of(context).size.width,
                padding: const EdgeInsets.only(left: 28.0, top: 30.0, right: 28.0, bottom: 0),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(36.0),
                    topRight: Radius.circular(36.0),
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
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.timer_outlined,
                                size: 20,
                                color: Theme.of(context).colorScheme.primary,
                              ),
                              Text(' ${meal.readyInMinutes} min'),
                            ],
                          ),
                          Row(
                            children: [
                              Icon(
                                Icons.paid_outlined,
                                size: 20,
                                color: Theme.of(context).colorScheme.primary,
                              ),
                              Text(' ${meal.pricePerServing!.toStringAsFixed(2)}\$'),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        meal.title,
                        style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 24),
                      MealDetailsNutritionsRow(meal: meal),
                      const SizedBox(height: 24),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: Theme.of(context).colorScheme.secondaryContainer,
                            width: 1,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.restaurant_outlined,
                              size: 20,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                            Text('  ${meal.servings} ${meal.servings == 1 ? 'serving' : 'servings'}'),
                          ],
                        ),
                      ),
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
                        "Recipe:",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      ...meal.steps!.asMap().entries.map((entry) {
                        final index = entry.key + 1;
                        final step = entry.value;
                        return Text('$index. $step');
                      }).toList(),
                      const SizedBox(height: 16),
                      const Text(
                        "Dish types:",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      ...meal.dishTypes!.map((dishType) {
                        return Text(dishType);
                      }).toList(),
                      const SizedBox(height: 16),
                    ],
                  ),
                ),
              ),
              Positioned(
                bottom: 20,
                right: 20,
                child: IconButton(
                  icon: const Icon(Icons.favorite),
                  onPressed: () {
                    // akcja wykonywana po kliknięciu ikony
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class MealDetailsNutritionsRow extends StatelessWidget {
  final Meal meal;

  const MealDetailsNutritionsRow({Key? key, required this.meal}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _buildNutritionItem(
          context,
          meal.calories.round().toString(),
          'kcal',
        ),
        _buildNutritionItem(
          context,
          '${meal.proteins.round().toString()}g',
          'protein',
        ),
        _buildNutritionItem(
          context,
          '${meal.fats.round().toString()}g',
          'fat',
        ),
        _buildNutritionItem(
          context,
          '${meal.carbs.round().toString()}g',
          'carbs',
        ),
      ],
    );
  }

  Widget _buildNutritionItem(
    BuildContext context,
    String value,
    String nutrient,
  ) {
    final theme = Theme.of(context);
    final textStyle = theme.textTheme.bodyMedium!.copyWith(
      color: theme.colorScheme.onSecondaryContainer,
    );

    return Card(
      child: SizedBox(
        width: 70,
        height: 70,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              value,
              style: textStyle.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              nutrient,
              style: textStyle,
            ),
          ],
        ),
      ),
    );
  }
}
