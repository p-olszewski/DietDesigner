import 'package:diet_designer/models/comment.dart';
import 'package:diet_designer/models/nutrition_plan.dart';
import 'package:diet_designer/providers/user_data_provider.dart';
import 'package:diet_designer/services/firestore_service.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class CommentInput extends StatefulWidget {
  const CommentInput({
    super.key,
    required this.nutritionPlan,
  });

  final NutritionPlan nutritionPlan;

  @override
  State<CommentInput> createState() => _CommentInputState();
}

class _CommentInputState extends State<CommentInput> {
  final TextEditingController _commentController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 12.0),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.5),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
          borderRadius: BorderRadius.circular(12),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 4.0),
          child: Row(
            children: [
              Expanded(
                child: TextFormField(
                  controller: _commentController,
                  decoration: const InputDecoration(
                    labelText: 'Type a comment...',
                    border: InputBorder.none,
                    floatingLabelBehavior: FloatingLabelBehavior.never,
                    isDense: true,
                    contentPadding: EdgeInsets.only(bottom: 16.0, left: 8.0),
                  ),
                ),
              ),
              IconButton(
                color: Theme.of(context).primaryColor,
                onPressed: () async => await _sendComment(),
                icon: const Icon(Icons.send),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future _sendComment() async {
    final planId = '${widget.nutritionPlan.uid}_${widget.nutritionPlan.date}';
    final user = context.read<UserDataProvider>().user;
    final currentUserName = '${user.firstname} ${user.lastname}';
    final comment = Comment(
      content: _commentController.text,
      date: DateTime.now(),
      userName: currentUserName,
      userAvatar: user.avatarBase64!,
    );
    await addCommentToCollection(planId, comment);
    _commentController.clear();
  }
}
