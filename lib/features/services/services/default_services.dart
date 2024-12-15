import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:appointment_app/features/services/services/service_management_service.dart';
import '../models/service_category.dart';
import '../services/category_management_service.dart';

class DefaultServices {
  // Define required categories with their default configurations
  static const List<Map<String, dynamic>> defaultCategories = [
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

  // Convert the list to a map for easier lookup
  static final Map<String, Map<String, dynamic>> requiredCategories = {
    for (var category in defaultCategories)
      category['name'] as String: {
        'nameHe': category['nameHe'],
        'order': category['order'],
      }
  };

  static List<Map<String, dynamic>> get defaultServices => [
    // Nails Category
    {
      'name': 'Gel Manicure with Anatomical Structure',
      'nameHe': 'לק ג׳ל עם מבנה אנטומי',
      'durationMinutes': 90,
      'price': 120.0,
      'categoryName': 'Nails',
      'isBasePrice': false,
      'order': 1,
    },
    {
      'name': 'Gel Construction',
      'nameHe': 'בנייה בג׳ל',
      'durationMinutes': 150,
      'price': 300.0,
      'categoryName': 'Nails',
      'order': 2,
    },
    
    // Add-ons Category
    {
      'name': 'Simple Decorations',
      'nameHe': 'קישוטים קלים',
      'durationMinutes': 20,
      'price': 10.0,
      'categoryName': 'Add-ons',
      'description': 'French tips, stars, hearts',
      'descriptionHe': 'פרנץ כפול, כוכבים, לבבות',
      'order': 1,
    },
    {
      'name': 'Complex Decorations',
      'nameHe': 'קישוטים מורכבים',
      'durationMinutes': 45,
      'price': 50.0,
      'categoryName': 'Add-ons',
      'isBasePrice': true,
      'order': 2,
    },
    {
      'name': 'Single Nail Fix',
      'nameHe': 'השלמת ציפורן',
      'durationMinutes': 20,
      'price': 10.0,
      'categoryName': 'Add-ons',
      'order': 3,
    },

    // Removal Category
    {
      'name': 'Gel Polish Removal',
      'nameHe': 'הסרת לק ג׳ל',
      'durationMinutes': 30,
      'price': 50.0,
      'categoryName': 'Removal',
      'order': 1,
    },
    {
      'name': 'Construction Removal',
      'nameHe': 'הסרת בנייה',
      'durationMinutes': 50,
      'price': 70.0,
      'categoryName': 'Removal',
      'order': 2,
    },

    // Feet Category
    {
      'name': 'Gel Pedicure',
      'nameHe': 'לק ג׳ל ברגליים',
      'durationMinutes': 60,
      'price': 100.0,
      'categoryName': 'Feet',
      'order': 1,
    },

    // Special Treatments Category
    {
      'name': 'Nail Lifting Treatment',
      'nameHe': 'הרמת ציפורניים',
      'durationMinutes': 40,
      'price': 80.0,
      'categoryName': 'Special Treatments',
      'description': 'For lifted nails',
      'descriptionHe': 'לציפורניים נישריות',
      'order': 1,
    },

    // Threading Category
    {
      'name': 'Eyebrows and Upper Lip Threading',
      'nameHe': 'ניקוי גבות ושפם עם חוט',
      'durationMinutes': 40,
      'price': 80.0,
      'categoryName': 'Threading',
      'order': 1,
    },
  ];

  /// Ensures all required categories exist and are properly configured
  static Future<List<ServiceCategory>> ensureRequiredCategories(
    CategoryManagementService categoryService,
    List<ServiceCategory> existingCategories,
  ) async {
    print('Starting category initialization...');
    print('Existing categories: ${existingCategories.map((c) => '${c.name} (${c.id})').join(', ')}');

    final batch = FirebaseFirestore.instance.batch();
    final categoriesCollection = FirebaseFirestore.instance.collection('service_categories');
    final createdDocs = <DocumentReference>[];
    final missingCategories = <String>[];

    // Check each required category
    for (final entry in requiredCategories.entries) {
      final categoryName = entry.key;
      final defaultConfig = entry.value;
      
      // Find existing category (case-insensitive)
      final existingCategory = existingCategories
          .where((cat) => cat.name.toLowerCase() == categoryName.toLowerCase())
          .firstOrNull;

      print('Checking category "$categoryName": ${existingCategory != null ? 'exists' : 'missing'}');

      if (existingCategory == null) {
        // Category doesn't exist, create it
        missingCategories.add(categoryName);
        final docRef = categoriesCollection.doc();
        createdDocs.add(docRef);
        print('Creating new category "$categoryName" with ID: ${docRef.id}');
        batch.set(docRef, {
          'name': categoryName, // Use exact case from requiredCategories
          'nameHe': defaultConfig['nameHe'],
          'order': defaultConfig['order'],
          'isActive': true,
          'subCategoryIds': [],
          'addonIds': [],
          'createdAt': FieldValue.serverTimestamp(),
          'updatedAt': FieldValue.serverTimestamp(),
        });
      } else {
        // Category exists, ensure it has the correct configuration
        final updates = <String, dynamic>{};
        
        if (existingCategory.name != categoryName) { // Ensure exact case match
          updates['name'] = categoryName;
        }
        if (existingCategory.nameHe != defaultConfig['nameHe']) {
          updates['nameHe'] = defaultConfig['nameHe'];
        }
        if (existingCategory.order != defaultConfig['order']) {
          updates['order'] = defaultConfig['order'];
        }
        if (!existingCategory.isActive) {
          updates['isActive'] = true;
        }
        
        if (updates.isNotEmpty) {
          print('Updating category "${existingCategory.name}" (${existingCategory.id}) with: $updates');
          updates['updatedAt'] = FieldValue.serverTimestamp();
          batch.update(categoriesCollection.doc(existingCategory.id), updates);
        }
      }
    }

    // Apply all changes in a batch
    if (missingCategories.isNotEmpty) {
      print('Creating missing categories: ${missingCategories.join(', ')}');
    }
    await batch.commit();

    // If we created new categories, wait for them and get their data
    if (createdDocs.isNotEmpty) {
      print('Waiting for created categories to be available...');
      final futures = createdDocs.map((doc) => doc.get());
      final snapshots = await Future.wait(futures);
      
      // Convert snapshots to categories
      final newCategories = snapshots
          .where((snap) => snap.exists)
          .map((snap) => ServiceCategory.fromFirestore(snap))
          .toList();
      
      print('Created categories: ${newCategories.map((c) => '${c.name} (${c.id})').join(', ')}');
      
      // Combine with existing categories
      final allCategories = [...existingCategories, ...newCategories];
      print('All categories: ${allCategories.map((c) => '${c.name} (${c.id})').join(', ')}');
      return allCategories;
    }

    // If no new categories were created, return existing ones
    return existingCategories;
  }

  static Future<void> initializeDefaultServices(
    BusinessServiceManagementService service,
    List<ServiceCategory> categories,
    CategoryManagementService categoryService,
  ) async {
    print('\nStarting service initialization...');
    print('Initial categories: ${categories.map((c) => '${c.name} (${c.id})').join(', ')}');

    // First ensure all required categories exist and are properly configured
    categories = await ensureRequiredCategories(categoryService, categories);
    print('\nAfter ensuring categories: ${categories.map((c) => '${c.name} (${c.id})').join(', ')}');

    // Create a case-insensitive map of category names to their IDs
    final categoryMap = {
      for (var category in categories) 
        category.name.toLowerCase(): category.id
    };
    print('\nCategory map: ${categoryMap.entries.map((e) => '${e.key}: ${e.value}').join(', ')}');

    // Get all existing services without ordering (to avoid index requirement)
    final servicesCollection = FirebaseFirestore.instance.collection('business_services');
    final existingServicesSnapshot = await servicesCollection.get();
    
    // Delete all existing services using a batch
    final deleteBatch = FirebaseFirestore.instance.batch();
    for (final doc in existingServicesSnapshot.docs) {
      deleteBatch.delete(doc.reference);
    }
    print('\nDeleting ${existingServicesSnapshot.docs.length} existing services...');
    await deleteBatch.commit();

    // Add all default services using batches of 500 (Firestore limit)
    final createBatch = FirebaseFirestore.instance.batch();
    var batchCount = 0;
    print('\nCreating new services...');

    for (final serviceData in defaultServices) {
      final categoryName = serviceData['categoryName'] as String;
      final categoryId = categoryMap[categoryName.toLowerCase()];
      
      print('Processing service "${serviceData['name']}" for category "$categoryName"');
      if (categoryId == null) {
        print('\nERROR: Category lookup failed!');
        print('Looking for: ${categoryName.toLowerCase()}');
        print('Available in map: ${categoryMap.keys.join(', ')}');
        throw Exception('Category "$categoryName" not found even after initialization. Available categories: ${categories.map((c) => c.name).join(', ')}');
      }

      final docRef = servicesCollection.doc();
      createBatch.set(docRef, {
        'name': serviceData['name'],
        'nameHe': serviceData['nameHe'],
        'durationMinutes': serviceData['durationMinutes'],
        'price': serviceData['price'],
        'category': categoryId,
        'isBasePrice': serviceData['isBasePrice'] ?? false,
        'description': serviceData['description'],
        'descriptionHe': serviceData['descriptionHe'],
        'order': serviceData['order'],
        'isActive': true,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });

      batchCount++;
      if (batchCount == 500) {
        print('Committing batch of 500 services...');
        await createBatch.commit();
        batchCount = 0;
      }
    }

    // Commit any remaining operations
    if (batchCount > 0) {
      print('Committing final batch of $batchCount services...');
      await createBatch.commit();
    }
    print('\nService initialization complete!');
  }
} 