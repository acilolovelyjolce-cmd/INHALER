import 'dart:async';

import '../models/order_request.dart';
import '../models/owner_profile.dart';
import '../models/parts_catalog.dart';
import '../models/product.dart';
import 'demo_catalog.dart';
import 'option_stock.dart';

class DemoMemoryStore {
  DemoMemoryStore._() {
    paracords.addAll(demoCords);
    trinkets.addAll(demoTrinkets);
    products.addAll(demoProducts());
    orders.addAll(demoOrders());
    owner = demoOwner;
  }

  static final DemoMemoryStore instance = DemoMemoryStore._();

  final List<Product> products = [];
  final List<ProductOption> paracords = [];
  final List<ProductOption> trinkets = [];
  final List<OrderRequest> orders = [];
  OwnerProfile owner = demoOwner;
  bool signedIn = false;

  final StreamController<List<Product>> productsCtrl =
      StreamController<List<Product>>.broadcast();
  final StreamController<PartsCatalog> partsCtrl =
      StreamController<PartsCatalog>.broadcast();
  final StreamController<List<OrderRequest>> ordersCtrl =
      StreamController<List<OrderRequest>>.broadcast();
  final StreamController<OwnerProfile> ownerCtrl =
      StreamController<OwnerProfile>.broadcast();
  final StreamController<bool> authCtrl = StreamController<bool>.broadcast();

  void emitProducts() => productsCtrl.add(List.unmodifiable(products));
  void emitParts() => partsCtrl.add(partsCatalog);
  void emitOrders() => ordersCtrl.add(List.unmodifiable(orders));
  void emitOwner() => ownerCtrl.add(owner);

  PartsCatalog get partsCatalog => PartsCatalog(
        paracords: List.unmodifiable(paracords),
        trinkets: List.unmodifiable(trinkets),
      );

  void attachParts() {
    for (var i = 0; i < products.length; i++) {
      products[i] = products[i].copyWith(paracords: [...paracords], trinkets: [...trinkets]);
    }
    emitProducts();
  }

  void upsertPart(ProductOption option, {required bool trinket}) {
    final list = trinket ? trinkets : paracords;
    final idx = list.indexWhere((item) => item.id == option.id);
    if (idx >= 0) {
      list[idx] = option;
    } else {
      list.add(option);
    }
    attachParts();
    emitParts();
  }

  void deletePart(String id) {
    paracords.removeWhere((item) => item.id == id);
    trinkets.removeWhere((item) => item.id == id);
    attachParts();
    emitParts();
  }

  String? applyOrderStock(Iterable<OrderItem> items, {required bool restore}) {
    if (!restore) {
      final message = OptionStock.shortage(products, items);
      if (message != null) return message;
    }
    final next = OptionStock.apply(products, items, sign: restore ? 1 : -1);
    products
      ..clear()
      ..addAll(next);
    _copyStocksToParts();
    emitProducts();
    emitParts();
    return null;
  }

  void _copyStocksToParts() {
    final stocks = <String, int>{
      for (final product in products)
        for (final option in [...product.paracords, ...product.trinkets]) option.id: option.stock,
    };
    for (var i = 0; i < paracords.length; i++) {
      final stock = stocks[paracords[i].id];
      if (stock != null) paracords[i] = paracords[i].copyWith(stock: stock);
    }
    for (var i = 0; i < trinkets.length; i++) {
      final stock = stocks[trinkets[i].id];
      if (stock != null) trinkets[i] = trinkets[i].copyWith(stock: stock);
    }
  }

  void upsertProduct(Product product) {
    final attached = product.copyWith(paracords: [...paracords], trinkets: [...trinkets]);
    final idx = products.indexWhere((item) => item.id == attached.id);
    if (idx >= 0) {
      products[idx] = attached;
    } else {
      products.add(attached);
    }
    emitProducts();
  }
}
