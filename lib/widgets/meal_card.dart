import 'package:diet_designer/models/meal.dart';
import 'package:diet_designer/shared/popup_messenger.dart';
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

class MealCardContainer extends StatelessWidget {
  const MealCardContainer({
    super.key,
    required this.meal,
  });

  final Meal meal;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Card(
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
                    image: NetworkImage(meal.imageThumbnail),
                  ),
                ),
              ),
            ),
            title: Text(meal.title),
            subtitle: Text(
              '${meal.calories} kcal\n${meal.proteins} protein, ${meal.fats} fat, ${meal.carbs} carbs',
            ),
          ),
        ),
        Positioned(
          top: 0,
          right: 0,
          child: IconButton(
            icon: const Icon(
              Icons.replay,
              size: 16,
            ),
            onPressed: () => PopupMessenger.info('Not implemented yet'),
          ),
        ),
      ],
    );
  }
}
