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

    return Scaffold(
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  child: WeeklyDatePicker(
                    selectedDay: dateProvider.date,
                    changeDay: (value) => setState(() {
                      context.read<DateProvider>().setDate(value);
                    }),
                    enableWeeknumberText: false,
                    selectedBackgroundColor: Theme.of(context).colorScheme.primary,
                    backgroundColor: Theme.of(context).scaffoldBackgroundColor,
                  ),
                ),
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 24),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                dateProvider.dateFormattedWithWords,
                                style: Theme.of(context).textTheme.headlineMedium!.copyWith(fontWeight: FontWeight.bold),
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
                                          return Stack(
                                            children: [
                                              GestureDetector(
                                                onTap: () =>
                                                    Navigator.pushNamed(context, '/meal_details', arguments: snapshot.data![index]),
                                                child: MealCard(meal: snapshot.data![index]),
                                              ),
                                              Positioned(
                                                top: 30,
                                                right: 0,
                                                child: Container(
                                                  width: 34,
                                                  height: 34,
                                                  decoration: BoxDecoration(
                                                    color: Theme.of(context).colorScheme.secondaryContainer,
                                                    borderRadius: const BorderRadius.all(Radius.circular(12)),
                                                    boxShadow: [
                                                      BoxShadow(
                                                        color: Theme.of(context).colorScheme.primary.withOpacity(0.2),
                                                        spreadRadius: 1,
                                                        blurRadius: 2,
                                                        offset: const Offset(0, 1),
                                                      ),
                                                    ],
                                                  ),
                                                  child: IconButton(
                                                    onPressed: () => _buildBottomSheet(context, snapshot.data![index]),
                                                    icon: const Icon(
                                                      Icons.more_vert,
                                                      size: 16,
                                                    ),
                                                    color: Theme.of(context).colorScheme.onSecondaryContainer,
                                                  ),
                                                ),
                                              ),
                                            ],
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
                      ],
                    ),
                  ),
                ),
              ],
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => PopupMessenger.info('This feature is not yet implemented!'),
        child: const Icon(Icons.add),
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
        }
        retryCount++;
        await Future.delayed(const Duration(seconds: 1));
      } while (meals == null && retryCount < maxRetries);

      if (meals == null) {
        PopupMessenger.error("Please try again later.");
        return;
      }
      await saveMealsToDatabase(uid, meals, date);
    } catch (e) {
      PopupMessenger.error(e.toString());
    }
    setState(() => _isLoading = false);
  }

  void _replaceMealToSimilar(Meal meal) async {
    setState(() => _isLoading = true);
    int retryCount = 0;
    const maxRetries = 5;
    Meal? newMeal;

    try {
      do {
        try {
          newMeal = await APIService.instance.getSimilarMealFromAPI(meal, mealType: meal.id == 'meal_1' ? 'breakfast' : '');
        } catch (e) {
          debugPrint('Error fetching similar meal from API: $e');
        }
        retryCount++;
        await Future.delayed(const Duration(seconds: 1));
      } while ((newMeal == null || newMeal.spoonacularId == meal.spoonacularId) && retryCount < maxRetries);

      if (newMeal == null) {
        PopupMessenger.error("Please try again later.");
        return;
      }
      if (!mounted) return;
      final uid = context.read<AuthProvider>().uid!;
      final date = context.read<DateProvider>().dateFormattedWithDots;
      await replaceMeal(newMeal, date, uid);
      if (!mounted) return;
      Navigator.pushReplacementNamed(context, '/home');
    } catch (e) {
      PopupMessenger.error(e.toString());
    }
    setState(() => _isLoading = false);
  }

  Future<dynamic> _buildBottomSheet(BuildContext context, Meal meal) {
    final uid = context.read<AuthProvider>().uid!;
    final date = context.read<DateProvider>().dateFormattedWithDots;
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => Container(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            MaterialButton(
              onPressed: () => _replaceMealToSimilar(meal),
              child: Row(
                children: const [
                  Icon(Icons.cloud_sync_outlined),
                  SizedBox(width: 20.0),
                  Text('Replace with a similar meal'),
                ],
              ),
            ),
            MaterialButton(
              onPressed: () => _showFavoriteMealsPopup(context, meal),
              child: Row(
                children: const [
                  Icon(Icons.restart_alt),
                  SizedBox(width: 20.0),
                  Text('Replace with a meal from favorites'),
                ],
              ),
            ),
            meal.isFavorite
                ? MaterialButton(
                    onPressed: () async {
                      await removeMealFromFavorites(meal, uid, date);
                      if (!mounted) return;
                      Navigator.pop(context);
                      setState(() {});
                      PopupMessenger.info('Removed from favorites');
                    },
                    child: Row(
                      children: const [
                        Icon(Icons.remove),
                        SizedBox(width: 20.0),
                        Text('Remove from favorites'),
                      ],
                    ),
                  )
                : MaterialButton(
                    onPressed: () async {
                      await addMealToFavorites(meal, uid, date);
                      if (!mounted) return;
                      Navigator.pop(context);
                      setState(() {});
                      PopupMessenger.info('Added to favorites');
                    },
                    child: Row(
                      children: const [
                        Icon(Icons.favorite_outline),
                        SizedBox(width: 20.0),
                        Text('Add to favorites'),
                      ],
                    ),
                  ),
            MaterialButton(
              onPressed: () => PopupMessenger.info('This feature is not yet implemented'),
              child: Row(
                children: const [
                  Icon(Icons.share_outlined),
                  SizedBox(width: 20.0),
                  Text('Share with a friend'),
                ],
              ),
            ),
            MaterialButton(
              onPressed: () => Navigator.pop(context),
              child: Row(
                children: const [
                  Icon(Icons.close),
                  SizedBox(width: 20.0),
                  Text('Cancel'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showFavoriteMealsPopup(BuildContext context, Meal oldMeal) async {
    Navigator.pop(context);
    final uid = context.read<AuthProvider>().uid!;
    final meals = await getFavouritesMeals(uid);
    if (meals.isEmpty) {
      PopupMessenger.info('You have no favorite meals');
      return;
    }
    if (!mounted) return;
    final maxHeight = MediaQuery.of(context).size.height * 0.5;
    const elementHeight = 70.0;
    var height = meals.length * elementHeight > maxHeight ? maxHeight : meals.length * elementHeight;
    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Favorite meals'),
          content: SizedBox(
            height: height,
            width: 300.0,
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: meals.length,
              itemBuilder: (context, index) {
                final meal = meals[index];
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 0.0),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundImage: NetworkImage(meal.imageThumbnail),
                    ),
                    title: Text(meal.title),
                    onTap: () {
                      final date = context.read<DateProvider>().dateFormattedWithDots;
                      meal.id = oldMeal.id;
                      replaceMeal(meal, date, uid);
                      Navigator.pop(context);
                      PopupMessenger.info('Choosed ${meal.title}');
                      // _replaceMealToSimilar(meal);
                    },
                  ),
                );
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
          ],
        );
      },
    );
  }
}
