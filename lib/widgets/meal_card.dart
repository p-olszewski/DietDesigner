import 'package:flutter/material.dart';

class MealCard extends StatelessWidget {
  const MealCard({
    super.key,
    required this.meal,
  });

  final dynamic meal;

/* card to display each meal */
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 20),
        Text("${meal['title']} - ${meal['calories']} kcal, ${meal['protein']}g/${meal['fat']}g/${meal['carbs']}g"),
        Card(
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
            leading: Container(
              width: 60,
              height: 60,
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
                  image: NetworkImage(meal['image']),
                ),
              ),
            ),
            title: Text(meal['title']),
            subtitle: Text(
              '${meal['calories']} kcal\n${meal['protein']} protein, ${meal['fat']} fat, ${meal['carbs']} carbs',
            ),
          ),
        ),
      ],
    );
  }
}
