import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:diet_designer/models/comment.dart';
import 'package:diet_designer/providers/user_data_provider.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class CommentsStream extends StatelessWidget {
  const CommentsStream({
    super.key,
    required bool isLoading,
    required Stream<QuerySnapshot<Map<String, dynamic>>> snapshot,
  })  : _isLoading = isLoading,
        _snapshot = snapshot;

  final bool _isLoading;
  final Stream<QuerySnapshot<Map<String, dynamic>>> _snapshot;

  @override
  Widget build(BuildContext context) {
    final currentUserName = '${context.read<UserDataProvider>().user.firstname} ${context.read<UserDataProvider>().user.lastname}';
    final screenHeight = MediaQuery.of(context).size.height;
    return Expanded(
      child: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 10),
            _isLoading
                ? const Center(child: CircularProgressIndicator())
                : StreamBuilder(
                    stream: _snapshot,
                    builder: (context, snapshot) {
                      if (snapshot.hasError) {
                        return const Center(child: Text('Something went wrong'));
                      }
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      if (snapshot.data!.docs.isEmpty) {
                        return Column(
                          children: [
                            SizedBox(height: screenHeight * 0.3),
                            const Text('No comments yet. Be the first to comment!'),
                          ],
                        );
                      }

                      final comments = snapshot.data!.docs.map((e) => Comment.fromJson(e.data())).toList();
                      return ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: comments.length,
                        itemBuilder: (context, index) {
                          final comment = comments[index];
                          final isCurrentUser = comment.userName == currentUserName;

                          return Padding(
                            padding: EdgeInsets.symmetric(
                              vertical: 4.0,
                              horizontal: isCurrentUser ? 12.0 : 12.0,
                            ),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  if (!isCurrentUser)
                                    Padding(
                                      padding: const EdgeInsets.only(right: 12.0),
                                      child: Container(
                                        width: 50,
                                        height: 50,
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          boxShadow: [
                                            BoxShadow(
                                              color: Colors.black.withOpacity(0.5),
                                              blurRadius: 10,
                                              offset: const Offset(0, 3),
                                            ),
                                          ],
                                          image: DecorationImage(
                                            image: MemoryImage(base64Decode(comment.userAvatar)),
                                            fit: BoxFit.cover,
                                          ),
                                        ),
                                      ),
                                    ),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: isCurrentUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          isCurrentUser ? 'You' : comment.userName,
                                          style: Theme.of(context).textTheme.labelMedium!.copyWith(
                                                fontWeight: FontWeight.bold,
                                              ),
                                          textAlign: isCurrentUser ? TextAlign.end : TextAlign.start,
                                        ),
                                        Text(
                                          comment.content,
                                          style: Theme.of(context).textTheme.bodyMedium,
                                          textAlign: isCurrentUser ? TextAlign.end : TextAlign.start,
                                        ),
                                        Text(
                                          DateFormat('HH:mm, dd MMM').format(comment.date),
                                          style: Theme.of(context).textTheme.labelSmall!.copyWith(
                                                color: Colors.grey,
                                              ),
                                          textAlign: isCurrentUser ? TextAlign.end : TextAlign.start,
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      );
                    },
                  ),
          ],
        ),
      ),
    );
  }
}
