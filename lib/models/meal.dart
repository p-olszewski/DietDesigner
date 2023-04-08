class Meal {
  final double calories;
  final double carbs;
  final double fats;
  final double proteins;
  final int id;
  final double? pricePerServing;
  final int? readyInMinutes;
  final int? servings;
  final String? title;
  final List<Map<String, dynamic>>? ingredients;
  final List<String>? steps;
  final List<String>? dishTypes;

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
    this.dishTypes,
  );

  Meal.fromJson(Map<String, dynamic> json)
      : calories = json['nutrition']['nutrients'].firstWhere((nutrient) => nutrient['name'] == 'Calories')['amount'],
        carbs = json['nutrition']['nutrients'].firstWhere((nutrient) => nutrient['name'] == 'Carbohydrates')['amount'],
        fats = json['nutrition']['nutrients'].firstWhere((nutrient) => nutrient['name'] == 'Fat')['amount'],
        proteins = json['nutrition']['nutrients'].firstWhere((nutrient) => nutrient['name'] == 'Protein')['amount'],
        id = json['id'],
        pricePerServing = json['pricePerServing'],
        readyInMinutes = json['readyInMinutes'],
        servings = json['servings'],
        title = json['title'],
        ingredients = json['ingredients']
            .map((ingredient) => {
                  'name': ingredient['name'],
                  'amount': ingredient['amount'],
                  'unit': ingredient['unit'],
                })
            .toList(),
        steps = json['analyzedInstructions'][0]['steps'].map((step) => step['step']).toList(),
        dishTypes = List<String>.from(json['dishTypes']);

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
        'dishTypes': dishTypes,
      };
}
