import 'package:diet_designer/models/meal.dart';
import 'package:diet_designer/providers/auth_provider.dart';
import 'package:diet_designer/providers/date_provider.dart';
import 'package:diet_designer/services/api_service.dart';
import 'package:diet_designer/services/firestore_service.dart';
import 'package:diet_designer/shared/popup_messenger.dart';
import 'package:diet_designer/widgets/meal_card.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:weekly_date_picker/weekly_date_picker.dart';

class HomeTab extends StatefulWidget {
  const HomeTab({super.key});

  @override
  State<HomeTab> createState() => _HomeTabState();
}

class _HomeTabState extends State<HomeTab> {
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final dateProvider = context.watch<DateProvider>();
    final uid = context.watch<AuthProvider>().uid!;

    // final dateProvider = context.read<DateProvider>();
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.symmetric(vertical: 0, horizontal: 20),
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.max,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const SizedBox(height: 20),
                    WeeklyDatePicker(
                      selectedDay: dateProvider.date, // DateTime
                      changeDay: (value) => setState(() {
                        context.read<DateProvider>().setDate(value);
                      }),
                      enableWeeknumberText: false,
                      selectedBackgroundColor: Theme.of(context).colorScheme.primary,
                    ),
                    FutureBuilder(
                      future: getMealsFromDatabase(uid, dateProvider.dateFormattedWithDots),
                      builder: (context, AsyncSnapshot<List<Meal>> snapshot) {
                        if (snapshot.hasData) {
                          if (snapshot.data!.isEmpty) {
                            return SizedBox(
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
                                      onPressed: () => _generateNutritionPlan(uid, dateProvider.dateFormattedWithDots),
                                      child: const Text('Generate nutrition plan'),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          } else {
                            return ListView.builder(
                              physics: const ScrollPhysics(),
                              scrollDirection: Axis.vertical,
                              shrinkWrap: true,
                              itemCount: snapshot.data!.length,
                              itemBuilder: (context, index) {
                                return GestureDetector(
                                  onTap: () => Navigator.pushNamed(context, '/meal_details', arguments: snapshot.data![index]),
                                  child: Hero(
                                    tag: 'meal-${snapshot.data![index].id}',
                                    child: MealCard(meal: snapshot.data![index]),
                                  ),
                                );
                              },
                            );
                          }
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
        onPressed: () => PopupMessenger.info('This feature is not yet implemented!'),
        child: const Icon(Icons.sync),
      ),
    );
  }

  void _generateNutritionPlan(String uid, String date) async {
    setState(() => _isLoading = true);
    List<Meal>? meals = [];
    int retryCount = 0;
    const maxRetries = 5;

    try {
      final user = await getUserData(uid);
      if (user == null) return;
      do {
        try {
          meals = await APIService.instance.getMealsFromAPI(user);
        } catch (e) {
          debugPrint('Error fetching meals: $e');
          PopupMessenger.error("Please try again later.");
        }
        retryCount++;
        await Future.delayed(const Duration(seconds: 1));
      } while (meals == null && retryCount < maxRetries);

      if (meals == null) return;
      await saveMealsToDatabase(uid, meals, date);
    } catch (e) {
      PopupMessenger.error(e.toString());
    }
    setState(() => _isLoading = false);
  }
}
