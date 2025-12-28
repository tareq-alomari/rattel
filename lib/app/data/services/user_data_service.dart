import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class UserDataService {
  FirebaseFirestore get _db => FirebaseFirestore.instance;
  bool get _isFirebaseReady => Firebase.apps.isNotEmpty;

  Future<void> setUserData(String uid, Map<String, dynamic> data) async {
    if (!_isFirebaseReady) return;
    await _db.collection('users').doc(uid).set(data, SetOptions(merge: true));
  }

  Stream<DocumentSnapshot>? userStream(String uid) {
    if (!_isFirebaseReady) return null;
    return _db.collection('users').doc(uid).snapshots();
  }
}
