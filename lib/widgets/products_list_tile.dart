import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:diet_designer/models/list_element.dart';
import 'package:diet_designer/providers/shopping_list_provider.dart';
import 'package:diet_designer/services/firestore_service.dart';
import 'package:diet_designer/shared/shared.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ProductListTile extends StatefulWidget {
  const ProductListTile({super.key, required this.doc});

  final QueryDocumentSnapshot<Object?> doc;

  @override
  State<ProductListTile> createState() => _ProductListTileState();
}

class _ProductListTileState extends State<ProductListTile> {
  final TextEditingController nameController = TextEditingController();
  String? _nameErrorText;
  late String listId;

  @override
  void initState() {
    super.initState();
    nameController.text = widget.doc['name'];
    listId = context.read<ShoppingListProvider>().listId;
  }

  @override
  void dispose() {
    nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: ValueKey(widget.doc.id),
      onDismissed: (direction) {
        countAndUpdateItemsCounter(listId);
        deleteListElement(listId, widget.doc.id);
        PopupMessenger.info('${widget.doc['name']} deleted.');
      },
      background: Container(
        decoration: BoxDecoration(
          borderRadius: const BorderRadius.all(Radius.circular(8)),
          color: Theme.of(context).colorScheme.error,
        ),
        child: const Padding(
          padding: EdgeInsets.only(right: 16),
          child: Icon(
            Icons.delete,
            color: Colors.white,
          ),
        ),
      ),
      child: ListTile(
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(8)),
        ),
        title: Row(
          children: [
            Checkbox(
              value: widget.doc['bought'],
              onChanged: (bool? value) {
                updateListElement(
                  ListElement(
                    name: widget.doc['name'],
                    bought: value!,
                    order: widget.doc['order'],
                  ),
                  listId,
                  widget.doc.id,
                );
              },
            ),
            Expanded(
              child: Text(widget.doc['name']),
            ),
          ],
        ),
        onTap: () => showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Edit product'),
            content: Column(mainAxisSize: MainAxisSize.min, children: [
              TextFormField(
                controller: nameController,
                textAlign: TextAlign.left,
                decoration: InputDecoration(
                  labelText: 'Product name',
                  hintText: 'e.g. bread',
                  errorText: _nameErrorText,
                ),
              ),
            ]),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Cancel'),
              ),
              FilledButton(
                onPressed: () async {
                  FocusScope.of(context).requestFocus(FocusNode());
                  if (nameController.text.isEmpty) {
                    setState(() => _nameErrorText = 'Field cannot be empty!');
                    return;
                  }
                  try {
                    final name = nameController.text;
                    await updateListElement(
                        ListElement(
                          name: name,
                          order: widget.doc['order'],
                        ),
                        listId,
                        widget.doc.id);
                    PopupMessenger.info('Product name updated.');
                    setState(() => _nameErrorText = null);
                  } catch (e) {
                    // error handling
                  }
                  if (!mounted) return;
                  Navigator.of(context).pop();
                },
                child: const Text('Save'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
