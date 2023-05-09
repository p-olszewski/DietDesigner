import 'package:diet_designer/models/meal.dart';
import 'package:diet_designer/providers/auth_provider.dart';
import 'package:diet_designer/providers/date_provider.dart';
import 'package:diet_designer/providers/user_data_provider.dart';
import 'package:diet_designer/services/firestore_service.dart';
import 'package:diet_designer/shared/popup_messenger.dart';
import 'package:flutter/material.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'package:provider/provider.dart';

class MealDetailsScreen extends StatefulWidget {
  final Meal meal;

  const MealDetailsScreen({Key? key, required this.meal}) : super(key: key);

  @override
  State<MealDetailsScreen> createState() => _MealDetailsScreenState();
}

class _MealDetailsScreenState extends State<MealDetailsScreen> {
  void checkIsMealInFavorites() async {
    final isFavorite = await isMealFavorite(widget.meal, context.read<AuthProvider>().uid!);
    setState(() {
      widget.meal.isFavorite = isFavorite;
    });
  }

  void _toggleFavorite() async {
    try {
      final uid = context.read<AuthProvider>().uid!;
      final date = context.read<DateProvider>().dateFormattedWithDots;
      if (widget.meal.isFavorite) {
        await removeMealFromFavorites(widget.meal, uid, date);
        PopupMessenger.info('Removed from favorites');
      } else {
        await addMealToFavorites(widget.meal, uid, date);
        PopupMessenger.info('Added to favorites');
      }
      setState(() {
        widget.meal.isFavorite = !widget.meal.isFavorite;
      });
    } on Exception catch (e) {
      PopupMessenger.error(e.toString());
    }
  }

  @override
  void initState() {
    super.initState();
    checkIsMealInFavorites();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.loose,
        children: [
          MealDetailsPhoto(meal: widget.meal),
          MealDetailsData(meal: widget.meal),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _toggleFavorite(),
        child: Icon(
          widget.meal.isFavorite ? Icons.favorite : Icons.favorite_border,
        ),
      ),
    );
  }
}

class MealDetailsPhoto extends StatelessWidget {
  const MealDetailsPhoto({super.key, required this.meal});

  final Meal meal;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => showDialog(
        context: context,
        builder: (context) => MealPhotoDialog(meal: meal),
      ),
      child: Stack(
        fit: StackFit.loose,
        children: [
          Container(
            height: 420,
            decoration: BoxDecoration(
              image: DecorationImage(
                image: NetworkImage(meal.imageLarge),
                fit: BoxFit.cover,
              ),
            ),
          ),
          Positioned(
            top: 40,
            left: 24,
            child: GestureDetector(
              onTap: () => Navigator.pop(context, true),
              child: Stack(
                children: const <Widget>[
                  Positioned(
                    left: 1.0,
                    top: 4.0,
                    child: Icon(
                      Icons.arrow_back,
                      color: Colors.black54,
                      size: 32,
                    ),
                  ),
                  Icon(
                    Icons.arrow_back,
                    color: Colors.white,
                    size: 36,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class MealDetailsData extends StatelessWidget {
  const MealDetailsData({super.key, required this.meal});

  final Meal meal;

  @override
  Widget build(BuildContext context) {
    TextStyle titleStyle = Theme.of(context).textTheme.headlineLarge!.copyWith(fontWeight: FontWeight.bold);
    TextStyle subtitleStyle = Theme.of(context).textTheme.titleLarge!.copyWith(fontWeight: FontWeight.bold);
    TextStyle textStyle = Theme.of(context).textTheme.bodyMedium!;
    TextStyle labelStyle = Theme.of(context).textTheme.labelLarge!.copyWith(color: Colors.grey[600]);

    return DraggableScrollableSheet(
      initialChildSize: 0.6,
      minChildSize: 0.6,
      maxChildSize: 0.90,
      builder: (context, scrollController) {
        return SafeArea(
          child: Stack(
            fit: StackFit.loose,
            children: [
              Container(
                width: MediaQuery.of(context).size.width,
                padding: const EdgeInsets.only(left: 32.0, top: 16.0, right: 32.0, bottom: 0),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(36.0),
                    topRight: Radius.circular(36.0),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      spreadRadius: 1,
                      blurRadius: 6,
                      offset: const Offset(1, 1),
                    ),
                  ],
                ),
                child: SingleChildScrollView(
                  controller: scrollController,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Align(
                        alignment: Alignment.topCenter,
                        child: Container(
                          height: 4.0,
                          width: 48.0,
                          decoration: BoxDecoration(
                            color: Colors.grey[300],
                            borderRadius: BorderRadius.circular(2.0),
                          ),
                        ),
                      ),
                      const SizedBox(height: 18.0),
                      Text(meal.title, style: titleStyle),
                      const SizedBox(height: 12),
                      _buildIconRow(context, style: labelStyle),
                      const SizedBox(height: 44),
                      _buildNutrientsRow(context, meal, labelStyle),
                      const SizedBox(height: 32),
                      _buildIngredients(context, meal, subtitleStyle, textStyle),
                      const SizedBox(height: 32),
                      _buildRecipe(context, meal, subtitleStyle, textStyle),
                      const SizedBox(height: 24),
                      _buildDishTypes(context, meal, subtitleStyle, textStyle),
                      const SizedBox(height: 32),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Row _buildIconRow(BuildContext context, {TextStyle? style}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Icon(
              Icons.timer_outlined,
              size: 20,
              color: Theme.of(context).colorScheme.primary,
            ),
            Text('  ${meal.readyInMinutes} min', style: style),
          ],
        ),
        Row(
          children: [
            Icon(
              Icons.restaurant_outlined,
              size: 20,
              color: Theme.of(context).colorScheme.primary,
            ),
            Text('  ${meal.servings} ${meal.servings == 1 ? 'serving' : 'servings'}', style: style),
          ],
        ),
        Row(
          children: [
            Icon(
              Icons.paid_outlined,
              size: 20,
              color: Theme.of(context).colorScheme.primary,
            ),
            Text('  ${meal.pricePerServing!.toStringAsFixed(2)}\$ ps', style: style),
          ],
        ),
      ],
    );
  }

  _buildNutrientsRow(BuildContext context, Meal meal, TextStyle labelStyle) {
    var user = context.read<UserDataProvider>().user;

    nutrientItem(String value, String label, double percent) {
      Color progressColor = percent < 0.5
          ? Theme.of(context).colorScheme.primary
          : percent < 0.75
              ? Colors.orange
              : Colors.red;
      return CircularPercentIndicator(
        radius: 36.0,
        lineWidth: 9.0,
        percent: percent,
        progressColor: progressColor,
        backgroundColor: progressColor.withOpacity(0.2),
        center: Text(
          value,
          style: Theme.of(context).textTheme.labelLarge!.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        circularStrokeCap: CircularStrokeCap.round,
        animation: true,
        animationDuration: 800,
        footer: Text(
          label,
          style: labelStyle,
        ),
      );
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        nutrientItem(
          meal.calories.round().toString(),
          'kcal',
          meal.calories / user.calories!,
        ),
        nutrientItem(
          '${meal.proteins.round().toString()}g',
          'protein',
          meal.proteins / user.proteins!,
        ),
        nutrientItem(
          '${meal.fats.round().toString()}g',
          'fat',
          meal.fats / user.fats!,
        ),
        nutrientItem(
          '${meal.carbs.round().toString()}g',
          'carbs',
          meal.carbs / user.carbs!,
        ),
      ],
    );
  }

  Column _buildIngredients(BuildContext context, Meal meal, TextStyle titleStyle, TextStyle textStyle) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 8.0),
          child: Text(
            "Ingredients:",
            style: titleStyle,
          ),
        ),
        ...meal.ingredients!.map((ingredient) {
          return Text('${ingredient['amount']} ${ingredient['unit']} ${ingredient['name']}', style: textStyle);
        }).toList(),
      ],
    );
  }

  _buildRecipe(BuildContext context, Meal meal, TextStyle titleStyle, TextStyle textStyle) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 8.0),
          child: Text(
            "Recipe:",
            style: titleStyle,
          ),
        ),
        ...meal.steps!.asMap().entries.map((entry) {
          final index = entry.key + 1;
          final step = entry.value;
          return Padding(
            padding: const EdgeInsets.only(bottom: 8.0),
            child: Text('$index. $step', style: textStyle),
          );
        }).toList(),
      ],
    );
  }

  _buildDishTypes(BuildContext context, Meal meal, TextStyle titleStyle, TextStyle textStyle) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 8.0),
          child: Text("Dish types:", style: titleStyle),
        ),
        ...meal.dishTypes!.map((dishType) {
          return Text(dishType, style: textStyle);
        }).toList(),
      ],
    );
  }
}

class MealPhotoDialog extends StatelessWidget {
  const MealPhotoDialog({Key? key, required this.meal}) : super(key: key);

  final Meal meal;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: GestureDetector(
        onTap: () => Navigator.of(context).pop(),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
          ),
          child: InteractiveViewer(
            minScale: 1.0,
            maxScale: 4.0,
            child: AspectRatio(
              aspectRatio: 636 / 393,
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  image: DecorationImage(
                    image: NetworkImage(meal.imageLarge),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
