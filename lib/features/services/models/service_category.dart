import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:business_scheduler/core/services/logger_service.dart';

part 'service_category.freezed.dart';
part 'service_category.g.dart';

@freezed
class ServiceCategory with _$ServiceCategory {
  const ServiceCategory._();

  const factory ServiceCategory({
    required String id,
    required String name,
    required String nameHe,
    required int order,
    String? parentId,
    @Default(true) bool isActive,
    @Default([]) List<String> subCategoryIds,
    @Default([]) List<String> addonIds,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) = _ServiceCategory;

  factory ServiceCategory.fromJson(Map<String, dynamic> json) =>
      _$ServiceCategoryFromJson(json);

  factory ServiceCategory.fromFirestore(DocumentSnapshot doc) {
    try {
      Logger.log(
        'Converting document to ServiceCategory',
        category: LogCategory.other,
        operation: 'PARSE',
        data: {'docId': doc.id},
      );
      
      final data = doc.data() as Map<String, dynamic>;
      
      return ServiceCategory(
        id: doc.id,
        name: data['name'] as String,
        nameHe: data['nameHe'] as String,
        order: (data['order'] as num).toInt(),
        parentId: data['parentId'] as String?,
        isActive: data['isActive'] as bool? ?? true,
        subCategoryIds: (data['subCategoryIds'] as List<dynamic>?)?.map((e) => e as String).toList() ?? [],
        addonIds: (data['addonIds'] as List<dynamic>?)?.map((e) => e as String).toList() ?? [],
        createdAt: (data['createdAt'] as Timestamp?)?.toDate(),
        updatedAt: (data['updatedAt'] as Timestamp?)?.toDate(),
      );
    } catch (e, stackTrace) {
      Logger.log(
        'Error converting document to ServiceCategory',
        category: LogCategory.other,
        operation: 'PARSE_ERROR',
        level: LogLevel.error,
        data: {
          'docId': doc.id,
          'error': e.toString(),
          'stackTrace': stackTrace.toString(),
          'documentData': doc.data(),
        },
        forceLog: true,
      );
      rethrow;
    }
  }

  Map<String, dynamic> toFirestore() {
    final data = {
      'name': name,
      'nameHe': nameHe,
      'order': order,
      'parentId': parentId,
      'isActive': isActive,
      'subCategoryIds': subCategoryIds,
      'addonIds': addonIds,
      'createdAt': createdAt ?? FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    };

    Logger.log(
      'Serializing ServiceCategory to Firestore data',
      category: LogCategory.other,
      operation: 'SERIALIZE',
      data: {'id': id},
    );

    return data;
  }

  bool get isSubcategory => parentId != null;
} 