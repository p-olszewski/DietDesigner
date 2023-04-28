import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:diet_designer/providers/shopping_list_provider.dart';
import 'package:diet_designer/services/firestore_service.dart';
import 'package:diet_designer/widgets/list_name_dialog.dart';
import 'package:diet_designer/widgets/products_list_tile.dart';
import 'package:diet_designer/widgets/user_management_dialog.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ShoppingListDetailsScreen extends StatefulWidget {
  const ShoppingListDetailsScreen({super.key});

  @override
  State<ShoppingListDetailsScreen> createState() => _ShoppingListDetailsScreenState();
}

class _ShoppingListDetailsScreenState extends State<ShoppingListDetailsScreen> {
  late Stream<QuerySnapshot<Map<String, dynamic>>> snapshot;
  final bool _isLoading = false;
  late String listId;

  @override
  void initState() {
    super.initState();
    listId = context.read<ShoppingListProvider>().listId;
    snapshot = getShoppingListElements(listId);
  }

  @override
  Widget build(BuildContext context) {
    var screenWidth = MediaQuery.of(context).size.width;
    var screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      appBar: AppBar(
        title: Text(context.watch<ShoppingListProvider>().listTitle),
        actions: [
          IconButton(
            onPressed: () => showDialog(
              context: context,
              builder: (context) => const ListNameDialog(),
            ),
            icon: const Icon(Icons.edit),
          ),
          IconButton(
            onPressed: () => showDialog(
              context: context,
              builder: (context) => const UserManagementDialog(),
            ),
            icon: const Icon(Icons.manage_accounts),
          ),
        ],
      ),
      body: SizedBox(
        width: screenWidth,
        height: screenHeight,
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 14.0),
                  child: Text(
                    "Products:",
                    style: Theme.of(context).textTheme.headlineMedium!.copyWith(fontWeight: FontWeight.bold),
                  ),
                ),
                _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : SingleChildScrollView(
                        child: Column(
                          children: [
                            StreamBuilder<QuerySnapshot>(
                              stream: snapshot,
                              builder: (context, snapshot) {
                                if (!snapshot.hasData) {
                                  return const Center(
                                    child: CircularProgressIndicator(),
                                  );
                                }
                                return ListView.builder(
                                  physics: const ScrollPhysics(),
                                  shrinkWrap: true,
                                  itemCount: snapshot.data!.docs.length,
                                  itemBuilder: (BuildContext context, int index) {
                                    var doc = snapshot.data!.docs[index];
                                    return ProductListTile(doc: doc);
                                  },
                                );
                              },
                            ),
                          ],
                        ),
                      ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
