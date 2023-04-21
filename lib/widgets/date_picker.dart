import 'package:flutter/material.dart';

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
        TextButton(onPressed: () {}, child: const Text('01.01.2023')),
        IconButton(onPressed: () {}, icon: const Icon(Icons.navigate_next))
      ],
    );
  }
}
