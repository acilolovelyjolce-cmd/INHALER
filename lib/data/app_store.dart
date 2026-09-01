import 'dart:async';

import '../models/order_request.dart';
import '../models/owner_profile.dart';
import '../models/product.dart';
import 'demo_catalog.dart';
import 'option_stock.dart';

class DemoMemoryStore {
  DemoMemoryStore._() {
    products.addAll(demoProducts());
    orders.addAll(demoOrders());
    owner = demoOwner;
  }

  static final DemoMemoryStore instance = DemoMemoryStore._();

  final List<Product> products = [];
  final List<OrderRequest> orders = [];
  OwnerProfile owner = demoOwner;
  bool signedIn = false;

  final StreamController<List<Product>> productsCtrl =
      StreamController<List<Product>>.broadcast();
  final StreamController<List<OrderRequest>> ordersCtrl =
      StreamController<List<OrderRequest>>.broadcast();
  final StreamController<OwnerProfile> ownerCtrl =
      StreamController<OwnerProfile>.broadcast();
  final StreamController<bool> authCtrl = StreamController<bool>.broadcast();

  void emitProducts() => productsCtrl.add(List.unmodifiable(products));
  void emitOrders() => ordersCtrl.add(List.unmodifiable(orders));
  void emitOwner() => ownerCtrl.add(owner);

  String? applyOrderStock(Iterable<OrderItem> items, {required bool restore}) {
    final need = OptionStock.needed(items);
    if (!restore) {
      final message = OptionStock.shortage(products, need);
      if (message != null) return message;
    }
    final next = OptionStock.apply(products, need, sign: restore ? 1 : -1);
    products
      ..clear()
      ..addAll(next);
    emitProducts();
    return null;
  }

  void upsertProduct(Product product) {
    final idx = products.indexWhere((item) => item.id == product.id);
    if (idx >= 0) {
      products[idx] = product;
    } else {
      products.add(product);
    }
    final synced = OptionStock.syncFrom(products, product);
    products
      ..clear()
      ..addAll(synced);
    emitProducts();
  }
}
