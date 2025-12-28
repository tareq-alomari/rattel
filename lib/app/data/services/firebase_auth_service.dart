import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../models/user_model.dart';

class FirebaseAuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  Stream<User?> authStateChanges() => _auth.authStateChanges();

  UserModel _mapFirebaseUser(User user, {String? name, String? role}) {
    return UserModel(
      firebaseId: user.uid,
      name: name ?? user.displayName ?? 'User',
      email: user.email ?? '',
      password: '', // Password is not stored locally for Firebase users
      role: role ?? 'student',
      points: 0,
    );
  }

  Future<UserModel?> signUpWithEmail(
    String email,
    String password,
    String name,
    String role,
  ) async {
    final cred = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
    if (cred.user != null) {
      await cred.user!.updateDisplayName(name);
      return _mapFirebaseUser(cred.user!, name: name, role: role);
    }
    return null;
  }

  Future<UserModel?> signInWithEmail(String email, String password) async {
    final cred = await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
    if (cred.user != null) {
      return _mapFirebaseUser(cred.user!);
    }
    return null;
  }

  Future<UserModel?> signInWithGoogle() async {
    final googleUser = await _googleSignIn.signIn();
    if (googleUser == null) return null;
    final googleAuth = await googleUser.authentication;
    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );
    final cred = await _auth.signInWithCredential(credential);
    if (cred.user != null) {
      return _mapFirebaseUser(cred.user!);
    }
    return null;
  }

  Future<void> signOut() async {
    await _auth.signOut();
    await _googleSignIn.signOut();
  }
}
