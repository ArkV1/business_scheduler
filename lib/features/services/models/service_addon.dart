import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'service_addon.freezed.dart';
part 'service_addon.g.dart';

@freezed
class ServiceAddon with _$ServiceAddon {
  const ServiceAddon._();

  const factory ServiceAddon({
    required String id,
    required String name,
    required String nameHe,
    required double price,
    @Default(true) bool isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) = _ServiceAddon;

  factory ServiceAddon.fromJson(Map<String, dynamic> json) =>
      _$ServiceAddonFromJson(json);

  factory ServiceAddon.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return ServiceAddon(
      id: doc.id,
      name: data['name'] as String,
      nameHe: data['nameHe'] as String,
      price: (data['price'] as num).toDouble(),
      isActive: data['isActive'] as bool? ?? true,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'nameHe': nameHe,
      'price': price,
      'isActive': isActive,
      'createdAt': createdAt ?? FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    };
  }
} 