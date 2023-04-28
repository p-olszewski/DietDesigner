import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:diet_designer/providers/auth_provider.dart';
import 'package:diet_designer/providers/shopping_list_provider.dart';
import 'package:diet_designer/services/firestore_service.dart';
import 'package:diet_designer/widgets/new_list_dialog.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ShoppingListTab extends StatefulWidget {
  const ShoppingListTab({super.key});

  @override
  State<ShoppingListTab> createState() => _ShoppingListTabState();
}

class _ShoppingListTabState extends State<ShoppingListTab> {
  late Stream<QuerySnapshot<Map<String, dynamic>>> snapshot;
  final bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    snapshot = getShoppingLists(context.read<AuthProvider>().uid!);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 14.0),
              child: Text(
                "Your lists:",
                style: Theme.of(context).textTheme.headlineMedium!.copyWith(fontWeight: FontWeight.bold),
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    _isLoading
                        ? const Center(child: CircularProgressIndicator())
                        : StreamBuilder(
                            stream: snapshot,
                            builder: (context, snapshot) {
                              if (snapshot.hasData) {
                                if (snapshot.data!.docs.isEmpty) {
                                  return SizedBox(
                                    width: double.infinity,
                                    height: MediaQuery.of(context).size.height * 0.6,
                                    child: const Align(
                                      alignment: Alignment.center,
                                      child: Text('No shopping lists yet.'),
                                    ),
                                  );
                                } else {
                                  return ListView.builder(
                                    physics: const ScrollPhysics(),
                                    scrollDirection: Axis.vertical,
                                    shrinkWrap: true,
                                    itemCount: snapshot.data!.docs.length,
                                    itemBuilder: (context, index) {
                                      var doc = snapshot.data!.docs[index];
                                      return Card(
                                        child: ListTile(
                                          title: Text(doc['title']),
                                          subtitle: Text('Items: ${doc['itemsCounter']}'),
                                          trailing: const Icon(Icons.arrow_forward),
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(10),
                                          ),
                                          onTap: () {
                                            if (!mounted) return;
                                            context.read<ShoppingListProvider>().setListId(doc.reference.id);
                                            context.read<ShoppingListProvider>().setListTitle(doc['title']);
                                            context.read<ShoppingListProvider>().countItems(doc.reference.id);
                                            Navigator.pushNamed(context, '/shopping_list_details');
                                          },
                                          onLongPress: () {
                                            showDialog(
                                              context: context,
                                              builder: (context) => AlertDialog(
                                                title: const Text('Are you sure?'),
                                                content: const Text('Do you want to delete this shopping list?'),
                                                actions: [
                                                  TextButton(
                                                    onPressed: () {
                                                      Navigator.of(context).pop();
                                                    },
                                                    child: const Text('No'),
                                                  ),
                                                  FilledButton(
                                                    onPressed: () {
                                                      deleteShoppingList(doc.reference.id);
                                                      Navigator.of(context).pop();
                                                    },
                                                    child: const Text('Yes'),
                                                  )
                                                ],
                                              ),
                                            );
                                          },
                                        ),
                                      );
                                    },
                                  );
                                }
                              } else {
                                return const Center(child: CircularProgressIndicator());
                              }
                            },
                          ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => showDialog(
          context: context,
          builder: (context) => const NewListDialog(),
        ),
        child: const Icon(Icons.add),
      ),
    );
  }
}
