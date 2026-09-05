import 'package:flutter_test/flutter_test.dart';
import 'package:whimsical_hub/models/order_request.dart';
import 'package:whimsical_hub/providers/catalog_providers.dart';

OrderRequest _order({
  required String id,
  OrderStatus status = OrderStatus.newRequest,
}) {
  final now = DateTime.utc(2026, 9, 5);
  return OrderRequest(
    id: id,
    shopSlug: 'shop',
    customerName: 'Ada',
    customerContact: '0917',
    items: const [
      OrderItem(
        productId: 'p1',
        productName: 'Mint',
        quantity: 1,
        priceAtOrder: 100,
      ),
    ],
    totalAmount: 100,
    status: status,
    paymentStatus: PaymentStatus.unpaid,
    createdAt: now,
    updatedAt: now,
  );
}

void main() {
  test('overlay prefers the local status until the inbox catches up', () {
    final remote = [_order(id: 'a'), _order(id: 'b')];
    final overlays = OrderOverlayState(
      updates: {'a': _order(id: 'a', status: OrderStatus.confirmed)},
    );

    final live = applyOrderOverlays(remote, overlays);

    expect(live.map((order) => order.status).toList(), [
      OrderStatus.confirmed,
      OrderStatus.newRequest,
    ]);
  });

  test('hidden orders leave the live list', () {
    final remote = [_order(id: 'a'), _order(id: 'b')];
    final overlays = OrderOverlayState(hidden: {'a'});

    expect(applyOrderOverlays(remote, overlays).map((order) => order.id), ['b']);
  });
}
