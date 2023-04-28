import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:diet_designer/models/list_element.dart';
import 'package:diet_designer/services/firestore_service.dart';
import 'package:diet_designer/shared/shared.dart';
import 'package:flutter/material.dart';

class ShoppingListDetailsScreen extends StatefulWidget {
  final String listId;
  final String listTitle;

  const ShoppingListDetailsScreen({super.key, required this.listId, required this.listTitle});

  @override
  State<ShoppingListDetailsScreen> createState() => _ShoppingListDetailsScreenState();
}

class _ShoppingListDetailsScreenState extends State<ShoppingListDetailsScreen> {
  late Stream<QuerySnapshot<Map<String, dynamic>>> snapshot;
  final bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    snapshot = getShoppingListElements(widget.listId);
  }

  @override
  Widget build(BuildContext context) {
    var screenWidth = MediaQuery.of(context).size.width;
    var screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.listTitle),
        actions: [
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.edit),
          ),
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.manage_accounts),
          ),
        ],
      ),
      body: SizedBox(
        width: screenWidth,
        height: screenHeight,
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: Column(
                  children: [
                    const SizedBox(height: 40),
                    StreamBuilder<QuerySnapshot>(
                      stream: snapshot,
                      builder: (context, snapshot) {
                        if (!snapshot.hasData) {
                          return const Center(
                            child: CircularProgressIndicator(),
                          );
                        }
                        return ListView.builder(
                          shrinkWrap: true,
                          padding: const EdgeInsets.all(8),
                          itemCount: snapshot.data!.docs.length,
                          itemBuilder: (BuildContext context, int index) {
                            var doc = snapshot.data!.docs[index];
                            return ListElementCard(doc: doc, listId: widget.listId);
                          },
                        );
                      },
                    ),
                  ],
                ),
              ),
      ),
    );
  }
}

class ListElementCard extends StatelessWidget {
  const ListElementCard({super.key, required this.doc, required this.listId});

  final QueryDocumentSnapshot<Object?> doc;
  final String listId;

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: ValueKey(doc.id),
      onDismissed: (direction) {
        deleteListElement(listId, doc.id);
        PopupMessenger.info('${doc['name']} has been deleted');
      },
      background: const Card(
        color: Colors.red,
        child: Padding(
          padding: EdgeInsets.only(right: 16),
          child: Icon(
            Icons.delete,
            color: Colors.white,
          ),
        ),
      ),
      child: Card(
        child: ListTile(
          title: Row(
            children: [
              Checkbox(
                value: doc['bought'],
                onChanged: (bool? value) {
                  updateListElement(
                    ListElement(
                      name: doc['name'],
                      bought: value!,
                      order: doc['order'],
                    ),
                    listId,
                    doc.id,
                  );
                },
              ),
              Expanded(
                child: Text(doc['name']),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
