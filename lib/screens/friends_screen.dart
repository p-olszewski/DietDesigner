import 'package:diet_designer/providers/auth_provider.dart';
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
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Friends'),
        ),
        body: const Padding(
          padding: EdgeInsets.all(24.0),
          child: Center(
            child: Text('Friends'),
          ),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () => showDialog(
            context: context,
            builder: (context) => const _AddFriendDialog(),
          ),
          child: const Icon(Icons.add),
        ));
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
  void initState() {
    super.initState();
  }

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
            hintText: 'e.g. test@test.com',
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
