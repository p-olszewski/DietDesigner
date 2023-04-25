import 'package:diet_designer/providers/date_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class DatePicker extends StatelessWidget {
  const DatePicker({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final dateProvider = context.read<DateProvider>();
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 40),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            onPressed: () => dateProvider.setDate(dateProvider.date.subtract(const Duration(days: 1))),
            icon: const Icon(Icons.navigate_before),
            iconSize: 26,
          ),
          TextButton(
              onPressed: () async {
                DateTime? newDate = await showDatePicker(
                  context: context,
                  initialDate: dateProvider.date,
                  firstDate: DateTime(1900),
                  lastDate: DateTime(2100),
                );
                if (newDate == null) return;
                dateProvider.setDate(newDate);
              },
              style: TextButton.styleFrom(
                textStyle: const TextStyle(
                  fontSize: 16,
                ),
                foregroundColor: Theme.of(context).textTheme.bodyMedium!.color,
              ),
              child: const DateButtonText()),
          IconButton(
            onPressed: () => dateProvider.setDate(dateProvider.date.add(const Duration(days: 1))),
            icon: const Icon(Icons.navigate_next),
            iconSize: 26,
          )
        ],
      ),
    );
  }
}

class DateButtonText extends StatelessWidget {
  const DateButtonText({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Text(context.watch<DateProvider>().dateFormattedWithWords);
  }
}
