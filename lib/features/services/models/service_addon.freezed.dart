// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'service_addon.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

ServiceAddon _$ServiceAddonFromJson(Map<String, dynamic> json) {
  return _ServiceAddon.fromJson(json);
}

/// @nodoc
mixin _$ServiceAddon {
  String get id => throw _privateConstructorUsedError;
  String get name => throw _privateConstructorUsedError;
  String get nameHe => throw _privateConstructorUsedError;
  double get price => throw _privateConstructorUsedError;
  bool get isActive => throw _privateConstructorUsedError;
  DateTime? get createdAt => throw _privateConstructorUsedError;
  DateTime? get updatedAt => throw _privateConstructorUsedError;

  /// Serializes this ServiceAddon to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of ServiceAddon
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ServiceAddonCopyWith<ServiceAddon> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ServiceAddonCopyWith<$Res> {
  factory $ServiceAddonCopyWith(
          ServiceAddon value, $Res Function(ServiceAddon) then) =
      _$ServiceAddonCopyWithImpl<$Res, ServiceAddon>;
  @useResult
  $Res call(
      {String id,
      String name,
      String nameHe,
      double price,
      bool isActive,
      DateTime? createdAt,
      DateTime? updatedAt});
}

/// @nodoc
class _$ServiceAddonCopyWithImpl<$Res, $Val extends ServiceAddon>
    implements $ServiceAddonCopyWith<$Res> {
  _$ServiceAddonCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ServiceAddon
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? nameHe = null,
    Object? price = null,
    Object? isActive = null,
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
      price: null == price
          ? _value.price
          : price // ignore: cast_nullable_to_non_nullable
              as double,
      isActive: null == isActive
          ? _value.isActive
          : isActive // ignore: cast_nullable_to_non_nullable
              as bool,
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
abstract class _$$ServiceAddonImplCopyWith<$Res>
    implements $ServiceAddonCopyWith<$Res> {
  factory _$$ServiceAddonImplCopyWith(
          _$ServiceAddonImpl value, $Res Function(_$ServiceAddonImpl) then) =
      __$$ServiceAddonImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String name,
      String nameHe,
      double price,
      bool isActive,
      DateTime? createdAt,
      DateTime? updatedAt});
}

/// @nodoc
class __$$ServiceAddonImplCopyWithImpl<$Res>
    extends _$ServiceAddonCopyWithImpl<$Res, _$ServiceAddonImpl>
    implements _$$ServiceAddonImplCopyWith<$Res> {
  __$$ServiceAddonImplCopyWithImpl(
      _$ServiceAddonImpl _value, $Res Function(_$ServiceAddonImpl) _then)
      : super(_value, _then);

  /// Create a copy of ServiceAddon
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? nameHe = null,
    Object? price = null,
    Object? isActive = null,
    Object? createdAt = freezed,
    Object? updatedAt = freezed,
  }) {
    return _then(_$ServiceAddonImpl(
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
      price: null == price
          ? _value.price
          : price // ignore: cast_nullable_to_non_nullable
              as double,
      isActive: null == isActive
          ? _value.isActive
          : isActive // ignore: cast_nullable_to_non_nullable
              as bool,
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
class _$ServiceAddonImpl extends _ServiceAddon {
  const _$ServiceAddonImpl(
      {required this.id,
      required this.name,
      required this.nameHe,
      required this.price,
      this.isActive = true,
      this.createdAt,
      this.updatedAt})
      : super._();

  factory _$ServiceAddonImpl.fromJson(Map<String, dynamic> json) =>
      _$$ServiceAddonImplFromJson(json);

  @override
  final String id;
  @override
  final String name;
  @override
  final String nameHe;
  @override
  final double price;
  @override
  @JsonKey()
  final bool isActive;
  @override
  final DateTime? createdAt;
  @override
  final DateTime? updatedAt;

  @override
  String toString() {
    return 'ServiceAddon(id: $id, name: $name, nameHe: $nameHe, price: $price, isActive: $isActive, createdAt: $createdAt, updatedAt: $updatedAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ServiceAddonImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.nameHe, nameHe) || other.nameHe == nameHe) &&
            (identical(other.price, price) || other.price == price) &&
            (identical(other.isActive, isActive) ||
                other.isActive == isActive) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.updatedAt, updatedAt) ||
                other.updatedAt == updatedAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType, id, name, nameHe, price, isActive, createdAt, updatedAt);

  /// Create a copy of ServiceAddon
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ServiceAddonImplCopyWith<_$ServiceAddonImpl> get copyWith =>
      __$$ServiceAddonImplCopyWithImpl<_$ServiceAddonImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$ServiceAddonImplToJson(
      this,
    );
  }
}

abstract class _ServiceAddon extends ServiceAddon {
  const factory _ServiceAddon(
      {required final String id,
      required final String name,
      required final String nameHe,
      required final double price,
      final bool isActive,
      final DateTime? createdAt,
      final DateTime? updatedAt}) = _$ServiceAddonImpl;
  const _ServiceAddon._() : super._();

  factory _ServiceAddon.fromJson(Map<String, dynamic> json) =
      _$ServiceAddonImpl.fromJson;

  @override
  String get id;
  @override
  String get name;
  @override
  String get nameHe;
  @override
  double get price;
  @override
  bool get isActive;
  @override
  DateTime? get createdAt;
  @override
  DateTime? get updatedAt;

  /// Create a copy of ServiceAddon
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ServiceAddonImplCopyWith<_$ServiceAddonImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
