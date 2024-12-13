import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/social_link.dart';

class SocialLinksRepository {
  final FirebaseFirestore _firestore;
  final String _collection = 'social_links';

  SocialLinksRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  Stream<List<SocialLink>> getSocialLinks() {
    return _firestore
        .collection(_collection)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => SocialLink.fromMap({...doc.data(), 'id': doc.id}))
            .toList());
  }

  Future<void> addSocialLink(SocialLink socialLink) async {
    await _firestore.collection(_collection).add(socialLink.toMap());
  }

  Future<void> updateSocialLink(SocialLink socialLink) async {
    await _firestore
        .collection(_collection)
        .doc(socialLink.id)
        .update(socialLink.toMap());
  }

  Future<void> deleteSocialLink(String id) async {
    await _firestore.collection(_collection).doc(id).delete();
  }

  Future<void> toggleSocialLinkStatus(String id, bool isActive) async {
    await _firestore
        .collection(_collection)
        .doc(id)
        .update({'isActive': isActive});
  }
} 