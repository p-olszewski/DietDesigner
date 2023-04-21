import 'package:diet_designer/providers/date_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class DatePicker extends StatelessWidget {
  const DatePicker({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        IconButton(onPressed: () {}, icon: const Icon(Icons.navigate_before)),
        TextButton(
            onPressed: () async {
              DateTime? newDate = await showDatePicker(
                context: context,
                initialDate: context.read<DateProvider>().date,
                firstDate: DateTime(1900),
                lastDate: DateTime(2100),
              );
              if (newDate == null) return;
              context.read<DateProvider>().setDate(newDate);
            },
            child: const DateButton()),
        IconButton(onPressed: () {}, icon: const Icon(Icons.navigate_next))
      ],
    );
  }
}

class DateButton extends StatelessWidget {
  const DateButton({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Text(context.watch<DateProvider>().formattedDate);
  }
}
