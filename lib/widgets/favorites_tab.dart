import 'package:diet_designer/models/meal.dart';
import 'package:diet_designer/providers/auth_provider.dart';
import 'package:diet_designer/providers/date_provider.dart';
import 'package:diet_designer/services/firestore_service.dart';
import 'package:diet_designer/shared/popup_messenger.dart';
import 'package:diet_designer/widgets/meal_card.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class FavoritesTab extends StatefulWidget {
  const FavoritesTab({super.key});

  @override
  State<FavoritesTab> createState() => _FavoritesTabState();
}

class _FavoritesTabState extends State<FavoritesTab> {
  final bool _isLoading = false;
  final List<String> _options = ['meals', 'plan'];
  String _selectedOption = 'meals';

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final uid = context.watch<AuthProvider>().uid!;

    return Scaffold(
        body: Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 10.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 14.0, bottom: 4.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Favorites",
                      style: Theme.of(context).textTheme.headlineMedium!.copyWith(fontWeight: FontWeight.bold),
                    ),
                    SegmentedButton(
                      segments: const [
                        ButtonSegment(
                          value: 'meals',
                          label: Text('meals'),
                          icon: Icon(Icons.restaurant),
                        ),
                        ButtonSegment(
                          value: 'plans',
                          label: Text('plans'),
                          icon: Icon(Icons.calendar_today),
                        ),
                      ],
                      selected: {_selectedOption},
                      onSelectionChanged: (value) => setState(() => _selectedOption = value.first),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  _isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : FutureBuilder(
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
                        ),
                ],
              ),
            ),
          ),
        ],
      ),
    ));
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
}
