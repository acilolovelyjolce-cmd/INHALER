import 'dart:async';

import '../models/order_request.dart';
import '../models/owner_profile.dart';
import '../models/product.dart';
import 'demo_catalog.dart';

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
}
