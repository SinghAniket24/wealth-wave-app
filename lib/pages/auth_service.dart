import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Stream to track authentication state
  Stream<User?> get userChanges => _auth.authStateChanges();

  // Get current user
  User? get currentUser => _auth.currentUser;

  // Sign up with email and password
  Future<String?> signUpWithEmail(String email, String password, String name, String photoUrl) async {
    try {
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Update user profile with name and photo
      await userCredential.user?.updateDisplayName(name);
      await userCredential.user?.updatePhotoURL(photoUrl);

      // Send email verification
      await userCredential.user?.sendEmailVerification();

      // Store user data in Firestore
      await _firestore.collection('users').doc(userCredential.user!.uid).set({
        'uid': userCredential.user!.uid,
        'name': name,
        'email': email,
        'photoUrl': photoUrl,
        'createdAt': FieldValue.serverTimestamp(),
      });

      return null; // Success
    } catch (e) {
      return e.toString();
    }
  }

  // Sign in with email and password
  Future<String?> signInWithEmail(String email, String password) async {
    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Check if email is verified
      if (!userCredential.user!.emailVerified) {
        return "Please verify your email before signing in.";
      }

      return null; // Success
    } catch (e) {
      return e.toString();
    }
  }

  // Google Sign-In
  Future<String?> signInWithGoogle() async {
    try {
      final GoogleSignIn googleSignIn = GoogleSignIn(
        clientId: "56664279631-4761uhl81sc9oqe1m3o14td90q3a47tc.apps.googleusercontent.com", // 🔥 Add Web Client ID here
        scopes: ['email'],
      );

      final GoogleSignInAccount? googleUser = await googleSignIn.signIn();
      if (googleUser == null) return "Google Sign-In cancelled";

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      UserCredential userCredential = await _auth.signInWithCredential(credential);

      // Check if new user, then store data
      if (userCredential.additionalUserInfo!.isNewUser) {
        await _firestore.collection('users').doc(userCredential.user!.uid).set({
          'uid': userCredential.user!.uid,
          'name': userCredential.user!.displayName ?? "User",
          'email': userCredential.user!.email,
          'photoUrl': userCredential.user!.photoURL ?? "",
          'createdAt': FieldValue.serverTimestamp(),
        });
      }

      return null; // Success
    } catch (e) {
      return e.toString();
    }
  }

  // Reset password
  Future<String?> resetPassword(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
      return null; // Success
    } catch (e) {
      return e.toString();
    }
  }

  // Update user profile (name and photo)
  Future<String?> updateProfile(String name, String photoUrl) async {
    try {
      await _auth.currentUser!.updateDisplayName(name);
      await _auth.currentUser!.updatePhotoURL(photoUrl);
      await _firestore.collection('users').doc(_auth.currentUser!.uid).update({
        'name': name,
        'photoUrl': photoUrl,
      });
      return null; // Success
    } catch (e) {
      return e.toString();
    }
  }

  // Sign out function
  Future<void> signOut() async {
    await GoogleSignIn().signOut();
    await _auth.signOut();
  }
}
