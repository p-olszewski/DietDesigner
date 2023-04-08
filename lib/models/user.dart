class User {
  final int activity;
  final int age;
  final bool hasCalculatedData;
  final double calories;
  final double carbs;
  final String email;
  final double fats;
  final String gender;
  final int height;
  final int mealsNumber;
  final double proteins;
  final String target;
  final double weight;

  User(
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
  );

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
}
