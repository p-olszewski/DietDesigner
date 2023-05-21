import 'package:diet_designer/providers/auth_provider.dart';
import 'package:diet_designer/providers/shopping_list_provider.dart';
import 'package:diet_designer/services/firestore_service.dart';
import 'package:diet_designer/shared/popup_messenger.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ShoppingListUserManagementDialog extends StatefulWidget {
  const ShoppingListUserManagementDialog({super.key});

  @override
  State<ShoppingListUserManagementDialog> createState() => _ShoppingListUserManagementDialogState();
}

class _ShoppingListUserManagementDialogState extends State<ShoppingListUserManagementDialog> {
  final TextEditingController _emailController = TextEditingController();
  late Future<dynamic> userEmails;
  late Future<dynamic> friendsList;
  late String listId;
  String? _nameErrorText;

  @override
  void initState() {
    super.initState();
    listId = context.read<ShoppingListProvider>().listId;
    userEmails = getShoppingListUserEmails(listId);
    friendsList = getFriends(context.read<AuthProvider>().uid!);
  }

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var emailAddressInput = Padding(
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
    );

    var actionButtons = [
      TextButton(
        onPressed: () => Navigator.of(context).pop(),
        child: const Text('Cancel'),
      ),
      FilledButton(
        child: const Text('Share'),
        onPressed: () async {
          if (_emailController.text.isEmpty) {
            setState(() => _nameErrorText = 'Please enter an email address.');
            return;
          }
          try {
            await shareShoppingListToUser(listId, _emailController.text);
            if (!mounted) return;
            Navigator.of(context).pop();
            PopupMessenger.info('Added ${_emailController.text} to the list.');
            _emailController.clear();
            setState(() => _nameErrorText = null);
          } catch (e) {
            setState(() => _nameErrorText = e.toString());
          }
        },
      ),
    ];

    return AlertDialog(
      title: const Text('Manage users'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ChipsList(userEmails: userEmails, widget: widget),
          emailAddressInput,
          Row(
            children: [
              FutureBuilder(
                future: friendsList,
                builder: (context, snapshot) {
                  if (!snapshot.hasData || snapshot.data.isEmpty) {
                    return const SizedBox.shrink();
                  }
                  return Wrap(
                    crossAxisAlignment: WrapCrossAlignment.start,
                    children: [
                      const Padding(
                        padding: EdgeInsets.only(left: 0, top: 14, right: 6, bottom: 4),
                        child: Text(
                          'Friends:',
                          style: TextStyle(color: Colors.grey),
                        ),
                      ),
                      ...snapshot.data.map((friend) => TextButton(
                            child: Text(friend.email),
                            onPressed: () async {
                              _emailController.text = friend.email;
                            },
                          )),
                    ],
                  );
                },
              ),
            ],
          ),
        ],
      ),
      actions: actionButtons,
    );
  }
}

class ChipsList extends StatelessWidget {
  const ChipsList({
    super.key,
    required this.userEmails,
    required this.widget,
  });

  final Future userEmails;
  final ShoppingListUserManagementDialog widget;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: userEmails,
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }
        return SizedBox(
          height: (50 * snapshot.data!.length).toDouble(),
          width: 300,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: snapshot.data!.length,
            itemBuilder: (context, index) {
              return Chip(
                label: Text(snapshot.data![index]),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(50),
                ),
                onDeleted: () {
                  String listId = context.read<ShoppingListProvider>().listId;
                  deleteUserFromShoppingList(listId, snapshot.data![index]);
                  Navigator.of(context).pop();
                  PopupMessenger.info('Removed ${snapshot.data![index]} from the list.');
                },
              );
            },
          ),
        );
      },
    );
  }
}
