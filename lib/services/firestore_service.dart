import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:diet_designer/models/meal.dart';
import 'package:diet_designer/models/shopping_list.dart';
import 'package:diet_designer/models/list_element.dart';
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

Future<user_model.User?> getUserData(String uid) async {
  final userSnapshot = await _database.doc('users/$uid').get();
  if (userSnapshot.data() == null || userSnapshot.data()!['hasCalculatedData'] != true) {
    return null;
  } else {
    return user_model.User.fromJson(userSnapshot.data()!);
  }
}

Future saveMealsToDatabase(String uid, List<Meal> meals, String date) async {
  try {
    final nutritionPlanCollection = _database.collection('users/$uid/nutrition_plans');
    await nutritionPlanCollection.doc(date).set({
      'date': date,
    });
    final mealCollection = _database.collection('users/$uid/nutrition_plans/$date/meals');
    for (int i = 0; i < meals.length; i++) {
      final meal = meals[i];
      final mealId = 'meal_${i + 1}';
      meal.id = mealId;
      await mealCollection.doc(mealId).set(meal.toJson());
    }
  } catch (e) {
    throw Exception('Failed to load data: $e');
  }
}

Future<List<Meal>> getMealsFromDatabase(String uid, String date) async {
  try {
    final mealCollection = _database.collection('users/$uid/nutrition_plans/$date/meals');
    final mealSnapshot = await mealCollection.get();
    final List<Meal> meals = [];
    for (var doc in mealSnapshot.docs) {
      meals.add(Meal.fromFirestore(doc.data()));
    }
    return meals;
  } catch (e) {
    throw Exception('Failed to load data: $e');
  }
}

Future replaceMeal(Meal newMeal, String date, String uid) async {
  try {
    final mealCollection = _database.collection('users/$uid/nutrition_plans/$date/meals');
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
      final List<Meal> meals = await getMealsFromDatabase(uid, formattedDate);
      mealsList.addAll(meals);
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

Stream<QuerySnapshot<Map<String, dynamic>>> getShoppingListElements(String listId) {
  try {
    final shoppingListCollection = _database.collection('shopping_lists/$listId/products').orderBy('order');
    return shoppingListCollection.snapshots();
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

addUserToShoppingList(String listId, String userEmail) async {
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

archiveShoppingList(String listId) {
  try {
    _database.doc('/shopping_lists/$listId').update({'archived': true});
  } catch (e) {
    throw Exception('Failed to archive shopping list: $e');
  }
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
    final mealRef = _database.doc('users/$uid/nutrition_plans/$date/meals/${meal.id}');
    final favoritesMealsCollection = _database.collection('users/$uid/favorites_meals');

    await Future.wait([
      mealRef.set({...meal.toJson(), 'isFavorite': true}),
      favoritesMealsCollection.doc(meal.spoonacularId.toString()).set({...meal.toJson(), 'isFavorite': true}),
    ]);
  } catch (e) {
    throw Exception('Failed while adding to favorites: $e');
  }
}

Future removeMealFromFavorites(Meal meal, String uid, String date) async {
  try {
    final mealRef = _database.doc('users/$uid/nutrition_plans/$date/meals/${meal.id}');
    final favoritesMealsCollection = _database.collection('users/$uid/favorites_meals');

    await Future.wait([
      mealRef.update({'isFavorite': false}),
      favoritesMealsCollection.doc(meal.spoonacularId.toString()).delete(),
    ]);
  } catch (e) {
    throw Exception('Failed while adding/removing from favorites: $e');
  }
}

Future<List<Meal>> getFavouritesMeals(String uid) async {
  try {
    final favoritesMealsCollection = _database.collection('users/$uid/favorites_meals');
    final mealSnapshot = await favoritesMealsCollection.get();
    final List<Meal> meals = [];
    for (var doc in mealSnapshot.docs) {
      meals.add(Meal.fromFirestore(doc.data()));
    }
    return meals;
  } catch (e) {
    throw Exception('Failed to get favorites meals: $e');
  }
}
