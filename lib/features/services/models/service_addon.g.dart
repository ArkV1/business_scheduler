// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'service_addon.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$ServiceAddonImpl _$$ServiceAddonImplFromJson(Map<String, dynamic> json) =>
    _$ServiceAddonImpl(
      id: json['id'] as String,
      name: json['name'] as String,
      nameHe: json['nameHe'] as String,
      price: (json['price'] as num).toDouble(),
      isActive: json['isActive'] as bool? ?? true,
      createdAt: json['createdAt'] == null
          ? null
          : DateTime.parse(json['createdAt'] as String),
      updatedAt: json['updatedAt'] == null
          ? null
          : DateTime.parse(json['updatedAt'] as String),
    );

Map<String, dynamic> _$$ServiceAddonImplToJson(_$ServiceAddonImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'nameHe': instance.nameHe,
      'price': instance.price,
      'isActive': instance.isActive,
      'createdAt': instance.createdAt?.toIso8601String(),
      'updatedAt': instance.updatedAt?.toIso8601String(),
    };
