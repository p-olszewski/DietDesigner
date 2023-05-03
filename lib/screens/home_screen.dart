import 'package:diet_designer/providers/navbar_provider.dart';
import 'package:diet_designer/providers/user_data_provider.dart';
import 'package:diet_designer/widgets/favorites_tab.dart';
import 'package:diet_designer/widgets/home_tab.dart';
import 'package:diet_designer/widgets/shopping_list_tab.dart';
import 'package:diet_designer/shared/shared.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    var user = context.read<UserDataProvider>().user;
    return Scaffold(
      appBar: AppBar(
        title: Text('Hello, ${user.firstname ?? user.email}!'),
        scrolledUnderElevation: 0,
      ),
      drawer: const DrawerMenu(),
      body: [
        const HomeTab(),
        const FavoritesTab(),
        const ShoppingListTab(),
      ][context.watch<NavBarProvider>().currentIndex],
      bottomNavigationBar: const BottomNavbarMenu(),
    );
  }
}
