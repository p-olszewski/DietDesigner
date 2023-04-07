class Meal {
  final double calories;
  final double carbs;
  final double fats;
  final double proteins;
  final int id;
  final double pricePerServing;
  final int readyInMinutes;
  final int servings;
  final String title;
  final List<String> ingredients;
  final List<String> steps;

  Meal(
    this.calories,
    this.carbs,
    this.fats,
    this.proteins,
    this.id,
    this.pricePerServing,
    this.readyInMinutes,
    this.servings,
    this.title,
    this.ingredients,
    this.steps,
  );

  Meal.fromJson(Map<String, dynamic> json)
      : calories = json['Calories'],
        carbs = json['Carbohydrates'],
        fats = json['Fats'],
        proteins = json['Proteins'],
        id = json['id'],
        pricePerServing = json['pricePerServing'],
        readyInMinutes = json['readyInMinutes'],
        servings = json['servings'],
        title = json['title'],
        ingredients = json['ingredients'].cast<String>(),
        steps = json['steps'].cast<String>();

  Map<String, dynamic> toJson() => {
        'Calories': calories,
        'Carbohydrates': carbs,
        'Fats': fats,
        'Proteins': proteins,
        'id': id,
        'pricePerServing': pricePerServing,
        'readyInMinutes': readyInMinutes,
        'servings': servings,
        'title': title,
        'ingredients': ingredients,
        'steps': steps,
      };
}
