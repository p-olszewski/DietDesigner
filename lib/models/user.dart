import 'package:diet_designer/utils/utils.dart';

class User {
  final String? firstname;
  final String? lastname;
  final int? activity;
  final int? age;
  final bool? hasCalculatedData;
  final String? email;
  final String? gender;
  final int? height;
  final int? mealsNumber;
  final String? target;
  final num? weight;
  int? calories;
  int? carbs;
  int? proteins;
  int? fats;
  String? avatarBase64;
  List<dynamic> friends;

  User({
    this.firstname,
    this.lastname,
    this.activity,
    this.age,
    this.hasCalculatedData,
    this.calories,
    this.carbs,
    this.email,
    this.fats,
    this.gender,
    this.height,
    this.mealsNumber,
    this.proteins,
    this.target,
    this.weight,
    this.avatarBase64,
    this.friends = const [],
  });

  User.fromJson(Map<String, dynamic> json)
      : firstname = json['firstname'],
        lastname = json['lastname'],
        activity = json['activity'],
        age = json['age'],
        hasCalculatedData = json['hasCalculatedData'],
        calories = json['calories'],
        carbs = json['carbs'],
        email = json['email'],
        fats = json['fats'],
        gender = json['gender'],
        height = json['height'],
        mealsNumber = json['mealsNumber'],
        proteins = json['proteins'],
        target = json['target'],
        weight = json['weight'],
        avatarBase64 = json['avatarBase64'],
        friends = json['friends'];

  Map<String, dynamic> toJson() => {
        'firstname': firstname,
        'lastname': lastname,
        'activity': activity,
        'age': age,
        'hasCalculatedData': hasCalculatedData,
        'calories': calories,
        'carbs': carbs,
        'email': email,
        'fats': fats,
        'gender': gender,
        'height': height,
        'mealsNumber': mealsNumber,
        'proteins': proteins,
        'target': target,
        'weight': weight,
        'avatarBase64': avatarBase64,
        'friends': friends,
      };

  // Harris-Benedict equation
  void calculateCaloriesAndMacronutrients() {
    double bmr;
    if (gender == Gender.male.toString()) {
      bmr = 66.5 + (13.75 * weight!) + (5.003 * height!) - (6.75 * age!);
    } else {
      bmr = 655.1 + (9.563 * weight!) + (1.850 * height!) - (4.676 * age!);
    }

    switch (activity) {
      case 1:
        bmr = bmr * 1.2;
        break;
      case 2:
        bmr = bmr * 1.375;
        break;
      case 3:
        bmr = bmr * 1.55;
        break;
      case 4:
        bmr = bmr * 1.725;
        break;
      case 5:
        bmr = bmr * 1.9;
        break;
      default:
        bmr = bmr;
        break;
    }

    Target userTarget = Target.values.firstWhere((e) => e.toString().split('.').last == target);
    switch (userTarget) {
      case Target.cut:
        calories = (0.95 * bmr).round();
        proteins = (1.8 * weight!).round();
        fats = (gender == Gender.male.name ? 0.7 * weight! : weight!).round();
        break;
      case Target.stay:
        calories = bmr.round();
        proteins = (1.4 * weight!).round();
        fats = weight!.round();
        break;
      case Target.gain:
        calories = (1.05 * bmr).round();
        proteins = (1.6 * weight!).round();
        fats = (gender == Gender.male.name ? weight! : 1.1 * weight!).round();
        break;
      default:
        break;
    }

    carbs = ((calories! - (4 * proteins!) - (9 * fats!)) / 4).round();
  }
}
