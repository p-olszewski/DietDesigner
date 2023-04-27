import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class NewListDialog extends StatefulWidget {
  const NewListDialog({Key? key}) : super(key: key);

  @override
  State<NewListDialog> createState() => _NewListDialogState();
}

class _NewListDialogState extends State<NewListDialog> {
  final TextEditingController _listTitleController = TextEditingController();
  DateTimeRange _dateRange = DateTimeRange(
    start: DateTime.now(),
    end: DateTime.now().add(const Duration(days: 7)),
  );

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
      title: const Text('Generate a new shopping list'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextField(
            controller: _listTitleController,
            autofocus: true,
            decoration: const InputDecoration(labelText: 'List name', hintText: 'e.g. Lidl'),
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
                ' (${duration.inDays} days)',
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
              setState(() => _dateRange = newDateRange);
            },
          ),
        ],
      ),
      actions: [
        TextButton(
          child: const Text('Cancel'),
          onPressed: () => Navigator.of(context).pop(),
        ),
        FilledButton(
          child: const Text('Generate'),
          onPressed: () {},
        ),
      ],
    );
  }
}
