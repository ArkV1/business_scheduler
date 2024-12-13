import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:appointment_app/core/services/logger_service.dart';

part 'user.freezed.dart';
part 'user.g.dart';

@freezed
class User with _$User {
  const User._();

  const factory User({
    required String id,
    required String email,
    required String fullName,
    @Default(false) bool isAdmin,
    String? phoneNumber,
    String? photoURL,
    required DateTime createdAt,
  }) = _User;

  factory User.fromJson(Map<String, dynamic> json) => _$UserFromJson(json);

  factory User.fromFirebaseUser(firebase_auth.User firebaseUser) {
    return User(
      id: firebaseUser.uid,
      email: firebaseUser.email ?? '',
      fullName: firebaseUser.displayName ?? '',
      photoURL: firebaseUser.photoURL,
      createdAt: DateTime.now(),
    );
  }

  static Future<User> fromFirebaseUserWithData(firebase_auth.User firebaseUser) async {
    Logger.firebase(
      'GET',
      'users',
      docId: firebaseUser.uid,
    );

    final userData = await FirebaseFirestore.instance
        .collection('users')
        .doc(firebaseUser.uid)
        .get();

    if (!userData.exists) {
      Logger.firebase(
        'INFO',
        'users',
        data: {'message': 'User document not found, creating from Firebase user'},
      );
      return User.fromFirebaseUser(firebaseUser);
    }

    final data = userData.data()!;
    Logger.firebase(
      'RECEIVED',
      'users',
      docId: firebaseUser.uid,
      data: {'fromCache': userData.metadata.isFromCache},
    );

    return User(
      id: firebaseUser.uid,
      email: firebaseUser.email ?? '',
      fullName: data['fullName'] ?? firebaseUser.displayName ?? '',
      isAdmin: data['isAdmin'] ?? false,
      phoneNumber: data['phoneNumber'],
      photoURL: firebaseUser.photoURL,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toFirestore() {
    final data = {
      'email': email,
      'fullName': fullName,
      'phoneNumber': phoneNumber,
      'photoURL': photoURL,
      'createdAt': Timestamp.fromDate(createdAt),
    };

    Logger.firebase(
      'WRITE',
      'users',
      data: data,
    );

    return data;
  }
}