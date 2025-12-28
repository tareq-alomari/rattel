import 'package:cloud_firestore/cloud_firestore.dart';

class UserDataService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Future<void> setUserData(String uid, Map<String, dynamic> data) async {
    await _db.collection('users').doc(uid).set(data, SetOptions(merge: true));
  }

  Stream<DocumentSnapshot> userStream(String uid) =>
      _db.collection('users').doc(uid).snapshots();
}
