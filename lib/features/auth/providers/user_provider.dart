import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user.dart';

// Debug flag to override admin status
const _debugAlwaysAdmin = false;  // Set to false in production

final authProvider = Provider<AuthService>((ref) => AuthService());

final authStateChangesProvider = StreamProvider<firebase_auth.User?>((ref) {
  return firebase_auth.FirebaseAuth.instance.authStateChanges();
});

final userProvider = StreamProvider<User?>((ref) async* {
  final authStateChanges = ref.watch(authStateChangesProvider);
  
  await for (final value in authStateChanges.when(
    data: (firebaseUser) async* {
      if (firebaseUser == null) {
        yield null;
      } else {
        final user = await User.fromFirebaseUserWithData(firebaseUser);
        if (_debugAlwaysAdmin) {
          yield user.copyWith(isAdmin: true);
        } else {
          yield user;
        }
      }
    },
    loading: () async* {
      yield null;
    },
    error: (_, __) async* {
      yield null;
    },
  )) {
    yield value;
  }
});

final isAdminProvider = Provider<bool>((ref) {
  if (_debugAlwaysAdmin) return true;
  
  return ref.watch(userProvider).when(
    data: (user) => user?.isAdmin ?? false,
    loading: () => false,
    error: (_, __) => false,
  );
});

class AuthService {
  final firebase_auth.FirebaseAuth _auth = firebase_auth.FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Store verification ID between steps (preserved for phone auth)
  // String? _verificationId;
  // int? _resendToken;

  // Email Authentication Methods
  Future<User> signInWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      final userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      
      return User.fromFirebaseUserWithData(userCredential.user!);
    } catch (e) {
      throw _handleAuthException(e);
    }
  }

  Future<User> registerWithEmail({
    required String email,
    required String password,
    required String fullName,
  }) async {
    try {
      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      
      final firebaseUser = userCredential.user!;
      await firebaseUser.updateDisplayName(fullName);

      final user = User(
        id: firebaseUser.uid,
        email: email,
        fullName: fullName,
        createdAt: DateTime.now(),
      );

      await _firestore
          .collection('users')
          .doc(firebaseUser.uid)
          .set(user.toFirestore());

      return user;
    } catch (e) {
      throw _handleAuthException(e);
    }
  }

  // Phone Authentication Methods (preserved for future use)
  /*
  Future<void> startPhoneVerification({
    required String phoneNumber,
    required Function(String) onCodeSent,
    required Function(String) onError,
    required Function() onAutoVerified,
  }) async {
    try {
      await _auth.verifyPhoneNumber(
        phoneNumber: phoneNumber,
        verificationCompleted: (firebase_auth.PhoneAuthCredential credential) async {
          try {
            await _auth.signInWithCredential(credential);
            onAutoVerified();
          } catch (e) {
            onError(_handleAuthException(e));
          }
        },
        verificationFailed: (firebase_auth.FirebaseAuthException e) {
          onError(_handleAuthException(e));
        },
        codeSent: (String verificationId, int? resendToken) {
          _verificationId = verificationId;
          _resendToken = resendToken;
          onCodeSent(verificationId);
        },
        codeAutoRetrievalTimeout: (String verificationId) {
          _verificationId = verificationId;
        },
        forceResendingToken: _resendToken,
        timeout: const Duration(seconds: 60),
      );
    } catch (e) {
      onError(_handleAuthException(e));
    }
  }

  Future<User> verifyPhoneAndRegister({
    required String smsCode,
    required String email,
    required String fullName,
    required String phoneNumber,
  }) async {
    try {
      if (_verificationId == null) {
        throw 'Verification ID not found. Please restart phone verification.';
      }

      final credential = firebase_auth.PhoneAuthProvider.credential(
        verificationId: _verificationId!,
        smsCode: smsCode,
      );

      final userCredential = await _auth.signInWithCredential(credential);
      final firebaseUser = userCredential.user!;

      await firebaseUser.updateEmail(email);
      await firebaseUser.updateDisplayName(fullName);

      final user = User(
        id: firebaseUser.uid,
        email: email,
        fullName: fullName,
        phoneNumber: phoneNumber,
        createdAt: DateTime.now(),
      );

      await _firestore
          .collection('users')
          .doc(firebaseUser.uid)
          .set(user.toFirestore());

      return user;
    } catch (e) {
      throw _handleAuthException(e);
    }
  }

  Future<User> signInWithPhone({
    required String phoneNumber,
    required String smsCode,
  }) async {
    try {
      if (_verificationId == null) {
        throw 'Verification ID not found. Please restart phone verification.';
      }

      final credential = firebase_auth.PhoneAuthProvider.credential(
        verificationId: _verificationId!,
        smsCode: smsCode,
      );

      final userCredential = await _auth.signInWithCredential(credential);
      return User.fromFirebaseUserWithData(userCredential.user!);
    } catch (e) {
      throw _handleAuthException(e);
    }
  }
  */

  Future<void> signOut() async {
    await _auth.signOut();
  }

  Future<void> resetPassword(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } catch (e) {
      throw _handleAuthException(e);
    }
  }

  String _handleAuthException(dynamic e) {
    if (e is firebase_auth.FirebaseAuthException) {
      switch (e.code) {
        case 'weak-password':
          return 'The password provided is too weak.';
        case 'email-already-in-use':
          return 'An account already exists for that email.';
        case 'user-not-found':
          return 'No user found for that email.';
        case 'wrong-password':
          return 'Wrong password provided.';
        case 'invalid-verification-code':
          return 'The SMS code you entered is invalid.';
        case 'invalid-verification-id':
          return 'Invalid verification. Please try again.';
        case 'too-many-requests':
          return 'Too many attempts. Please try again later.';
        case 'invalid-phone-number':
          return 'The phone number format is incorrect.';
        case 'operation-not-allowed':
          return 'This authentication method is not enabled. Please contact support.';
        case 'captcha-check-failed':
          return 'reCAPTCHA verification failed. Please try again.';
        case 'quota-exceeded':
          return 'SMS quota exceeded. Please try again later.';
        default:
          return 'An error occurred. Please try again.';
      }
    }
    return e.toString();
  }
}