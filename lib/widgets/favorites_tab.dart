import 'package:diet_designer/models/meal.dart';
import 'package:diet_designer/models/nutrition_plan.dart';
import 'package:diet_designer/providers/auth_provider.dart';
import 'package:diet_designer/providers/date_provider.dart';
import 'package:diet_designer/services/firestore_service.dart';
import 'package:diet_designer/shared/popup_messenger.dart';
import 'package:diet_designer/widgets/meal_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_toggle_tab/flutter_toggle_tab.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class FavoritesTab extends StatefulWidget {
  const FavoritesTab({super.key});

  @override
  State<FavoritesTab> createState() => _FavoritesTabState();
}

class _FavoritesTabState extends State<FavoritesTab> {
  final bool _isLoading = false;
  int _selectedOption = 1;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final uid = context.watch<AuthProvider>().uid!;
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 10.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildNavigationRow(context),
            _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _selectedOption == 0
                    ? _buildFavoritePlansList(uid)
                    : _buildFavoriteMealsList(uid)
          ],
        ),
      ),
    );
  }

  Padding _buildNavigationRow(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 12.0, bottom: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _selectedOption == 0 ? "Favorite plans" : "Favorite meals",
                    style: Theme.of(context).textTheme.headlineMedium!.copyWith(fontWeight: FontWeight.bold),
                  ),
                  Row(
                    children: [
                      const Icon(Icons.touch_app, color: Colors.grey, size: 12),
                      Text(
                        "  Tap to unfold",
                        style: Theme.of(context).textTheme.labelMedium!.copyWith(color: Colors.grey),
                      ),
                    ],
                  ),
                ],
              ),
              FlutterToggleTab(
                width: 30,
                height: 42,
                borderRadius: 50,
                marginSelected: const EdgeInsets.symmetric(horizontal: 2, vertical: 2),
                selectedTextStyle: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w400),
                unSelectedTextStyle: TextStyle(color: Theme.of(context).colorScheme.primary, fontSize: 12, fontWeight: FontWeight.w400),
                unSelectedBackgroundColors: [Theme.of(context).colorScheme.secondaryContainer],
                labels: const ['', ''],
                icons: const [Icons.event_note, Icons.fastfood],
                iconSize: 22,
                selectedIndex: _selectedOption,
                selectedLabelIndex: (index) {
                  setState(() {
                    if (index == _selectedOption) return;
                    _selectedOption = index;
                  });
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  FutureBuilder<List<Meal>> _buildFavoriteMealsList(String uid) {
    return FutureBuilder(
      future: getFavoriteMeals(uid),
      builder: (context, AsyncSnapshot<List<Meal>> snapshot) {
        if (snapshot.hasData) {
          if (snapshot.data!.isEmpty) {
            return SizedBox(
              width: double.infinity,
              height: MediaQuery.of(context).size.height * 0.6,
              child: const Align(
                alignment: Alignment.center,
                child: Text('You have no favorite meals yet.'),
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
                    ClipRRect(
                      borderRadius: BorderRadius.circular(10.0),
                      child: Material(
                        child: InkWell(
                          highlightColor: Colors.green.withOpacity(0.1),
                          splashColor: Colors.grey.withOpacity(0.1),
                          onTap: () async {
                            await Navigator.pushNamed(context, '/meal_details', arguments: snapshot.data![index]);
                            setState(() {});
                          },
                          onLongPress: () => _buildBottomSheet(context, snapshot.data![index]),
                          child: Ink(child: MealCard(meal: snapshot.data![index])),
                        ),
                      ),
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
    );
  }

  FutureBuilder<List<NutritionPlan>> _buildFavoritePlansList(String uid) {
    return FutureBuilder(
      future: getFavoriteNutritionPlans(uid),
      builder: (context, AsyncSnapshot<List<NutritionPlan>> snapshot) {
        if (snapshot.hasData) {
          if (snapshot.data!.isEmpty) {
            return SizedBox(
              width: double.infinity,
              height: MediaQuery.of(context).size.height * 0.6,
              child: const Align(
                alignment: Alignment.center,
                child: Text('You have no favorite plans yet.'),
              ),
            );
          } else {
            return ListView.builder(
              physics: const ScrollPhysics(),
              scrollDirection: Axis.vertical,
              shrinkWrap: true,
              itemCount: snapshot.data!.length,
              itemBuilder: (context, index) {
                return ExpansionTile(
                  title: Text(
                    _formatDate(snapshot.data![index].date),
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
                  backgroundColor: Theme.of(context).colorScheme.secondaryContainer.withOpacity(0.5),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20.0),
                  ),
                  children: snapshot.data![index].meals
                      .asMap()
                      .map(
                        (i, meal) => MapEntry(
                          i,
                          Column(
                            children: [
                              if (meal == snapshot.data![index].meals.first) const SizedBox(height: 5),
                              ListTile(
                                leading: Container(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(50.0),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.1),
                                        spreadRadius: 1,
                                        blurRadius: 4,
                                        offset: const Offset(1, 1),
                                      ),
                                    ],
                                  ),
                                  child: CircleAvatar(
                                    radius: 26.0,
                                    backgroundImage: NetworkImage(meal.imageThumbnail),
                                  ),
                                ),
                                title: Text(meal.title),
                                subtitle: Text(
                                    '${meal.calories.round()} kcal, ${meal.proteins.round()}g protein, ${meal.fats.round()}g fat, ${meal.carbs.round()}g carbs'),
                                onTap: () async {
                                  await Navigator.pushNamed(context, '/meal_details', arguments: meal);
                                  setState(() {});
                                },
                              ),
                              meal == snapshot.data![index].meals.last
                                  ? Column(
                                      children: [
                                        const SizedBox(height: 20),
                                        FilledButton(
                                          onPressed: () {},
                                          child: const Text('Use this plan'),
                                        ),
                                        const SizedBox(height: 15),
                                      ],
                                    )
                                  : Divider(
                                      indent: 16,
                                      endIndent: 16,
                                      thickness: 1,
                                      color: Colors.grey.shade200,
                                    ),
                            ],
                          ),
                        ),
                      )
                      .values
                      .toList(),
                );
              },
            );
          }
        } else {
          return const Center(child: CircularProgressIndicator());
        }
      },
    );
  }

  Future<dynamic> _buildBottomSheet(BuildContext context, Meal meal) {
    final uid = context.read<AuthProvider>().uid!;
    final date = context.read<DateProvider>().dateFormattedWithDots;
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
                await removeMealFromFavorites(meal, uid, date);
                if (!mounted) return;
                Navigator.pop(context);
                setState(() {});
                PopupMessenger.info('Removed from favorites');
              },
              child: Row(
                children: const [
                  Icon(Icons.favorite),
                  SizedBox(width: iconSpacing),
                  Text('Unfavorite'),
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

  String _formatDate(String dateString) {
    final dateTime = DateFormat('dd.MM.yyyy').parse(dateString);
    final weekday = DateFormat('EEEE').format(dateTime);
    final formattedDate = DateFormat('dd MMM yyyy').format(dateTime);
    return '$weekday, $formattedDate';
  }
}
