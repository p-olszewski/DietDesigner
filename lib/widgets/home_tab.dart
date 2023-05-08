import 'package:diet_designer/models/meal.dart';
import 'package:diet_designer/models/nutrition_plan.dart';
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
  late Future<NutritionPlan> _nutritionPlan;
  late DateProvider _dateProvider;
  late final String _uid;
  bool _isLoading = false;
  bool _isFavorite = false;

  void checkIsPlanInFavorites() async {
    NutritionPlan nutritionPlan = await _nutritionPlan;
    final isFavorite = await isNutritionPlanFavorite(nutritionPlan, _uid);
    setState(() => _isFavorite = isFavorite);
  }

  void _toggleFavorite() async {
    try {
      NutritionPlan nutritionPlan = await _nutritionPlan;
      if (nutritionPlan.meals.isEmpty) {
        PopupMessenger.info('Cannot add empty nutrition plan to favorites.');
        return;
      }
      if (_isFavorite) {
        await removeNutritionPlanFromFavorites(nutritionPlan, _uid);
        PopupMessenger.info('Removed plan from favorites.');
      } else {
        await addNutritionPlanToFavorites(nutritionPlan);
        PopupMessenger.info('Added plan to favorites.');
      }
      setState(() => _isFavorite = !_isFavorite);
    } catch (e) {
      PopupMessenger.error('Failed to toggle favorite.');
    }
  }

  @override
  void initState() {
    super.initState();
    _uid = context.read<AuthProvider>().uid!;
    _dateProvider = context.read<DateProvider>();
    _nutritionPlan = getNutritionPlan(_uid, _dateProvider.dateFormattedWithDots);
    checkIsPlanInFavorites();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  child: WeeklyDatePicker(
                    selectedDay: _dateProvider.date,
                    changeDay: (value) => setState(() {
                      context.read<DateProvider>().setDate(value);
                      _nutritionPlan = getNutritionPlan(_uid, _dateProvider.dateFormattedWithDots);
                      checkIsPlanInFavorites();
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
                                _dateProvider.dateFormattedWithWords,
                                style: Theme.of(context).textTheme.headlineMedium!.copyWith(fontWeight: FontWeight.bold),
                              ),
                              FutureBuilder(
                                future: _nutritionPlan,
                                builder: (context, snapshot) {
                                  if (snapshot.hasData) {
                                    if (snapshot.data!.meals.isEmpty) {
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
                                                onPressed: () => _generateNutritionPlan(_uid, _dateProvider.dateFormattedWithDots),
                                                child: const Text('Generate nutrition plan'),
                                              ),
                                            ],
                                          ),
                                        ),
                                      );
                                    } else {
                                      final nutritionPlan = snapshot.data!;
                                      return ListView.builder(
                                        physics: const ScrollPhysics(),
                                        scrollDirection: Axis.vertical,
                                        shrinkWrap: true,
                                        itemCount: snapshot.data!.meals.length,
                                        itemBuilder: (context, index) {
                                          return Stack(
                                            children: [
                                              GestureDetector(
                                                onTap: () =>
                                                    Navigator.pushNamed(context, '/meal_details', arguments: nutritionPlan.meals[index]),
                                                child: MealCard(meal: nutritionPlan.meals[index]),
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
                                                    onPressed: () => _buildBottomSheet(context, nutritionPlan.meals[index]),
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
        onPressed: () => _toggleFavorite(),
        child: Icon(_isFavorite ? Icons.favorite : Icons.favorite_border),
      ),
    );
  }

  void _generateNutritionPlan(String uid, String date) async {
    setState(() => _isLoading = true);
    NutritionPlan? nutritionPlan;
    int retryCount = 0;
    const maxRetries = 5;

    try {
      final user = await getUserData(uid);
      if (user == null) return;
      do {
        try {
          final meals = await APIService.instance.getMealsFromAPI(user);
          if (meals != null) {
            nutritionPlan = NutritionPlan(meals, date, uid);
          }
        } catch (e) {
          debugPrint('Error fetching meals: $e');
        }
        retryCount++;
      } while (nutritionPlan == null && retryCount < maxRetries);

      if (nutritionPlan == null) {
        PopupMessenger.error("Please try again later.");
        return;
      }
      await saveNutritionPlan(nutritionPlan);
    } catch (e) {
      PopupMessenger.error(e.toString());
    }
    setState(() {
      _isLoading = false;
      _nutritionPlan = getNutritionPlan(_uid, _dateProvider.dateFormattedWithDots);
    });
  }

  void _replaceMealFromCloud(Meal meal) async {
    setState(() => _isLoading = true);
    int retryCount = 0;
    const maxRetries = 8;
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
    setState(() {
      _isLoading = false;
      _nutritionPlan = getNutritionPlan(_uid, _dateProvider.dateFormattedWithDots);
    });
  }

  Future<dynamic> _buildBottomSheet(BuildContext context, Meal meal) {
    const iconSpacing = 30.0;
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            MaterialButton(
              onPressed: () => _replaceMealFromCloud(meal),
              child: Row(
                children: const [
                  Icon(Icons.cloud_sync_outlined),
                  SizedBox(width: iconSpacing),
                  Text('Replace from cloud'),
                ],
              ),
            ),
            MaterialButton(
              onPressed: () => _showFavoriteMealsPopup(context, meal),
              child: Row(
                children: const [
                  Icon(Icons.restart_alt),
                  SizedBox(width: iconSpacing),
                  Text('Replace from favorites'),
                ],
              ),
            ),
            meal.isFavorite
                ? MaterialButton(
                    onPressed: () async {
                      await removeMealFromFavorites(meal, _uid, _dateProvider.dateFormattedWithDots);
                      if (!mounted) return;
                      Navigator.pop(context);
                      setState(() {
                        _nutritionPlan = getNutritionPlan(_uid, _dateProvider.dateFormattedWithDots);
                      });
                      PopupMessenger.info('Removed from favorites');
                    },
                    child: Row(
                      children: const [
                        Icon(Icons.favorite),
                        SizedBox(width: iconSpacing),
                        Text('Unfavorite'),
                      ],
                    ),
                  )
                : MaterialButton(
                    onPressed: () async {
                      await addMealToFavorites(meal, _uid, _dateProvider.dateFormattedWithDots);
                      if (!mounted) return;
                      Navigator.pop(context);
                      setState(() {
                        _nutritionPlan = getNutritionPlan(_uid, _dateProvider.dateFormattedWithDots);
                      });
                      PopupMessenger.info('Added to favorites');
                    },
                    child: Row(
                      children: const [
                        Icon(Icons.favorite_outline),
                        SizedBox(width: iconSpacing),
                        Text('Favorite'),
                      ],
                    ),
                  ),
            MaterialButton(
              onPressed: () => PopupMessenger.info('This feature is not yet implemented'),
              child: Row(
                children: const [
                  Icon(Icons.share_outlined),
                  SizedBox(width: iconSpacing),
                  Text('Share'),
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
    final meals = await getFavoriteMeals(_uid);
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
          title: const Text('Choose meal'),
          content: SizedBox(
            height: height,
            width: 400.0,
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: meals.length,
              itemBuilder: (context, index) {
                final meal = meals[index];
                final kcalDiff = '${meal.calories - oldMeal.calories >= 0 ? '↑' : '↓'}${(meal.calories - oldMeal.calories).abs().round()}';
                final proteinsDiff =
                    '${meal.proteins - oldMeal.proteins >= 0 ? '↑' : '↓'}${(meal.proteins - oldMeal.proteins).abs().round()}';
                final fatsDiff = '${meal.fats - oldMeal.fats >= 0 ? '↑' : '↓'}${(meal.fats - oldMeal.fats).abs().round()}';
                final carbsDiff = '${meal.carbs - oldMeal.carbs >= 0 ? '↑' : '↓'}${(meal.carbs - oldMeal.carbs).abs().round()}';
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 0.0),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundImage: NetworkImage(meal.imageThumbnail),
                    ),
                    title: Text(meal.title),
                    subtitle: Text('${kcalDiff}kcal, ${proteinsDiff}p, ${fatsDiff}f, ${carbsDiff}c'),
                    onTap: () async {
                      meal.id = oldMeal.id;
                      await replaceMeal(meal, _dateProvider.dateFormattedWithDots, _uid);
                      if (!mounted) return;
                      Navigator.pop(context);
                      setState(() {
                        _isLoading = false;
                        _nutritionPlan = getNutritionPlan(_uid, _dateProvider.dateFormattedWithDots);
                      });
                      PopupMessenger.info('Meal replaced');
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
