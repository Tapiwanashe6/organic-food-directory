import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as fa;

class FavoritesRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final fa.FirebaseAuth _auth = fa.FirebaseAuth.instance;

  Future<List<String>> getFavorites() async {
    final uid = _auth.currentUser!.uid;
    final snap = await _firestore.collection('users').doc(uid).collection('favorites').get();
    return snap.docs.map((doc) => doc.id).toList();
  }

  Future<void> toggleFavorite(String productId) async {
    final uid = _auth.currentUser!.uid;
    final ref = _firestore.collection('users').doc(uid).collection('favorites').doc(productId);
    final exists = (await ref.get()).exists;
    if (exists) {
      await ref.delete();
    } else {
      await ref.set({'addedAt': FieldValue.serverTimestamp()});
    }
  }
}