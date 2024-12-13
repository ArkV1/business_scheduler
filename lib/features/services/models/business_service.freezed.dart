// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'business_service.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

BusinessService _$BusinessServiceFromJson(Map<String, dynamic> json) {
  return _BusinessService.fromJson(json);
}

/// @nodoc
mixin _$BusinessService {
  String get id => throw _privateConstructorUsedError;
  String get name => throw _privateConstructorUsedError;
  String get nameHe => throw _privateConstructorUsedError;
  int get durationMinutes => throw _privateConstructorUsedError;
  double get price => throw _privateConstructorUsedError;
  bool get isActive => throw _privateConstructorUsedError;
  String get category => throw _privateConstructorUsedError;
  String? get description => throw _privateConstructorUsedError;
  String? get descriptionHe => throw _privateConstructorUsedError;
  List<BusinessServiceAddon>? get addons => throw _privateConstructorUsedError;
  bool? get isBasePrice => throw _privateConstructorUsedError;
  int? get order => throw _privateConstructorUsedError;
  DateTime? get createdAt => throw _privateConstructorUsedError;
  DateTime? get updatedAt => throw _privateConstructorUsedError;

  /// Serializes this BusinessService to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of BusinessService
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $BusinessServiceCopyWith<BusinessService> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $BusinessServiceCopyWith<$Res> {
  factory $BusinessServiceCopyWith(
          BusinessService value, $Res Function(BusinessService) then) =
      _$BusinessServiceCopyWithImpl<$Res, BusinessService>;
  @useResult
  $Res call(
      {String id,
      String name,
      String nameHe,
      int durationMinutes,
      double price,
      bool isActive,
      String category,
      String? description,
      String? descriptionHe,
      List<BusinessServiceAddon>? addons,
      bool? isBasePrice,
      int? order,
      DateTime? createdAt,
      DateTime? updatedAt});
}

/// @nodoc
class _$BusinessServiceCopyWithImpl<$Res, $Val extends BusinessService>
    implements $BusinessServiceCopyWith<$Res> {
  _$BusinessServiceCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of BusinessService
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? nameHe = null,
    Object? durationMinutes = null,
    Object? price = null,
    Object? isActive = null,
    Object? category = null,
    Object? description = freezed,
    Object? descriptionHe = freezed,
    Object? addons = freezed,
    Object? isBasePrice = freezed,
    Object? order = freezed,
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
      durationMinutes: null == durationMinutes
          ? _value.durationMinutes
          : durationMinutes // ignore: cast_nullable_to_non_nullable
              as int,
      price: null == price
          ? _value.price
          : price // ignore: cast_nullable_to_non_nullable
              as double,
      isActive: null == isActive
          ? _value.isActive
          : isActive // ignore: cast_nullable_to_non_nullable
              as bool,
      category: null == category
          ? _value.category
          : category // ignore: cast_nullable_to_non_nullable
              as String,
      description: freezed == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String?,
      descriptionHe: freezed == descriptionHe
          ? _value.descriptionHe
          : descriptionHe // ignore: cast_nullable_to_non_nullable
              as String?,
      addons: freezed == addons
          ? _value.addons
          : addons // ignore: cast_nullable_to_non_nullable
              as List<BusinessServiceAddon>?,
      isBasePrice: freezed == isBasePrice
          ? _value.isBasePrice
          : isBasePrice // ignore: cast_nullable_to_non_nullable
              as bool?,
      order: freezed == order
          ? _value.order
          : order // ignore: cast_nullable_to_non_nullable
              as int?,
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
abstract class _$$BusinessServiceImplCopyWith<$Res>
    implements $BusinessServiceCopyWith<$Res> {
  factory _$$BusinessServiceImplCopyWith(_$BusinessServiceImpl value,
          $Res Function(_$BusinessServiceImpl) then) =
      __$$BusinessServiceImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String name,
      String nameHe,
      int durationMinutes,
      double price,
      bool isActive,
      String category,
      String? description,
      String? descriptionHe,
      List<BusinessServiceAddon>? addons,
      bool? isBasePrice,
      int? order,
      DateTime? createdAt,
      DateTime? updatedAt});
}

/// @nodoc
class __$$BusinessServiceImplCopyWithImpl<$Res>
    extends _$BusinessServiceCopyWithImpl<$Res, _$BusinessServiceImpl>
    implements _$$BusinessServiceImplCopyWith<$Res> {
  __$$BusinessServiceImplCopyWithImpl(
      _$BusinessServiceImpl _value, $Res Function(_$BusinessServiceImpl) _then)
      : super(_value, _then);

  /// Create a copy of BusinessService
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? nameHe = null,
    Object? durationMinutes = null,
    Object? price = null,
    Object? isActive = null,
    Object? category = null,
    Object? description = freezed,
    Object? descriptionHe = freezed,
    Object? addons = freezed,
    Object? isBasePrice = freezed,
    Object? order = freezed,
    Object? createdAt = freezed,
    Object? updatedAt = freezed,
  }) {
    return _then(_$BusinessServiceImpl(
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
      durationMinutes: null == durationMinutes
          ? _value.durationMinutes
          : durationMinutes // ignore: cast_nullable_to_non_nullable
              as int,
      price: null == price
          ? _value.price
          : price // ignore: cast_nullable_to_non_nullable
              as double,
      isActive: null == isActive
          ? _value.isActive
          : isActive // ignore: cast_nullable_to_non_nullable
              as bool,
      category: null == category
          ? _value.category
          : category // ignore: cast_nullable_to_non_nullable
              as String,
      description: freezed == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String?,
      descriptionHe: freezed == descriptionHe
          ? _value.descriptionHe
          : descriptionHe // ignore: cast_nullable_to_non_nullable
              as String?,
      addons: freezed == addons
          ? _value._addons
          : addons // ignore: cast_nullable_to_non_nullable
              as List<BusinessServiceAddon>?,
      isBasePrice: freezed == isBasePrice
          ? _value.isBasePrice
          : isBasePrice // ignore: cast_nullable_to_non_nullable
              as bool?,
      order: freezed == order
          ? _value.order
          : order // ignore: cast_nullable_to_non_nullable
              as int?,
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
class _$BusinessServiceImpl extends _BusinessService {
  const _$BusinessServiceImpl(
      {required this.id,
      required this.name,
      required this.nameHe,
      required this.durationMinutes,
      required this.price,
      required this.isActive,
      required this.category,
      this.description,
      this.descriptionHe,
      final List<BusinessServiceAddon>? addons,
      this.isBasePrice,
      this.order,
      this.createdAt,
      this.updatedAt})
      : _addons = addons,
        super._();

  factory _$BusinessServiceImpl.fromJson(Map<String, dynamic> json) =>
      _$$BusinessServiceImplFromJson(json);

  @override
  final String id;
  @override
  final String name;
  @override
  final String nameHe;
  @override
  final int durationMinutes;
  @override
  final double price;
  @override
  final bool isActive;
  @override
  final String category;
  @override
  final String? description;
  @override
  final String? descriptionHe;
  final List<BusinessServiceAddon>? _addons;
  @override
  List<BusinessServiceAddon>? get addons {
    final value = _addons;
    if (value == null) return null;
    if (_addons is EqualUnmodifiableListView) return _addons;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(value);
  }

  @override
  final bool? isBasePrice;
  @override
  final int? order;
  @override
  final DateTime? createdAt;
  @override
  final DateTime? updatedAt;

  @override
  String toString() {
    return 'BusinessService(id: $id, name: $name, nameHe: $nameHe, durationMinutes: $durationMinutes, price: $price, isActive: $isActive, category: $category, description: $description, descriptionHe: $descriptionHe, addons: $addons, isBasePrice: $isBasePrice, order: $order, createdAt: $createdAt, updatedAt: $updatedAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$BusinessServiceImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.nameHe, nameHe) || other.nameHe == nameHe) &&
            (identical(other.durationMinutes, durationMinutes) ||
                other.durationMinutes == durationMinutes) &&
            (identical(other.price, price) || other.price == price) &&
            (identical(other.isActive, isActive) ||
                other.isActive == isActive) &&
            (identical(other.category, category) ||
                other.category == category) &&
            (identical(other.description, description) ||
                other.description == description) &&
            (identical(other.descriptionHe, descriptionHe) ||
                other.descriptionHe == descriptionHe) &&
            const DeepCollectionEquality().equals(other._addons, _addons) &&
            (identical(other.isBasePrice, isBasePrice) ||
                other.isBasePrice == isBasePrice) &&
            (identical(other.order, order) || other.order == order) &&
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
      durationMinutes,
      price,
      isActive,
      category,
      description,
      descriptionHe,
      const DeepCollectionEquality().hash(_addons),
      isBasePrice,
      order,
      createdAt,
      updatedAt);

  /// Create a copy of BusinessService
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$BusinessServiceImplCopyWith<_$BusinessServiceImpl> get copyWith =>
      __$$BusinessServiceImplCopyWithImpl<_$BusinessServiceImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$BusinessServiceImplToJson(
      this,
    );
  }
}

abstract class _BusinessService extends BusinessService {
  const factory _BusinessService(
      {required final String id,
      required final String name,
      required final String nameHe,
      required final int durationMinutes,
      required final double price,
      required final bool isActive,
      required final String category,
      final String? description,
      final String? descriptionHe,
      final List<BusinessServiceAddon>? addons,
      final bool? isBasePrice,
      final int? order,
      final DateTime? createdAt,
      final DateTime? updatedAt}) = _$BusinessServiceImpl;
  const _BusinessService._() : super._();

  factory _BusinessService.fromJson(Map<String, dynamic> json) =
      _$BusinessServiceImpl.fromJson;

  @override
  String get id;
  @override
  String get name;
  @override
  String get nameHe;
  @override
  int get durationMinutes;
  @override
  double get price;
  @override
  bool get isActive;
  @override
  String get category;
  @override
  String? get description;
  @override
  String? get descriptionHe;
  @override
  List<BusinessServiceAddon>? get addons;
  @override
  bool? get isBasePrice;
  @override
  int? get order;
  @override
  DateTime? get createdAt;
  @override
  DateTime? get updatedAt;

  /// Create a copy of BusinessService
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$BusinessServiceImplCopyWith<_$BusinessServiceImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

BusinessServiceAddon _$BusinessServiceAddonFromJson(Map<String, dynamic> json) {
  return _BusinessServiceAddon.fromJson(json);
}

/// @nodoc
mixin _$BusinessServiceAddon {
  String get name => throw _privateConstructorUsedError;
  String get nameHe => throw _privateConstructorUsedError;
  int get durationMinutes => throw _privateConstructorUsedError;
  double get price => throw _privateConstructorUsedError;
  String? get description => throw _privateConstructorUsedError;
  String? get descriptionHe => throw _privateConstructorUsedError;

  /// Serializes this BusinessServiceAddon to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of BusinessServiceAddon
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $BusinessServiceAddonCopyWith<BusinessServiceAddon> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $BusinessServiceAddonCopyWith<$Res> {
  factory $BusinessServiceAddonCopyWith(BusinessServiceAddon value,
          $Res Function(BusinessServiceAddon) then) =
      _$BusinessServiceAddonCopyWithImpl<$Res, BusinessServiceAddon>;
  @useResult
  $Res call(
      {String name,
      String nameHe,
      int durationMinutes,
      double price,
      String? description,
      String? descriptionHe});
}

/// @nodoc
class _$BusinessServiceAddonCopyWithImpl<$Res,
        $Val extends BusinessServiceAddon>
    implements $BusinessServiceAddonCopyWith<$Res> {
  _$BusinessServiceAddonCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of BusinessServiceAddon
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? name = null,
    Object? nameHe = null,
    Object? durationMinutes = null,
    Object? price = null,
    Object? description = freezed,
    Object? descriptionHe = freezed,
  }) {
    return _then(_value.copyWith(
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      nameHe: null == nameHe
          ? _value.nameHe
          : nameHe // ignore: cast_nullable_to_non_nullable
              as String,
      durationMinutes: null == durationMinutes
          ? _value.durationMinutes
          : durationMinutes // ignore: cast_nullable_to_non_nullable
              as int,
      price: null == price
          ? _value.price
          : price // ignore: cast_nullable_to_non_nullable
              as double,
      description: freezed == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String?,
      descriptionHe: freezed == descriptionHe
          ? _value.descriptionHe
          : descriptionHe // ignore: cast_nullable_to_non_nullable
              as String?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$BusinessServiceAddonImplCopyWith<$Res>
    implements $BusinessServiceAddonCopyWith<$Res> {
  factory _$$BusinessServiceAddonImplCopyWith(_$BusinessServiceAddonImpl value,
          $Res Function(_$BusinessServiceAddonImpl) then) =
      __$$BusinessServiceAddonImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String name,
      String nameHe,
      int durationMinutes,
      double price,
      String? description,
      String? descriptionHe});
}

/// @nodoc
class __$$BusinessServiceAddonImplCopyWithImpl<$Res>
    extends _$BusinessServiceAddonCopyWithImpl<$Res, _$BusinessServiceAddonImpl>
    implements _$$BusinessServiceAddonImplCopyWith<$Res> {
  __$$BusinessServiceAddonImplCopyWithImpl(_$BusinessServiceAddonImpl _value,
      $Res Function(_$BusinessServiceAddonImpl) _then)
      : super(_value, _then);

  /// Create a copy of BusinessServiceAddon
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? name = null,
    Object? nameHe = null,
    Object? durationMinutes = null,
    Object? price = null,
    Object? description = freezed,
    Object? descriptionHe = freezed,
  }) {
    return _then(_$BusinessServiceAddonImpl(
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      nameHe: null == nameHe
          ? _value.nameHe
          : nameHe // ignore: cast_nullable_to_non_nullable
              as String,
      durationMinutes: null == durationMinutes
          ? _value.durationMinutes
          : durationMinutes // ignore: cast_nullable_to_non_nullable
              as int,
      price: null == price
          ? _value.price
          : price // ignore: cast_nullable_to_non_nullable
              as double,
      description: freezed == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String?,
      descriptionHe: freezed == descriptionHe
          ? _value.descriptionHe
          : descriptionHe // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$BusinessServiceAddonImpl extends _BusinessServiceAddon {
  const _$BusinessServiceAddonImpl(
      {required this.name,
      required this.nameHe,
      required this.durationMinutes,
      required this.price,
      this.description,
      this.descriptionHe})
      : super._();

  factory _$BusinessServiceAddonImpl.fromJson(Map<String, dynamic> json) =>
      _$$BusinessServiceAddonImplFromJson(json);

  @override
  final String name;
  @override
  final String nameHe;
  @override
  final int durationMinutes;
  @override
  final double price;
  @override
  final String? description;
  @override
  final String? descriptionHe;

  @override
  String toString() {
    return 'BusinessServiceAddon(name: $name, nameHe: $nameHe, durationMinutes: $durationMinutes, price: $price, description: $description, descriptionHe: $descriptionHe)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$BusinessServiceAddonImpl &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.nameHe, nameHe) || other.nameHe == nameHe) &&
            (identical(other.durationMinutes, durationMinutes) ||
                other.durationMinutes == durationMinutes) &&
            (identical(other.price, price) || other.price == price) &&
            (identical(other.description, description) ||
                other.description == description) &&
            (identical(other.descriptionHe, descriptionHe) ||
                other.descriptionHe == descriptionHe));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, name, nameHe, durationMinutes,
      price, description, descriptionHe);

  /// Create a copy of BusinessServiceAddon
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$BusinessServiceAddonImplCopyWith<_$BusinessServiceAddonImpl>
      get copyWith =>
          __$$BusinessServiceAddonImplCopyWithImpl<_$BusinessServiceAddonImpl>(
              this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$BusinessServiceAddonImplToJson(
      this,
    );
  }
}

abstract class _BusinessServiceAddon extends BusinessServiceAddon {
  const factory _BusinessServiceAddon(
      {required final String name,
      required final String nameHe,
      required final int durationMinutes,
      required final double price,
      final String? description,
      final String? descriptionHe}) = _$BusinessServiceAddonImpl;
  const _BusinessServiceAddon._() : super._();

  factory _BusinessServiceAddon.fromJson(Map<String, dynamic> json) =
      _$BusinessServiceAddonImpl.fromJson;

  @override
  String get name;
  @override
  String get nameHe;
  @override
  int get durationMinutes;
  @override
  double get price;
  @override
  String? get description;
  @override
  String? get descriptionHe;

  /// Create a copy of BusinessServiceAddon
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$BusinessServiceAddonImplCopyWith<_$BusinessServiceAddonImpl>
      get copyWith => throw _privateConstructorUsedError;
}
