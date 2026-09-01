import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../data/orders_repository.dart';
import '../data/products_repository.dart';
import '../models/order_request.dart';
import '../models/owner_profile.dart';
import '../models/product.dart';
import 'auth_provider.dart';

part 'catalog_providers.g.dart';

@Riverpod(keepAlive: true)
ProductsRepository productsRepository(ProductsRepositoryRef ref) =>
    ProductsRepository();

@Riverpod(keepAlive: true)
OrdersRepository ordersRepository(OrdersRepositoryRef ref) => OrdersRepository();

@riverpod
class PublishedProducts extends _$PublishedProducts {
  @override
  Future<List<Product>> build(String slug) async {
    final repo = ref.watch(productsRepositoryProvider);
    final stream = repo.watchPublished(slug);
    final sub = stream.skip(1).listen((next) => state = AsyncData(next));
    ref.onDispose(sub.cancel);
    return stream.first;
  }
}

@riverpod
class OwnerProducts extends _$OwnerProducts {
  @override
  Future<List<Product>> build() async {
    ref.watch(authProvider);
    final repo = ref.watch(productsRepositoryProvider);
    final stream = repo.watchAll();
    final sub = stream.skip(1).listen((next) => state = AsyncData(next));
    ref.onDispose(sub.cancel);
    return stream.first;
  }
}

@riverpod
class ShopProfile extends _$ShopProfile {
  @override
  Future<OwnerProfile?> build(String slug) async {
    final repo = ref.watch(ownerRepositoryProvider);
    final stream = repo.watchBySlug(slug);
    final sub = stream.skip(1).listen((next) => state = AsyncData(next));
    ref.onDispose(sub.cancel);
    return stream.first;
  }
}

@riverpod
class MyProfile extends _$MyProfile {
  @override
  Future<OwnerProfile?> build() async {
    ref.watch(authProvider);
    final repo = ref.watch(ownerRepositoryProvider);
    final stream = repo.watchMine();
    final sub = stream.skip(1).listen((next) => state = AsyncData(next));
    ref.onDispose(sub.cancel);
    return stream.first;
  }
}

@Riverpod(keepAlive: true)
class OrdersInbox extends _$OrdersInbox {
  final _seen = <String>{};
  var _ready = false;

  @override
  Stream<List<OrderRequest>> build() async* {
    ref.watch(authProvider);
    final repo = ref.watch(ordersRepositoryProvider);
    await for (final list in repo.watchForOwner()) {
      if (_ready) {
        final newcomers = list.where((o) => !_seen.contains(o.id)).toList();
        if (newcomers.isNotEmpty) {
          ref.read(orderCelebrationProvider.notifier).burst();
        }
      }
      _seen
        ..clear()
        ..addAll(list.map((o) => o.id));
      _ready = true;
      yield list;
    }
  }
}

@Riverpod(keepAlive: true)
class OrderCelebration extends _$OrderCelebration {
  @override
  int build() => 0;

  void burst() => state++;
}

class CartLine {
  const CartLine({
    required this.productId,
    required this.productName,
    required this.price,
    required this.quantity,
    this.imageUrl,
    this.variantSelection = const {},
  });

  final String productId;
  final String productName;
  final double price;
  final int quantity;
  final String? imageUrl;
  final Map<String, String> variantSelection;

  double get lineTotal => price * quantity;

  String get variantKey =>
      variantSelection.entries.map((e) => '${e.key}:${e.value}').join('|');

  CartLine copyWith({int? quantity}) => CartLine(
        productId: productId,
        productName: productName,
        price: price,
        quantity: quantity ?? this.quantity,
        imageUrl: imageUrl,
        variantSelection: variantSelection,
      );
}

@Riverpod(keepAlive: true)
class Cart extends _$Cart {
  @override
  List<CartLine> build() => const [];

  void add(CartLine line) {
    final idx = state.indexWhere(
      (item) =>
          item.productId == line.productId && item.variantKey == line.variantKey,
    );
    if (idx >= 0) {
      final next = [...state];
      next[idx] = next[idx].copyWith(quantity: next[idx].quantity + line.quantity);
      state = next;
    } else {
      state = [...state, line];
    }
  }

  void setQuantity(int index, int quantity) {
    if (quantity <= 0) {
      removeAt(index);
      return;
    }
    final next = [...state];
    next[index] = next[index].copyWith(quantity: quantity);
    state = next;
  }

  void removeAt(int index) {
    final next = [...state]..removeAt(index);
    state = next;
  }

  void clear() => state = const [];

  double get total => state.fold(0, (sum, line) => sum + line.lineTotal);
}

@Riverpod(keepAlive: true)
class SubmitLock extends _$SubmitLock {
  @override
  DateTime? build() => null;

  bool get isLocked {
    final until = state;
    if (until == null) return false;
    return DateTime.now().isBefore(until);
  }

  void lock([Duration duration = const Duration(seconds: 8)]) {
    state = DateTime.now().add(duration);
  }
}
