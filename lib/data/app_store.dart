import 'dart:async';

import '../models/order_request.dart';
import '../models/owner_profile.dart';
import '../models/part_kind.dart';
import '../models/parts_catalog.dart';
import '../models/product.dart';
import 'demo_catalog.dart';
import 'option_stock.dart';

class DemoMemoryStore {
  DemoMemoryStore._() {
    paracords.addAll(demoCords);
    trinkets.addAll(demoTrinkets);
    letterings.addAll(demoLetterings);
    ropes.addAll(demoRopes);
    specialTrinkets.addAll(demoSpecialTrinkets);
    products.addAll(demoProducts());
    orders.addAll(demoOrders());
    owner = demoOwner;
  }

  static final DemoMemoryStore instance = DemoMemoryStore._();

  final List<Product> products = [];
  final List<ProductOption> paracords = [];
  final List<ProductOption> trinkets = [];
  final List<ProductOption> letterings = [];
  final List<ProductOption> ropes = [];
  final List<ProductOption> specialTrinkets = [];
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
        letterings: List.unmodifiable(letterings),
        ropes: List.unmodifiable(ropes),
        specialTrinkets: List.unmodifiable(specialTrinkets),
      );

  List<ProductOption> _listFor(PartKind kind) => switch (kind) {
        PartKind.paracord => paracords,
        PartKind.trinket => trinkets,
        PartKind.lettering => letterings,
        PartKind.rope => ropes,
        PartKind.specialTrinket => specialTrinkets,
      };

  void attachParts() {
    for (var i = 0; i < products.length; i++) {
      products[i] = products[i].copyWith(
        paracords: [...paracords],
        trinkets: [...trinkets],
        letterings: [...letterings],
        ropes: [...ropes],
        specialTrinkets: [...specialTrinkets],
      );
    }
    emitProducts();
  }

  void upsertPart(ProductOption option, {required PartKind kind}) {
    final list = _listFor(kind);
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
    letterings.removeWhere((item) => item.id == id);
    ropes.removeWhere((item) => item.id == id);
    specialTrinkets.removeWhere((item) => item.id == id);
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
        for (final option in product.allPartOptions) option.id: option.stock,
    };
    void apply(List<ProductOption> list) {
      for (var i = 0; i < list.length; i++) {
        final stock = stocks[list[i].id];
        if (stock != null) list[i] = list[i].copyWith(stock: stock);
      }
    }

    apply(paracords);
    apply(trinkets);
    apply(letterings);
    apply(ropes);
    apply(specialTrinkets);
  }

  void upsertProduct(Product product) {
    final attached = product.copyWith(
      paracords: [...paracords],
      trinkets: [...trinkets],
      letterings: [...letterings],
      ropes: [...ropes],
      specialTrinkets: [...specialTrinkets],
    );
    final idx = products.indexWhere((item) => item.id == attached.id);
    if (idx >= 0) {
      products[idx] = attached;
    } else {
      products.add(attached);
    }
    emitProducts();
  }
}
