import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreService {
  final CollectionReference recipes = FirebaseFirestore.instance.collection(
    'recipes',
  );

  Future<void> addRecipe(String name, String text) {
    return recipes.add({
      'name': name,
      'recipe': text,
      'timestamp': Timestamp.now(),
    });
  }

  Stream<QuerySnapshot> getRecipesStream() {
    final recipeStream =
        recipes.orderBy('timestamp', descending: true).snapshots();
    return recipeStream;
  }

  Future<void> updateRecipe(String id, String name, String text) {
    return recipes.doc(id).update({
      'name': name,
      'recipe': text,
      'timestamp': Timestamp.now(),
    });
  }

  Future<void> deleteRecipe(String id) {
    return recipes.doc(id).delete();
  }
}
