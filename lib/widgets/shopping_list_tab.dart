import 'package:flutter/material.dart';

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
                  children: const [
                    Card(
                      child: ListTile(
                        title: Text("Shopping list 1"),
                        subtitle: Text("Created 3 days ago"),
                        trailing: Icon(Icons.arrow_forward_ios),
                      ),
                    ),
                    Card(
                      child: ListTile(
                        title: Text("Shopping list 2"),
                        subtitle: Text("Created 2 days ago"),
                        trailing: Icon(Icons.arrow_forward_ios),
                      ),
                    ),
                    Card(
                      child: ListTile(
                        title: Text("Shopping list 3"),
                        subtitle: Text("Created 1 day ago"),
                        trailing: Icon(Icons.arrow_forward_ios),
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
