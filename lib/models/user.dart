class User {
  final int activity;
  final int age;
  final bool calculatedData;
  final int calories;
  final int carbs;
  final String email;
  final int fats;
  final String gener;
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
    this.gener,
    this.height,
    this.mealsNumber,
    this.proteins,
    this.target,
    this.weight,
  );

  User.fromJson(Map<String, dynamic> json)
      : activity = json['activity'],
        age = json['age'],
        calculatedData = json['calculatedData'],
        calories = json['calories'],
        carbs = json['carbs'],
        email = json['email'],
        fats = json['fats'],
        gener = json['gener'],
        height = json['height'],
        mealsNumber = json['mealsNumber'],
        proteins = json['proteins'],
        target = json['target'],
        weight = json['weight'];

  Map<String, dynamic> toJson() => {
        'activity': activity,
        'age': age,
        'calculatedData': calculatedData,
        'calories': calories,
        'carbs': carbs,
        'email': email,
        'fats': fats,
        'gener': gener,
        'height': height,
        'mealsNumber': mealsNumber,
        'proteins': proteins,
        'target': target,
        'weight': weight,
      };
}
