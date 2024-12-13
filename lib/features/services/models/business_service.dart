import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

part 'business_service.freezed.dart';
part 'business_service.g.dart';

@freezed
class BusinessService with _$BusinessService {
  const BusinessService._();

  const factory BusinessService({
    required String id,
    required String name,
    required String nameHe,
    required int durationMinutes,
    required double price,
    required bool isActive,
    required String category,
    String? description,
    String? descriptionHe,
    List<BusinessServiceAddon>? addons,
    bool? isBasePrice,
    int? order,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) = _BusinessService;

  factory BusinessService.fromJson(Map<String, dynamic> json) =>
      _$BusinessServiceFromJson(json);

  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'nameHe': nameHe,
      'durationMinutes': durationMinutes,
      'price': price,
      'isActive': isActive,
      'category': category,
      'description': description,
      'descriptionHe': descriptionHe,
      'addons': addons?.map((addon) => addon.toFirestore()).toList(),
      'isBasePrice': isBasePrice,
      'order': order,
      'createdAt': createdAt != null ? Timestamp.fromDate(createdAt!) : FieldValue.serverTimestamp(),
      'updatedAt': Timestamp.fromDate(DateTime.now()),
    };
  }

  static BusinessService fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return BusinessService(
      id: doc.id,
      name: data['name'] as String,
      nameHe: data['nameHe'] as String,
      durationMinutes: data['durationMinutes'] as int,
      price: (data['price'] as num).toDouble(),
      isActive: data['isActive'] as bool,
      category: data['category'] as String? ?? 'other',
      description: data['description'] as String?,
      descriptionHe: data['descriptionHe'] as String?,
      addons: (data['addons'] as List<dynamic>?)?.map((e) => BusinessServiceAddon.fromFirestore(e)).toList(),
      isBasePrice: data['isBasePrice'] as bool?,
      order: data['order'] as int?,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate(),
    );
  }
}

@freezed
class BusinessServiceAddon with _$BusinessServiceAddon {
  const BusinessServiceAddon._();

  const factory BusinessServiceAddon({
    required String name,
    required String nameHe,
    required int durationMinutes,
    required double price,
    String? description,
    String? descriptionHe,
  }) = _BusinessServiceAddon;

  factory BusinessServiceAddon.fromJson(Map<String, dynamic> json) =>
      _$BusinessServiceAddonFromJson(json);

  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'nameHe': nameHe,
      'durationMinutes': durationMinutes,
      'price': price,
      'description': description,
      'descriptionHe': descriptionHe,
    };
  }

  static BusinessServiceAddon fromFirestore(Map<String, dynamic> data) {
    return BusinessServiceAddon(
      name: data['name'] as String,
      nameHe: data['nameHe'] as String,
      durationMinutes: data['durationMinutes'] as int,
      price: (data['price'] as num).toDouble(),
      description: data['description'] as String?,
      descriptionHe: data['descriptionHe'] as String?,
    );
  }
} 