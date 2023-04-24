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
        body: SizedBox(
          height: double.infinity,
          width: double.infinity,
          child: Stack(
            fit: StackFit.loose,
            children: [
              MealDetailsPhoto(meal: widget.meal),
              MealDetailsData(meal: widget.meal),
            ],
          ),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () => _addToFavourites(),
          child: Icon(
            isFavourite ? Icons.favorite : Icons.favorite_border,
          ),
        ));
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
            height: 350,
            decoration: BoxDecoration(
              image: DecorationImage(
                image: NetworkImage(meal.image),
                fit: BoxFit.cover,
              ),
            ),
          ),
          Positioned(
            top: 42,
            left: 21,
            child: Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(15),
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
      initialChildSize: 0.7,
      minChildSize: 0.7,
      maxChildSize: 0.90,
      builder: (context, scrollController) {
        return SafeArea(
          child: Stack(
            fit: StackFit.loose,
            children: [
              Container(
                width: MediaQuery.of(context).size.width,
                padding: const EdgeInsets.only(left: 28.0, top: 34, right: 28.0, bottom: 0),
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
                      const SizedBox(height: 24),
                      MealDetailsNutritionsRow(meal: meal),
                      const SizedBox(height: 16),
                      Text(
                          'Ready in: ${meal.readyInMinutes} min\nServings: ${meal.servings}\nPrice per serving: ${meal.pricePerServing}\$'),
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
          '${meal.calories.round().toString()}g',
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

    return Container(
      width: 80,
      height: 60,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.secondaryContainer,
        borderRadius: BorderRadius.circular(16),
      ),
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
    );
  }
}
