// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'catalog_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$productsRepositoryHash() =>
    r'6df256fc838b6e97bb7a7fbcdb6f4d58f4e90b84';

/// See also [productsRepository].
@ProviderFor(productsRepository)
final productsRepositoryProvider = Provider<ProductsRepository>.internal(
  productsRepository,
  name: r'productsRepositoryProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$productsRepositoryHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef ProductsRepositoryRef = ProviderRef<ProductsRepository>;
String _$ordersRepositoryHash() => r'75a3bf807ccf7363797f77e2b84b014963b871f6';

/// See also [ordersRepository].
@ProviderFor(ordersRepository)
final ordersRepositoryProvider = Provider<OrdersRepository>.internal(
  ordersRepository,
  name: r'ordersRepositoryProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$ordersRepositoryHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef OrdersRepositoryRef = ProviderRef<OrdersRepository>;
String _$publishedProductsHash() => r'31aa5e9173fd09038f9273ab69bf5fcd76d478a5';

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

abstract class _$PublishedProducts
    extends BuildlessStreamNotifier<List<Product>> {
  late final String slug;

  Stream<List<Product>> build(String slug);
}

/// See also [PublishedProducts].
@ProviderFor(PublishedProducts)
const publishedProductsProvider = PublishedProductsFamily();

/// See also [PublishedProducts].
class PublishedProductsFamily extends Family<AsyncValue<List<Product>>> {
  /// See also [PublishedProducts].
  const PublishedProductsFamily();

  /// See also [PublishedProducts].
  PublishedProductsProvider call(String slug) {
    return PublishedProductsProvider(slug);
  }

  @override
  PublishedProductsProvider getProviderOverride(
    covariant PublishedProductsProvider provider,
  ) {
    return call(provider.slug);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'publishedProductsProvider';
}

/// See also [PublishedProducts].
class PublishedProductsProvider
    extends StreamNotifierProviderImpl<PublishedProducts, List<Product>> {
  /// See also [PublishedProducts].
  PublishedProductsProvider(String slug)
    : this._internal(
        () => PublishedProducts()..slug = slug,
        from: publishedProductsProvider,
        name: r'publishedProductsProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$publishedProductsHash,
        dependencies: PublishedProductsFamily._dependencies,
        allTransitiveDependencies:
            PublishedProductsFamily._allTransitiveDependencies,
        slug: slug,
      );

  PublishedProductsProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.slug,
  }) : super.internal();

  final String slug;

  @override
  Stream<List<Product>> runNotifierBuild(covariant PublishedProducts notifier) {
    return notifier.build(slug);
  }

  @override
  Override overrideWith(PublishedProducts Function() create) {
    return ProviderOverride(
      origin: this,
      override: PublishedProductsProvider._internal(
        () => create()..slug = slug,
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        slug: slug,
      ),
    );
  }

  @override
  StreamNotifierProviderElement<PublishedProducts, List<Product>>
  createElement() {
    return _PublishedProductsProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is PublishedProductsProvider && other.slug == slug;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, slug.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin PublishedProductsRef on StreamNotifierProviderRef<List<Product>> {
  /// The parameter `slug` of this provider.
  String get slug;
}

class _PublishedProductsProviderElement
    extends StreamNotifierProviderElement<PublishedProducts, List<Product>>
    with PublishedProductsRef {
  _PublishedProductsProviderElement(super.provider);

  @override
  String get slug => (origin as PublishedProductsProvider).slug;
}

String _$ownerProductsHash() => r'396e8153d676818efe1a216b9275d456112e03d4';

/// See also [OwnerProducts].
@ProviderFor(OwnerProducts)
final ownerProductsProvider =
    StreamNotifierProvider<OwnerProducts, List<Product>>.internal(
      OwnerProducts.new,
      name: r'ownerProductsProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$ownerProductsHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$OwnerProducts = StreamNotifier<List<Product>>;
String _$shopProfileHash() => r'68cb1b18e0894a631f02ec006c1cf53acb42f333';

abstract class _$ShopProfile extends BuildlessStreamNotifier<OwnerProfile?> {
  late final String slug;

  Stream<OwnerProfile?> build(String slug);
}

/// See also [ShopProfile].
@ProviderFor(ShopProfile)
const shopProfileProvider = ShopProfileFamily();

/// See also [ShopProfile].
class ShopProfileFamily extends Family<AsyncValue<OwnerProfile?>> {
  /// See also [ShopProfile].
  const ShopProfileFamily();

  /// See also [ShopProfile].
  ShopProfileProvider call(String slug) {
    return ShopProfileProvider(slug);
  }

  @override
  ShopProfileProvider getProviderOverride(
    covariant ShopProfileProvider provider,
  ) {
    return call(provider.slug);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'shopProfileProvider';
}

/// See also [ShopProfile].
class ShopProfileProvider
    extends StreamNotifierProviderImpl<ShopProfile, OwnerProfile?> {
  /// See also [ShopProfile].
  ShopProfileProvider(String slug)
    : this._internal(
        () => ShopProfile()..slug = slug,
        from: shopProfileProvider,
        name: r'shopProfileProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$shopProfileHash,
        dependencies: ShopProfileFamily._dependencies,
        allTransitiveDependencies: ShopProfileFamily._allTransitiveDependencies,
        slug: slug,
      );

  ShopProfileProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.slug,
  }) : super.internal();

  final String slug;

  @override
  Stream<OwnerProfile?> runNotifierBuild(covariant ShopProfile notifier) {
    return notifier.build(slug);
  }

  @override
  Override overrideWith(ShopProfile Function() create) {
    return ProviderOverride(
      origin: this,
      override: ShopProfileProvider._internal(
        () => create()..slug = slug,
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        slug: slug,
      ),
    );
  }

  @override
  StreamNotifierProviderElement<ShopProfile, OwnerProfile?> createElement() {
    return _ShopProfileProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is ShopProfileProvider && other.slug == slug;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, slug.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin ShopProfileRef on StreamNotifierProviderRef<OwnerProfile?> {
  /// The parameter `slug` of this provider.
  String get slug;
}

class _ShopProfileProviderElement
    extends StreamNotifierProviderElement<ShopProfile, OwnerProfile?>
    with ShopProfileRef {
  _ShopProfileProviderElement(super.provider);

  @override
  String get slug => (origin as ShopProfileProvider).slug;
}

String _$myProfileHash() => r'eb805afd4b605a8291d5c2259334184e1d3f3ab7';

/// See also [MyProfile].
@ProviderFor(MyProfile)
final myProfileProvider =
    StreamNotifierProvider<MyProfile, OwnerProfile?>.internal(
      MyProfile.new,
      name: r'myProfileProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$myProfileHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$MyProfile = StreamNotifier<OwnerProfile?>;
String _$ordersInboxHash() => r'04804ee508a110f1104224c59b71e25b6f481bf8';

/// See also [OrdersInbox].
@ProviderFor(OrdersInbox)
final ordersInboxProvider =
    StreamNotifierProvider<OrdersInbox, List<OrderRequest>>.internal(
      OrdersInbox.new,
      name: r'ordersInboxProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$ordersInboxHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$OrdersInbox = StreamNotifier<List<OrderRequest>>;
String _$orderCelebrationHash() => r'd1f788a634cf1d47d63927d00b2c706df8b20517';

/// See also [OrderCelebration].
@ProviderFor(OrderCelebration)
final orderCelebrationProvider =
    NotifierProvider<OrderCelebration, int>.internal(
      OrderCelebration.new,
      name: r'orderCelebrationProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$orderCelebrationHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$OrderCelebration = Notifier<int>;
String _$cartHash() => r'605a502690d1bed85fe7077c97e0880bf0e405b9';

/// See also [Cart].
@ProviderFor(Cart)
final cartProvider = NotifierProvider<Cart, List<CartLine>>.internal(
  Cart.new,
  name: r'cartProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$cartHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$Cart = Notifier<List<CartLine>>;
String _$submitLockHash() => r'045649f856feb1fcbef5cbf97ac579784562e967';

/// See also [SubmitLock].
@ProviderFor(SubmitLock)
final submitLockProvider = NotifierProvider<SubmitLock, DateTime?>.internal(
  SubmitLock.new,
  name: r'submitLockProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$submitLockHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$SubmitLock = Notifier<DateTime?>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
