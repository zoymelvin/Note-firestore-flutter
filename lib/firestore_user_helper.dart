import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_note/models/user_model.dart';

class FirestoreUserHelper {
  final _userRef = FirebaseFirestore.instance
      .collection('users_notes')
      .withConverter<UserModel>(
        fromFirestore: (snapshot, _) => UserModel.fromJson(snapshot.data()!),
        toFirestore: (userModel, _) => userModel.toJson(),
      );

  Future<void> addUser(UserModel user) async {
    await _userRef.doc(user.userId).set(user);
  }
  
  Future<UserModel?> getUser(String uid) async {
    final doc = await _userRef.doc(uid).get();
    return doc.data();
  }
}