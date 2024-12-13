// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'service_category.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

ServiceCategory _$ServiceCategoryFromJson(Map<String, dynamic> json) {
  return _ServiceCategory.fromJson(json);
}

/// @nodoc
mixin _$ServiceCategory {
  String get id => throw _privateConstructorUsedError;
  String get name => throw _privateConstructorUsedError;
  String get nameHe => throw _privateConstructorUsedError;
  int get order => throw _privateConstructorUsedError;
  String? get parentId => throw _privateConstructorUsedError;
  bool get isActive => throw _privateConstructorUsedError;
  List<String> get subCategoryIds => throw _privateConstructorUsedError;
  List<String> get addonIds => throw _privateConstructorUsedError;
  DateTime? get createdAt => throw _privateConstructorUsedError;
  DateTime? get updatedAt => throw _privateConstructorUsedError;

  /// Serializes this ServiceCategory to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of ServiceCategory
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ServiceCategoryCopyWith<ServiceCategory> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ServiceCategoryCopyWith<$Res> {
  factory $ServiceCategoryCopyWith(
          ServiceCategory value, $Res Function(ServiceCategory) then) =
      _$ServiceCategoryCopyWithImpl<$Res, ServiceCategory>;
  @useResult
  $Res call(
      {String id,
      String name,
      String nameHe,
      int order,
      String? parentId,
      bool isActive,
      List<String> subCategoryIds,
      List<String> addonIds,
      DateTime? createdAt,
      DateTime? updatedAt});
}

/// @nodoc
class _$ServiceCategoryCopyWithImpl<$Res, $Val extends ServiceCategory>
    implements $ServiceCategoryCopyWith<$Res> {
  _$ServiceCategoryCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ServiceCategory
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? nameHe = null,
    Object? order = null,
    Object? parentId = freezed,
    Object? isActive = null,
    Object? subCategoryIds = null,
    Object? addonIds = null,
    Object? createdAt = freezed,
    Object? updatedAt = freezed,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      nameHe: null == nameHe
          ? _value.nameHe
          : nameHe // ignore: cast_nullable_to_non_nullable
              as String,
      order: null == order
          ? _value.order
          : order // ignore: cast_nullable_to_non_nullable
              as int,
      parentId: freezed == parentId
          ? _value.parentId
          : parentId // ignore: cast_nullable_to_non_nullable
              as String?,
      isActive: null == isActive
          ? _value.isActive
          : isActive // ignore: cast_nullable_to_non_nullable
              as bool,
      subCategoryIds: null == subCategoryIds
          ? _value.subCategoryIds
          : subCategoryIds // ignore: cast_nullable_to_non_nullable
              as List<String>,
      addonIds: null == addonIds
          ? _value.addonIds
          : addonIds // ignore: cast_nullable_to_non_nullable
              as List<String>,
      createdAt: freezed == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      updatedAt: freezed == updatedAt
          ? _value.updatedAt
          : updatedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$ServiceCategoryImplCopyWith<$Res>
    implements $ServiceCategoryCopyWith<$Res> {
  factory _$$ServiceCategoryImplCopyWith(_$ServiceCategoryImpl value,
          $Res Function(_$ServiceCategoryImpl) then) =
      __$$ServiceCategoryImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String name,
      String nameHe,
      int order,
      String? parentId,
      bool isActive,
      List<String> subCategoryIds,
      List<String> addonIds,
      DateTime? createdAt,
      DateTime? updatedAt});
}

/// @nodoc
class __$$ServiceCategoryImplCopyWithImpl<$Res>
    extends _$ServiceCategoryCopyWithImpl<$Res, _$ServiceCategoryImpl>
    implements _$$ServiceCategoryImplCopyWith<$Res> {
  __$$ServiceCategoryImplCopyWithImpl(
      _$ServiceCategoryImpl _value, $Res Function(_$ServiceCategoryImpl) _then)
      : super(_value, _then);

  /// Create a copy of ServiceCategory
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? nameHe = null,
    Object? order = null,
    Object? parentId = freezed,
    Object? isActive = null,
    Object? subCategoryIds = null,
    Object? addonIds = null,
    Object? createdAt = freezed,
    Object? updatedAt = freezed,
  }) {
    return _then(_$ServiceCategoryImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      nameHe: null == nameHe
          ? _value.nameHe
          : nameHe // ignore: cast_nullable_to_non_nullable
              as String,
      order: null == order
          ? _value.order
          : order // ignore: cast_nullable_to_non_nullable
              as int,
      parentId: freezed == parentId
          ? _value.parentId
          : parentId // ignore: cast_nullable_to_non_nullable
              as String?,
      isActive: null == isActive
          ? _value.isActive
          : isActive // ignore: cast_nullable_to_non_nullable
              as bool,
      subCategoryIds: null == subCategoryIds
          ? _value._subCategoryIds
          : subCategoryIds // ignore: cast_nullable_to_non_nullable
              as List<String>,
      addonIds: null == addonIds
          ? _value._addonIds
          : addonIds // ignore: cast_nullable_to_non_nullable
              as List<String>,
      createdAt: freezed == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      updatedAt: freezed == updatedAt
          ? _value.updatedAt
          : updatedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$ServiceCategoryImpl extends _ServiceCategory {
  const _$ServiceCategoryImpl(
      {required this.id,
      required this.name,
      required this.nameHe,
      required this.order,
      this.parentId,
      this.isActive = true,
      final List<String> subCategoryIds = const [],
      final List<String> addonIds = const [],
      this.createdAt,
      this.updatedAt})
      : _subCategoryIds = subCategoryIds,
        _addonIds = addonIds,
        super._();

  factory _$ServiceCategoryImpl.fromJson(Map<String, dynamic> json) =>
      _$$ServiceCategoryImplFromJson(json);

  @override
  final String id;
  @override
  final String name;
  @override
  final String nameHe;
  @override
  final int order;
  @override
  final String? parentId;
  @override
  @JsonKey()
  final bool isActive;
  final List<String> _subCategoryIds;
  @override
  @JsonKey()
  List<String> get subCategoryIds {
    if (_subCategoryIds is EqualUnmodifiableListView) return _subCategoryIds;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_subCategoryIds);
  }

  final List<String> _addonIds;
  @override
  @JsonKey()
  List<String> get addonIds {
    if (_addonIds is EqualUnmodifiableListView) return _addonIds;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_addonIds);
  }

  @override
  final DateTime? createdAt;
  @override
  final DateTime? updatedAt;

  @override
  String toString() {
    return 'ServiceCategory(id: $id, name: $name, nameHe: $nameHe, order: $order, parentId: $parentId, isActive: $isActive, subCategoryIds: $subCategoryIds, addonIds: $addonIds, createdAt: $createdAt, updatedAt: $updatedAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ServiceCategoryImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.nameHe, nameHe) || other.nameHe == nameHe) &&
            (identical(other.order, order) || other.order == order) &&
            (identical(other.parentId, parentId) ||
                other.parentId == parentId) &&
            (identical(other.isActive, isActive) ||
                other.isActive == isActive) &&
            const DeepCollectionEquality()
                .equals(other._subCategoryIds, _subCategoryIds) &&
            const DeepCollectionEquality().equals(other._addonIds, _addonIds) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.updatedAt, updatedAt) ||
                other.updatedAt == updatedAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      name,
      nameHe,
      order,
      parentId,
      isActive,
      const DeepCollectionEquality().hash(_subCategoryIds),
      const DeepCollectionEquality().hash(_addonIds),
      createdAt,
      updatedAt);

  /// Create a copy of ServiceCategory
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ServiceCategoryImplCopyWith<_$ServiceCategoryImpl> get copyWith =>
      __$$ServiceCategoryImplCopyWithImpl<_$ServiceCategoryImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$ServiceCategoryImplToJson(
      this,
    );
  }
}

abstract class _ServiceCategory extends ServiceCategory {
  const factory _ServiceCategory(
      {required final String id,
      required final String name,
      required final String nameHe,
      required final int order,
      final String? parentId,
      final bool isActive,
      final List<String> subCategoryIds,
      final List<String> addonIds,
      final DateTime? createdAt,
      final DateTime? updatedAt}) = _$ServiceCategoryImpl;
  const _ServiceCategory._() : super._();

  factory _ServiceCategory.fromJson(Map<String, dynamic> json) =
      _$ServiceCategoryImpl.fromJson;

  @override
  String get id;
  @override
  String get name;
  @override
  String get nameHe;
  @override
  int get order;
  @override
  String? get parentId;
  @override
  bool get isActive;
  @override
  List<String> get subCategoryIds;
  @override
  List<String> get addonIds;
  @override
  DateTime? get createdAt;
  @override
  DateTime? get updatedAt;

  /// Create a copy of ServiceCategory
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ServiceCategoryImplCopyWith<_$ServiceCategoryImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
