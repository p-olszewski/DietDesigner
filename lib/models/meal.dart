class Meal {
  final double calories;
  final double carbs;
  final double fats;
  final double proteins;
  final int spoonacularId;
  final double? pricePerServing;
  final int? readyInMinutes;
  final int? servings;
  final String title;
  final List<Map<String, dynamic>>? ingredients;
  final List<String>? steps;
  final List<String>? dishTypes;
  final List<String>? diets;
  final String imageSmall;
  final String imageMedium;
  final String imageLarge;
  final String? sourceUrl;
  String? id;
  bool isFavorite = false;

  Meal(
    this.calories,
    this.carbs,
    this.fats,
    this.proteins,
    this.spoonacularId,
    this.pricePerServing,
    this.readyInMinutes,
    this.servings,
    this.title,
    this.ingredients,
    this.steps,
    this.dishTypes,
    this.diets,
    this.imageSmall,
    this.imageMedium,
    this.imageLarge,
    this.sourceUrl,
  );

  Meal.fromJson(Map<String, dynamic> json)
      : calories = json['nutrition']['nutrients'].firstWhere((nutrient) => nutrient['name'] == 'Calories')['amount'],
        carbs = json['nutrition']['nutrients'].firstWhere((nutrient) => nutrient['name'] == 'Carbohydrates')['amount'],
        fats = json['nutrition']['nutrients'].firstWhere((nutrient) => nutrient['name'] == 'Fat')['amount'],
        proteins = json['nutrition']['nutrients'].firstWhere((nutrient) => nutrient['name'] == 'Protein')['amount'],
        spoonacularId = json['id'],
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
        diets = List<String>.from(json['diets']),
        imageSmall = 'https://spoonacular.com/recipeImages/${json['id']}-90x90.jpg',
        imageMedium = 'https://spoonacular.com/recipeImages/${json['id']}-480x360.jpg',
        imageLarge = 'https://spoonacular.com/recipeImages/${json['id']}-636x393.jpg',
        sourceUrl = json['sourceUrl'];

  Map<String, dynamic> toJson() => {
        'kcal': calories,
        'carbs': carbs,
        'fat': fats,
        'protein': proteins,
        'spoonacularId': spoonacularId,
        'pricePerServing': pricePerServing,
        'readyInMinutes': readyInMinutes,
        'servings': servings,
        'title': title,
        'ingredients': ingredients,
        'steps': steps,
        'dishTypes': dishTypes,
        'diets': diets,
        'imageSmall': imageSmall,
        'imageMedium': imageMedium,
        'imageLarge': imageLarge,
        'sourceUrl': sourceUrl,
        'id': id ?? '',
        'isFavorite': isFavorite,
      };

  Meal.fromFirestore(Map<String, dynamic> json)
      : calories = json['kcal'],
        carbs = json['carbs'],
        fats = json['fat'],
        proteins = json['protein'],
        spoonacularId = json['spoonacularId'],
        pricePerServing = json['pricePerServing'],
        readyInMinutes = json['readyInMinutes'],
        servings = json['servings'],
        title = json['title'],
        ingredients = json['ingredients'].map((ingredient) => Map<String, dynamic>.from(ingredient)).toList().cast<Map<String, dynamic>>(),
        steps = json['steps'].map((step) => step.toString()).toList().cast<String>(),
        dishTypes = json['dishTypes'].map((dishType) => dishType.toString()).toList().cast<String>(),
        diets = json['diets'].map((diet) => diet.toString()).toList().cast<String>(),
        imageSmall = json['imageSmall'],
        imageMedium = json['imageMedium'],
        imageLarge = json['imageLarge'],
        sourceUrl = json['sourceUrl'],
        id = json['id'],
        isFavorite = json['isFavorite'];
}
