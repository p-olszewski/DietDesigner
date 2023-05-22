import 'dart:convert';

import 'package:diet_designer/models/user.dart';
import 'package:diet_designer/providers/auth_provider.dart';
import 'package:diet_designer/providers/user_data_provider.dart';
import 'package:diet_designer/services/firestore_service.dart';
import 'package:diet_designer/shared/shared.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class FriendsScreen extends StatefulWidget {
  const FriendsScreen({super.key});

  @override
  State<FriendsScreen> createState() => _FriendsScreenState();
}

class _FriendsScreenState extends State<FriendsScreen> {
  late Future<List<User>>? _friends;

  @override
  void initState() {
    super.initState();
    _friends = getFriends(context.read<AuthProvider>().uid!);
  }

  @override
  Widget build(BuildContext context) {
    var screenWidth = MediaQuery.of(context).size.width;
    var screenHeight = MediaQuery.of(context).size.height;
    final user = context.watch<UserDataProvider>().user;

    return Scaffold(
        appBar: AppBar(
          title: Text('${user.firstname!} ${user.lastname!}'),
        ),
        body: SizedBox(
          width: screenWidth,
          height: screenHeight,
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 10.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 12.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Your friends:",
                          style: Theme.of(context).textTheme.headlineMedium!.copyWith(fontWeight: FontWeight.bold),
                        ),
                        Row(
                          children: [
                            const Icon(Icons.info_outline, color: Colors.grey, size: 12),
                            Text(
                              "  You will be added to their friends list as well.",
                              style: Theme.of(context).textTheme.labelMedium!.copyWith(color: Colors.grey),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),
                  FutureBuilder<List<User>>(
                    future: _friends,
                    builder: (context, snapshot) {
                      if (snapshot.hasData) {
                        return snapshot.data!.isEmpty
                            ? SizedBox(
                                width: double.infinity,
                                height: MediaQuery.of(context).size.height * 0.6,
                                child: const Align(
                                  alignment: Alignment.center,
                                  child: Text('You have no friends yet.'),
                                ),
                              )
                            : ListView.builder(
                                physics: const ScrollPhysics(),
                                shrinkWrap: true,
                                itemCount: snapshot.data!.length,
                                itemBuilder: (context, index) {
                                  return _buildFriendCard(snapshot, index, context);
                                },
                              );
                      } else if (snapshot.hasError) {
                        return Text(snapshot.error.toString());
                      }
                      return const Center(child: CircularProgressIndicator());
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () async => await showDialog(
            context: context,
            builder: (context) => const _AddFriendDialog(),
          ).then(
            (value) => setState(() {
              _friends = getFriends(context.read<AuthProvider>().uid!);
            }),
          ),
          child: const Icon(Icons.add),
        ));
  }

  Container _buildFriendCard(AsyncSnapshot<List<User>> snapshot, int index, BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 5),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.3),
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 5.0),
        child: Row(
          children: [
            Padding(
              padding: const EdgeInsets.all(10.0),
              child: Container(
                width: 60,
                height: 60,
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
                    image: MemoryImage(base64Decode(snapshot.data![index].avatarBase64!)),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${snapshot.data![index].firstname!} ${snapshot.data![index].lastname!}',
                    style: Theme.of(context).textTheme.titleMedium!.copyWith(fontWeight: FontWeight.bold),
                  ),
                  Text(snapshot.data![index].email!),
                ],
              ),
            ),
            IconButton(
              icon: const Icon(Icons.delete),
              onPressed: () async => _removeFriend(context.read<AuthProvider>().uid!, snapshot.data![index].email!),
            ),
          ],
        ),
      ),
    );
  }

  _removeFriend(String userId, String email) async {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Are you sure?'),
        content: Text('Do you want to delete $email from your friends?'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: const Text('No'),
          ),
          FilledButton(
            onPressed: () async {
              await removeFriend(userId, email);
              if (!mounted) return;
              Navigator.of(context).pop();
              setState(() {
                _friends = getFriends(userId);
              });
            },
            child: const Text('Yes'),
          )
        ],
      ),
    );
  }
}

class _AddFriendDialog extends StatefulWidget {
  const _AddFriendDialog();

  @override
  State<_AddFriendDialog> createState() => _AddFriendDialogState();
}

class _AddFriendDialogState extends State<_AddFriendDialog> {
  final TextEditingController _emailController = TextEditingController();
  String? _nameErrorText;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Add a friend'),
      content: Padding(
        padding: const EdgeInsets.only(top: 10),
        child: TextField(
          autofocus: true,
          controller: _emailController,
          textAlign: TextAlign.left,
          decoration: InputDecoration(
            labelText: 'Email',
            hintText: 'e.g. some@email.com',
            errorText: _nameErrorText,
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        FilledButton(
          child: const Text('Add'),
          onPressed: () async {
            if (_emailController.text.isEmpty) {
              setState(() => _nameErrorText = 'Please enter an email address.');
              return;
            }
            try {
              await addFriend(context.read<AuthProvider>().uid!, _emailController.text);
              if (!mounted) return;
              Navigator.pop(context);
              PopupMessenger.info('Added ${_emailController.text} to the list.');
              _emailController.clear();
              setState(() => _nameErrorText = null);
            } catch (e) {
              setState(() => _nameErrorText = e.toString());
            }
          },
        ),
      ],
    );
  }
}
