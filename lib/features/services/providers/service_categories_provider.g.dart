// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'service_categories_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$serviceCategoriesHash() => r'8e12e2f7d0a2ac9e61b7bbcb0b7dbe4b7ac67d6d';

/// See also [serviceCategories].
@ProviderFor(serviceCategories)
final serviceCategoriesProvider =
    StreamProvider<List<ServiceCategory>>.internal(
  serviceCategories,
  name: r'serviceCategoriesProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$serviceCategoriesHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef ServiceCategoriesRef = StreamProviderRef<List<ServiceCategory>>;
String _$categorySubcategoriesHash() =>
    r'9b8b917fd7138c59ff38151152e674d3cff75e95';

/// Copied from Dart SDK
class _SystemHash {
  _SystemHash._();

  static int combine(int hash, int value) {
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + value);
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + ((0x0007ffff & hash) << 10));
    return hash ^ (hash >> 6);
  }

  static int finish(int hash) {
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + ((0x03ffffff & hash) << 3));
    // ignore: parameter_assignments
    hash = hash ^ (hash >> 11);
    return 0x1fffffff & (hash + ((0x00003fff & hash) << 15));
  }
}

/// See also [categorySubcategories].
@ProviderFor(categorySubcategories)
const categorySubcategoriesProvider = CategorySubcategoriesFamily();

/// See also [categorySubcategories].
class CategorySubcategoriesFamily
    extends Family<AsyncValue<List<ServiceCategory>>> {
  /// See also [categorySubcategories].
  const CategorySubcategoriesFamily();

  /// See also [categorySubcategories].
  CategorySubcategoriesProvider call(
    String categoryId,
  ) {
    return CategorySubcategoriesProvider(
      categoryId,
    );
  }

  @override
  CategorySubcategoriesProvider getProviderOverride(
    covariant CategorySubcategoriesProvider provider,
  ) {
    return call(
      provider.categoryId,
    );
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'categorySubcategoriesProvider';
}

/// See also [categorySubcategories].
class CategorySubcategoriesProvider
    extends StreamProvider<List<ServiceCategory>> {
  /// See also [categorySubcategories].
  CategorySubcategoriesProvider(
    String categoryId,
  ) : this._internal(
          (ref) => categorySubcategories(
            ref as CategorySubcategoriesRef,
            categoryId,
          ),
          from: categorySubcategoriesProvider,
          name: r'categorySubcategoriesProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$categorySubcategoriesHash,
          dependencies: CategorySubcategoriesFamily._dependencies,
          allTransitiveDependencies:
              CategorySubcategoriesFamily._allTransitiveDependencies,
          categoryId: categoryId,
        );

  CategorySubcategoriesProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.categoryId,
  }) : super.internal();

  final String categoryId;

  @override
  Override overrideWith(
    Stream<List<ServiceCategory>> Function(CategorySubcategoriesRef provider)
        create,
  ) {
    return ProviderOverride(
      origin: this,
      override: CategorySubcategoriesProvider._internal(
        (ref) => create(ref as CategorySubcategoriesRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        categoryId: categoryId,
      ),
    );
  }

  @override
  StreamProviderElement<List<ServiceCategory>> createElement() {
    return _CategorySubcategoriesProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is CategorySubcategoriesProvider &&
        other.categoryId == categoryId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, categoryId.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin CategorySubcategoriesRef on StreamProviderRef<List<ServiceCategory>> {
  /// The parameter `categoryId` of this provider.
  String get categoryId;
}

class _CategorySubcategoriesProviderElement
    extends StreamProviderElement<List<ServiceCategory>>
    with CategorySubcategoriesRef {
  _CategorySubcategoriesProviderElement(super.provider);

  @override
  String get categoryId => (origin as CategorySubcategoriesProvider).categoryId;
}

String _$categoryAddonsHash() => r'b0d1b86a9dea2425d2a277ddb11ca4bd5b51b620';

/// See also [categoryAddons].
@ProviderFor(categoryAddons)
const categoryAddonsProvider = CategoryAddonsFamily();

/// See also [categoryAddons].
class CategoryAddonsFamily extends Family<AsyncValue<List<ServiceAddon>>> {
  /// See also [categoryAddons].
  const CategoryAddonsFamily();

  /// See also [categoryAddons].
  CategoryAddonsProvider call(
    String categoryId,
  ) {
    return CategoryAddonsProvider(
      categoryId,
    );
  }

  @override
  CategoryAddonsProvider getProviderOverride(
    covariant CategoryAddonsProvider provider,
  ) {
    return call(
      provider.categoryId,
    );
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'categoryAddonsProvider';
}

/// See also [categoryAddons].
class CategoryAddonsProvider extends StreamProvider<List<ServiceAddon>> {
  /// See also [categoryAddons].
  CategoryAddonsProvider(
    String categoryId,
  ) : this._internal(
          (ref) => categoryAddons(
            ref as CategoryAddonsRef,
            categoryId,
          ),
          from: categoryAddonsProvider,
          name: r'categoryAddonsProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$categoryAddonsHash,
          dependencies: CategoryAddonsFamily._dependencies,
          allTransitiveDependencies:
              CategoryAddonsFamily._allTransitiveDependencies,
          categoryId: categoryId,
        );

  CategoryAddonsProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.categoryId,
  }) : super.internal();

  final String categoryId;

  @override
  Override overrideWith(
    Stream<List<ServiceAddon>> Function(CategoryAddonsRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: CategoryAddonsProvider._internal(
        (ref) => create(ref as CategoryAddonsRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        categoryId: categoryId,
      ),
    );
  }

  @override
  StreamProviderElement<List<ServiceAddon>> createElement() {
    return _CategoryAddonsProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is CategoryAddonsProvider && other.categoryId == categoryId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, categoryId.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin CategoryAddonsRef on StreamProviderRef<List<ServiceAddon>> {
  /// The parameter `categoryId` of this provider.
  String get categoryId;
}

class _CategoryAddonsProviderElement
    extends StreamProviderElement<List<ServiceAddon>> with CategoryAddonsRef {
  _CategoryAddonsProviderElement(super.provider);

  @override
  String get categoryId => (origin as CategoryAddonsProvider).categoryId;
}
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
