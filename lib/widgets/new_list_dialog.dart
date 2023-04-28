import 'package:diet_designer/models/shopping_list.dart';
import 'package:diet_designer/providers/auth_provider.dart';
import 'package:diet_designer/services/firestore_service.dart';
import 'package:diet_designer/shared/popup_messenger.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class NewListDialog extends StatefulWidget {
  const NewListDialog({Key? key}) : super(key: key);

  @override
  State<NewListDialog> createState() => _NewListDialogState();
}

class _NewListDialogState extends State<NewListDialog> {
  final TextEditingController _listTitleController = TextEditingController();
  DateTimeRange _dateRange = DateTimeRange(
    start: DateTime.now(),
    end: DateTime.now().add(const Duration(days: 6)),
  );
  bool _isLoading = false;
  String? _nameErrorText;

  @override
  Widget build(BuildContext context) {
    final startDate = _dateRange.start;
    final endDate = _dateRange.end;
    final duration = _dateRange.duration;
    TextStyle textStyle = Theme.of(context).textTheme.titleMedium!;
    TextStyle subtitleStyle = textStyle.copyWith(fontWeight: FontWeight.bold);
    TextStyle labelStyle = Theme.of(context).textTheme.labelLarge!.copyWith(color: Colors.grey[600]);

    return AlertDialog(
      scrollable: true,
      title: const Text('Generate new shopping list'),
      content: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextField(
                  controller: _listTitleController,
                  autofocus: true,
                  decoration: InputDecoration(
                    labelText: 'List name',
                    hintText: 'e.g. Lidl',
                    errorText: _nameErrorText,
                  ),
                ),
                const SizedBox(height: 20),
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
                      firstDate: DateTime.now().subtract(const Duration(days: 365)),
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
                      PopupMessenger.error('Maximum date range is 7 days! Changing to 7 days.');
                      final endDate = newDateRange.start.add(const Duration(days: 6));
                      newDateRange = DateTimeRange(start: newDateRange.start, end: endDate);
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
                onPressed: () async {
                  if (_listTitleController.text.isEmpty) {
                    setState(() => _nameErrorText = 'List name cannot be empty!');
                    return;
                  }
                  if (duration.inDays > 6) {
                    PopupMessenger.error('Date range cannot be longer than 7 days!');
                    return;
                  }
                  setState(() => _isLoading = true);
                  var userId = context.read<AuthProvider>().uid;
                  if (userId != null) {
                    var title = _listTitleController.text;
                    await generateNewShoppingList(
                      userId,
                      ShoppingList(title, users: [userId]),
                      DateFormat('dd.MM.yyyy').format(startDate),
                      DateFormat('dd.MM.yyyy').format(endDate),
                    );
                    setState(() => _isLoading = false);
                    if (!mounted) return;
                    PopupMessenger.info('Added $title list.');
                  } else {
                    PopupMessenger.error('You have to be logged in to add a list!');
                  }
                  if (!mounted) return;
                  Navigator.of(context).pop();
                },
              ),
            ],
    );
  }
}
