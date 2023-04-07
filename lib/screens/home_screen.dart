import 'package:diet_designer/services/flutterfire.dart';
import 'package:diet_designer/screens/login_screen.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("DietDesigner"),
        centerTitle: true,
        elevation: 4,
        shadowColor: Theme.of(context).shadowColor,
        backgroundColor: Theme.of(context).colorScheme.primaryContainer,
        leading: IconButton(
          onPressed: () {},
          icon: const Icon(Icons.menu),
        ),
        actions: [
          IconButton(
            onPressed: () async {
              bool shouldRedirect = await signOut();
              if (shouldRedirect) {
                if (!mounted) return;
                Fluttertoast.showToast(msg: "Logged out");
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const LoginScreen(),
                  ),
                );
              }
            },
            icon: const Icon(Icons.logout),
          )
        ],
      ),
      body: const Center(
        child: Text("Home page"),
      ),
    );
  }
}