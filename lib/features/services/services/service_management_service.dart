import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/business_service.dart';
import '../../../core/utils/firebase_error_handler.dart';

final businessServiceManagementProvider = Provider<BusinessServiceManagementService>(
  (ref) => BusinessServiceManagementService()
);

class BusinessServiceManagementService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _collection = 'business_services';

  // Create a new business service
  Future<BusinessService> createBusinessService({
    required String name,
    required String nameHe,
    required int durationMinutes,
    required double price,
    required String category,
    bool? isBasePrice,
    List<BusinessServiceAddon>? addons,
    String? description,
    String? descriptionHe,
  }) async {
    final serviceData = BusinessService(
      id: '',
      name: name,
      nameHe: nameHe,
      durationMinutes: durationMinutes,
      price: price,
      category: category,
      isActive: true,
      isBasePrice: isBasePrice ?? false,
      addons: addons,
      description: description,
      descriptionHe: descriptionHe,
      createdAt: DateTime.now(),
    ).toFirestore();

    final docRef = await _firestore.collection(_collection).add(serviceData);
    final doc = await docRef.get();
    return BusinessService.fromFirestore(doc);
  }

  // Get all business services
  Stream<List<BusinessService>> getAllBusinessServices() {
    return _firestore
        .collection(_collection)
        .orderBy('category')
        .orderBy('order')
        .snapshots()
        .handleError((error, stackTrace) {
          if (error is FirebaseException && 
              error.code == 'failed-precondition' && 
              error.message?.contains('index') == true) {
            final message = error.message ?? '';
            final newMessage = message.replaceFirst(
              'The query requires an index.',
              'The All Services list (sorted by category and order) requires a database index.',
            );
            error = FirebaseException(
              plugin: error.plugin,
              code: error.code,
              message: newMessage,
            );
          }
          handleFirebaseError(error, stackTrace);
          throw error;
        })
        .map((snapshot) {
          if (snapshot.docs.isEmpty) {
            return const <BusinessService>[];
          }
          return snapshot.docs.map((doc) => BusinessService.fromFirestore(doc)).toList();
        });
  }

  // Get active business services only
  Stream<List<BusinessService>> getActiveBusinessServices() {
    try {
      return _firestore
          .collection(_collection)
          .where('isActive', isEqualTo: true)
          .orderBy('category')
          .orderBy('order')
          .snapshots()
          .handleError((error, stackTrace) {
            if (error is FirebaseException && 
                error.code == 'failed-precondition' && 
                error.message?.contains('index') == true) {
              // If index error, fall back to unordered query
              return _firestore
                  .collection(_collection)
                  .where('isActive', isEqualTo: true)
                  .snapshots();
            }
            handleFirebaseError(error, stackTrace);
            throw error;
          })
          .map((snapshot) {
            if (snapshot.docs.isEmpty) {
              return const <BusinessService>[];
            }
            final services = snapshot.docs
                .map((doc) => BusinessService.fromFirestore(doc))
                .toList();
            
            // If we're using the fallback query, sort in memory
            if (!snapshot.metadata.isFromCache) {
              services.sort((a, b) {
                final categoryCompare = a.category.compareTo(b.category);
                if (categoryCompare != 0) return categoryCompare;
                return (a.order ?? 0).compareTo(b.order ?? 0);
              });
            }
            return services;
          });
    } catch (e) {
      // If any error occurs, return empty stream
      return Stream.value([]);
    }
  }

  // Update business service
  Future<void> updateBusinessService(String serviceId, {
    String? name,
    String? nameHe,
    int? durationMinutes,
    double? price,
    String? category,
    bool? isActive,
    bool? isBasePrice,
    List<BusinessServiceAddon>? addons,
    String? description,
    String? descriptionHe,
    int? order,
  }) async {
    final updates = <String, dynamic>{
      if (name != null) 'name': name,
      if (nameHe != null) 'nameHe': nameHe,
      if (durationMinutes != null) 'durationMinutes': durationMinutes,
      if (price != null) 'price': price,
      if (category != null) 'category': category,
      if (isActive != null) 'isActive': isActive,
      if (isBasePrice != null) 'isBasePrice': isBasePrice,
      if (addons != null) 'addons': addons.map((addon) => addon.toFirestore()).toList(),
      if (description != null) 'description': description,
      if (descriptionHe != null) 'descriptionHe': descriptionHe,
      if (order != null) 'order': order,
      'updatedAt': FieldValue.serverTimestamp(),
    };

    await _firestore.collection(_collection).doc(serviceId).update(updates);
  }

  // Delete business service
  Future<void> deleteBusinessService(String serviceId) async {
    await _firestore.collection(_collection).doc(serviceId).delete();
  }

  // Toggle business service active status
  Future<void> toggleBusinessServiceStatus(String serviceId, bool isActive) async {
    await updateBusinessService(serviceId, isActive: isActive);
  }

  // Update service order
  Future<void> updateServiceOrder(String serviceId, int newOrder) async {
    await updateBusinessService(serviceId, order: newOrder);
  }
} 