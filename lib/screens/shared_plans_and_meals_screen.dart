import 'package:diet_designer/models/nutrition_plan.dart';
import 'package:diet_designer/providers/auth_provider.dart';
import 'package:diet_designer/providers/user_data_provider.dart';
import 'package:diet_designer/services/firestore_service.dart';
import 'package:diet_designer/shared/shared.dart';
import 'package:diet_designer/utils/utils.dart';
import 'package:diet_designer/widgets/nutrition_plan_user_management_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_toggle_tab/flutter_toggle_tab.dart';
import 'package:provider/provider.dart';

class SharedPlansAndMealsScreen extends StatefulWidget {
  const SharedPlansAndMealsScreen({super.key});

  @override
  State<SharedPlansAndMealsScreen> createState() => _SharedPlansAndMealsScreenState();
}

class _SharedPlansAndMealsScreenState extends State<SharedPlansAndMealsScreen> {
  final bool _isLoading = false;
  late int _selectedOption;
  @override
  void initState() {
    super.initState();
    _selectedOption = 1;
  }

  @override
  Widget build(BuildContext context) {
    final uid = context.watch<AuthProvider>().uid!;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Shared'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 10.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildNavigationRow(context),
              _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _selectedOption == 0
                      ? _buildSharedPlansList(uid)
                      : _buildSharedMealsList(uid)
            ],
          ),
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
                    _selectedOption == 0 ? "Plans" : "Meals",
                    style: Theme.of(context).textTheme.headlineMedium!.copyWith(fontWeight: FontWeight.bold),
                  ),
                  Row(
                    children: [
                      const Icon(Icons.touch_app, color: Colors.grey, size: 12),
                      Text(
                        _selectedOption == 0 ? "  Tap to unfold" : "  Tap for details",
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

  FutureBuilder<List<NutritionPlan>> _buildSharedPlansList(String uid) {
    return FutureBuilder(
      key: UniqueKey(),
      future: getSharedNutritionPlans(),
      builder: (context, AsyncSnapshot<List<NutritionPlan>> snapshot) {
        if (snapshot.hasData) {
          if (snapshot.data!.isEmpty) {
            return SizedBox(
              width: double.infinity,
              height: MediaQuery.of(context).size.height * 0.6,
              child: const Align(
                alignment: Alignment.center,
                child: Text('You have not shared any plans yet.'),
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
                    formatDate(snapshot.data![index].date),
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  //
                  subtitle: uid == snapshot.data![index].uid
                      ? Text(
                          'You shared this plan with ${snapshot.data![index].sharedUsers.length} people.',
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w400,
                          ),
                        )
                      : const Text(
                          'Shared to you.',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w400,
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
                                    backgroundImage: NetworkImage(meal.imageSmall),
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
                                        ElevatedButton(
                                          onPressed: () async {
                                            if (uid == snapshot.data![index].uid) {
                                              await _showPlanSharingPopup(context, snapshot.data![index]);
                                            } else {
                                              final email = context.read<UserDataProvider>().user.email;
                                              await deleteUserFromSharedPlan(snapshot.data![index], email!);
                                              PopupMessenger.info('You left this shared plan.');
                                            }
                                            setState(() => _selectedOption = 0);
                                          },
                                          style: ElevatedButton.styleFrom(
                                            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 0),
                                          ),
                                          child: Text(uid == snapshot.data![index].uid ? 'Manage users' : 'Leave plan'),
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

  _buildSharedMealsList(String uid) {
    return const Center(
      child: Text('Shared meals'),
    );
  }

  Future<void> _showPlanSharingPopup(BuildContext context, NutritionPlan nutritionPlan) async {
    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return NutritionPlanUserManagementDialog(nutritionPlan: nutritionPlan);
      },
    ).then((value) {
      Future.delayed(const Duration(seconds: 1), () {
        setState(() {
          _selectedOption = 0;
        });
      });
    });
  }
}
