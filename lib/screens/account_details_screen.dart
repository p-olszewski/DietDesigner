import 'dart:convert';
import 'dart:io';

import 'package:diet_designer/models/user.dart';
import 'package:diet_designer/providers/auth_provider.dart';
import 'package:diet_designer/providers/user_data_provider.dart';
import 'package:diet_designer/services/firestore_service.dart';
import 'package:diet_designer/shared/popup_messenger.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

class AccountDetailsScreen extends StatefulWidget {
  const AccountDetailsScreen({super.key});

  @override
  State<AccountDetailsScreen> createState() => _AccountDetailsScreenState();
}

class _AccountDetailsScreenState extends State<AccountDetailsScreen> {
  late User user;

  @override
  void initState() {
    super.initState();
    user = context.read<UserDataProvider>().user;
  }

  @override
  Widget build(BuildContext context) {
    User user = context.read<UserDataProvider>().user;
    TextStyle valueStyle = Theme.of(context).textTheme.bodyLarge!.copyWith(fontWeight: FontWeight.bold);
    TextStyle subTitleStyle = Theme.of(context).textTheme.titleLarge!.copyWith(
          fontWeight: FontWeight.w100,
          color: Theme.of(context).colorScheme.primary,
        );
    TextStyle labelStyle = Theme.of(context).textTheme.bodyLarge!.copyWith(color: Colors.grey[600]);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
        scrolledUnderElevation: 1,
      ),
      body: SingleChildScrollView(
        child: Center(
          child: Column(
            children: [
              _UserHeader(user: user, labelStyle: labelStyle),
              const SizedBox(height: 40),
              _PersonalDetails(
                user: user,
                subTitleStyle: subTitleStyle,
                valueStyle: valueStyle,
                labelStyle: labelStyle,
              ),
              const SizedBox(height: 40),
              _DailyRequirements(
                user: user,
                subTitleStyle: subTitleStyle,
                valueStyle: valueStyle,
                labelStyle: labelStyle,
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.pushNamed(context, '/account_edit');
        },
        child: const Icon(Icons.edit),
      ),
    );
  }
}

class _UserHeader extends StatefulWidget {
  const _UserHeader({
    required this.user,
    required this.labelStyle,
  });

  final User user;
  final TextStyle labelStyle;

  @override
  State<_UserHeader> createState() => _UserHeaderState();
}

class _UserHeaderState extends State<_UserHeader> {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primary,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.5),
            blurRadius: 20,
            offset: const Offset(0, 3),
          ),
        ],
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(30),
          bottomRight: Radius.circular(30),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.only(top: 2.0, bottom: 34.0),
        child: Column(
          children: [
            Stack(
              children: [
                Container(
                  width: 150,
                  height: 150,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.5),
                        blurRadius: 10,
                        offset: const Offset(0, 3),
                      ),
                    ],
                    image: DecorationImage(
                      image: MemoryImage(base64Decode(widget.user.avatarBase64!)),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Theme.of(context).colorScheme.secondaryContainer,
                    ),
                    child: Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Theme.of(context).colorScheme.onPrimary,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.5),
                            blurRadius: 10,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: IconButton(
                        onPressed: () => changePhoto(context),
                        icon: Icon(
                          Icons.edit,
                          color: Theme.of(context).colorScheme.onPrimaryContainer,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 30),
            Text(
              "${widget.user.firstname!} ${widget.user.lastname!}",
              style: TextStyle(
                color: Theme.of(context).colorScheme.onPrimary,
                fontWeight: FontWeight.w100,
                fontSize: 30,
                shadows: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.5),
                    blurRadius: 10,
                    offset: const Offset(0, 0),
                  ),
                ],
              ),
            ),
            Text(
              widget.user.email!,
              style: TextStyle(
                color: Theme.of(context).colorScheme.onPrimary,
                fontWeight: FontWeight.w100,
                fontSize: 16,
                shadows: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.5),
                    blurRadius: 10,
                    offset: const Offset(0, 0),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> changePhoto(BuildContext context) async {
    ImagePicker picker = ImagePicker();
    final pickedImage = await picker.pickImage(
      source: ImageSource.gallery,
      maxHeight: 300.0,
      maxWidth: 300.0,
    );

    if (pickedImage != null) {
      final file = File(pickedImage.path);
      final bytes = await file.readAsBytes();
      final base64Image = base64Encode(bytes);

      if (!mounted) return;
      final uid = context.read<AuthProvider>().uid!;
      final user = context.read<UserDataProvider>().user;
      user.avatarBase64 = base64Image;
      context.read<UserDataProvider>().setUser(user);
      updateUserData(uid, user);
      setState(() {
        widget.user.avatarBase64 = base64Image;
      });
      PopupMessenger.info('Image updated.');
    } else {
      PopupMessenger.info('No image selected.');
    }
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
                  Text(
                    'Meals number:',
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
                  Text(
                    '${user.mealsNumber!}',
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
                    'Proteins:',
                    style: labelStyle,
                  ),
                  Text(
                    'Carbohydrates:',
                    style: labelStyle,
                  ),
                  Text(
                    'Fats:',
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
