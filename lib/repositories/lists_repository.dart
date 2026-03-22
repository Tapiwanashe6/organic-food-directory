import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as fa;
import '../models/list_model.dart';

class ListsRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final fa.FirebaseAuth _auth = fa.FirebaseAuth.instance;

  Stream<List<ListModel>> getLists() {
    final uid = _auth.currentUser!.uid;
    return _firestore
        .collection('users')
        .doc(uid)
        .collection('lists')
        .orderBy('updatedAt', descending: true)
        .snapshots()
        .map((snap) {
          return snap.docs
              .map((doc) {
                try {
                  return ListModel.fromMap({...doc.data(), 'id': doc.id});
                } catch (e) {
                  debugPrint('Error parsing list: $e');
                  rethrow;
                }
              })
              .toList();
        })
        .handleError((error) {
          debugPrint('Error in lists stream: $error');
          return <ListModel>[]; // Return empty list on error
        });
  }

  Future<ListModel> createList(String title) async {
    final uid = _auth.currentUser!.uid;
    final now = DateTime.now();
    final docRef = await _firestore
        .collection('users')
        .doc(uid)
        .collection('lists')
        .add({
      'title': title,
      'items': [],
      'color': 'green',
      'icon': 'shopping_basket_outlined',
      'createdAt': now,
      'updatedAt': now,
    });

    return ListModel(
      id: docRef.id,
      title: title,
      items: [],
      color: 'green',
      icon: 'shopping_basket_outlined',
      createdAt: now,
      updatedAt: now,
    );
  }

  Future<void> updateList(ListModel list) async {
    final uid = _auth.currentUser!.uid;
    await _firestore
        .collection('users')
        .doc(uid)
        .collection('lists')
        .doc(list.id)
        .update({
      'title': list.title,
      'items': list.items,
      'color': list.color,
      'icon': list.icon,
      'updatedAt': DateTime.now(),
    });
  }

  Future<void> deleteList(String listId) async {
    final uid = _auth.currentUser!.uid;
    await _firestore
        .collection('users')
        .doc(uid)
        .collection('lists')
        .doc(listId)
        .delete();
  }

  Future<void> addItemToList(String listId, String item) async {
    final uid = _auth.currentUser!.uid;
    final docRef = _firestore
        .collection('users')
        .doc(uid)
        .collection('lists')
        .doc(listId);

    final doc = await docRef.get();
    if (doc.exists) {
      final items = List<String>.from(doc['items'] ?? []);
      if (!items.contains(item)) {
        items.add(item);
        await docRef.update({
          'items': items,
          'updatedAt': DateTime.now(),
        });
      }
    }
  }

  Future<void> removeItemFromList(String listId, String item) async {
    final uid = _auth.currentUser!.uid;
    final docRef = _firestore
        .collection('users')
        .doc(uid)
        .collection('lists')
        .doc(listId);

    final doc = await docRef.get();
    if (doc.exists) {
      final items = List<String>.from(doc['items'] ?? []);
      items.remove(item);
      await docRef.update({
        'items': items,
        'updatedAt': DateTime.now(),
      });
    }
  }
}
