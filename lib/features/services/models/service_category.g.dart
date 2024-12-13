// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'service_category.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$ServiceCategoryImpl _$$ServiceCategoryImplFromJson(
        Map<String, dynamic> json) =>
    _$ServiceCategoryImpl(
      id: json['id'] as String,
      name: json['name'] as String,
      nameHe: json['nameHe'] as String,
      order: (json['order'] as num).toInt(),
      parentId: json['parentId'] as String?,
      isActive: json['isActive'] as bool? ?? true,
      subCategoryIds: (json['subCategoryIds'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      addonIds: (json['addonIds'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      createdAt: json['createdAt'] == null
          ? null
          : DateTime.parse(json['createdAt'] as String),
      updatedAt: json['updatedAt'] == null
          ? null
          : DateTime.parse(json['updatedAt'] as String),
    );

Map<String, dynamic> _$$ServiceCategoryImplToJson(
        _$ServiceCategoryImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'nameHe': instance.nameHe,
      'order': instance.order,
      'parentId': instance.parentId,
      'isActive': instance.isActive,
      'subCategoryIds': instance.subCategoryIds,
      'addonIds': instance.addonIds,
      'createdAt': instance.createdAt?.toIso8601String(),
      'updatedAt': instance.updatedAt?.toIso8601String(),
    };
