import 'package:diet_designer/models/nutrition_plan.dart';
import 'package:diet_designer/providers/auth_provider.dart';
import 'package:diet_designer/services/firestore_service.dart';
import 'package:diet_designer/shared/shared.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class NutritionPlanNameDialog extends StatefulWidget {
  const NutritionPlanNameDialog({super.key, required this.nutritionPlan});

  final NutritionPlan nutritionPlan;

  @override
  State<NutritionPlanNameDialog> createState() => _NutritionPlanNameDialogState();
}

class _NutritionPlanNameDialogState extends State<NutritionPlanNameDialog> {
  final TextEditingController _titleController = TextEditingController();
  String? _nameErrorText;

  @override
  void initState() {
    super.initState();
    _titleController.text = widget.nutritionPlan.name;
  }

  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Edit plan name'),
      content: TextField(
        autofocus: true,
        controller: _titleController,
        textAlign: TextAlign.left,
        decoration: InputDecoration(
          labelText: 'Plan name',
          errorText: _nameErrorText,
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: () => _updatePlanName(),
          child: const Text('Save'),
        ),
      ],
    );
  }

  Future<void> _updatePlanName() async {
    if (_titleController.text.isEmpty) {
      setState(() => _nameErrorText = 'Please enter a name');
      return;
    }
    // for only favorite plans yet
    // TODO fix rename - now it creates new field 'title', not updates 'name' field
    // TODO update plans after rename
    try {
      final uid = context.read<AuthProvider>().uid!;
      final planId = widget.nutritionPlan.date;
      final title = _titleController.text;
      await updateFavoriteNutritionPlanName(uid, planId, title);
      if (!mounted) return;
      Navigator.pop(context);
      PopupMessenger.info('Plan name updated.');
      _titleController.clear();
      setState(() => _nameErrorText = null);
    } catch (e) {
      setState(() => _nameErrorText = e.toString());
    }
  }
}
