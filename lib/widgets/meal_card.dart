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
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 2),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.4),
            spreadRadius: 1,
            blurRadius: 6,
            offset: const Offset(1, 1),
          ),
        ],
        borderRadius: BorderRadius.circular(18.0),
      ),
      child: Column(
        children: [MealPhoto(meal: meal), MealDescription(meal: meal)],
      ),
    );
  }
}

class MealPhoto extends StatelessWidget {
  const MealPhoto({
    super.key,
    required this.meal,
  });

  final Meal meal;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(18),
          topRight: Radius.circular(18),
        ),
        image: DecorationImage(
          fit: BoxFit.cover,
          image: NetworkImage(meal.imageMedium),
        ),
      ),
      child: AspectRatio(
        aspectRatio: 2,
        child: Container(),
      ),
    );
  }
}

class MealDescription extends StatelessWidget {
  const MealDescription({
    super.key,
    required this.meal,
  });

  final Meal meal;

  @override
  Widget build(BuildContext context) {
    TextStyle titleStyle = Theme.of(context).textTheme.titleLarge!.copyWith(fontWeight: FontWeight.bold);
    TextStyle labelStyle = Theme.of(context).textTheme.labelMedium!.copyWith(color: Colors.grey[600]);
    const iconSize = 16.0;
    return Padding(
      padding: const EdgeInsets.only(left: 12.0, right: 12.0, top: 12.0, bottom: 14.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            meal.title,
            style: titleStyle,
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.timer_outlined,
                    size: iconSize,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  Text('  ${meal.readyInMinutes} min', style: labelStyle),
                ],
              ),
              Row(
                children: [
                  Icon(
                    Icons.restaurant_outlined,
                    size: iconSize,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  Text('  ${meal.servings} ${meal.servings == 1 ? 'serving' : 'servings'}', style: labelStyle),
                ],
              ),
              Row(
                children: [
                  Icon(
                    Icons.paid_outlined,
                    size: iconSize,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  Text('  ${meal.pricePerServing!.toStringAsFixed(2)}\$ ps', style: labelStyle),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}
