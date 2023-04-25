import 'package:diet_designer/models/meal.dart';
import 'package:flutter/material.dart';
import 'package:percent_indicator/percent_indicator.dart';

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
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 1,
                    offset: const Offset(1, 1),
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
                padding: const EdgeInsets.only(left: 32.0, top: 28.0, right: 32.0, bottom: 0),
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
                      const SizedBox(height: 8),
                      Text(
                        meal.title,
                        style: Theme.of(context).textTheme.headlineLarge!.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      const SizedBox(height: 12),
                      _buildIconRow(context),
                      const SizedBox(height: 40),
                      _buildNutrientsRow(context, meal),
                      const SizedBox(height: 40),
                      _buildIngredients(context, meal),
                      const SizedBox(height: 16),
                      _buildRecipe(context, meal),
                      const SizedBox(height: 16),
                      _buildDishTypes(context, meal),
                      const SizedBox(height: 16),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Row _buildIconRow(BuildContext context) {
    TextStyle? textStyle = Theme.of(context).textTheme.labelLarge!.copyWith(
          color: Colors.grey[600],
        );
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Icon(
              Icons.timer_outlined,
              size: 20,
              color: Theme.of(context).colorScheme.primary,
            ),
            Text(
              '  ${meal.readyInMinutes} min',
              style: textStyle,
            ),
          ],
        ),
        Row(
          children: [
            Icon(
              Icons.restaurant_outlined,
              size: 20,
              color: Theme.of(context).colorScheme.primary,
            ),
            Text(
              '  ${meal.servings} ${meal.servings == 1 ? 'serving' : 'servings'}',
              style: textStyle,
            ),
          ],
        ),
        Row(
          children: [
            Icon(
              Icons.paid_outlined,
              size: 20,
              color: Theme.of(context).colorScheme.primary,
            ),
            Text(
              '  ${meal.pricePerServing!.toStringAsFixed(2)}\$ ps',
              style: textStyle,
            ),
          ],
        ),
      ],
    );
  }

  _buildNutrientsRow(BuildContext context, Meal meal) {
    TextStyle? labelStyle = Theme.of(context).textTheme.labelLarge!.copyWith(
          color: Colors.grey[600],
        );

    nutrientItem(String value, String label, double percent) {
      Color progressColor = percent < 0.5
          ? Theme.of(context).colorScheme.primary
          : percent < 0.8
              ? Colors.orange
              : Colors.red;
      return CircularPercentIndicator(
        radius: 36.0,
        lineWidth: 10.0,
        percent: percent,
        progressColor: progressColor,
        backgroundColor: progressColor.withOpacity(0.2),
        center: Text(
          value,
          style: Theme.of(context).textTheme.labelLarge!.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        circularStrokeCap: CircularStrokeCap.round,
        animation: true,
        animationDuration: 600,
        footer: Text(
          label,
          style: labelStyle,
        ),
      );
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        nutrientItem(
          meal.calories.round().toString(),
          'calories',
          meal.calories / 3000,
        ),
        nutrientItem(
          '${meal.proteins.round().toString()}g',
          'protein',
          meal.proteins / 200,
        ),
        nutrientItem(
          '${meal.fats.round().toString()}g',
          'fat',
          meal.fats / 50,
        ),
        nutrientItem(
          '${meal.carbs.round().toString()}g',
          'carbs',
          meal.carbs / 300,
        ),
      ],
    );
  }

  Column _buildIngredients(BuildContext context, Meal meal) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Ingredients:",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        ...meal.ingredients!.map((ingredient) {
          return Text('${ingredient['amount']} ${ingredient['unit']} ${ingredient['name']}');
        }).toList(),
      ],
    );
  }

  _buildRecipe(BuildContext context, Meal meal) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Recipe:",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        ...meal.steps!.asMap().entries.map((entry) {
          final index = entry.key + 1;
          final step = entry.value;
          return Text('$index. $step');
        }).toList(),
      ],
    );
  }

  _buildDishTypes(BuildContext context, Meal meal) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Dish types:",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        ...meal.dishTypes!.map((dishType) {
          return Text(dishType);
        }).toList(),
      ],
    );
  }
}
