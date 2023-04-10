
import 'package:flutter/material.dart';

class DrawerMenu extends StatelessWidget {
  const DrawerMenu({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Column(
        children: [
          const SizedBox(height: 70),
          const CircleAvatar(
            radius: 50,
            backgroundImage: NetworkImage("https://i.pravatar.cc/300"),
          ),
          const SizedBox(height: 30),
          TextButton(
            onPressed: () {},
            child: const Text("Szczegóły konta"),
          ),
          TextButton(
            onPressed: () {},
            child: const Text("Ustawienia"),
          ),
          TextButton(
            onPressed: () {},
            child: const Text("Wyloguj"),
          ),
        ],
      ),
    );
  }
}
