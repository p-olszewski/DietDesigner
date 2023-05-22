import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:diet_designer/models/nutrition_plan.dart';
import 'package:diet_designer/services/firestore_service.dart';
import 'package:diet_designer/widgets/comments_input.dart';
import 'package:diet_designer/widgets/comments_stream.dart';
import 'package:flutter/material.dart';

class CommentsScreen extends StatefulWidget {
  const CommentsScreen({super.key, required this.nutritionPlan});

  final NutritionPlan nutritionPlan;

  @override
  State<CommentsScreen> createState() => _CommentsScreenState();
}

class _CommentsScreenState extends State<CommentsScreen> {
  late Stream<QuerySnapshot<Map<String, dynamic>>> _snapshot;
  final bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    final planId = '${widget.nutritionPlan.uid}_${widget.nutritionPlan.date}';
    _snapshot = getComments(planId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.nutritionPlan.name),
      ),
      body: Column(
        children: [
          CommentsStream(isLoading: _isLoading, snapshot: _snapshot),
          CommentInput(nutritionPlan: widget.nutritionPlan),
        ],
      ),
    );
  }
}
