// ignore_for_file: avoid_print, use_build_context_synchronously, unused_element

import 'dart:convert';
import 'dart:developer' as dev;
import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:crypto/crypto.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import 'package:zaitoon/helper/navigation_helper.dart';
import 'package:zaitoon/screens/bottom_navigation/bottom_navigation.dart';
import 'package:zaitoon/screens/login_screen/login_screen.dart';
import 'package:zaitoon/screens/user_data_collection_screen/provider/user_data_provider.dart';
import 'package:zaitoon/screens/user_data_collection_screen/user_data_collection_screen.dart';

class AuthProvider with ChangeNotifier {
  /// firebase auth
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance; // Add this
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  UserModel? _user;
  bool _isLoading = false;
  bool _isSignedIn = false;

  UserModel? get user => _user;
  bool get isLoading => _isLoading;
  bool get isSignedIn => _isSignedIn;

  Future<void> _saveUserToFirestore(UserModel user,
      {String? displayName}) async {
    try {
      await _firestore.collection('users').doc(user.uid).set({
        'uid': user.uid,
        'email': user.email,
        // 'name': displayName,
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      dev.log('User data saved to Firestore successfully');
    } catch (e) {
      dev.log('Error saving user data to Firestore: $e');
      throw Exception('Failed to save user data');
    }
  }

  Future<UserModel?> signInWithGoogle(BuildContext context) async {
    try {
      _isLoading = true;
      notifyListeners();

      dev.log('Starting Google Sign In process');

      // Trigger Google Sign In flow
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

      if (googleUser == null) {
        dev.log('Google Sign In was aborted by user');
        _isLoading = false;
        notifyListeners();
        return null;
      }

      dev.log('Getting Google Auth details');
      // Obtain auth details from request
      final GoogleSignInAuthentication googleAuth;
      try {
        googleAuth = await googleUser.authentication;
      } catch (e) {
        dev.log('Error getting Google Auth details: $e');
        throw Exception('Failed to get Google authentication details');
      }

      if (googleAuth.accessToken == null || googleAuth.idToken == null) {
        dev.log('Google Auth tokens are null');
        throw Exception('Google Auth tokens are missing');
      }

      dev.log('Creating Firebase credential');
      // Create new credential
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      dev.log('Signing in to Firebase');
      // Sign in to Firebase with credential
      final UserCredential userCredential;
      try {
        userCredential = await _auth.signInWithCredential(credential);
      } catch (e) {
        dev.log('Firebase sign in error: $e');
        throw Exception('Failed to sign in to Firebase');
      }

      final User? firebaseUser = userCredential.user;

      if (firebaseUser != null) {
        dev.log('Firebase user created successfully');
        dev.log('UID: ${firebaseUser.uid}');
        dev.log('Email: ${firebaseUser.email}');
        dev.log('Name: ${firebaseUser.displayName}');

        if (firebaseUser.email == null || firebaseUser.displayName == null) {
          throw Exception('Required user information is missing');
        }

        _user = UserModel(
          uid: firebaseUser.uid,
          email: firebaseUser.email,
        );

        await _saveUserToFirestore(_user!,
            displayName: firebaseUser.displayName);

        final SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setString('uidKey', firebaseUser.uid);
        await prefs.setString('emailKey', firebaseUser.email!);

        checkAndLoadUserData(context: context);

        _isSignedIn = true;
        notifyListeners();
        return _user;
      } else {
        dev.log('Firebase user is null after sign in');
        throw Exception('Failed to create Firebase user');
      }
    } catch (e) {
      dev.log('Error in signInWithGoogle: $e', error: e);
      // Show error to user
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Sign in failed: ${e.toString()}')),
        );
      }
    } finally {
      _isLoading = false;
      notifyListeners();
    }
    return null;
  }

  /// Sign in with Apple
  Future<UserModel?> signInWithApple(BuildContext context) async {
    try {
      _isLoading = true;
      notifyListeners();

      // Generate nonce
      final rawNonce = generateNonce();
      final nonce = _sha256ofString(rawNonce);

      dev.log('Requesting Apple credentials...');

      // Request credential for Apple Sign In
      final credential = await SignInWithApple.getAppleIDCredential(
        scopes: [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
        nonce: nonce,
      );

      dev.log('Apple credentials received');

      // Verify we have the required token
      if (credential.identityToken == null) {
        throw Exception('Apple Sign In failed - identity token is null');
      }

      dev.log('Creating Firebase credential');

      // Create Firebase credential
      final oauthCredential = OAuthProvider('apple.com').credential(
        idToken: credential.identityToken!,
        accessToken: credential.authorizationCode,
        rawNonce: rawNonce, // Important: Pass the raw nonce
      );

      dev.log('Signing in to Firebase');

      // Sign in to Firebase
      final userCredential = await _auth.signInWithCredential(oauthCredential);
      final firebaseUser = userCredential.user;

      if (firebaseUser == null) {
        throw Exception('Firebase user is null after sign in');
      }

      dev.log('Firebase sign in successful, UID: ${firebaseUser.uid}');

      // Create display name from Apple credential if available
      String? displayName;
      if (credential.givenName != null || credential.familyName != null) {
        displayName =
            '${credential.givenName ?? ''} ${credential.familyName ?? ''}'
                .trim();
        if (displayName.isNotEmpty) {
          await firebaseUser.updateDisplayName(displayName);
        }
      }

      // Create user model
      _user = UserModel(
        uid: firebaseUser.uid,
        email: firebaseUser.email ?? credential.email,
      );

      // Save to SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('uidKey', firebaseUser.uid);
      if (_user?.email != null) {
        await prefs.setString('emailKey', _user!.email!);
      }

      dev.log('Local storage updated');

      // Save to Firestore
      await _firestore.collection('users').doc(firebaseUser.uid).set({
        'uid': firebaseUser.uid,
        'email': _user?.email,
        'name': displayName,
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      dev.log('Firestore updated');

      await checkAndLoadUserData(context: context);

      _isSignedIn = true;
      notifyListeners();
      return _user;
    } on SignInWithAppleAuthorizationException catch (e) {
      dev.log('Apple Sign In Authorization Error: ${e.code} - ${e.message}');
      if (e.code != AuthorizationErrorCode.canceled && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Apple Sign In failed: ${e.message}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } on FirebaseAuthException catch (e) {
      dev.log('Firebase Auth Error: ${e.code} - ${e.message}');
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Authentication failed: ${e.message}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      dev.log('Error in signInWithApple: $e');
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Sign in failed: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      _isLoading = false;
      notifyListeners();
    }
    return null;
  }

  Future<void> checkAndLoadUserData({required BuildContext context}) async {
    try {
      final provider = Provider.of<UserDataProvider>(context, listen: false);
      await provider.loadUserDetails(); // Load details from SharedPreferences

      // Check if all required user details exist
      if (provider.name == null ||
          provider.name!.isEmpty ||
          provider.age == null ||
          provider.age! <= 0 ||
          provider.gender.isEmpty) {
        // Navigate to user collection screen if any details are missing
        navigateAndRemove(
          context: context,
          screen: const UserDataCollection(
            isFromOnboarding: true,
          ),
        );
      } else {
        // All details exist, navigate to home screen
        navigateAndRemove(
          context: context,
          screen: const BottomNavigationScreen(),
        );
      }
    } catch (e) {
      print('Error loading user data: $e');
      // On error, direct to user collection screen
      navigateAndRemove(
        context: context,
        screen: const UserDataCollection(
          isFromOnboarding: true,
        ),
      );
    }
  }

  Future<void> signOut(BuildContext context) async {
    try {
      await _googleSignIn.signOut();
      await _auth.signOut();
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.clear();
      print('User signed out');

      _isSignedIn = false;
      _user = null;
      notifyListeners();

      navigateAndRemove(context: context, screen: const AuthScreen());
    } catch (e) {
      print('Error signing out: $e');
    }
  }

  // hit api for login

// get token from shared pref
  Future<String?> getToken() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  Future<void> checkUserStatus() async {
    try {
      _isSignedIn = await isUserSignedIn();
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isSignedIn = false;
      _isLoading = false;
      notifyListeners();
      dev.log('Error checking user status: $e');
    }
  }

  Future<bool> isUserSignedIn() async {
    try {
      // Get current Firebase user
      User? currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser == null) {
        dev.log('No Firebase user found');
        return false;
      }

      // Get stored preferences
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? storedUid = prefs.getString('uidKey');
      String? storedEmail = prefs.getString('emailKey');

      // Verify stored UID matches current Firebase user
      if (storedUid != currentUser.uid) {
        dev.log('Stored UID does not match Firebase UID');
        return false;
      }

      // If we reach here, user is properly authenticated
      _user = UserModel(
        uid: currentUser.uid,
        email: storedEmail ?? currentUser.email,
      );

      dev.log('User authenticated successfully');
      dev.log('User UID: ${currentUser.uid}');
      return true;
    } catch (e) {
      dev.log('Error checking user sign-in status: $e');
      return false;
    }
  }

  // check if user is signed in or not if not then show snackbar as login required for bookmark
  Future<bool> checkSignIn(BuildContext context) async {
    if (_isSignedIn) {
      return true;
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Login required to bookmark'),
          action: SnackBarAction(
            label: 'Login',
            onPressed: () {
              navigateAndRemove(context: context, screen: const AuthScreen());
            },
          ),
        ),
      );
      return false;
    }
  }

  // apple sign in
  /// Generate a random string that will be used as the state parameter for Apple Sign In
  String generateNonce([int length = 32]) {
    const charset =
        '0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._';
    final random = Random.secure();
    return List.generate(length, (_) => charset[random.nextInt(charset.length)])
        .join();
  }

  String _sha256ofString(String input) {
    final bytes = utf8.encode(input);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }
}

class UserModel {
  final String uid;
  final String? email;

  UserModel({
    required this.uid,
    this.email,
  });

  factory UserModel.fromFirebase(dynamic user) {
    return UserModel(
      uid: user.uid,
      email: user.email,
    );
  }
}
