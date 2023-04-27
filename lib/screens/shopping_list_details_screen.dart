import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:diet_designer/services/firestore_service.dart';
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
    snapshot = getShoppingListProducts(widget.listId);
  }

  @override
  Widget build(BuildContext context) {
    var screenWidth = MediaQuery.of(context).size.width;
    var screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.listTitle),
      ),
      body: SizedBox(
        width: screenWidth,
        height: screenHeight,
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : Column(
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
                        physics: const AlwaysScrollableScrollPhysics(),
                        scrollDirection: Axis.vertical,
                        shrinkWrap: true,
                        padding: const EdgeInsets.all(8),
                        itemCount: snapshot.data!.docs.length,
                        itemBuilder: (BuildContext context, int index) {
                          var doc = snapshot.data!.docs[index];
                          return ListTile(
                            title: Text(doc['name']),
                          );
                        },
                      );
                    },
                  ),
                ],
              ),
      ),
    );
  }
}
