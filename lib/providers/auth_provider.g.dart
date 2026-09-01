// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'auth_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$ownerRepositoryHash() => r'7e9d933b579bdd9e16820b9d42c4e6769cd14fe9';

/// See also [ownerRepository].
@ProviderFor(ownerRepository)
final ownerRepositoryProvider = Provider<OwnerRepository>.internal(
  ownerRepository,
  name: r'ownerRepositoryProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$ownerRepositoryHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef OwnerRepositoryRef = ProviderRef<OwnerRepository>;
String _$authHash() => r'88ce8437d07a6a4aa72bcbfddb8d7d52447e3686';

/// See also [Auth].
@ProviderFor(Auth)
final authProvider = StreamNotifierProvider<Auth, AuthSnapshot>.internal(
  Auth.new,
  name: r'authProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$authHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$Auth = StreamNotifier<AuthSnapshot>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
