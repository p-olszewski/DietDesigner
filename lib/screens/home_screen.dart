import 'package:diet_designer/services/auth.dart';
import 'package:diet_designer/screens/login_screen.dart';
import 'package:diet_designer/shared/shared.dart';
import 'package:diet_designer/widgets/meal_card.dart';
import 'package:flutter/material.dart';

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
        actions: [
          IconButton(
            onPressed: () async {
              bool shouldRedirect = await signOut();
              if (shouldRedirect) {
                if (!mounted) return;
                PopupMessenger.info("Logged out");
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
      drawer: const DrawerMenu(),
      body: Padding(
        padding: const EdgeInsets.symmetric(vertical: 30, horizontal: 20),
        child: SingleChildScrollView(
          child: Column(
            children: [
              const Text(
                "Your meal plan today: ",
                style: TextStyle(fontSize: 18),
              ),
              ListView.builder(
                physics: const ScrollPhysics(),
                scrollDirection: Axis.vertical,
                shrinkWrap: true,
                itemCount: 5,
                itemBuilder: (context, index) {
                  return MealCard(
                    meal: {
                      'title': 'Meal ${index + 1}',
                      'calories': '523',
                      'protein': '32',
                      'fat': '15',
                      'carbs': '74',
                      'image': 'https://spoonacular.com/recipeImages/658418-312x231.jpg',
                    },
                  );
                },
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: const BottomNavbarMenu(),
    );
  }
}
