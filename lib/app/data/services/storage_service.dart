import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';

class StorageService {
  final FirebaseStorage _storage = FirebaseStorage.instance;

  Future<String> uploadFile(String uid, File file, String path) async {
    final ref = _storage.ref().child('users/$uid/$path');
    await ref.putFile(file);
    return await ref.getDownloadURL();
  }

  Future<void> deleteFile(String uid, String path) async {
    final ref = _storage.ref().child('users/$uid/$path');
    await ref.delete();
  }
}
