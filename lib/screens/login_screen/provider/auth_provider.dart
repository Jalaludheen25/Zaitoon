// ignore_for_file: avoid_print, use_build_context_synchronously, unused_element

import 'dart:convert';
import 'dart:developer' as dev;
import 'dart:math';
import 'package:crypto/crypto.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  UserModel? _user;
  bool _isLoading = false;

  UserModel? get user => _user;
  bool get isLoading => _isLoading;

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
        final SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setString('uidKey', firebaseUser.uid);
        await prefs.setString('emailKey', firebaseUser.email!);

        checkAndLoadUserData(context: context);

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

      final rawNonce = generateNonce();
      final nonce = _sha256ofString(rawNonce);

      // First, check if Apple Sign In is available
      final isAvailable = await SignInWithApple.isAvailable();
      if (!isAvailable) {
        throw PlatformException(
          code: 'APPLE_SIGN_IN_NOT_AVAILABLE',
          message: 'Apple Sign In is not available on this device',
        );
      }

      // Request credential with explicit webAuthenticationOptions
      final appleCredential = await SignInWithApple.getAppleIDCredential(
        scopes: [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
        webAuthenticationOptions: WebAuthenticationOptions(
          clientId: 'co.d4dx.zaitoon.signin', // Your Service ID
          redirectUri: Uri.parse(
              'https://zai-toon-dc9fc.firebaseapp.com/__/auth/handler'),
        ),
        nonce: nonce,
      );

      if (appleCredential.identityToken == null) {
        throw PlatformException(
          code: 'MISSING_TOKEN',
          message: 'Identity token is missing',
        );
      }

      // Create OAuthCredential
      final oauthCredential = OAuthProvider("apple.com").credential(
        idToken: appleCredential.identityToken!,
        rawNonce: rawNonce,
        accessToken: appleCredential.authorizationCode,
      );

      // Sign in with Firebase
      final userCredential = await _auth.signInWithCredential(oauthCredential);
      final firebaseUser = userCredential.user;

      if (firebaseUser != null) {
        String? displayName;

        // Handle name
        if (appleCredential.givenName != null ||
            appleCredential.familyName != null) {
          displayName =
              '${appleCredential.givenName ?? ''} ${appleCredential.familyName ?? ''}'
                  .trim();
          await firebaseUser.updateDisplayName(displayName);
        }

        displayName = displayName?.isNotEmpty == true
            ? displayName
            : (firebaseUser.displayName ?? 'Apple User');

        debugPrint('Successfully signed in with Apple: ${firebaseUser.uid}');

        _user = UserModel(
          uid: firebaseUser.uid,
          email: firebaseUser.email,
        );
        final SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setString('uidKey', firebaseUser.uid);
        await prefs.setString('emailKey', firebaseUser.email!);

        checkAndLoadUserData(context: context);
        notifyListeners();
        return _user;
      }
    } on SignInWithAppleAuthorizationException catch (e) {
      debugPrint('Apple Sign In Authorization Error: ${e.code} - ${e.message}');
      if (e.code != AuthorizationErrorCode.canceled) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Apple Sign In failed: ${e.message}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } on FirebaseAuthException catch (e) {
      debugPrint('Firebase Auth Error: ${e.code} - ${e.message}');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Firebase Auth Error: ${e.message}'),
          backgroundColor: Colors.red,
        ),
      );
    } catch (e) {
      debugPrint('Generic Error during Apple Sign In: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Sign in failed: $e'),
          backgroundColor: Colors.red,
        ),
      );
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
      navigateAndRemove(context: context, screen: const AuthScreen());

      _user = null;
      notifyListeners();
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

  bool _isSignedIn = false;

  bool get isSignedIn => _isSignedIn;

  Future<void> checkUserStatus() async {
    _isSignedIn = await isUserSignedIn();
    notifyListeners();
  }

  Future<bool> isUserSignedIn() async {
    User? currentUser = FirebaseAuth.instance.currentUser;
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? uid = prefs.getString('uidKey');
    String? email = prefs.getString('emailKey');
    _user = UserModel(
      uid: uid ?? currentUser?.uid ?? '',
      email: email,
    );
    dev.log('User signed in: ${currentUser != null}');
    dev.log('User UID: $uid');
    return currentUser != null && uid != null;
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
  String _generateNonce([int length = 32]) {
    const charset =
        '0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._';
    final random = Random.secure();
    return List.generate(length, (_) => charset[random.nextInt(charset.length)])
        .join();
  }

  /// Returns the sha256 hash of [input] in hex notation.
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
