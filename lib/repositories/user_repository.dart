import 'package:firebase_auth/firebase_auth.dart' as fa;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../models/user_model.dart';

class UserRepository {
  final fa.FirebaseAuth _auth = fa.FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  late final GoogleSignIn _googleSignIn;
  final FirebaseStorage _storage = FirebaseStorage.instance;
  
  bool _googleSignInInitialized = false;

  /// Lazy initialization of GoogleSignIn - only when needed
  GoogleSignIn _getGoogleSignIn() {
    if (!_googleSignInInitialized) {
      _googleSignIn = GoogleSignIn(
        clientId: '885163617614-dlc8fqdenhnh7rq01ca9qqcc8pj1pmst.apps.googleusercontent.com',
      );
      _googleSignInInitialized = true;
    }
    return _googleSignIn;
  }

  Future<UserModel> signUp(String email, String password, String name) async {
    try {
      // Validate inputs
      if (email.isEmpty || password.isEmpty || name.isEmpty) {
        throw Exception('All fields are required');
      }
      if (password.length < 6) {
        throw Exception('Password must be at least 6 characters');
      }
      
      final cred = await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      ).timeout(
        const Duration(seconds: 30),
        onTimeout: () {
          throw Exception('Sign up timeout: Request took too long');
        },
      );
      
      // Send email verification
      try {
        await cred.user?.sendEmailVerification();
      } catch (e) {
        // Continue even if verification email fails
      }
      
      final user = UserModel(
        uid: cred.user!.uid,
        name: name,
        email: email,
        isEmailVerified: false,
      );
      await _firestore.collection('users').doc(cred.user!.uid).set(user.toMap());
      return user;
    } on FirebaseAuthException catch (e) {
      String errorMessage;
      switch (e.code) {
        case 'email-already-in-use':
          errorMessage = 'This email is already registered';
          break;
        case 'invalid-email':
          errorMessage = 'Invalid email format';
          break;
        case 'weak-password':
          errorMessage = 'Password is too weak';
          break;
        default:
          errorMessage = e.message ?? 'Sign up failed';
      }
      throw Exception(errorMessage);
    } catch (e) {
      throw Exception('Sign up failed: $e');
    }
  }

  Future<UserModel> login(String email, String password) async {
    try {
      // Validate input
      if (email.isEmpty || password.isEmpty) {
        throw Exception('Email and password are required');
      }
      
      final cred = await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      ).timeout(
        const Duration(seconds: 30),
        onTimeout: () {
          throw Exception('Login timeout: Request took too long');
        },
      );
      
      final doc = await _firestore.collection('users').doc(cred.user!.uid).get();
      final isVerified = cred.user?.emailVerified ?? false;
      final data = doc.data() ?? {
        'uid': cred.user!.uid,
        'name': 'User',
        'email': email,
      };
      data['isEmailVerified'] = isVerified;
      return UserModel.fromMap(data);
    } on FirebaseAuthException catch (e) {
      // Provide user-friendly error messages
      String errorMessage;
      switch (e.code) {
        case 'user-not-found':
          errorMessage = 'No account found with this email';
          break;
        case 'wrong-password':
          errorMessage = 'Incorrect password';
          break;
        case 'invalid-email':
          errorMessage = 'Invalid email format';
          break;
        case 'user-disabled':
          errorMessage = 'This account has been disabled';
          break;
        case 'too-many-requests':
          errorMessage = 'Too many failed login attempts. Please try again later';
          break;
        default:
          errorMessage = e.message ?? 'Login failed';
      }
      throw Exception(errorMessage);
    } catch (e) {
      throw Exception('Login failed: $e');
    }
  }

  Future<UserModel> signInWithGoogle() async {
    try {
      // Get/initialize GoogleSignIn lazily on first use
      final googleSignIn = _getGoogleSignIn();
      
      // Attempt to sign in with Google
      final googleUser = await googleSignIn.signIn().timeout(
        const Duration(seconds: 30),
        onTimeout: () {
          throw Exception('Google sign in timeout');
        },
      );
      
      if (googleUser == null) {
        throw Exception('Google sign in cancelled by user');
      }
      
      final googleAuth = await googleUser.authentication;
      final cred = fa.GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );
      
      final userCred = await _auth.signInWithCredential(cred);
      final doc = await _firestore.collection('users').doc(userCred.user!.uid).get();
      
      if (!doc.exists) {
        // Create new user document for Google sign in
        final user = UserModel(
          uid: userCred.user!.uid,
          name: userCred.user!.displayName ?? 'User',
          email: userCred.user!.email ?? '',
          isEmailVerified: true, // Google sign in users are auto-verified
        );
        await _firestore.collection('users').doc(userCred.user!.uid).set(user.toMap());
        return user;
      }
      
      final data = doc.data()!;
      data['isEmailVerified'] = userCred.user?.emailVerified ?? true;
      return UserModel.fromMap(data);
    } catch (e) {
      throw Exception('Google sign in failed: $e');
    }
  }

  Future<UserModel> getCurrentUser() async {
    final uid = _auth.currentUser!.uid;
    final doc = await _firestore.collection('users').doc(uid).get();
    final isVerified = _auth.currentUser?.emailVerified ?? false;
    final data = doc.data() ?? {};
    data['isEmailVerified'] = isVerified;
    return UserModel.fromMap(data);
  }

  Future<void> updateProfile(UserModel user) async {
    await _firestore.collection('users').doc(user.uid).update(user.toMap());
  }

  /// Upload profile picture - For web apps, use CloudinaryService instead
  /// This method is maintained for backward compatibility but is optimized for Cloudinary URLs
  Future<UserModel> uploadProfilePicture(String imagePath) async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) throw Exception('User not authenticated');

    try {
      // For web apps, imagePath is typically a Cloudinary URL already
      // This method just saves the URL to Firestore
      // If you need to upload a new image, use CloudinaryService.pickAndUploadImage()
      // followed by updateProfilePictureUrl(cloudinaryUrl)
      
      if (imagePath.isEmpty) {
        throw Exception('Image path/URL cannot be empty');
      }

      // Get the current user to preserve other data
      final currentUser = await getCurrentUser();
      
      // Update user document with profile picture URL
      await _firestore.collection('users').doc(uid).update({
        'profilePicture': imagePath,
        'profilePictureUpdatedAt': DateTime.now(),
      });
      
      // Return updated user with the image URL
      final updatedUser = UserModel(
        uid: currentUser.uid,
        name: currentUser.name,
        email: currentUser.email,
        phone: currentUser.phone,
        address: currentUser.address,
        profilePicture: imagePath,
        isEmailVerified: currentUser.isEmailVerified,
      );
      return updatedUser;
    } catch (e) {
      throw Exception('Error updating profile picture: $e');
    }
  }

  Future<void> logout() async {
    await _googleSignIn.signOut();
    await _auth.signOut();
  }
  
  bool isEmailVerified() => _auth.currentUser?.emailVerified ?? false;

  /// Change user password
  /// Requires current email and old password to re-authenticate
  Future<void> changePassword(String currentPassword, String newPassword) async {
    try {
      final user = _auth.currentUser;
      if (user == null) throw Exception('User not authenticated');
      
      // Re-authenticate user before changing password
      final credential = fa.EmailAuthProvider.credential(
        email: user.email!,
        password: currentPassword,
      );
      
      await user.reauthenticateWithCredential(credential);
      
      // Change password
      await user.updatePassword(newPassword);
      
      // Sign out user after password change for security
      // User must sign back in with new password
      await logout();
    } catch (e) {
      rethrow;
    }
  }

  /// Delete user account and all associated data
  Future<void> deleteAccount(String password) async {
    try {
      final user = _auth.currentUser;
      if (user == null) throw Exception('User not authenticated');
      
      // Re-authenticate user before deletion
      final credential = fa.EmailAuthProvider.credential(
        email: user.email!,
        password: password,
      );
      
      await user.reauthenticateWithCredential(credential);
      
      // Delete user profile picture from storage if exists
      try {
        await _storage.ref().child('profile_pictures').child(user.uid).delete();
      } catch (e) {
        // Ignore storage deletion errors (file might not exist)
      }
      
      // Delete user document from Firestore
      await _firestore.collection('users').doc(user.uid).delete();
      
      // Delete user from Firebase Auth
      await user.delete();
    } catch (e) {
      rethrow;
    }
  }

  /// Update marketing email preference
  Future<void> updateMarketingPreference(bool value) async {
    try {
      final uid = _auth.currentUser?.uid;
      if (uid == null) throw Exception('User not authenticated');
      
      await _firestore.collection('users').doc(uid).update({
        'marketingEmails': value,
        'updatedAt': DateTime.now(),
      });
    } catch (e) {
      rethrow;
    }
  }

  /// Get marketing email preference
  Future<bool> getMarketingPreference() async {
    try {
      final uid = _auth.currentUser?.uid;
      if (uid == null) throw Exception('User not authenticated');
      
      final doc = await _firestore.collection('users').doc(uid).get();
      return doc.data()?['marketingEmails'] ?? true;
    } catch (e) {
      return true; // Default to true if no preference set
    }
  }

  /// Submit feedback to Firestore
  Future<void> submitFeedback(String feedback) async {
    try {
      final uid = _auth.currentUser?.uid;
      if (uid == null) throw Exception('User not authenticated');
      
      await _firestore.collection('feedback').add({
        'uid': uid,
        'email': _auth.currentUser?.email,
        'feedback': feedback,
        'timestamp': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      rethrow;
    }
  }

  /// Update user profile picture with a Cloudinary URL
  /// Takes a secure_url from Cloudinary and updates the user's profilePicture field
  Future<UserModel> updateProfilePictureUrl(String imageUrl) async {
    try {
      final uid = _auth.currentUser?.uid;
      if (uid == null) throw Exception('User not authenticated');
      
      if (imageUrl.isEmpty) throw Exception('Image URL cannot be empty');
      
      // Get the current user to preserve other data
      final currentUser = await getCurrentUser();
      
      // Update user document with Cloudinary URL
      await _firestore.collection('users').doc(uid).update({
        'profilePicture': imageUrl,
        'profilePictureUpdatedAt': DateTime.now(),
      });
      
      // Return updated user with the image URL
      final updatedUser = UserModel(
        uid: currentUser.uid,
        name: currentUser.name,
        email: currentUser.email,
        phone: currentUser.phone,
        address: currentUser.address,
        profilePicture: imageUrl,
        isEmailVerified: currentUser.isEmailVerified,
        notificationCount: currentUser.notificationCount,
      );
      return updatedUser;
    } catch (e) {
      throw Exception('Error updating profile picture: $e');
    }
  }
}