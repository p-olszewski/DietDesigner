import 'dart:convert';

import 'package:diet_designer/models/user.dart';
import 'package:diet_designer/providers/auth_provider.dart';
import 'package:diet_designer/providers/user_data_provider.dart';
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
    User user = context.read<UserDataProvider>().user;

    return Drawer(
      backgroundColor: Theme.of(context).colorScheme.onPrimary,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 30),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 90),
            Row(
              children: [
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.5),
                        blurRadius: 10,
                        offset: const Offset(0, 3),
                      ),
                    ],
                    image: DecorationImage(
                      image: MemoryImage(base64Decode(user.avatarBase64!)),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                const SizedBox(width: 20),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      user.firstname!,
                      style: Theme.of(context).textTheme.titleLarge!.copyWith(fontWeight: FontWeight.bold),
                    ),
                    Text(
                      user.lastname!,
                      style: Theme.of(context).textTheme.labelMedium!.copyWith(color: Colors.grey),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 50),
            TextButton.icon(
              icon: const Icon(Icons.account_circle_outlined),
              onPressed: () {
                if (!mounted) return;
                Navigator.pop(context);
                Navigator.pushNamed(context, "/account_details");
              },
              label: const Text("Account details"),
            ),
            TextButton.icon(
              icon: const Icon(Icons.share_outlined),
              onPressed: () {
                Navigator.pushNamed(context, "/shared_nutrition_plans");
              },
              label: const Text("Shared nutrition plans"),
            ),
            TextButton.icon(
              icon: const Icon(Icons.group_outlined),
              onPressed: () {
                Navigator.pushNamed(context, "/friends");
              },
              label: const Text("Friends"),
            ),
            TextButton.icon(
              icon: const Icon(Icons.contact_support_outlined),
              onPressed: () {
                Navigator.pushNamed(context, "/contact");
              },
              label: const Text("Contact"),
            ),
            TextButton.icon(
              icon: const Icon(Icons.logout_outlined),
              onPressed: () async {
                bool shouldRedirect = await context.read<AuthProvider>().signOut();
                if (shouldRedirect) {
                  PopupMessenger.info('You have been logged out!');
                  if (!mounted) return;
                  Navigator.pushNamed(context, "/login");
                }
              },
              label: const Text("Logout"),
            ),
            const Spacer(),
            const Logo(fontSize: 16),
            const Text(
              "© 2023 Przemysław Olszewski",
              style: TextStyle(fontSize: 10, color: Colors.grey),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}
