import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/service_category.dart';
import '../models/service_addon.dart';
import '../../../core/utils/firebase_error_handler.dart';
import '../../../core/services/logger_service.dart';

final categoryManagementProvider = Provider<CategoryManagementService>((ref) {
  return CategoryManagementService();
});

class CategoryManagementService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _categoriesCollection = 'service_categories';
  final String _addonsCollection = 'service_addons';

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
  Stream<List<ServiceCategory>> getAllServiceCategories({String? parentId}) {
    try {
      Logger.firebase(
        'LISTEN',
        _categoriesCollection,
        data: {'parentId': parentId},
      );

      Query query = _firestore.collection(_categoriesCollection);
      
      // Remove the parentId filter for now to see all categories
      // if (parentId != null) {
      //   query = query.where('parentId', isEqualTo: parentId);
      // } else {
      //   query = query.where('parentId', isNull: true);
      // }

      // Try with ordering first
      return query
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
              // If index error, fall back to unordered query
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
            print('Got snapshot with ${snapshot.docs.length} documents');
            if (snapshot.docs.isEmpty) {
              print('No categories found in snapshot');
              return const <ServiceCategory>[];
            }

            try {
              final categories = snapshot.docs
                  .map((doc) {
                    // print('Processing doc ${doc.id}: ${doc.data()}');
                    return ServiceCategory.fromFirestore(doc);
                  })
                  .toList();
              
              // If we're using the fallback query, sort in memory
              if (!snapshot.metadata.isFromCache) {
                categories.sort((a, b) => (a.order).compareTo(b.order));
              }

              print('Returning ${categories.length} categories');
              return categories;
            } catch (e) {
              print('Error processing category documents: $e');
              rethrow;
            }
          });
    } catch (e) {
      print('Error in getAllServiceCategories: $e');
      // If any error occurs, return empty stream
      return Stream.value([]);
    }
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
    final categoryRef = _firestore.collection(_categoriesCollection).doc(id);
    final categoryDoc = await categoryRef.get();
    
    if (!categoryDoc.exists) return;
    
    final category = ServiceCategory.fromFirestore(categoryDoc);

    // If this is a subcategory, remove it from parent's list
    if (category.parentId != null) {
      await _firestore.collection(_categoriesCollection).doc(category.parentId).update({
        'subCategoryIds': FieldValue.arrayRemove([id])
      });
    }

    // Delete all subcategories recursively
    for (final subCategoryId in category.subCategoryIds) {
      await deleteServiceCategory(subCategoryId);
    }

    // Delete all associated addons
    for (final addonId in category.addonIds) {
      await _firestore.collection(_addonsCollection).doc(addonId).delete();
    }

    Logger.firebase(
      'DELETE',
      _categoriesCollection,
      docId: id,
    );

    await categoryRef.delete();
  }

  // Check and initialize default categories if none exist
  Future<void> _initializeDefaultCategoriesIfEmpty() async {
    final snapshot = await _firestore.collection(_categoriesCollection).limit(1).get();
    if (snapshot.docs.isNotEmpty) return;
    
    await initializeDefaultCategories();
  }

  // Initialize default categories
  Future<void> initializeDefaultCategories() async {
    try {
      print('\nInitializing default categories...');
      final defaultCategories = [
        {
          'name': 'Nails',
          'nameHe': 'ציפורניים',
          'order': 1,
        },
        {
          'name': 'Add-ons',
          'nameHe': 'תוספות',
          'order': 2,
        },
        {
          'name': 'Removal',
          'nameHe': 'הסרה',
          'order': 3,
        },
        {
          'name': 'Feet',
          'nameHe': 'רגליים',
          'order': 4,
        },
        {
          'name': 'Special Treatments',
          'nameHe': 'טיפולים מיוחדים',
          'order': 5,
        },
        {
          'name': 'Threading',
          'nameHe': 'מריטה בחוט',
          'order': 6,
        },
      ];

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
} 