import 'package:diet_designer/services/auth.dart';
import 'package:diet_designer/shared/shared.dart';
import 'package:flutter/material.dart';

class DrawerMenu extends StatefulWidget {
  const DrawerMenu({
    super.key,
  });

  @override
  State<DrawerMenu> createState() => _DrawerMenuState();
}

class _DrawerMenuState extends State<DrawerMenu> {
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
            onPressed: () async {
              bool shouldRedirect = await signOut();
              if (shouldRedirect) {
                PopupMessenger.info('You have been logged out!');
                if (!mounted) return;
                Navigator.pushNamed(context, "/login");
              }
            },
            child: const Text("Wyloguj"),
          ),
        ],
      ),
    );
  }
}
