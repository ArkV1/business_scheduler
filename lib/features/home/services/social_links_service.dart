import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:io';
import '../models/social_link.dart';
import '../../../core/utils/firebase_error_handler.dart';

class SocialLinksService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final String _collection = 'social_links';

  Stream<List<SocialLink>> getSocialLinks() {
    return _firestore
        .collection(_collection)
        .orderBy('order')
        .snapshots()
        .handleError((error, stackTrace) {
          final errorInfo = FirebaseErrorInfo.fromError(error, stackTrace);
          if (errorInfo.isIndexError) {
            // Propagate index errors so they can be shown in the UI
            throw error;
          }
          // For other errors, log and return empty list
          handleFirebaseError(error, stackTrace);
          return const Stream.empty();
        })
        .map((snapshot) => snapshot.docs
            .map((doc) => SocialLink.fromMap({...doc.data(), 'id': doc.id}))
            .toList());
  }

  Future<void> reorderSocialLinks(List<SocialLink> links) async {
    try {
      final batch = _firestore.batch();
      
      for (var i = 0; i < links.length; i++) {
        final link = links[i];
        if (link.order != i) {
          batch.update(
            _firestore.collection(_collection).doc(link.id),
            {'order': i},
          );
        }
      }
      
      await batch.commit();
    } catch (error, stackTrace) {
      final errorInfo = FirebaseErrorInfo.fromError(error, stackTrace);
      handleFirebaseError(error, stackTrace);
      throw Exception('Failed to reorder social links: ${errorInfo.message}');
    }
  }

  Future<String?> _uploadImage(String imagePath) async {
    if (imagePath.isEmpty) return null;
    
    try {
      final file = File(imagePath);
      final fileName = 'social_icons/${DateTime.now().millisecondsSinceEpoch}_${file.path.split('/').last}';
      final ref = _storage.ref().child(fileName);
      
      await ref.putFile(file);
      return await ref.getDownloadURL();
    } catch (error, stackTrace) {
      final errorInfo = FirebaseErrorInfo.fromError(error, stackTrace);
      handleFirebaseError(error, stackTrace);
      throw Exception('Failed to upload social link icon: ${errorInfo.message}');
    }
  }

  Future<void> addSocialLink({
    required String name,
    String? nameHe,
    String? iconPath,
    String? url,
    int? order,
    bool isHeader = false,
  }) async {
    try {
      String? uploadedIconPath;
      
      // Only upload icon if it's not a header and has an icon path
      if (!isHeader && iconPath != null && iconPath.isNotEmpty && !iconPath.startsWith('http')) {
        uploadedIconPath = await _uploadImage(iconPath);
      }

      final docRef = isHeader 
          ? _firestore.collection(_collection).doc('header')
          : _firestore.collection(_collection).doc();

      await docRef.set({
        'name': name,
        'nameHe': nameHe,
        'iconPath': !isHeader ? (uploadedIconPath ?? _getDefaultIconPath(name)) : null,
        'url': url,
        'isActive': true,
        'order': order ?? 0,
        'isHeader': isHeader,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (error, stackTrace) {
      final errorInfo = FirebaseErrorInfo.fromError(error, stackTrace);
      handleFirebaseError(error, stackTrace);
      throw Exception('Failed to add social link: ${errorInfo.message}');
    }
  }

  Future<void> updateSocialLink(SocialLink link) async {
    try {
      String? iconPath = link.iconPath;
      
      // Only upload icon if it's not a header and has a new icon path
      if (!link.isHeader && iconPath != null && iconPath.isNotEmpty && !iconPath.startsWith('http')) {
        final uploadedPath = await _uploadImage(iconPath);
        if (uploadedPath != null) {
          iconPath = uploadedPath;
        }
      }

      final docRef = link.isHeader
          ? _firestore.collection(_collection).doc('header')
          : _firestore.collection(_collection).doc(link.id);

      await docRef.set({
        'name': link.name,
        'nameHe': link.nameHe,
        'iconPath': !link.isHeader ? iconPath : null,
        'url': link.url,
        'isActive': link.isActive,
        'order': link.order,
        'isHeader': link.isHeader,
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    } catch (error, stackTrace) {
      final errorInfo = FirebaseErrorInfo.fromError(error, stackTrace);
      handleFirebaseError(error, stackTrace);
      throw Exception('Failed to update social link: ${errorInfo.message}');
    }
  }

  Future<void> deleteSocialLink(String id) async {
    try {
      // Get the social link data
      final doc = await _firestore.collection(_collection).doc(id).get();
      if (doc.exists) {
        final data = doc.data();
        final iconPath = data?['iconPath'] as String?;
        
        // If it's a Firebase Storage URL, delete the image
        if (iconPath != null && iconPath.contains('firebase') && iconPath.contains('social_icons')) {
          try {
            final ref = _storage.refFromURL(iconPath);
            await ref.delete();
          } catch (error, stackTrace) {
            // Log but don't fail if image deletion fails
            handleFirebaseError(error, stackTrace);
          }
        }
      }
      
      await _firestore.collection(_collection).doc(id).delete();
    } catch (error, stackTrace) {
      final errorInfo = FirebaseErrorInfo.fromError(error, stackTrace);
      handleFirebaseError(error, stackTrace);
      throw Exception('Failed to delete social link: ${errorInfo.message}');
    }
  }

  String _getDefaultIconPath(String platform) {
    switch (platform.toLowerCase()) {
      case 'facebook':
        return '';  // Using Material Icons instead of assets
      case 'instagram':
        return '';
      case 'whatsapp':
        return '';
      case 'phone':
        return '';
      case 'email':
        return '';
      case 'website':
        return '';
      default:
        return '';
    }
  }
} 