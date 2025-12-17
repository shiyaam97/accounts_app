import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../models/user_model.dart';

class AuthRepository {
  final FirebaseAuth _firebaseAuth;
  final GoogleSignIn _googleSignIn;
  final FirebaseFirestore _firestore;

  AuthRepository({
    FirebaseAuth? firebaseAuth,
    GoogleSignIn? googleSignIn,
    FirebaseFirestore? firestore,
  })  : _firebaseAuth = firebaseAuth ?? FirebaseAuth.instance,
        _googleSignIn = googleSignIn ?? GoogleSignIn.instance,
        _firestore = firestore ?? FirebaseFirestore.instance;

  /// Stream of current user state
  Stream<UserModel> get user {
    return _firebaseAuth.authStateChanges().map((firebaseUser) {
      if (firebaseUser == null) {
        return UserModel.empty;
      } else {
        return UserModel(
          id: firebaseUser.uid,
          email: firebaseUser.email ?? '',
          name: firebaseUser.displayName,
          profilePic: firebaseUser.photoURL,
        );
      }
    });
  }

  /// Login with Google
  ///
  Future<void> logInWithGoogle() async {
    try {
      final GoogleAuthProvider googleProvider =
      GoogleAuthProvider();

      final UserCredential userCredential =
      await FirebaseAuth.instance
          .signInWithProvider(googleProvider);

      if (userCredential.user != null) {
        await _saveUserToFirestore(userCredential.user!);
      }
    } catch (e) {
      // debugPrint('Google login failed: $e');
    }
  }

  /// Login with Email & Password
  Future<void> logInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
    } catch (e) {
      throw Exception('Log in with email failed: $e');
    }
  }

  /// Sign up with Email & Password
  Future<void> signUp({
    required String email,
    required String password,
    String? name,
  }) async {
    try {
      final UserCredential userCredential =
      await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (userCredential.user != null) {
        if (name != null) {
          await userCredential.user!.updateDisplayName(name);
        }

        // Save user to Firestore
        await _saveUserToFirestore(userCredential.user!, name: name);
      }
    } catch (e) {
      throw Exception('Sign up failed: $e');
    }
  }

  /// Log out from both Firebase and Google
  Future<void> logOut() async {
    try {
      await Future.wait([
        _firebaseAuth.signOut(),
        _googleSignIn.signOut(),
      ]);
    } catch (e) {
      throw Exception('Log out failed: $e');
    }
  }

  /// Save new user to Firestore
  Future<void> _saveUserToFirestore(User user, {String? name}) async {
    final userRef = _firestore.collection('users').doc(user.uid);
    final userData = await userRef.get();

    if (!userData.exists) {
      final newUser = UserModel(
        id: user.uid,
        email: user.email ?? '',
        name: name ?? user.displayName,
        profilePic: user.photoURL,
      );
      await userRef.set(newUser.toMap());
    }
  }
}
