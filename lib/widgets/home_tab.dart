import 'package:diet_designer/models/meal.dart';
import 'package:diet_designer/models/nutrition_plan.dart';
import 'package:diet_designer/providers/auth_provider.dart';
import 'package:diet_designer/providers/date_provider.dart';
import 'package:diet_designer/services/api_service.dart';
import 'package:diet_designer/services/firestore_service.dart';
import 'package:diet_designer/services/pdf_service.dart';
import 'package:diet_designer/shared/popup_messenger.dart';
import 'package:diet_designer/widgets/meal_card.dart';
import 'package:diet_designer/widgets/new_plan_date_range_dialog.dart';
import 'package:diet_designer/widgets/nutrition_plan_statistics.dart';
import 'package:diet_designer/widgets/nutrition_plan_user_management_dialog.dart';
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

  @override
  void initState() {
    super.initState();
    _uid = context.read<AuthProvider>().uid!;
    _dateProvider = context.read<DateProvider>();
    _nutritionPlan =
        getNutritionPlan(_uid, _dateProvider.dateFormattedWithDots);
    _checkIsPlanInFavorites();
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
                      _nutritionPlan = getNutritionPlan(
                          _uid, _dateProvider.dateFormattedWithDots);
                      _checkIsPlanInFavorites();
                    }),
                    enableWeeknumberText: false,
                    selectedBackgroundColor:
                        Theme.of(context).colorScheme.primary,
                    backgroundColor: Theme.of(context).scaffoldBackgroundColor,
                  ),
                ),
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(
                              vertical: 8, horizontal: 22),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    _dateProvider.dateFormattedWithWords,
                                    style: Theme.of(context)
                                        .textTheme
                                        .headlineMedium!
                                        .copyWith(fontWeight: FontWeight.bold),
                                  ),
                                  IconButton(
                                    onPressed: () =>
                                        _buildPlanBottomSheet(context),
                                    icon: const Icon(Icons.more_vert),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 4),
                              // show meals
                              FutureBuilder(
                                future: _nutritionPlan,
                                builder: (context, snapshot) {
                                  if (snapshot.hasData) {
                                    if (snapshot.data!.meals.isEmpty) {
                                      return SizedBox(
                                        width: double.infinity,
                                        height:
                                            MediaQuery.of(context).size.height *
                                                0.6,
                                        child: Align(
                                          alignment: Alignment.center,
                                          child: Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.center,
                                            children: [
                                              const Text('No meals found.'),
                                              const SizedBox(height: 20),
                                              ElevatedButton(
                                                onPressed: () =>
                                                    _generateNutritionPlan(
                                                        _uid,
                                                        _dateProvider
                                                            .dateFormattedWithDots),
                                                child: const Text(
                                                    'Generate nutrition plan'),
                                              ),
                                              TextButton(
                                                onPressed: () async =>
                                                    await showDialog(
                                                  barrierDismissible: false,
                                                  context: context,
                                                  builder: (BuildContext
                                                          context) =>
                                                      const NewPlanDateRangeDialog(),
                                                ).then(
                                                  (value) => setState(() {
                                                    _nutritionPlan =
                                                        getNutritionPlan(
                                                            _uid,
                                                            _dateProvider
                                                                .dateFormattedWithDots);
                                                  }),
                                                ),
                                                child: const Text(
                                                    'Generate for date range'),
                                              ),
                                              TextButton(
                                                onPressed: () =>
                                                    _showFavoritePlansPopup(
                                                        context),
                                                child: const Text(
                                                    'Choose from favorites'),
                                              ),
                                            ],
                                          ),
                                        ),
                                      );
                                    } else {
                                      final nutritionPlan = snapshot.data!;
                                      List<String> mealTypes =
                                          _getListOfMealTypes(nutritionPlan);
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
                                                    Navigator.pushNamed(context,
                                                        '/meal_details',
                                                        arguments: nutritionPlan
                                                            .meals[index]),
                                                onLongPress: () =>
                                                    _buildMealBottomSheet(
                                                        context,
                                                        nutritionPlan
                                                            .meals[index]),
                                                child: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    const SizedBox(height: 10),
                                                    Text(
                                                      mealTypes[index]
                                                          .toUpperCase(),
                                                      style: Theme.of(context)
                                                          .textTheme
                                                          .titleLarge!
                                                          .copyWith(
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w100,
                                                              color: Colors.grey
                                                                  .shade400),
                                                    ),
                                                    MealCard(
                                                        meal: nutritionPlan
                                                            .meals[index]),
                                                  ],
                                                ),
                                              ),
                                              Positioned(
                                                top: 45,
                                                right: 0,
                                                child: IconButton(
                                                  onPressed: () =>
                                                      _buildMealBottomSheet(
                                                          context,
                                                          nutritionPlan
                                                              .meals[index]),
                                                  icon: Icon(
                                                    Icons.more_vert,
                                                    size: 26,
                                                    color: Colors.white,
                                                    shadows: [
                                                      Shadow(
                                                        offset: const Offset(
                                                            0.5, 0.5),
                                                        blurRadius: 2.0,
                                                        color: Colors
                                                            .grey.shade600,
                                                      ),
                                                    ],
                                                  ),
                                                  color: Theme.of(context)
                                                      .colorScheme
                                                      .onSecondaryContainer,
                                                ),
                                              ),
                                            ],
                                          );
                                        },
                                      );
                                    }
                                  } else {
                                    return const Center(
                                        child: CircularProgressIndicator());
                                  }
                                },
                              ),
                              const SizedBox(height: 20),
                              // show statistics
                              FutureBuilder(
                                future: _nutritionPlan,
                                builder: (context, snapshot) {
                                  if (snapshot.hasData) {
                                    if (snapshot.data!.meals.isNotEmpty) {
                                      final nutritionPlan = snapshot.data!;
                                      return NutritionPlanStatistics(
                                          nutritionPlan: nutritionPlan);
                                    } else {
                                      return const SizedBox.shrink();
                                    }
                                  } else {
                                    return const SizedBox.shrink();
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
        onPressed: () => _toggleFavoritePlan(),
        child: Icon(_isFavorite ? Icons.favorite : Icons.favorite_border),
      ),
    );
  }

  void _checkIsPlanInFavorites() async {
    NutritionPlan nutritionPlan = await _nutritionPlan;
    final isFavorite = await isNutritionPlanFavorite(nutritionPlan, _uid);
    setState(() => _isFavorite = isFavorite);
  }

  void _toggleFavoritePlan() async {
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
      _nutritionPlan =
          getNutritionPlan(_uid, _dateProvider.dateFormattedWithDots);
    });
  }

  void _replaceMealFromCloud(Meal meal) async {
    Navigator.pop(context);
    setState(() => _isLoading = true);
    int retryCount = 0;
    const maxRetries = 8;
    Meal? newMeal;

    try {
      do {
        try {
          newMeal = await APIService.instance.getSimilarMealFromAPI(meal,
              mealType: meal.id == 'meal_1' ? 'breakfast' : '');
        } catch (e) {
          debugPrint('Error fetching similar meal from API: $e');
        }
        retryCount++;
        await Future.delayed(const Duration(seconds: 1));
      } while (
          (newMeal == null || newMeal.spoonacularId == meal.spoonacularId) &&
              retryCount < maxRetries);

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
      _nutritionPlan =
          getNutritionPlan(_uid, _dateProvider.dateFormattedWithDots);
    });
  }

  Future<dynamic> _buildPlanBottomSheet(BuildContext context) {
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
              onPressed: () async {
                Navigator.pop(context);
                _generateNutritionPlan(
                    _uid, _dateProvider.dateFormattedWithDots);
                await removeNutritionPlanFromFavorites(
                    await _nutritionPlan, _uid);
                setState(() => _isFavorite = !_isFavorite);
              },
              child: Row(
                children: const [
                  Icon(Icons.cloud_sync_outlined),
                  SizedBox(width: iconSpacing),
                  Text('Generate new plan'),
                ],
              ),
            ),
            MaterialButton(
              onPressed: () async {
                _toggleFavoritePlan();
                Navigator.pop(context);
              },
              child: Row(
                children: [
                  Icon(_isFavorite ? Icons.favorite : Icons.favorite_outline),
                  const SizedBox(width: iconSpacing),
                  Text(_isFavorite ? 'Unfavorite' : 'Favorite'),
                ],
              ),
            ),
            MaterialButton(
              onPressed: () async =>
                  _showPlanSharingPopup(context, await _nutritionPlan),
              child: Row(
                children: const [
                  Icon(Icons.share_outlined),
                  SizedBox(width: iconSpacing),
                  Text('Share'),
                ],
              ),
            ),
            MaterialButton(
              onPressed: () async =>
                  await PDFService.generatePDFForNutritionPlan(
                      await _nutritionPlan),
              child: Row(
                children: const [
                  Icon(Icons.download_outlined),
                  SizedBox(width: iconSpacing),
                  Text('Download as PDF'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<dynamic> _buildMealBottomSheet(BuildContext context, Meal meal) {
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
                  Text('Generate new meal'),
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
                      await removeMealFromFavorites(
                          meal, _uid, _dateProvider.dateFormattedWithDots);
                      if (!mounted) return;
                      Navigator.pop(context);
                      setState(() {
                        _nutritionPlan = getNutritionPlan(
                            _uid, _dateProvider.dateFormattedWithDots);
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
                      await addMealToFavorites(
                          meal, _uid, _dateProvider.dateFormattedWithDots);
                      if (!mounted) return;
                      Navigator.pop(context);
                      setState(() {
                        _nutritionPlan = getNutritionPlan(
                            _uid, _dateProvider.dateFormattedWithDots);
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
          ],
        ),
      ),
    );
  }

  Future<void> _showFavoriteMealsPopup(
      BuildContext context, Meal oldMeal) async {
    Navigator.pop(context);
    final meals = await getFavoriteMeals(_uid);
    if (meals.isEmpty) {
      PopupMessenger.info('You have no favorite meals');
      return;
    }
    if (!mounted) return;
    final maxHeight = MediaQuery.of(context).size.height * 0.5;
    const elementHeight = 80.0;
    var height = meals.length * elementHeight > maxHeight
        ? maxHeight
        : meals.length * elementHeight;
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
                final kcalDiff =
                    '${meal.calories - oldMeal.calories >= 0 ? '↑' : '↓'}${(meal.calories - oldMeal.calories).abs().round()}';
                final proteinsDiff =
                    '${meal.proteins - oldMeal.proteins >= 0 ? '↑' : '↓'}${(meal.proteins - oldMeal.proteins).abs().round()}';
                final fatsDiff =
                    '${meal.fats - oldMeal.fats >= 0 ? '↑' : '↓'}${(meal.fats - oldMeal.fats).abs().round()}';
                final carbsDiff =
                    '${meal.carbs - oldMeal.carbs >= 0 ? '↑' : '↓'}${(meal.carbs - oldMeal.carbs).abs().round()}';
                return Padding(
                  padding: const EdgeInsets.symmetric(
                      vertical: 4.0, horizontal: 0.0),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundImage: NetworkImage(meal.imageSmall),
                    ),
                    title: Text(meal.title),
                    subtitle: Text(
                        '${kcalDiff}kcal, ${proteinsDiff}p, ${fatsDiff}f, ${carbsDiff}c'),
                    onTap: () async {
                      meal.id = oldMeal.id;
                      await replaceMeal(
                          meal, _dateProvider.dateFormattedWithDots, _uid);
                      if (!mounted) return;
                      Navigator.pop(context);
                      setState(() {
                        _isLoading = false;
                        _nutritionPlan = getNutritionPlan(
                            _uid, _dateProvider.dateFormattedWithDots);
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

  Future<void> _showFavoritePlansPopup(BuildContext context) async {
    final nutritionPlans = await getFavoriteNutritionPlans(_uid);
    if (nutritionPlans.isEmpty) {
      PopupMessenger.info('You have no favorite plans');
      return;
    }
    if (!mounted) return;
    final maxHeight = MediaQuery.of(context).size.height * 0.5;
    const elementHeight = 70.0;
    var height = nutritionPlans.length * elementHeight > maxHeight
        ? maxHeight
        : nutritionPlans.length * elementHeight;
    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Choose plan'),
          content: SizedBox(
            height: height,
            width: 400.0,
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: nutritionPlans.length,
              itemBuilder: (context, index) {
                final plan = nutritionPlans[index];
                return ListTile(
                  title: Text(plan.name),
                  onTap: () async {
                    NutritionPlan nutritionPlan = plan;
                    nutritionPlan.date = _dateProvider.dateFormattedWithDots;
                    await saveNutritionPlan(nutritionPlan);
                    if (!mounted) return;
                    Navigator.pop(context);
                    setState(() {
                      _nutritionPlan = getNutritionPlan(
                          _uid, _dateProvider.dateFormattedWithDots);
                    });
                  },
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

  Future<void> _showPlanSharingPopup(
      BuildContext context, NutritionPlan nutritionPlan) async {
    Navigator.pop(context);
    if (!mounted) return;
    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return NutritionPlanUserManagementDialog(nutritionPlan: nutritionPlan);
      },
    );
  }

  List<String> _getListOfMealTypes(NutritionPlan nutritionPlan) {
    List<String> mealTypes;
    switch (nutritionPlan.meals.length) {
      case 3:
        mealTypes = ['Breakfast', 'Dinner', 'Supper'];
        break;
      case 4:
        mealTypes = ['Breakfast', 'Lunch', 'Dinner', 'Supper'];
        break;
      case 5:
        mealTypes = ['Breakfast', 'Brunch', 'Lunch', 'Dinner', 'Supper'];
        break;
      case 6:
        mealTypes = [
          'Breakfast',
          'Brunch',
          'Lunch',
          'Dinner',
          'Afternoon meal',
          'Supper'
        ];
        break;
      default:
        mealTypes = [
          'Meal 1',
          'Meal 2',
          'Meal 3',
          'Meal 4',
          'Meal 5',
          'Meal 6'
        ];
        break;
    }
    return mealTypes;
  }
}
