import 'package:diet_designer/models/list_element.dart';
import 'package:diet_designer/providers/shopping_list_provider.dart';
import 'package:diet_designer/services/firestore_service.dart';
import 'package:diet_designer/shared/popup_messenger.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class AddProductDialog extends StatefulWidget {
  const AddProductDialog({super.key});

  @override
  State<AddProductDialog> createState() => _AddProductDialogState();
}

class _AddProductDialogState extends State<AddProductDialog> {
  final TextEditingController _titleController = TextEditingController();
  late String _listId;
  String? _nameErrorText;

  @override
  void initState() {
    super.initState();
    _listId = context.read<ShoppingListProvider>().listId;
  }

  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Add product'),
      content: TextField(
        autofocus: true,
        controller: _titleController,
        textAlign: TextAlign.left,
        decoration: InputDecoration(
          labelText: 'Product name',
          hintText: 'e.g. bread',
          errorText: _nameErrorText,
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        FilledButton(
          child: const Text('Save'),
          onPressed: () => _addProduct(),
        ),
      ],
    );
  }

  Future<void> _addProduct() async {
    if (_titleController.text.isEmpty) {
      setState(() => _nameErrorText = 'Please enter a name.');
      return;
    }
    try {
      final name = _titleController.text;
      final order = await getMaxOrder(_listId);
      await addProductToShoppingList(ListElement(name: name, order: order), _listId);
      countAndUpdateItemsCounter(_listId);
      if (!mounted) return;
      Navigator.of(context).pop();
      context.read<ShoppingListProvider>().countItems(_listId);
      PopupMessenger.info('Product added.');
      _titleController.clear();
      setState(() => _nameErrorText = null);
    } catch (e) {
      setState(() => _nameErrorText = e.toString());
    }
  }
}
