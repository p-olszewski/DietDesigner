import 'package:diet_designer/models/meal.dart';
import 'package:diet_designer/providers/date_provider.dart';
import 'package:diet_designer/services/api_service.dart';
import 'package:diet_designer/services/firestore.dart';
import 'package:diet_designer/shared/popup_messenger.dart';
import 'package:diet_designer/widgets/date_picker.dart';
import 'package:diet_designer/widgets/meal_card.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class HomeTab extends StatefulWidget {
  const HomeTab({super.key});

  @override
  State<HomeTab> createState() => _HomeTabState();
}

class _HomeTabState extends State<HomeTab> {
  @override
  Widget build(BuildContext context) {
    final dateProvider = context.read<DateProvider>();
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.symmetric(vertical: 0, horizontal: 20),
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 30),
              Text(
                "Your meal plan for ${context.watch<DateProvider>().formattedDate}r.",
                style: const TextStyle(fontSize: 16),
              ),
              const DatePicker(),
              FutureBuilder(
                future: getMealsFromDatabase(dateProvider.formattedDate),
                builder: (context, AsyncSnapshot<List<Meal>> snapshot) {
                  if (snapshot.hasData) {
                    return snapshot.data!.isEmpty
                        // TODO - make this look better
                        ? SizedBox(
                            width: double.infinity,
                            height: MediaQuery.of(context).size.height * 0.6,
                            child: Align(
                              alignment: Alignment.center,
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  const Text('No meals found.'),
                                  const SizedBox(height: 10),
                                  ElevatedButton(
                                    onPressed: () => _getMealsFromAPI(),
                                    child: const Text('Generate nutrition plan'),
                                  ),
                                ],
                              ),
                            ),
                          )
                        : ListView.builder(
                            physics: const ScrollPhysics(),
                            scrollDirection: Axis.vertical,
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
        onPressed: () =>
            PopupMessenger.info('This is no longer used to generate nutrition plans. Use the button in the center of the screen instead.'),
        child: const Icon(Icons.sync),
      ),
    );
  }

  void _getMealsFromAPI() async {
    List<Meal>? meals = [];
    String date = context.read<DateProvider>().formattedDate;
    try {
      meals = await APIService.instance.fetchMeals(550, 40, 5);
      if (meals == null) return;
      await saveMealsToDatabase(meals, date);
      PopupMessenger.info('Successfully saved ${meals.length} meals to the Firestore!');
    } catch (e) {
      PopupMessenger.error(e.toString());
    }
  }
}
