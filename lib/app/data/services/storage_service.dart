import 'dart:io';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_storage/firebase_storage.dart';

class StorageService {
  FirebaseStorage get _storage => FirebaseStorage.instance;
  bool get _isFirebaseReady => Firebase.apps.isNotEmpty;

  Future<String?> uploadFile(String uid, File file, String path) async {
    if (!_isFirebaseReady) return null;
    final ref = _storage.ref().child('users/$uid/$path');
    await ref.putFile(file);
    return await ref.getDownloadURL();
  }

  Future<void> deleteFile(String uid, String path) async {
    if (!_isFirebaseReady) return;
    final ref = _storage.ref().child('users/$uid/$path');
    await ref.delete();
  }
}
