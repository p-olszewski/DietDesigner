import 'package:intl/intl.dart';

enum NumberInputFieldType {
  age,
  height,
  weight,
}

enum Target {
  cut,
  stay,
  gain,
}

enum Gender {
  female,
  male,
}

String formatDate(String dateString) {
  final dateTime = DateFormat('dd.MM.yyyy').parse(dateString);
  final weekday = DateFormat('EEEE').format(dateTime);
  final formattedDate = DateFormat('dd MMM yyyy').format(dateTime);
  return '$weekday, $formattedDate';
}
