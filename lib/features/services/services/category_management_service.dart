import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/service_category.dart';
import '../models/service_addon.dart';
import '../../../core/utils/firebase_error_handler.dart';
import '../../../core/services/logger_service.dart';
import 'dart:async';
import '../services/default_services.dart';

final categoryManagementProvider = Provider<CategoryManagementService>((ref) {
  return CategoryManagementService();
});

class CategoryManagementService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _categoriesCollection = 'service_categories';
  final String _addonsCollection = 'service_addons';
  Stream<List<ServiceCategory>>? _categoriesStream;

  // Create a new service category
  Future<ServiceCategory> createServiceCategory({
    required String name,
    required String nameHe,
    required int order,
    String? parentId,
  }) async {
    final categoryData = ServiceCategory(
      id: '',
      name: name,
      nameHe: nameHe,
      order: order,
      parentId: parentId,
    ).toFirestore();

    Logger.firebase(
      'CREATE',
      _categoriesCollection,
      data: {
        'name': name,
        'nameHe': nameHe,
        'order': order,
        'parentId': parentId,
      },
    );

    final docRef = await _firestore.collection(_categoriesCollection).add(categoryData);
    
    // If this is a subcategory, update the parent's subcategory list
    if (parentId != null) {
      await _firestore.collection(_categoriesCollection).doc(parentId).update({
        'subCategoryIds': FieldValue.arrayUnion([docRef.id])
      });
    }

    final doc = await docRef.get();
    return ServiceCategory.fromFirestore(doc);
  }

  // Get all service categories
  @Deprecated('Use watchServiceCategories() instead')
  Stream<List<ServiceCategory>> getAllServiceCategories({String? parentId}) {
    return watchServiceCategories(parentId: parentId);
  }

  // Get subcategories for a category
  Stream<List<ServiceCategory>> getSubcategories(String categoryId) {
    return getAllServiceCategories(parentId: categoryId);
  }

  // Check if any categories exist
  Future<bool> hasCategories() async {
    try {
      print('\nChecking if categories exist...');
      final snapshot = await _firestore.collection(_categoriesCollection).limit(1).get();
      final result = snapshot.docs.isNotEmpty;
      print('Categories exist: $result');
      return result;
    } catch (e) {
      print('Error in hasCategories: $e');
      return false;
    }
  }

  // Update a service category
  Future<void> updateServiceCategory(
    String id, {
    String? name,
    String? nameHe,
    int? order,
    bool? isActive,
    String? parentId,
  }) async {
    final updates = <String, dynamic>{
      if (name != null) 'name': name,
      if (nameHe != null) 'nameHe': nameHe,
      if (order != null) 'order': order,
      if (isActive != null) 'isActive': isActive,
      if (parentId != null) 'parentId': parentId,
      'updatedAt': FieldValue.serverTimestamp(),
    };

    if (updates.isEmpty) return;

    Logger.firebase(
      'UPDATE',
      _categoriesCollection,
      docId: id,
      data: updates,
    );

    final categoryRef = _firestore.collection(_categoriesCollection).doc(id);
    final categoryDoc = await categoryRef.get();
    
    if (!categoryDoc.exists) return;
    
    final currentCategory = ServiceCategory.fromFirestore(categoryDoc);

    // If parent ID is changing, update both old and new parent's subcategory lists
    if (parentId != null && currentCategory.parentId != parentId) {
      // Remove from old parent if exists
      if (currentCategory.parentId != null) {
        await _firestore.collection(_categoriesCollection).doc(currentCategory.parentId).update({
          'subCategoryIds': FieldValue.arrayRemove([id])
        });
      }
      // Add to new parent
      await _firestore.collection(_categoriesCollection).doc(parentId).update({
        'subCategoryIds': FieldValue.arrayUnion([id])
      });
    }

    await categoryRef.update(updates);
  }

  // Delete a service category
  Future<void> deleteServiceCategory(String id) async {
    try {
      final categoryRef = _firestore.collection(_categoriesCollection).doc(id);
      final categoryDoc = await categoryRef.get();
      
      if (!categoryDoc.exists) {
        print('Category $id does not exist');
        return;
      }
      
      final category = ServiceCategory.fromFirestore(categoryDoc);
      
      print('Deleting category: ${category.name} (ID: $id)');
      
      // First handle subcategories
      if (category.subCategoryIds.isNotEmpty) {
        print('Deleting ${category.subCategoryIds.length} subcategories');
        for (final subCategoryId in category.subCategoryIds) {
          await deleteServiceCategory(subCategoryId);
        }
      }

      // Then handle parent reference
      if (category.parentId != null) {
        print('Updating parent category ${category.parentId}');
        await _firestore.collection(_categoriesCollection)
            .doc(category.parentId)
            .update({
          'subCategoryIds': FieldValue.arrayRemove([id])
        });
      }

      // Handle addons
      if (category.addonIds.isNotEmpty) {
        print('Deleting ${category.addonIds.length} addons');
        for (final addonId in category.addonIds) {
          await _firestore.collection(_addonsCollection)
              .doc(addonId)
              .delete();
        }
      }

      // Finally delete the category itself
      print('Deleting the category document');
      await categoryRef.delete();

      print('Category deletion completed successfully');
    } catch (e, stackTrace) {
      print('Error deleting category: $e');
      print('Stack trace: $stackTrace');
      rethrow;
    }
  }

  // Initialize default categories
  Future<void> initializeDefaultCategories() async {
    try {
      print('\nInitializing default categories...');
      
      final defaultCategories = DefaultServices.defaultCategories;
      final batch = _firestore.batch();
      
      for (final category in defaultCategories) {
        final docRef = _firestore.collection(_categoriesCollection).doc();
        print('Creating category ${category['name']} with ID: ${docRef.id}');
        batch.set(docRef, {
          ...category,
          'isActive': true,
          'subCategoryIds': [],
          'addonIds': [],
          'createdAt': FieldValue.serverTimestamp(),
          'updatedAt': FieldValue.serverTimestamp(),
        });
      }

      await batch.commit();
      print('Default categories initialized successfully');
    } catch (e) {
      print('Error initializing default categories: $e');
      rethrow;
    }
  }

  // Addon Management Methods
  Future<ServiceAddon> createAddon({
    required String name,
    required String nameHe,
    required double price,
    required String categoryId,
  }) async {
    final addonData = ServiceAddon(
      id: '',
      name: name,
      nameHe: nameHe,
      price: price,
    ).toFirestore();

    Logger.firebase(
      'CREATE',
      _addonsCollection,
      data: {
        'name': name,
        'nameHe': nameHe,
        'price': price,
        'categoryId': categoryId,
      },
    );

    final docRef = await _firestore.collection(_addonsCollection).add(addonData);
    
    // Add addon to category
    await _firestore.collection(_categoriesCollection).doc(categoryId).update({
      'addonIds': FieldValue.arrayUnion([docRef.id])
    });

    final doc = await docRef.get();
    return ServiceAddon.fromFirestore(doc);
  }

  Future<void> updateAddon(
    String id, {
    String? name,
    String? nameHe,
    double? price,
    bool? isActive,
  }) async {
    final updates = <String, dynamic>{
      if (name != null) 'name': name,
      if (nameHe != null) 'nameHe': nameHe,
      if (price != null) 'price': price,
      if (isActive != null) 'isActive': isActive,
      'updatedAt': FieldValue.serverTimestamp(),
    };

    if (updates.isEmpty) return;

    Logger.firebase(
      'UPDATE',
      _addonsCollection,
      docId: id,
      data: updates,
    );

    await _firestore.collection(_addonsCollection).doc(id).update(updates);
  }

  Future<void> deleteAddon(String id, String categoryId) async {
    await _firestore.collection(_categoriesCollection).doc(categoryId).update({
      'addonIds': FieldValue.arrayRemove([id])
    });
    await _firestore.collection(_addonsCollection).doc(id).delete();

    Logger.firebase(
      'DELETE',
      _addonsCollection,
      docId: id,
      data: {'categoryId': categoryId},
    );
  }

  Stream<List<ServiceAddon>> getCategoryAddons(String categoryId) {
    return _firestore
        .collection(_addonsCollection)
        .where('categoryId', isEqualTo: categoryId)
        .orderBy('order')
        .snapshots()
        .handleError((error, stackTrace) {
          handleFirebaseError(error, stackTrace);
          throw error; // Propagate the error instead of returning empty list
        })
        .map((snapshot) => snapshot.docs
            .map((doc) => ServiceAddon.fromFirestore(doc))
            .toList());
  }

  Stream<List<ServiceCategory>> watchServiceCategories({String? parentId}) {
    if (_categoriesStream != null) {
      return _categoriesStream!;
    }

    Query query = _firestore.collection(_categoriesCollection);
    
    _categoriesStream = query
        .orderBy('order')
        .snapshots()
        .handleError((error, stackTrace) {
          Logger.firebase(
            'ERROR',
            _categoriesCollection,
            data: {'error': error.toString()},
            level: LogLevel.error,
            forceLog: true,
          );
          if (error is FirebaseException && 
              error.code == 'failed-precondition' && 
              error.message?.contains('index') == true) {
            print('Index error detected, falling back to unordered query');
            return query.snapshots();
          }
          handleFirebaseError(error, stackTrace);
          throw error;
        })
        .map((snapshot) {
          Logger.firebase(
            'RECEIVED',
            _categoriesCollection,
            data: {
              'count': snapshot.docs.length,
              'fromCache': snapshot.metadata.isFromCache,
            },
          );

          final categories = snapshot.docs
              .map((doc) => ServiceCategory.fromFirestore(doc))
              .toList();
          
          if (!snapshot.metadata.isFromCache) {
            categories.sort((a, b) => (a.order).compareTo(b.order));
          }

          return categories;
        })
        .asBroadcastStream();

    return _categoriesStream!;
  }
} 