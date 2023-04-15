import 'package:flutter/material.dart';

class ShoppingListTab extends StatefulWidget {
  const ShoppingListTab({super.key});

  @override
  State<ShoppingListTab> createState() => _ShoppingListTabState();
}

class _ShoppingListTabState extends State<ShoppingListTab> {
  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Text("Shopping list tab"),
      ),
    );
  }
}
