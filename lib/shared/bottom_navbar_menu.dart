import 'package:diet_designer/providers/navbar_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class BottomNavbarMenu extends StatelessWidget {
  const BottomNavbarMenu({super.key});

  @override
  Widget build(BuildContext context) {
    return NavigationBar(
      selectedIndex: context.watch<NavBarProvider>().currentIndex,
      onDestinationSelected: (int newIndex) => context.read<NavBarProvider>().setCurrentIndex(newIndex),
      labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
      destinations: const [
        NavigationDestination(
          icon: Icon(Icons.home),
          label: 'Home',
        ),
        NavigationDestination(
          icon: Icon(Icons.calculate),
          label: 'Calculator',
        ),
        NavigationDestination(
          icon: Icon(Icons.account_circle),
          label: 'Account',
        ),
      ],
    );
  }
}
