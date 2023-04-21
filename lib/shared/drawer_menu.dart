import 'package:diet_designer/providers/auth_provider.dart';
import 'package:diet_designer/shared/shared.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

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
            onPressed: () => PopupMessenger.info("This feature is not yet implemented!"),
            child: const Text("Account details"),
          ),
          TextButton(
            onPressed: () {
              if (!mounted) return;
              Navigator.pushNamed(context, "/calculator");
            },
            child: const Text("Calculator"),
          ),
          TextButton(
            onPressed: () => PopupMessenger.info("This feature is not yet implemented!"),
            child: const Text("Settings"),
          ),
          TextButton(
            onPressed: () async {
              bool shouldRedirect = await context.read<AuthProvider>().signOut();
              if (shouldRedirect) {
                PopupMessenger.info('You have been logged out!');
                if (!mounted) return;
                Navigator.pushNamed(context, "/login");
              }
            },
            child: const Text("Logout"),
          ),
        ],
      ),
    );
  }
}
