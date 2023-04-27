import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:diet_designer/providers/auth_provider.dart';
import 'package:diet_designer/services/firestore_service.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ShoppingListTab extends StatefulWidget {
  const ShoppingListTab({super.key});

  @override
  State<ShoppingListTab> createState() => _ShoppingListTabState();
}

class _ShoppingListTabState extends State<ShoppingListTab> {
  final bool _isLoading = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final uid = context.watch<AuthProvider>().uid!;

    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 12.0),
              child: Text(
                "Your lists:",
                style: Theme.of(context).textTheme.headlineMedium!.copyWith(fontWeight: FontWeight.bold),
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 24),
                      child: _isLoading
                          ? const Center(child: CircularProgressIndicator())
                          : FutureBuilder(
                              future: getShoppingLists(uid),
                              builder: (context, AsyncSnapshot<QuerySnapshot<Map<String, dynamic>>> snapshot) {
                                if (snapshot.hasData) {
                                  if (snapshot.data!.docs.isEmpty) {
                                    return SizedBox(
                                      width: double.infinity,
                                      height: MediaQuery.of(context).size.height * 0.6,
                                      child: Align(
                                        alignment: Alignment.center,
                                        child: Column(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          crossAxisAlignment: CrossAxisAlignment.center,
                                          children: [
                                            const Text('No shopping lists yet.'),
                                            const SizedBox(height: 10),
                                            ElevatedButton(
                                              onPressed: () {},
                                              child: const Text('Generate shopping list'),
                                            ),
                                          ],
                                        ),
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
                                        return ListTile(
                                          title: Text(doc['title']),
                                          trailing: const Icon(Icons.arrow_forward),
                                          onTap: () {
                                            if (!mounted) return;
                                            Navigator.pushNamed(
                                              context,
                                              '/shopping_list_details',
                                              arguments: {
                                                'id': doc.reference.id,
                                                'title': doc['title'],
                                              },
                                            );
                                          },
                                        );
                                      },
                                    );
                                  }
                                } else {
                                  return const Center(child: CircularProgressIndicator());
                                }
                              },
                            ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
