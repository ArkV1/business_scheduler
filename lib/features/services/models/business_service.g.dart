// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'business_service.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$BusinessServiceImpl _$$BusinessServiceImplFromJson(
        Map<String, dynamic> json) =>
    _$BusinessServiceImpl(
      id: json['id'] as String,
      name: json['name'] as String,
      nameHe: json['nameHe'] as String,
      durationMinutes: (json['durationMinutes'] as num).toInt(),
      price: (json['price'] as num).toDouble(),
      isActive: json['isActive'] as bool,
      category: json['category'] as String,
      description: json['description'] as String?,
      descriptionHe: json['descriptionHe'] as String?,
      addons: (json['addons'] as List<dynamic>?)
          ?.map((e) => BusinessServiceAddon.fromJson(e as Map<String, dynamic>))
          .toList(),
      isBasePrice: json['isBasePrice'] as bool?,
      order: (json['order'] as num?)?.toInt(),
      createdAt: json['createdAt'] == null
          ? null
          : DateTime.parse(json['createdAt'] as String),
      updatedAt: json['updatedAt'] == null
          ? null
          : DateTime.parse(json['updatedAt'] as String),
    );

Map<String, dynamic> _$$BusinessServiceImplToJson(
        _$BusinessServiceImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'nameHe': instance.nameHe,
      'durationMinutes': instance.durationMinutes,
      'price': instance.price,
      'isActive': instance.isActive,
      'category': instance.category,
      'description': instance.description,
      'descriptionHe': instance.descriptionHe,
      'addons': instance.addons,
      'isBasePrice': instance.isBasePrice,
      'order': instance.order,
      'createdAt': instance.createdAt?.toIso8601String(),
      'updatedAt': instance.updatedAt?.toIso8601String(),
    };

_$BusinessServiceAddonImpl _$$BusinessServiceAddonImplFromJson(
        Map<String, dynamic> json) =>
    _$BusinessServiceAddonImpl(
      name: json['name'] as String,
      nameHe: json['nameHe'] as String,
      durationMinutes: (json['durationMinutes'] as num).toInt(),
      price: (json['price'] as num).toDouble(),
      description: json['description'] as String?,
      descriptionHe: json['descriptionHe'] as String?,
    );

Map<String, dynamic> _$$BusinessServiceAddonImplToJson(
        _$BusinessServiceAddonImpl instance) =>
    <String, dynamic>{
      'name': instance.name,
      'nameHe': instance.nameHe,
      'durationMinutes': instance.durationMinutes,
      'price': instance.price,
      'description': instance.description,
      'descriptionHe': instance.descriptionHe,
    };
