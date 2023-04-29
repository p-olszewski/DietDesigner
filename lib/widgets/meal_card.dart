import 'package:diet_designer/models/meal.dart';
import 'package:flutter/material.dart';

class MealCard extends StatelessWidget {
  const MealCard({
    super.key,
    required this.meal,
  });

  final Meal meal;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 20),
        Text("${meal.calories.round()} kcal, ${meal.proteins.round()}g proteins, ${meal.fats.round()}g fats, ${meal.carbs.round()}g carbs"),
        MealCardContainer(meal: meal),
      ],
    );
  }
}

class MealCardContainer extends StatefulWidget {
  const MealCardContainer({
    super.key,
    required this.meal,
  });

  final Meal meal;

  @override
  State<MealCardContainer> createState() => _MealCardContainerState();
}

class _MealCardContainerState extends State<MealCardContainer> {
  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
        leading: AspectRatio(
          aspectRatio: 1,
          child: Container(
            decoration: BoxDecoration(
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  spreadRadius: 1,
                  blurRadius: 6,
                  offset: const Offset(1, 1),
                ),
              ],
              borderRadius: BorderRadius.circular(15.0),
              image: DecorationImage(
                fit: BoxFit.cover,
                image: NetworkImage(widget.meal.imageThumbnail),
              ),
            ),
          ),
        ),
        title: Text(widget.meal.title),
        subtitle: Text(
          '${widget.meal.calories} kcal\n${widget.meal.proteins} protein, ${widget.meal.fats} fat, ${widget.meal.carbs} carbs',
        ),
      ),
    );
  }
}
