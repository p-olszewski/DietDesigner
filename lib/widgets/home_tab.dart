import 'package:diet_designer/models/meal.dart';
import 'package:diet_designer/services/api_service.dart';
import 'package:diet_designer/services/firestore.dart';
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
              Text(
                "Your meal plan for ${getCurrentDate()}r.",
                style: const TextStyle(fontSize: 18),
              ),
              FutureBuilder(
                future: getMealsFromDatabase(),
                builder: (context, AsyncSnapshot<List<Meal>> snapshot) {
                  if (snapshot.hasData) {
                    return ListView.builder(
                      shrinkWrap: true,
                      itemCount: snapshot.data!.length,
                      itemBuilder: (context, index) {
                        return MealCard(meal: snapshot.data![index]);
                      },
                    );
                  } else {
                    return const Center(child: CircularProgressIndicator());
                  }
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

  void _getMealsFromAPI() async {
    List<Meal>? meals = [];
    try {
      meals = await APIService.instance.fetchMeals(550, 40, 5);
      if (meals == null) return;
      await saveMealsToDatabase(meals);
      PopupMessenger.info('Successfully saved ${meals.length} meals to the Firestore!');
    } catch (e) {
      PopupMessenger.error(e.toString());
    }
  }
}
