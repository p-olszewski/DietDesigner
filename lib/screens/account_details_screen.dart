import 'package:diet_designer/models/user.dart';
import 'package:diet_designer/providers/user_data_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class AccountDetailsScreen extends StatelessWidget {
  const AccountDetailsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    User user = context.read<UserDataProvider>().user;
    TextStyle titleStyle = Theme.of(context).textTheme.headlineMedium!.copyWith(fontWeight: FontWeight.bold);
    TextStyle valueStyle = Theme.of(context).textTheme.bodyLarge!.copyWith(fontWeight: FontWeight.bold);
    TextStyle subTitleStyle = Theme.of(context).textTheme.titleLarge!.copyWith(
          fontWeight: FontWeight.w100,
          color: Theme.of(context).colorScheme.primary,
        );
    TextStyle labelStyle = Theme.of(context).textTheme.bodyLarge!.copyWith(color: Colors.grey[600]);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Account details'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 24.0, horizontal: 16.0),
          child: Center(
            child: Column(
              children: [
                Column(
                  children: [
                    const CircleAvatar(
                      radius: 70,
                      backgroundImage: NetworkImage("https://i.pravatar.cc/300?img=24"),
                    ),
                    const SizedBox(height: 30),
                    Text(
                      "${user.firstname!} ${user.lastname!}",
                      style: titleStyle,
                    ),
                    Text(
                      user.email!,
                      style: labelStyle,
                    ),
                    const SizedBox(height: 50),
                    _PersonalDetails(
                      user: user,
                      subTitleStyle: subTitleStyle,
                      valueStyle: valueStyle,
                      labelStyle: labelStyle,
                    ),
                    const SizedBox(height: 50),
                    _DailyRequirements(
                      user: user,
                      subTitleStyle: subTitleStyle,
                      valueStyle: valueStyle,
                      labelStyle: labelStyle,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.pushNamed(context, '/calculator');
        },
        child: const Icon(Icons.edit),
      ),
    );
  }
}

class _PersonalDetails extends StatelessWidget {
  const _PersonalDetails({
    required this.subTitleStyle,
    required this.user,
    required this.valueStyle,
    required this.labelStyle,
  });

  final TextStyle subTitleStyle;
  final User user;
  final TextStyle valueStyle;
  final TextStyle labelStyle;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          'Personal details'.toUpperCase(),
          style: subTitleStyle,
        ),
        const _Divider(),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Flexible(
              flex: 1,
              fit: FlexFit.tight,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text('Gender:', style: labelStyle),
                  Text(
                    'Age:',
                    style: labelStyle,
                  ),
                  Text(
                    'Height:',
                    style: labelStyle,
                  ),
                  Text(
                    'Weight:',
                    style: labelStyle,
                  ),
                  Text(
                    'Activity level:',
                    style: labelStyle,
                  ),
                  Text(
                    'Target:',
                    style: labelStyle,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 10),
            Flexible(
              flex: 1,
              fit: FlexFit.tight,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.max,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Text('${user.gender}', style: valueStyle),
                      Icon(user.gender == 'male' ? Icons.male : Icons.female),
                    ],
                  ),
                  Text(
                    '${user.age!} years',
                    style: valueStyle,
                  ),
                  Text(
                    '${user.height!} cm',
                    style: valueStyle,
                  ),
                  Text(
                    '${user.weight!} kg',
                    style: valueStyle,
                  ),
                  Text(
                    '${user.activity!}/5',
                    style: valueStyle,
                  ),
                  Text(
                    user.target!,
                    style: valueStyle,
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _DailyRequirements extends StatelessWidget {
  const _DailyRequirements({
    required this.subTitleStyle,
    required this.user,
    required this.valueStyle,
    required this.labelStyle,
  });

  final TextStyle subTitleStyle;
  final User user;
  final TextStyle valueStyle;
  final TextStyle labelStyle;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          'Daily requirements'.toUpperCase(),
          style: subTitleStyle,
        ),
        const _Divider(),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Flexible(
              flex: 1,
              fit: FlexFit.tight,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    'Calories:',
                    style: labelStyle,
                  ),
                  Text(
                    'Protein:',
                    style: labelStyle,
                  ),
                  Text(
                    'Carbs:',
                    style: labelStyle,
                  ),
                  Text(
                    'Fat:',
                    style: labelStyle,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 10),
            Flexible(
              flex: 1,
              fit: FlexFit.tight,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${user.calories!}kcal',
                    style: valueStyle,
                  ),
                  Text(
                    '${user.proteins!}g',
                    style: valueStyle,
                  ),
                  Text(
                    '${user.carbs!}g',
                    style: valueStyle,
                  ),
                  Text(
                    '${user.fats!}g',
                    style: valueStyle,
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _Divider extends StatelessWidget {
  const _Divider();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Container(
        height: 2,
        width: 300,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(50),
          color: Theme.of(context).colorScheme.primary,
        ),
      ),
    );
  }
}
