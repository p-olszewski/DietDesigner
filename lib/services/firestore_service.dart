import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:diet_designer/models/comment.dart';
import 'package:diet_designer/models/meal.dart';
import 'package:diet_designer/models/nutrition_plan.dart';
import 'package:diet_designer/models/shopping_list.dart';
import 'package:diet_designer/models/list_element.dart';
import 'package:diet_designer/models/user.dart';
import 'package:diet_designer/shared/shared.dart';
import 'package:diet_designer/models/user.dart' as user_model;
import 'package:intl/intl.dart';

final FirebaseFirestore _database = FirebaseFirestore.instance;

Future<bool> addUserDocument(String uid, String email) async {
  if (uid.isEmpty || email.isEmpty) {
    return false;
  }
  try {
    await _database.doc('users/$uid').set({
      'email': email,
    });
    return true;
  } catch (e) {
    return false;
  }
}

Future<bool> checkUserHasCalculatedData(String uid) async {
  final userSnapshot = await _database.doc('users/$uid').get();
  if (userSnapshot.data() == null || userSnapshot.data()!['hasCalculatedData'] != true) {
    return false;
  } else {
    return true;
  }
}

bool updateUserData(String uid, user_model.User user) {
  try {
    // update only non-null fields
    final Map<String, dynamic> data = user.toJson()..removeWhere((key, value) => value == null);
    data['hasCalculatedData'] = true;
    _database.doc('users/$uid').update(data);
    return true;
  } catch (e) {
    PopupMessenger.error(e.toString());
    return false;
  }
}

Future<String> getUserEmail(String uid) {
  return _database.doc('users/$uid').get().then((value) => value.data()!['email']);
}

Future<user_model.User?> getUserData(String uid) async {
  final userSnapshot = await _database.doc('users/$uid').get();
  if (userSnapshot.data() == null || userSnapshot.data()!['hasCalculatedData'] != true) {
    return null;
  } else {
    return user_model.User.fromJson(userSnapshot.data()!);
  }
}

Future saveNutritionPlan(NutritionPlan nutritionPlan) async {
  try {
    final nutritionPlanCollection = _database.collection('nutrition_plans');
    final planId = '${nutritionPlan.uid}_${nutritionPlan.date}';
    await nutritionPlanCollection.doc(planId).set(nutritionPlan.toJson());
    final mealCollection = _database.collection('nutrition_plans/$planId/meals');
    for (int i = 0; i < nutritionPlan.meals.length; i++) {
      final meal = nutritionPlan.meals[i];
      final mealId = 'meal_${i + 1}';
      meal.id = mealId;
      await mealCollection.doc(mealId).set(meal.toJson());
    }
  } catch (e) {
    throw Exception('Failed to load data: $e');
  }
}

Future<NutritionPlan> getNutritionPlan(String uid, String date) async {
  try {
    final planSnapshot = await _database.collection('nutrition_plans').where('uid', isEqualTo: uid).where('date', isEqualTo: date).get();
    if (planSnapshot.docs.isEmpty) {
      return NutritionPlan([], date, uid);
    }
    final mealCollection = _database.collection('nutrition_plans/${planSnapshot.docs.first.id}/meals');
    final mealSnapshot = await mealCollection.get();
    final List<Meal> meals = [];
    for (var doc in mealSnapshot.docs) {
      meals.add(Meal.fromFirestore(doc.data()));
    }
    return NutritionPlan.fromJson(planSnapshot.docs.first.data(), meals);
  } catch (e) {
    throw Exception('Failed to load data: $e');
  }
}

Future replaceMeal(Meal newMeal, String date, String uid) async {
  try {
    final planSnapshot = await _database.collection('nutrition_plans').where('uid', isEqualTo: uid).where('date', isEqualTo: date).get();
    if (planSnapshot.docs.isEmpty) {
      throw Exception('Nutrition plan not found for given date and user id');
    }
    final mealCollection = _database.collection('nutrition_plans/${planSnapshot.docs.first.id}/meals');
    await mealCollection.doc(newMeal.id).set(newMeal.toJson());
  } catch (e) {
    throw Exception('Failed to load data: $e');
  }
}

Stream<QuerySnapshot<Map<String, dynamic>>> getShoppingLists(String uid) {
  try {
    final shoppingListCollection =
        _database.collection('shopping_lists').where('users', arrayContains: uid).where('archived', isEqualTo: false);
    return shoppingListCollection.snapshots();
  } catch (e) {
    throw Exception('Failed to load data: $e');
  }
}

generateNewShoppingList(String uid, ShoppingList newList, String startDate, String endDate) async {
  try {
    final DateFormat formatter = DateFormat('dd.MM.yyyy');
    final DateTime start = formatter.parse(startDate);
    final DateTime end = formatter.parse(endDate);

    // get all meals from the selected period
    final List<Meal> mealsList = [];
    for (DateTime date = start;
        date.isBefore(end.add(const Duration(days: 1)));
        date = date.add(
      const Duration(days: 1),
    ),) {
      final String formattedDate = formatter.format(date);
      final NutritionPlan nutritionPlan = await getNutritionPlan(uid, formattedDate);
      mealsList.addAll(nutritionPlan.meals);
    }

    // get all ingredients from the meals
    List<String> ingredientsList = [];
    for (var meal in mealsList) {
      for (var ingredient in meal.ingredients!) {
        ingredientsList.add(ingredient['name']);
      }
    }

    // remove duplicates
    ingredientsList = ingredientsList.toSet().toList();

    // get the number of ingredients and set the itemsCounter field on newList
    final int numIngredients = ingredientsList.length;
    newList.itemsCounter = numIngredients;

    // add shopping list to database
    final DocumentReference shoppingListsRef = await _database.collection('shopping_lists').add(
          newList.toJson(),
        );

    // add products to the shopping list's products subcollection
    final CollectionReference productsRef = shoppingListsRef.collection('products');

    // add all ingredients to the shopping list
    for (var ingredient in ingredientsList) {
      final ListElement newProduct = ListElement(
        name: ingredient,
        bought: false,
        order: ingredientsList.indexOf(ingredient).toDouble(),
      );
      await productsRef.add(newProduct.toJson());
    }
  } catch (e) {
    throw Exception('Failed to add shopping list: $e');
  }
}

updateShoppingListName(String listId, String title) async {
  try {
    _database.doc('shopping_lists/$listId').update({'title': title});
  } catch (e) {
    throw Exception('Failed to update shopping list name: $e');
  }
}

updateNutritionPlanName(String planId, String name) async {
  try {
    _database.doc('nutrition_plans/$planId').update({'name': name});
  } catch (e) {
    throw Exception('Failed to update nutrition plan name: $e');
  }
}

updateFavoriteNutritionPlanName(String uid, String planId, String name) async {
  try {
    _database.doc('users/$uid/favorite_plans/$planId').update({'name': name});
  } catch (e) {
    throw Exception('Failed to update favorite nutrition plan name: $e');
  }
}

deleteShoppingList(String listId) {
  // delete all products in the list first
  _database.collection('shopping_lists').doc(listId).collection('products').get().then(
    (QuerySnapshot<Map<String, dynamic>> value) {
      for (var element in value.docs) {
        _database.collection('shopping_lists').doc(listId).collection('products').doc(element.id).delete();
      }
      _database.collection('shopping_lists').doc(listId).delete();
    },
  );
}

Stream<QuerySnapshot<Map<String, dynamic>>> getShoppingListElementsStream(String listId) {
  try {
    final shoppingListCollection = _database.collection('shopping_lists/$listId/products').orderBy('order');
    return shoppingListCollection.snapshots();
  } catch (e) {
    throw Exception('Failed to get products: $e');
  }
}

Future<List<String>> getShoppingListElements(String listId) async {
  try {
    final List<String> products = [];
    var querySnapshot = await _database.collection('shopping_lists/$listId/products').orderBy('order').get();
    for (var doc in querySnapshot.docs) {
      products.add(doc.data()['name']);
    }
    return products;
  } catch (e) {
    throw Exception('Failed to get products: $e');
  }
}

Future<int> countAndUpdateItemsCounter(String listId) async {
  final listRef = _database.doc('shopping_lists/$listId');
  final productsSnapshot = await listRef.collection('products').get();
  int itemsCounter = productsSnapshot.docs.length;

  await listRef.update({'itemsCounter': itemsCounter});
  return itemsCounter;
}

addProductToShoppingList(ListElement newProduct, String listId) {
  try {
    _database.collection('shopping_lists/$listId/products').add(newProduct.toJson());
  } catch (e) {
    throw Exception('Failed to add product: $e');
  }
}

updateListElement(ListElement newProduct, String listId, String productId) {
  try {
    _database.doc('/shopping_lists/$listId/products/$productId').update(newProduct.toJson());
  } catch (e) {
    throw Exception('Failed to update product: $e');
  }
}

deleteListElement(String listId, String productId) {
  try {
    _database.doc('/shopping_lists/$listId/products/$productId').delete();
  } catch (e) {
    throw Exception('Failed to delete product: $e');
  }
}

Future<double> getMaxOrder(String listId) async {
  var doc = await _database.collection('/shopping_lists/$listId/products').orderBy('order', descending: true).limit(1).get();
  return doc.docs.isNotEmpty ? doc.docs.first['order'] + 1 : 0;
}

Future<dynamic> getShoppingListUserEmails(String listId) async {
  final shoppingListSnapshot = await _database.doc('shopping_lists/$listId').get();
  final userIds = List.from((shoppingListSnapshot.data())?['users']);
  final userEmails = await Future.wait(
    userIds.map((userId) async => (await _database.doc('users/$userId').get()).data()!['email']),
  );

  return userEmails.where((email) => email != null).cast<String>().toList();
}

shareShoppingListToUser(String listId, String userEmail) async {
  final userSnapshot = await _database.collection('users').where('email', isEqualTo: userEmail).get();
  if (userSnapshot.docs.isEmpty) {
    throw 'Cannot find user with email $userEmail.';
  }
  final shoppingListSnapshot = await _database.doc('shopping_lists/$listId').get();
  final userIds = List.from((shoppingListSnapshot.data())?['users']);
  if (userIds.contains(userSnapshot.docs.first.id)) {
    throw 'User $userEmail is already on the list.';
  }
  _database.doc('shopping_lists/$listId').update({
    'users': FieldValue.arrayUnion([userSnapshot.docs.first.id]),
  });
}

deleteUserFromShoppingList(String listId, String userEmail) async {
  final userSnapshot = await _database.collection('users').where('email', isEqualTo: userEmail).get();
  if (userSnapshot.docs.isEmpty) {
    throw 'Cannot find user with email $userEmail.';
  }
  final userId = userSnapshot.docs.first.id;
  _database.doc('shopping_lists/$listId').update({
    'users': FieldValue.arrayRemove([userId]),
  });
}

Future addMealToFavorites(Meal meal, String uid, String date) async {
  try {
    final mealRef = _database.doc('nutrition_plans/${uid}_$date/meals/${meal.id}');
    final favoriteMealsCollection = _database.collection('users/$uid/favorite_meals');

    await Future.wait([
      mealRef.set({...meal.toJson(), 'isFavorite': true}),
      favoriteMealsCollection.doc(meal.spoonacularId.toString()).set({...meal.toJson(), 'isFavorite': true}),
    ]);
  } catch (e) {
    throw Exception('Failed while adding to favorites: $e');
  }
}

Future removeMealFromFavorites(Meal meal, String uid, String date) async {
  try {
    final mealRef = _database.doc('nutrition_plans/${uid}_$date/meals/${meal.id}');
    final favoriteMealsCollection = _database.collection('users/$uid/favorite_meals');

    await Future.wait([
      mealRef.update({'isFavorite': false}),
      favoriteMealsCollection.doc(meal.spoonacularId.toString()).delete(),
    ]);
  } catch (e) {
    throw Exception('Failed while removing from favorites: $e');
  }
}

Future<List<Meal>> getFavoriteMeals(String uid) async {
  try {
    final favoriteMealsCollection = _database.collection('users/$uid/favorite_meals');
    final mealSnapshot = await favoriteMealsCollection.get();
    final List<Meal> meals = [];
    for (var doc in mealSnapshot.docs) {
      meals.add(Meal.fromFirestore(doc.data()));
    }
    return meals;
  } catch (e) {
    throw Exception('Failed to get favorites meals: $e');
  }
}

Future<bool> isMealFavorite(Meal meal, String uid) async {
  try {
    final favoriteMealsCollection = _database.collection('users/$uid/favorite_meals');
    final docSnapshot = await favoriteMealsCollection.doc(meal.spoonacularId.toString()).get();
    return docSnapshot.exists;
  } catch (e) {
    throw Exception('Failed to check if meal is in favorites: $e');
  }
}

Future addNutritionPlanToFavorites(NutritionPlan nutritionPlan) async {
  try {
    final nutritionPlanCollection = _database.collection('users/${nutritionPlan.uid}/favorite_plans');
    await nutritionPlanCollection.doc(nutritionPlan.date).set(nutritionPlan.toJson());
    final mealCollection = _database.collection('users/${nutritionPlan.uid}/favorite_plans/${nutritionPlan.date}/meals');
    for (int i = 0; i < nutritionPlan.meals.length; i++) {
      final meal = nutritionPlan.meals[i];
      final mealId = 'meal_${i + 1}';
      meal.id = mealId;
      await mealCollection.doc(mealId).set(meal.toJson());
    }
  } catch (e) {
    throw Exception('Failed to load data: $e');
  }
}

Future<List<NutritionPlan>> getFavoriteNutritionPlans(String uid) async {
  try {
    final favoritePlansCollection = _database.collection('users/$uid/favorite_plans');
    final plansSnapshot = await favoritePlansCollection.get();
    final List<NutritionPlan> favoritePlans = [];
    for (var doc in plansSnapshot.docs) {
      final List<Meal> meals = [];
      final mealSnapshot = await favoritePlansCollection.doc(doc.id).collection('meals').get();
      for (var mealDoc in mealSnapshot.docs) {
        meals.add(Meal.fromFirestore(mealDoc.data()));
      }
      favoritePlans.add(NutritionPlan.fromJson(doc.data(), meals));
    }
    return favoritePlans;
  } catch (e) {
    throw Exception('Failed to get favorites meals: $e');
  }
}

Future<bool> isNutritionPlanFavorite(NutritionPlan nutritionPlan, String uid) async {
  try {
    final favoritePlansCollection = _database.collection('users/$uid/favorite_plans');
    final docSnapshot = await favoritePlansCollection.doc(nutritionPlan.date).get();
    return docSnapshot.exists;
  } catch (e) {
    throw Exception('Failed to check if meal is in favorites: $e');
  }
}

Future removeNutritionPlanFromFavorites(NutritionPlan nutritionPlan, String uid) async {
  try {
    final mealsCollection = await _database.collection('users/$uid/favorite_plans/${nutritionPlan.date}/meals').get();
    // delete all meals in the plan first
    for (var element in mealsCollection.docs) {
      await _database.doc('users/$uid/favorite_plans/${nutritionPlan.date}/meals/${element.id}').delete();
    }
    await _database.doc('users/$uid/favorite_plans/${nutritionPlan.date}').delete();
  } catch (e) {
    throw Exception('Failed while removing from favorites: $e');
  }
}

Future shareNutritionPlanToUser(NutritionPlan nutritionPlan, String userEmail) async {
  final userSnapshot = await _database.collection('users').where('email', isEqualTo: userEmail).get();
  if (userSnapshot.docs.isEmpty) {
    throw 'Cannot find user with email $userEmail.';
  }
  final planId = '${nutritionPlan.uid}_${nutritionPlan.date}';
  final planSnapshot = await _database.doc('nutrition_plans/$planId').get();
  final userIds = List.from((planSnapshot.data())?['shared_users']);
  if (userIds.contains(userSnapshot.docs.first.id)) {
    throw 'User $userEmail is already on the list.';
  }
  _database.doc('nutrition_plans/$planId').update({
    'shared_users': FieldValue.arrayUnion([userSnapshot.docs.first.id]),
  });
}

Future<List<NutritionPlan>> getSharedNutritionPlans() async {
  try {
    final sharedPlansCollection = _database.collection('nutrition_plans');
    final plansSnapshot = await sharedPlansCollection.where('shared_users', isNotEqualTo: []).get();
    final List<NutritionPlan> sharedPlans = [];
    for (var doc in plansSnapshot.docs) {
      final List<Meal> meals = [];
      final mealSnapshot = await sharedPlansCollection.doc(doc.id).collection('meals').get();
      for (var mealDoc in mealSnapshot.docs) {
        meals.add(Meal.fromFirestore(mealDoc.data()));
      }
      sharedPlans.add(NutritionPlan.fromJson(doc.data(), meals));
    }
    return sharedPlans;
  } catch (e) {
    throw Exception('Failed to get favorites meals: $e');
  }
}

Future deleteUserFromSharedPlan(NutritionPlan nutritionPlan, String userEmail) async {
  try {
    final userSnapshot = await _database.collection('users').where('email', isEqualTo: userEmail).get();
    if (userSnapshot.docs.isEmpty) {
      throw 'Cannot find user with email $userEmail.';
    }
    final userId = userSnapshot.docs.first.id;
    final planId = '${nutritionPlan.uid}_${nutritionPlan.date}';
    await _database.doc('nutrition_plans/$planId').update({
      'shared_users': FieldValue.arrayRemove([userId]),
    });
  } catch (e) {
    throw Exception('Failed to load data: $e');
  }
}

Future<dynamic> getNutritionPlanUserEmails(NutritionPlan nutritionPlan) async {
  try {
    final nutritionPlanId = '${nutritionPlan.uid}_${nutritionPlan.date}';
    final nutritionPlanSnapshot = await _database.doc('nutrition_plans/$nutritionPlanId').get();
    if (!nutritionPlanSnapshot.exists) {
      return [];
    }
    final userIds = List.from(nutritionPlanSnapshot.data()!['shared_users']);
    final userEmails = await Future.wait(
      userIds.map((userId) async => (await _database.doc('users/$userId').get()).data()!['email']),
    );

    return userEmails.where((email) => email != null).cast<String>().toList();
  } catch (e) {
    throw Exception('Failed to load data: $e');
  }
}

Future addFriend(String uid, String friendEmail) async {
  // get friend uid
  var friendSnapshot = await _database.collection('users').where('email', isEqualTo: friendEmail).get();
  if (friendSnapshot.docs.isEmpty) {
    throw 'Cannot find user with email $friendEmail.';
  }
  final friendId = friendSnapshot.docs.first.id;
  // add friend to user friends
  await _database.doc('users/$uid').update({
    'friends': FieldValue.arrayUnion([friendId]),
  });
  // add user to friend friends
  await _database.doc('users/$friendId').update({
    'friends': FieldValue.arrayUnion([uid]),
  });
}

Future<List<User>> getFriends(String uid) async {
  try {
    final userSnapshot = await _database.doc('users/$uid').get();
    final friendIds = List.from(userSnapshot.data()!['friends']);
    final friends = await Future.wait(
      friendIds.map(
        (friendId) async => User.fromJson((await _database.doc('users/$friendId').get()).data()!),
      ),
    );
    return friends;
  } catch (e) {
    throw Exception('Failed to load data: $e');
  }
}

Future removeFriend(String uid, String friendEmail) async {
  // get friend uid
  var friendSnapshot = await _database.collection('users').where('email', isEqualTo: friendEmail).get();
  if (friendSnapshot.docs.isEmpty) {
    throw 'Cannot find user with email $friendEmail.';
  }
  final friendId = friendSnapshot.docs.first.id;
  // remove friend from user friends
  await _database.doc('users/$uid').update({
    'friends': FieldValue.arrayRemove([friendId]),
  });
  // remove user from friend friends
  await _database.doc('users/$friendId').update({
    'friends': FieldValue.arrayRemove([uid]),
  });
}

Future addCommentToCollection(String planId, Comment comment) {
  try {
    final commentCollection = _database.collection('comments');
    return commentCollection.add(comment.toJson()..addAll({'planId': planId}));
  } catch (e) {
    throw Exception('Failed to load data: $e');
  }
}

Stream<QuerySnapshot<Map<String, dynamic>>> getComments(String planId) {
  try {
    final commentsCollection = _database.collection('comments').where('planId', isEqualTo: planId).orderBy('date');
    return commentsCollection.snapshots();
  } catch (e) {
    throw Exception('Failed to load data: $e');
  }
}
