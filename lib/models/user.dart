class User {
  final int? activity;
  final int? age;
  final bool? hasCalculatedData;
  final String? email;
  final String? gender;
  final int? height;
  final int? mealsNumber;
  final String? target;
  final double? weight;
  int? calories;
  double? carbs;
  double? proteins;
  double? fats;

  User({
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
  });

  User.fromJson(Map<String, dynamic> json)
      : activity = json['activity'],
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
        weight = json['weight'];

  Map<String, dynamic> toJson() => {
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
      };

  // Harris-Benedict equation
  void calculateCaloriesAndMacronutrients() {
    double bmr;
    if (gender == 'man') {
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

    switch (target) {
      case 'cut':
        bmr = 0.85 * bmr;
        break;
      case 'stay':
        break;
      case 'gain':
        bmr = 1.1 * bmr;
        break;
      default:
        break;
    }

    calories = bmr.round();
  }
}
