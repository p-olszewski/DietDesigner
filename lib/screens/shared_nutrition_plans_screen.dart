import 'package:diet_designer/models/nutrition_plan.dart';
import 'package:diet_designer/providers/auth_provider.dart';
import 'package:diet_designer/providers/user_data_provider.dart';
import 'package:diet_designer/services/firestore_service.dart';
import 'package:diet_designer/shared/shared.dart';
import 'package:diet_designer/widgets/nutrition_plan_name_dialog.dart';
import 'package:diet_designer/widgets/nutrition_plan_user_management_dialog.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class SharedNutritionPlansScreen extends StatefulWidget {
  const SharedNutritionPlansScreen({super.key});

  @override
  State<SharedNutritionPlansScreen> createState() => _SharedNutritionPlansScreenState();
}

class _SharedNutritionPlansScreenState extends State<SharedNutritionPlansScreen> {
  final bool _isLoading = false;
  @override
  void initState() {
    super.initState();
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
              Padding(
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
                              "Nutrition plans",
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
                      ],
                    ),
                  ],
                ),
              ),
              _isLoading ? const Center(child: CircularProgressIndicator()) : _buildSharedPlansList(uid)
            ],
          ),
        ),
      ),
    );
  }

  FutureBuilder<List<NutritionPlan>> _buildSharedPlansList(String uid) {
    return FutureBuilder<List<NutritionPlan>>(
      key: UniqueKey(),
      future: getSharedNutritionPlans(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasData) {
          final plans = snapshot.data!;

          if (plans.isEmpty) {
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
              itemCount: plans.length,
              itemBuilder: (context, index) {
                final plan = plans[index];

                return FutureBuilder<String>(
                  future: getUserEmail(plan.uid),
                  builder: (context, emailSnapshot) {
                    if (emailSnapshot.connectionState == ConnectionState.waiting) {
                      return const SizedBox(
                        height: 50,
                        child: Center(child: CircularProgressIndicator()),
                      );
                    } else if (emailSnapshot.hasData) {
                      final ownerEmail = emailSnapshot.data!;
                      return ExpansionTile(
                        title: Row(
                          children: [
                            Text(
                              plan.name,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            uid == plan.uid
                                ? InkWell(
                                    borderRadius: BorderRadius.circular(9),
                                    onTap: () async {
                                      await showDialog(
                                        context: context,
                                        builder: (context) => NutritionPlanNameDialog(
                                          nutritionPlan: snapshot.data![index],
                                          isShared: true,
                                        ),
                                      ).then((value) => setState(() {}));
                                    },
                                    child: Ink(
                                      decoration: const BoxDecoration(
                                        shape: BoxShape.circle,
                                      ),
                                      child: const Padding(
                                        padding: EdgeInsets.all(6),
                                        child: Icon(Icons.edit, size: 18),
                                      ),
                                    ),
                                  )
                                : const SizedBox.shrink(),
                          ],
                        ),
                        subtitle: uid == plan.uid
                            ? Text('You shared this plan with ${plan.sharedUsers.length} people.')
                            : Text('Shared by $ownerEmail'),
                        tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
                        backgroundColor: Theme.of(context).colorScheme.secondaryContainer.withOpacity(0.5),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20.0),
                        ),
                        children: plan.meals
                            .asMap()
                            .map(
                              (i, meal) => MapEntry(
                                i,
                                Column(
                                  children: [
                                    if (meal == plan.meals.first) const SizedBox(height: 5),
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
                                    meal == plan.meals.last
                                        ? Column(
                                            children: [
                                              const SizedBox(height: 20),
                                              ElevatedButton.icon(
                                                onPressed: () async {
                                                  await Navigator.pushNamed(context, '/comments', arguments: plan);
                                                  setState(() {});
                                                },
                                                icon: const Icon(Icons.chat),
                                                label: const Text('Comments'),
                                              ),
                                              ElevatedButton.icon(
                                                onPressed: () async {
                                                  if (uid == plan.uid) {
                                                    await _showPlanSharingPopup(context, plan);
                                                  } else {
                                                    final email = context.read<UserDataProvider>().user.email;
                                                    await deleteUserFromSharedPlan(plan, email!);
                                                    PopupMessenger.info('You left this shared plan.');
                                                  }
                                                  setState(() {});
                                                },
                                                style: ElevatedButton.styleFrom(
                                                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 0),
                                                ),
                                                icon: Icon(uid == plan.uid ? Icons.manage_accounts : Icons.exit_to_app),
                                                label: Text(uid == plan.uid ? 'Manage users' : 'Leave plan'),
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
                    } else {
                      return const Text('Error retrieving email');
                    }
                  },
                );
              },
            );
          }
        } else if (snapshot.hasError) {
          return const Text('Error fetching plans');
        } else {
          return const SizedBox(); // Placeholder widget when there's no data or error
        }
      },
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
        setState(() {});
      });
    });
  }
}
