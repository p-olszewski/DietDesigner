import 'package:diet_designer/models/meal.dart';
import 'package:diet_designer/providers/auth_provider.dart';
import 'package:diet_designer/services/firestore_service.dart';
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

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final uid = context.watch<AuthProvider>().uid!;

    return Scaffold(
        body: Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 14.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Favorite meals",
                  style: Theme.of(context).textTheme.headlineMedium!.copyWith(fontWeight: FontWeight.bold),
                ),
                Row(
                  children: [
                    const Icon(Icons.touch_app, color: Colors.grey, size: 12),
                    Text(
                      "  Tap meal to open",
                      style: Theme.of(context).textTheme.labelMedium!.copyWith(color: Colors.grey),
                    ),
                  ],
                )
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
                          future: getFavouritesMeals(uid),
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
                                    return GestureDetector(
                                      onTap: () => Navigator.pushNamed(context, '/meal_details', arguments: snapshot.data![index]),
                                      child: MealCard(meal: snapshot.data![index]),
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
}
