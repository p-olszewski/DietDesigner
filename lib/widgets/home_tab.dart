import 'package:diet_designer/models/meal.dart';
import 'package:diet_designer/providers/auth_provider.dart';
import 'package:diet_designer/providers/date_provider.dart';
import 'package:diet_designer/services/api_service.dart';
import 'package:diet_designer/services/firestore_service.dart';
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
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final dateProvider = context.watch<DateProvider>();
    final uid = context.watch<AuthProvider>().uid!;
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
                    const SizedBox(height: 30),
                    const Text(
                      "Your meal plan for:",
                      style: TextStyle(fontSize: 16),
                    ),
                    const DatePicker(),
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
                                      onPressed: () => _getMealsFromAPI(),
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
                                return MealCard(meal: snapshot.data![index]);
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

  void _getMealsFromAPI() async {
    setState(() => _isLoading = true);
    List<Meal>? meals = [];
    String date = context.read<DateProvider>().dateFormattedWithDots;
    String uid = context.read<AuthProvider>().uid!;
    try {
      meals = await APIService.instance.fetchMeals(550, 40, 5);
      if (meals == null) return;
      await saveMealsToDatabase(uid, meals, date);
    } catch (e) {
      PopupMessenger.error(e.toString());
    }
    setState(() => _isLoading = false);
  }
}
