import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';

import 'database_config.dart';

class AuthService {
  AuthService({FirebaseAuth? auth, FirebaseDatabase? database})
    : _auth = auth ?? FirebaseAuth.instance,
      _database =
          database ??
          FirebaseDatabase.instanceFor(
            app: Firebase.app(),
            databaseURL: realtimeDatabaseUrl,
          );

  final FirebaseAuth _auth;
  final FirebaseDatabase _database;

  User? get currentUser => _auth.currentUser;

  Future<UserCredential> signIn({
    required String email,
    required String password,
  }) async {
    final credential = await _auth.signInWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );
    final user = credential.user;
    if (user != null) await ensureProfile(user);
    return credential;
  }

  Future<void> ensureProfile(User user) async {
    final profile = _database.ref('users/${user.uid}');
    final snapshot = await profile.get();
    if (snapshot.exists) return;

    await profile.set({
      'uid': user.uid,
      'name': user.displayName ?? 'User',
      'email': user.email,
      'createdAt': ServerValue.timestamp,
    });
  }

  Future<UserCredential> register({
    required String name,
    required String email,
    required String password,
  }) async {
    final credential = await _auth.createUserWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );
    final user = credential.user;
    if (user == null) {
      throw FirebaseAuthException(
        code: 'user-creation-failed',
        message: 'Firebase did not return the newly created user.',
      );
    }

    await user.updateDisplayName(name.trim());
    await _database.ref('users/${user.uid}').set({
      'uid': user.uid,
      'name': name.trim(),
      'email': user.email,
      'createdAt': ServerValue.timestamp,
    });
    return credential;
  }
}
