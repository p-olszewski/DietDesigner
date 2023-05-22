import 'package:diet_designer/models/nutrition_plan.dart';
import 'package:flutter/material.dart';

class CommentsScreen extends StatefulWidget {
  const CommentsScreen({super.key, required this.nutritionPlan});

  final NutritionPlan nutritionPlan;

  @override
  State<CommentsScreen> createState() => _CommentsScreenState();
}

class _CommentsScreenState extends State<CommentsScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.nutritionPlan.name),
      ),
      body: const Center(
        child: Text(
          'Comments',
          style: TextStyle(fontSize: 24),
        ),
      ),
    );
  }
}
