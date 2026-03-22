import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Sign up with email and password
  /// Returns UserModel or throws exception
  Future<UserModel> signUp(String email, String password, String name) async {
    try {
      UserCredential cred = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      
      // Send email verification
      await cred.user!.sendEmailVerification();
      
      // Create user profile in Firestore
      final user = UserModel(
        uid: cred.user!.uid,
        name: name,
        email: email,
        isEmailVerified: false,
      );
      
      await _firestore.collection('users').doc(cred.user!.uid).set(user.toMap());
      
      return user;
    } catch (e) {
      rethrow;
    }
  }

  /// Login with email and password
  /// Checks email verification before returning success
  Future<UserModel> login(String email, String password) async {
    try {
      UserCredential cred = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      
      // Reload to get latest email verification status
      await cred.user!.reload();
      
      // Check if email is verified
      if (!cred.user!.emailVerified) {
        throw 'Email not verified';
      }
      
      final doc = await _firestore.collection('users').doc(cred.user!.uid).get();
      final data = doc.data() ?? {
        'uid': cred.user!.uid,
        'name': 'User',
        'email': email,
      };
      data['isEmailVerified'] = true;
      
      return UserModel.fromMap(data);
    } catch (e) {
      rethrow;
    }
  }

  /// Logout
  Future<void> logout() async {
    await _auth.signOut();
  }

  /// Get auth state changes stream
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  /// Check if current user's email is verified
  bool isEmailVerified() {
    return _auth.currentUser?.emailVerified ?? false;
  }

  /// Get current user
  User? getCurrentUser() {
    return _auth.currentUser;
  }

  /// Reload current user data
  Future<void> reloadUser() async {
    await _auth.currentUser?.reload();
  }

  /// Resend email verification
  Future<void> resendEmailVerification() async {
    await _auth.currentUser?.sendEmailVerification();
  }
}
