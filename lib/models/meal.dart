class Meal {
  final double calories;
  final double carbs;
  final double fats;
  final double proteins;
  final int id;
  final double? pricePerServing;
  final int? readyInMinutes;
  final int? servings;
  final String title;
  final List<Map<String, dynamic>>? ingredients;
  final List<String>? steps;
  final List<String>? dishTypes;
  final String image;
  final String? sourceUrl;

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
    this.image,
    this.sourceUrl,
  );

  Meal.fromJson(Map<String, dynamic> json)
      : calories = json['nutrition']['nutrients'].firstWhere((nutrient) => nutrient['name'] == 'Calories')['amount'],
        carbs = json['nutrition']['nutrients'].firstWhere((nutrient) => nutrient['name'] == 'Carbohydrates')['amount'],
        fats = json['nutrition']['nutrients'].firstWhere((nutrient) => nutrient['name'] == 'Fat')['amount'],
        proteins = json['nutrition']['nutrients'].firstWhere((nutrient) => nutrient['name'] == 'Protein')['amount'],
        id = json['id'],
        pricePerServing = double.parse((json['pricePerServing'] / 100).toStringAsFixed(2)),
        readyInMinutes = json['readyInMinutes'],
        servings = json['servings'],
        title = json['title'],
        ingredients = json['nutrition']['ingredients']
            .map((ingredient) => {
                  'name': ingredient['name'],
                  'amount': ingredient['amount'],
                  'unit': ingredient['unit'],
                })
            .toList()
            .cast<Map<String, dynamic>>(),
        steps = json['analyzedInstructions'][0]['steps'].map((step) => step['step']).toList().cast<String>(),
        dishTypes = List<String>.from(json['dishTypes']),
        image = json['image'],
        sourceUrl = json['sourceUrl'];

  Map<String, dynamic> toJson() => {
        'kcal': calories,
        'carbs': carbs,
        'fat': fats,
        'protein': proteins,
        'id': id,
        'pricePerServing': pricePerServing,
        'readyInMinutes': readyInMinutes,
        'servings': servings,
        'title': title,
        'ingredients': ingredients,
        'steps': steps,
        'dishTypes': dishTypes,
        'image': image,
        'sourceUrl': sourceUrl,
      };

  Meal.fromFirestore(Map<String, dynamic> json)
      : calories = json['kcal'],
        carbs = json['carbs'],
        fats = json['fat'],
        proteins = json['protein'],
        id = json['id'],
        pricePerServing = json['pricePerServing'],
        readyInMinutes = json['readyInMinutes'],
        servings = json['servings'],
        title = json['title'],
        ingredients = json['ingredients'].map((ingredient) => Map<String, dynamic>.from(ingredient)).toList().cast<Map<String, dynamic>>(),
        steps = json['steps'].map((step) => step.toString()).toList().cast<String>(),
        dishTypes = json['dishTypes'].map((dishType) => dishType.toString()).toList().cast<String>(),
        image = json['image'],
        sourceUrl = json['sourceUrl'];
}
