import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

class FirebaseErrorInfo {
  final bool isIndexError;
  final String? indexUrl;
  final String message;
  final String code;
  final StackTrace? stackTrace;

  FirebaseErrorInfo({
    required this.isIndexError,
    this.indexUrl,
    required this.message,
    required this.code,
    this.stackTrace,
  });

  factory FirebaseErrorInfo.fromError(Object error, [StackTrace? stackTrace]) {
    if (error is! FirebaseException) {
      return FirebaseErrorInfo(
        isIndexError: false,
        message: error.toString(),
        code: 'unknown',
        stackTrace: stackTrace,
      );
    }

    final isIndexError = error.code == 'failed-precondition' && 
                        error.message?.contains('index') == true;

    String? indexUrl;
    String message = error.message ?? '';

    if (isIndexError) {
      // Extract the URL if it exists
      final urlMatch = RegExp(r'https://console\.firebase\.google\.com[^\s]+')
          .firstMatch(message);
      if (urlMatch != null) {
        indexUrl = urlMatch.group(0);
      }

      // Clean up the message
      final urlIndex = message.indexOf('You can create it here:');
      if (urlIndex != -1) {
        message = message.substring(0, urlIndex).trim();
      } else {
        message = message.split('.').first.trim();
      }

      // Add line break before "requires a database index"
      message = message.replaceAll('requires a database index', '\nrequires a database index');
    }

    return FirebaseErrorInfo(
      isIndexError: isIndexError,
      indexUrl: indexUrl,
      message: message,
      code: error.code,
      stackTrace: stackTrace,
    );
  }
}

void handleFirebaseError(Object error, StackTrace stackTrace) {
  final errorInfo = FirebaseErrorInfo.fromError(error, stackTrace);

  if (errorInfo.isIndexError && errorInfo.indexUrl != null) {
    debugPrint('Firestore Index Required');
    debugPrint('Create the required index by visiting:');
    debugPrint(errorInfo.indexUrl);
  }
  
  debugPrint('Firebase Error: ${errorInfo.code}');
  debugPrint('Message: ${errorInfo.message}');
  if (errorInfo.stackTrace != null) {
    debugPrint('Stack Trace:');
    debugPrint(errorInfo.stackTrace.toString());
  }
} 