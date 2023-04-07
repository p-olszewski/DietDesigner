class User {
  final int activity;
  final int age;
  final bool calculatedData;
  final int calories;
  final int carbs;
  final String email;
  final int fats;
  final String gender;
  final int height;
  final int mealsNumber;
  final int proteins;
  final String target;
  final int weight;

  User(
    this.activity,
    this.age,
    this.calculatedData,
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
        calculatedData = json['calculated_data'],
        calories = json['calories'],
        carbs = json['carbs'],
        email = json['email'],
        fats = json['fats'],
        gender = json['gender'],
        height = json['height'],
        mealsNumber = json['meals_number'],
        proteins = json['proteins'],
        target = json['target'],
        weight = json['weight'];

  Map<String, dynamic> toJson() => {
        'activity': activity,
        'age': age,
        'calculated_data': calculatedData,
        'calories': calories,
        'carbs': carbs,
        'email': email,
        'fats': fats,
        'gender': gender,
        'height': height,
        'meals_number': mealsNumber,
        'proteins': proteins,
        'target': target,
        'weight': weight,
      };
}
