import 'package:diet_designer/models/nutrition_plan.dart';
import 'package:diet_designer/providers/auth_provider.dart';
import 'package:diet_designer/providers/date_provider.dart';
import 'package:diet_designer/services/api_service.dart';
import 'package:diet_designer/services/firestore_service.dart';
import 'package:diet_designer/shared/shared.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class NewPlanDateRangeDialog extends StatefulWidget {
  const NewPlanDateRangeDialog({super.key});

  @override
  State<NewPlanDateRangeDialog> createState() => _NewPlanDateRangeDialogState();
}

class _NewPlanDateRangeDialogState extends State<NewPlanDateRangeDialog> {
  late DateTimeRange _dateRange;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _dateRange = DateTimeRange(
      start: context.read<DateProvider>().date,
      end: context.read<DateProvider>().date.add(const Duration(days: 6)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final startDate = _dateRange.start;
    final endDate = _dateRange.end;
    final duration = _dateRange.duration;
    TextStyle textStyle = Theme.of(context).textTheme.titleMedium!;
    TextStyle subtitleStyle = textStyle.copyWith(fontWeight: FontWeight.bold);
    TextStyle labelStyle = Theme.of(context)
        .textTheme
        .labelLarge!
        .copyWith(color: Colors.grey[600]);

    return AlertDialog(
      scrollable: true,
      title: const Text('Generate new nutrition plan'),
      content: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Date range:', style: subtitleStyle),
                Row(
                  children: [
                    Text(
                      '${DateFormat('dd.MM.yyyy').format(startDate)} - ${DateFormat('dd.MM.yyyy').format(endDate)}',
                      style: textStyle,
                    ),
                    Text(
                      ' (${duration.inDays + 1} days)',
                      style: labelStyle,
                    ),
                  ],
                ),
                TextButton(
                  child: const Text('Change'),
                  onPressed: () async {
                    DateTimeRange? newDateRange = await showDateRangePicker(
                      context: context,
                      firstDate:
                          DateTime.now().subtract(const Duration(days: 365)),
                      lastDate: DateTime.now().add(const Duration(days: 365)),
                      initialDateRange: _dateRange,
                      builder: (context, child) {
                        return Theme(
                          data: ThemeData.light().copyWith(
                            colorScheme: const ColorScheme.light().copyWith(
                              primary: Theme.of(context).colorScheme.primary,
                            ),
                          ),
                          child: child!,
                        );
                      },
                    );

                    if (newDateRange == null) return;
                    if (newDateRange.duration.inDays > 6) {
                      PopupMessenger.error(
                          'Maximum date range is 7 days! Changing to 7 days.');
                      final endDate =
                          newDateRange.start.add(const Duration(days: 6));
                      newDateRange = DateTimeRange(
                          start: newDateRange.start, end: endDate);
                      return;
                    }
                    setState(() => _dateRange = newDateRange!);
                  },
                ),
              ],
            ),
      actions: _isLoading
          ? null
          : [
              TextButton(
                child: const Text('Cancel'),
                onPressed: () => Navigator.of(context).pop(),
              ),
              FilledButton(
                child: const Text('Generate'),
                onPressed: () async =>
                    _generateNutritionPlanForDateRange(_dateRange),
              ),
            ],
    );
  }

  _generateNutritionPlanForDateRange(DateTimeRange dateRange) async {
    setState(() => _isLoading = true);
    NutritionPlan? nutritionPlan;
    int retryCount = 0;
    const maxRetries = 5;
    final uid = context.read<AuthProvider>().uid!;

    try {
      final user = await getUserData(uid);
      if (user == null) return;

      for (var i = 0; i <= dateRange.duration.inDays; i++) {
        final date = dateRange.start.add(Duration(days: i));
        final formattedDate = DateFormat('dd.MM.yyyy').format(date);
        do {
          try {
            final meals = await APIService.instance.getMealsFromAPI(user);
            if (meals != null) {
              nutritionPlan = NutritionPlan(meals, formattedDate, uid);
            }
          } catch (e) {
            debugPrint('Error fetching meals: $e');
          }
          retryCount++;
        } while (nutritionPlan == null && retryCount < maxRetries);
        if (nutritionPlan == null) {
          PopupMessenger.error("Please try again later.");
          return;
        }
        await saveNutritionPlan(nutritionPlan);
      }
    } catch (e) {
      PopupMessenger.error(e.toString());
    }
    setState(() {
      _isLoading = false;
      Navigator.pop(context);
    });
  }
}
