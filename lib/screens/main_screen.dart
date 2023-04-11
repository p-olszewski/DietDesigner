import 'package:diet_designer/providers/navbar_provider.dart';
import 'package:diet_designer/widgets/favourites_tab.dart';
import 'package:diet_designer/widgets/home_tab.dart';
import 'package:diet_designer/widgets/shopping_list_tab.dart';
import 'package:diet_designer/shared/shared.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("DietDesigner"),
        centerTitle: true,
        elevation: 4,
        shadowColor: Theme.of(context).shadowColor,
        backgroundColor: Theme.of(context).colorScheme.primaryContainer,
      ),
      drawer: const DrawerMenu(),
      body: [
        const HomeTab(),
        const FavouritesTab(),
        const ShoppingListTab(),
      ][context.watch<NavBarProvider>().currentIndex],
      bottomNavigationBar: const BottomNavbarMenu(),
    );
  }
}
