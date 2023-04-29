import 'package:diet_designer/models/meal.dart';
import 'package:diet_designer/providers/auth_provider.dart';
import 'package:diet_designer/providers/date_provider.dart';
import 'package:diet_designer/services/api_service.dart';
import 'package:diet_designer/services/firestore_service.dart';
import 'package:diet_designer/shared/shared.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class MealCard extends StatelessWidget {
  const MealCard({
    super.key,
    required this.meal,
  });

  final Meal meal;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 20),
        Text("${meal.calories.round()} kcal, ${meal.proteins.round()}g proteins, ${meal.fats.round()}g fats, ${meal.carbs.round()}g carbs"),
        MealCardContainer(meal: meal),
      ],
    );
  }
}

class MealCardContainer extends StatefulWidget {
  const MealCardContainer({
    super.key,
    required this.meal,
  });

  final Meal meal;

  @override
  State<MealCardContainer> createState() => _MealCardContainerState();
}

class _MealCardContainerState extends State<MealCardContainer> {
  bool _isLoading = false;
  @override
  Widget build(BuildContext context) {
    return _isLoading
        ? const Center(child: CircularProgressIndicator())
        : Stack(
            children: [
              Card(
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
                  leading: AspectRatio(
                    aspectRatio: 1,
                    child: Container(
                      decoration: BoxDecoration(
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.2),
                            spreadRadius: 1,
                            blurRadius: 6,
                            offset: const Offset(1, 1),
                          ),
                        ],
                        borderRadius: BorderRadius.circular(15.0),
                        image: DecorationImage(
                          fit: BoxFit.cover,
                          image: NetworkImage(widget.meal.imageThumbnail),
                        ),
                      ),
                    ),
                  ),
                  title: Text(widget.meal.title),
                  subtitle: Text(
                    '${widget.meal.calories} kcal\n${widget.meal.proteins} protein, ${widget.meal.fats} fat, ${widget.meal.carbs} carbs',
                  ),
                ),
              ),
              Positioned(
                top: 0,
                right: 0,
                child: IconButton(
                  icon: const Icon(
                    Icons.replay,
                    size: 16,
                  ),
                  onPressed: () => _regenerateMeal(widget.meal),
                ),
              ),
            ],
          );
  }

  void _regenerateMeal(Meal meal) async {
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
    } catch (e) {
      PopupMessenger.error(e.toString());
    }
    setState(() => _isLoading = false);
  }
}
