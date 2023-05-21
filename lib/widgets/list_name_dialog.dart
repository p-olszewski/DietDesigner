import 'package:diet_designer/providers/shopping_list_provider.dart';
import 'package:diet_designer/services/firestore_service.dart';
import 'package:diet_designer/shared/popup_messenger.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ListNameDialog extends StatefulWidget {
  const ListNameDialog({super.key});

  @override
  State<ListNameDialog> createState() => _ListNameDialogState();
}

class _ListNameDialogState extends State<ListNameDialog> {
  final TextEditingController _titleController = TextEditingController();
  late String listId;
  String? _nameErrorText;

  @override
  void initState() {
    super.initState();
    listId = context.read<ShoppingListProvider>().listId;
  }

  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    _titleController.text = context.read<ShoppingListProvider>().listTitle;

    return AlertDialog(
      title: const Text('Edit list name'),
      content: TextField(
        autofocus: true,
        controller: _titleController,
        textAlign: TextAlign.left,
        decoration: InputDecoration(
          labelText: 'List name',
          hintText: 'e.g. Lidl',
          errorText: _nameErrorText,
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: () => updateListName(),
          child: const Text('Save'),
        ),
      ],
    );
  }

  Future<void> updateListName() async {
    if (_titleController.text.isEmpty) {
      setState(() => _nameErrorText = 'Please enter a list name.');
      return;
    }
    try {
      await updateShoppingListName(listId, _titleController.text);
      if (!mounted) return;
      context.read<ShoppingListProvider>().setListTitle(_titleController.text);
      Navigator.of(context).pop();
      PopupMessenger.info('List name updated.');
      _titleController.clear();
      setState(() => _nameErrorText = null);
    } catch (e) {
      setState(() => _nameErrorText = e.toString());
    }
  }
}
