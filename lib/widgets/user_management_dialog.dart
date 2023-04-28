import 'package:diet_designer/providers/shopping_list_provider.dart';
import 'package:diet_designer/services/firestore_service.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:provider/provider.dart';

class UserManagementDialog extends StatefulWidget {
  const UserManagementDialog({super.key});

  @override
  State<UserManagementDialog> createState() => _UserManagementDialogState();
}

class _UserManagementDialogState extends State<UserManagementDialog> {
  final TextEditingController _emailController = TextEditingController();
  late Future<dynamic> userEmails;
  late String listId;
  String? _nameErrorText;

  @override
  void initState() {
    super.initState();
    listId = context.read<ShoppingListProvider>().listId;
    userEmails = getShoppingListUserEmails(listId);
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
          labelText: 'Email nowego użytkownika',
          hintText: 'np. test@test.com',
          errorText: _nameErrorText,
        ),
      ),
    );

    var actionButtons = [
      TextButton(
        onPressed: () => Navigator.of(context).pop(),
        child: const Text('Anuluj'),
      ),
      ElevatedButton(
        child: const Text('Udostępnij'),
        onPressed: () async {
          if (_emailController.text.isEmpty) {
            setState(() => _nameErrorText = 'Pole wymagane');
            return;
          }
          try {
            await addUserToShoppingList(listId, _emailController.text);
            if (!mounted) return;
            Navigator.of(context).pop();
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Udostępniono listę dla ${_emailController.text}'),
                duration: const Duration(seconds: 1),
              ),
            );
            _emailController.clear();
            setState(() => _nameErrorText = null);
          } catch (e) {
            setState(() => _nameErrorText = e.toString());
          }
        },
      ),
    ];

    return AlertDialog(
      title: const Text('Zarządzaj użytkownikami'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ChipsList(userEmails: userEmails, widget: widget),
          emailAddressInput,
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
  final UserManagementDialog widget;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: userEmails,
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }
        return SizedBox(
          height: 150,
          width: 200,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: snapshot.data!.length,
            itemBuilder: (context, index) {
              return Chip(
                label: Text(snapshot.data![index]),
                labelStyle: const TextStyle(fontSize: 12),
                onDeleted: () {
                  String listId = context.read<ShoppingListProvider>().listId;
                  deleteUserFromShoppingList(listId, snapshot.data![index]);
                  Navigator.of(context).pop();
                  Fluttertoast.showToast(msg: 'Usunięto ${snapshot.data![index]} z listy.');
                },
              );
            },
          ),
        );
      },
    );
  }
}
