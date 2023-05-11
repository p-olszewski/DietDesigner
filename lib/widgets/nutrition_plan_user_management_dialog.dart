import 'package:diet_designer/models/nutrition_plan.dart';
import 'package:diet_designer/services/firestore_service.dart';
import 'package:diet_designer/shared/shared.dart';
import 'package:flutter/material.dart';

class NutritionPlanUserManagementDialog extends StatefulWidget {
  const NutritionPlanUserManagementDialog({
    super.key,
    required this.nutritionPlan,
  });

  final NutritionPlan nutritionPlan;

  @override
  State<NutritionPlanUserManagementDialog> createState() => _NutritionPlanUserManagementDialogState();
}

class _NutritionPlanUserManagementDialogState extends State<NutritionPlanUserManagementDialog> {
  final TextEditingController _emailController = TextEditingController();
  late Future<dynamic>? userEmails;
  String? _nameErrorText;

  @override
  void initState() {
    super.initState();
    userEmails = getNutritionPlanUserEmails(widget.nutritionPlan);
  }

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var emailAddressInput = Padding(
      padding: const EdgeInsets.only(top: 10),
      child: TextField(
        autofocus: true,
        controller: _emailController,
        textAlign: TextAlign.left,
        decoration: InputDecoration(
          labelText: 'Email',
          hintText: 'e.g. test@test.com',
          errorText: _nameErrorText,
        ),
      ),
    );

    var actionButtons = [
      TextButton(
        onPressed: () => Navigator.of(context).pop(),
        child: const Text('Cancel'),
      ),
      FilledButton(
        child: const Text('Share'),
        onPressed: () async {
          if (_emailController.text.isEmpty) {
            setState(() => _nameErrorText = 'Please enter an email address.');
            return;
          }
          try {
            await shareNutritionPlanToUser(widget.nutritionPlan, _emailController.text);
            if (!mounted) return;
            Navigator.of(context).pop();
            PopupMessenger.info('Added ${_emailController.text} to the plan.');
            _emailController.clear();
            setState(() => _nameErrorText = null);
          } catch (e) {
            setState(() => _nameErrorText = e.toString());
          }
        },
      ),
    ];

    return AlertDialog(
      title: const Text('Manage users'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (userEmails != null) ChipsList(userEmails: userEmails!, widget: widget),
          emailAddressInput,
        ],
      ),
      actions: actionButtons,
    );
    // return AlertDialog(
    //   title: const Text('Share plan'),
    //   content: SizedBox(
    //     height: widget.height,
    //     width: 400.0,
    //     child: Column(
    //       children: [
    //         const Spacer(),
    //         if (widget.userEmails != null)
    //           ListView.builder(
    //             shrinkWrap: true,
    //             itemCount: widget.userEmails.length,
    //             itemBuilder: (context, index) {
    //               return Chip(
    //                   label: Text(widget.userEmails.data![index]),
    //                   shape: RoundedRectangleBorder(
    //                     borderRadius: BorderRadius.circular(50),
    //                   ),
    //                   onDeleted: () {});
    //             },
    //           ),
    //         TextField(
    //           controller: widget.emailController,
    //           decoration: const InputDecoration(
    //             labelText: 'Email',
    //             hintText: 'Enter email',
    //           ),
    //         ),
    //         const Spacer(),
    //       ],
    //     ),
    //   ),
    //   actions: [
    //     TextButton(
    //       onPressed: () => Navigator.pop(context),
    //       child: const Text('Cancel'),
    //     ),
    //     FilledButton(
    //       onPressed: () async {
    //         if (widget.emailController.text.isNotEmpty) {
    //           // await shareNutritionPlan(nutritionPlan, emailController.text);
    //           PopupMessenger.info('Plan shared');
    //         }
    //         Navigator.pop(context);
    //         PopupMessenger.info('Plan shared');
    //       },
    //       child: const Text('Share'),
    //     ),
    //   ],
    // );
  }
}

class ChipsList extends StatelessWidget {
  const ChipsList({
    super.key,
    required this.userEmails,
    required this.widget,
  });

  final Future userEmails;
  final NutritionPlanUserManagementDialog widget;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: userEmails,
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }
        return SizedBox(
          height: (50 * snapshot.data!.length).toDouble(),
          width: 300,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: snapshot.data!.length,
            itemBuilder: (context, index) {
              return Chip(
                label: Text(snapshot.data![index]),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(50),
                ),
                onDeleted: () {},
              );
            },
          ),
        );
      },
    );
  }
}
