
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:diet_designer/models/meal.dart';
import 'package:diet_designer/shared/shared.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:diet_designer/models/user.dart' as user_model;

final FirebaseFirestore _database = FirebaseFirestore.instance;
final String? _uid = FirebaseAuth.instance.currentUser?.uid;

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

Future<bool> checkUserHasCalculatedData() async {
  final userSnapshot = await _database.doc('users/$_uid').get();
  if (userSnapshot.data() == null || userSnapshot.data()!['hasCalculatedData'] != true) {
    return false;
  } else {
    return true;
  }
}

bool updateUserData(user_model.User user) {
  try {
    // update only non-null fields
    final Map<String, dynamic> data = user.toJson()..removeWhere((key, value) => value == null);
    data['hasCalculatedData'] = true;
    _database.doc('users/$_uid').update(data);
    return true;
  } catch (e) {
    PopupMessenger.error(e.toString());
    return false;
  }
}

Future<user_model.User?> getUserData() async {
  final userSnapshot = await _database.doc('users/$_uid').get();
  if (userSnapshot.data() == null || userSnapshot.data()!['hasCalculatedData'] != true) {
    return null;
  } else {
    return user_model.User.fromJson(userSnapshot.data()!);
  }
}

Future saveMealsToDatabase(List<Meal> meals, String date) async {
  try {
    final mealCollection = _database.collection('users/$_uid/nutrition_plans/$date/meals');
    for (int i = 0; i < meals.length; i++) {
      final meal = meals[i];
      final mealId = 'meal_${i + 1}';
      await mealCollection.doc(mealId).set(meal.toJson());
    }
  } catch (e) {
    throw Exception('Failed to load data: $e');
  }
}

Future<List<Meal>> getMealsFromDatabase(String date) async {
  try {
    final mealCollection = _database.collection('users/$_uid/nutrition_plans/$date/meals');
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
