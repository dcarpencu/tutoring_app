import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:movie_app/src/data/auth_base_api.dart';
import 'package:movie_app/src/models/index.dart';

class AuthApi implements AuthApiBase {
  AuthApi(this._auth, this._firestore);

  final FirebaseAuth _auth;
  final FirebaseFirestore _firestore;

  @override
  Future<AppUser?> getCurrentUser() async {
    final User? currentUser = _auth.currentUser;
    if (currentUser != null) {
      final DocumentSnapshot<Map<String, dynamic>> snapshot = await _firestore.doc('users/${currentUser.uid}').get();

      if (snapshot.exists) {
        return AppUser.fromJson(snapshot.data()!);
      } else {
        final AppUser user = AppUser(
          uid: currentUser.uid,
          email: currentUser.email!,
          username: currentUser.displayName!,
        );
        await _firestore.doc('users/${user.uid}').set(user.toJson());

        return user;
      }
    }
    return null;
  }

  @override
  Future<AppUser> login({required String email, required String password}) async {
    await _auth.signInWithEmailAndPassword(email: email, password: password);

    final DocumentSnapshot<Map<String, dynamic>> snapshot =
    await _firestore.doc('users/${_auth.currentUser!.uid}').get();
    return AppUser.fromJson(snapshot.data()!);
  }

  @override
  Future<AppUser> create({required String email, required String password, required String username}) async {
    final UserCredential credentials = await _auth.createUserWithEmailAndPassword(email: email, password: password);
    const String role = 'student';
    await _auth.currentUser!.updateDisplayName(username);

    final AppUser user = AppUser(
      uid: credentials.user!.uid,
      email: email,
      username: username,
      role: role,
    );

    await _firestore.doc('users/${user.uid}').set(user.toJson());

    return user;
  }

  @override
  Future<void> logOut() async {
    await _auth.signOut();
  }

  @override
  Future<AppUser> getUser(String uid) async {
    final DocumentSnapshot<Map<String, dynamic>> snapshot = await _firestore.doc('users/$uid').get();
    return AppUser.fromJson(snapshot.data()!);
  }
}
