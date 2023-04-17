import 'package:diet_designer/models/meal.dart';
import 'package:diet_designer/services/api_service.dart';
import 'package:diet_designer/shared/popup_messenger.dart';
import 'package:diet_designer/widgets/meal_card.dart';
import 'package:flutter/material.dart';

class HomeTab extends StatefulWidget {
  const HomeTab({super.key});

  @override
  State<HomeTab> createState() => _HomeTabState();
}

class _HomeTabState extends State<HomeTab> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.symmetric(vertical: 0, horizontal: 20),
        child: SingleChildScrollView(
          child: Column(
            children: [
              const SizedBox(height: 30),
              const Text(
                "Your meal plan today: ",
                style: TextStyle(fontSize: 18),
              ),
              ListView.builder(
                physics: const ScrollPhysics(),
                scrollDirection: Axis.vertical,
                shrinkWrap: true,
                itemCount: 7,
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
      floatingActionButton: FloatingActionButton(
        onPressed: () => _getMealsFromAPI(),
        child: const Icon(Icons.sync),
      ),
    );
  }

  _getMealsFromAPI() async {
    List<Meal>? meals = [];
    try {
      meals = await APIService.instance.fetchMeals(550, 40, 2);
      PopupMessenger.info('Successfully loaded meals!');
      for (Meal meal in meals!) {
        debugPrint(meal.ingredients.toString());
      }
    } catch (e) {
      PopupMessenger.error(e.toString());
    }
    debugPrint(meals.toString());
  }
}
