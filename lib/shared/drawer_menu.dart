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
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 70),
        child: Column(
          children: [
            const CircleAvatar(
              radius: 50,
              backgroundImage: NetworkImage("https://i.pravatar.cc/300?img=24"),
            ),
            const SizedBox(height: 30),
            TextButton(
              onPressed: () {
                if (!mounted) return;
                Navigator.pushNamed(context, "/account_details");
              },
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
              onPressed: () {
                if (!mounted) return;
                Navigator.pushNamed(context, "/shared_nutrition_plans");
              },
              child: const Text("Shared nutrition plans"),
            ),
            TextButton(
              onPressed: () {
                if (!mounted) return;
                Navigator.pushNamed(context, "/friends");
              },
              child: const Text("Friends"),
            ),
            TextButton(
              onPressed: () {
                if (!mounted) return;
                Navigator.pushNamed(context, "/contact");
              },
              child: const Text("Contact"),
            ),
            const Spacer(),
            ElevatedButton(
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
      ),
    );
  }
}
