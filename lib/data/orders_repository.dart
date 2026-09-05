import 'package:uuid/uuid.dart';

import '../config/env.dart';
import '../models/order_request.dart';
import 'api_client.dart';
import 'app_store.dart';
import 'poll.dart';

class OrdersRepository {
  OrdersRepository();

  final _uuid = const Uuid();
  final _api = ApiClient.instance;

  Stream<List<OrderRequest>> watchForOwner() async* {
    if (AppConfig.useDemo) {
      final store = DemoMemoryStore.instance;
      List<OrderRequest> sorted() => [...store.orders]
        ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
      yield sorted();
      yield* store.ordersCtrl.stream.map((_) => sorted());
      return;
    }
    yield* pollKeepingLast(_fetch, period: const Duration(seconds: 12));
  }

  Future<List<OrderRequest>> _fetch() async {
    final rows = await _api.get('/api/orders') as List<dynamic>;
    final orders = <OrderRequest>[];
    for (final row in rows) {
      if (row is! Map) continue;
      try {
        orders.add(OrderRequest.fromJson(Map<String, dynamic>.from(row)));
      } catch (_) {}
    }
    orders.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return orders;
  }

  Future<OrderRequest> submit({
    required String shopSlug,
    required String customerName,
    required String customerContact,
    required List<OrderItem> items,
    required double totalAmount,
    String? customerNote,
    String? honeypot,
    PaymentMethod? paymentMethod,
  }) async {
    if (honeypot != null && honeypot.trim().isNotEmpty) {
      return OrderRequest(
        id: 'honeypot',
        shopSlug: shopSlug,
        customerName: customerName,
        customerContact: customerContact,
        items: items,
        totalAmount: totalAmount,
        customerNote: customerNote,
        status: OrderStatus.newRequest,
        paymentStatus: PaymentStatus.unpaid,
        paymentMethod: paymentMethod,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
    }

    if (AppConfig.useDemo) {
      final order = OrderRequest(
        id: _uuid.v4(),
        shopSlug: shopSlug,
        customerName: customerName,
        customerContact: customerContact,
        items: items,
        totalAmount: totalAmount,
        customerNote: customerNote,
        status: OrderStatus.newRequest,
        paymentStatus: PaymentStatus.unpaid,
        paymentMethod: paymentMethod,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      final shortage = DemoMemoryStore.instance.applyOrderStock(items, restore: false);
      if (shortage != null) {
        throw ApiException(shortage, status: 409);
      }
      DemoMemoryStore.instance.orders.insert(0, order);
      DemoMemoryStore.instance.emitOrders();
      return order;
    }

    final row = await _api.post('/api/shops/$shopSlug/orders', {
      'customer_name': customerName,
      'customer_contact': customerContact,
      'items': items.map((item) => item.toJson()).toList(),
      'total_amount': totalAmount,
      'customer_note': customerNote,
      'payment_method': paymentMethod?.name == 'eWallet' ? 'e_wallet' : paymentMethod?.name,
      'honeypot': honeypot,
    }) as Map<String, dynamic>;
    return OrderRequest.fromJson(row);
  }

  Future<void> update(OrderRequest order) async {
    if (AppConfig.useDemo) {
      final store = DemoMemoryStore.instance;
      final idx = store.orders.indexWhere((o) => o.id == order.id);
      if (idx >= 0) {
        final previous = store.orders[idx];
        final wasCancelled = previous.status == OrderStatus.cancelled;
        final nowCancelled = order.status == OrderStatus.cancelled;
        final itemsChanged = previous.items.length != order.items.length ||
            previous.items.asMap().entries.any((entry) {
              final next = order.items[entry.key];
              return entry.value.productId != next.productId ||
                  entry.value.quantity != next.quantity;
            });
        if (!wasCancelled && nowCancelled) {
          store.applyOrderStock(previous.items, restore: true);
        } else if (wasCancelled && !nowCancelled) {
          final shortage = store.applyOrderStock(order.items, restore: false);
          if (shortage != null) {
            throw ApiException(shortage, status: 409);
          }
        } else if (!wasCancelled && !nowCancelled && itemsChanged) {
          store.applyOrderStock(previous.items, restore: true);
          final shortage = store.applyOrderStock(order.items, restore: false);
          if (shortage != null) {
            store.applyOrderStock(previous.items, restore: false);
            throw ApiException(shortage, status: 409);
          }
        }
        store.orders[idx] = order;
      }
      store.emitOrders();
      return;
    }
    await _api.put('/api/orders/${order.id}', order.toJson());
  }

  Future<void> updateStatus(OrderRequest order) async {
    if (AppConfig.useDemo) {
      await update(order);
      return;
    }
    final json = order.toJson();
    await _api.put('/api/orders/${order.id}', {
      'status': json['status'],
      'payment_status': json['payment_status'],
      'payment_method': json['payment_method'],
    });
  }

  Future<void> delete(String id) async {
    if (AppConfig.useDemo) {
      final store = DemoMemoryStore.instance;
      final idx = store.orders.indexWhere((order) => order.id == id);
      if (idx < 0) return;
      final previous = store.orders[idx];
      if (previous.status != OrderStatus.cancelled) {
        store.applyOrderStock(previous.items, restore: true);
      }
      store.orders.removeAt(idx);
      store.emitOrders();
      return;
    }
    await _api.delete('/api/orders/$id');
  }
}
