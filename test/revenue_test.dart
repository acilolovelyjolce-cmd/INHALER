import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:whimsical_hub/data/revenue.dart';
import 'package:whimsical_hub/models/order_request.dart';
import 'package:whimsical_hub/screens/dashboard/revenue_screen.dart';
import 'package:whimsical_hub/theme/app_theme.dart';

OrderRequest _order({
  required String id,
  required String name,
  required DateTime at,
  required double total,
  OrderStatus status = OrderStatus.completed,
  PaymentStatus pay = PaymentStatus.paid,
  int quantity = 1,
  String product = 'Baby Rex Inhaler Keychain',
  String? note,
}) {
  return OrderRequest(
    id: id,
    shopSlug: 'whimsical',
    customerName: name,
    customerContact: '09XX',
    items: [
      OrderItem(
        productId: 'p-$id',
        productName: product,
        quantity: quantity,
        priceAtOrder: total / quantity,
      ),
    ],
    totalAmount: total,
    customerNote: note,
    status: status,
    paymentStatus: pay,
    paymentMethod: PaymentMethod.eWallet,
    createdAt: at,
    updatedAt: at,
  );
}

void main() {
  final now = DateTime(2026, 9, 2, 16, 40);

  final orders = [
    _order(id: 'today-unpaid', name: 'Mika Santos', at: DateTime(2026, 9, 2, 14, 10), total: 570, status: OrderStatus.newRequest, pay: PaymentStatus.unpaid, note: 'gift wrap'),
    _order(id: 'today-paid', name: 'Lia Park', at: DateTime(2026, 9, 2, 9, 5), total: 450),
    _order(id: 'today-cancel', name: 'Gio Reyes', at: DateTime(2026, 9, 2, 11, 0), total: 430, status: OrderStatus.cancelled, pay: PaymentStatus.unpaid),
    _order(id: 'yesterday', name: 'Aya Lim', at: DateTime(2026, 9, 1, 18, 20), total: 600, quantity: 1),
    _order(id: 'sunday', name: 'Noel Cruz', at: DateTime(2026, 8, 30, 12, 0), total: 1320, quantity: 2, product: 'Pastel Ptero Set'),
    _order(id: 'august', name: 'Heart Dizon', at: DateTime(2026, 8, 12, 10, 0), total: 490),
  ];

  test('today excludes yesterday, cancelled, and counts unpaid in the take', () {
    final report = Revenue.of(orders, Revenue.windowFor(RevenuePeriod.today, now: now));
    expect(report.orders.map((o) => o.customerName), ['Mika Santos', 'Lia Park']);
    expect(report.take, 1020);
    expect(report.collected, 450);
    expect(report.open, 570);
    expect(report.cancelled.single.customerName, 'Gio Reyes');
    expect(report.pieces, 2);
  });

  test('yesterday is only that calendar day', () {
    final report = Revenue.of(orders, Revenue.windowFor(RevenuePeriod.yesterday, now: now));
    expect(report.orders.single.customerName, 'Aya Lim');
    expect(report.take, 600);
    expect(report.collected, 600);
  });

  test('week is Monday through Sunday of the current week', () {
    // 2 Sep 2026 is a Wednesday; week starts Monday 31 Aug.
    final report = Revenue.of(orders, Revenue.windowFor(RevenuePeriod.week, now: now));
    expect(
      report.orders.map((o) => o.customerName).toSet(),
      {'Mika Santos', 'Lia Park', 'Aya Lim'},
    );
    expect(report.take, 1620);
    expect(report.window.start, DateTime(2026, 8, 31));
    expect(report.window.end, DateTime(2026, 9, 7));
  });

  test('month keeps this month and drops last month', () {
    final report = Revenue.of(orders, Revenue.windowFor(RevenuePeriod.month, now: now));
    expect(report.orders.any((o) => o.customerName == 'Heart Dizon'), isFalse);
    expect(report.orders.any((o) => o.customerName == 'Aya Lim'), isTrue);
    expect(report.orders.any((o) => o.customerName == 'Noel Cruz'), isFalse);
  });

  test('a picked day opens only that date', () {
    final report = Revenue.of(
      orders,
      Revenue.windowFor(RevenuePeriod.custom, now: now, day: DateTime(2026, 8, 30)),
    );
    expect(report.orders.single.customerName, 'Noel Cruz');
    expect(report.pieces, 2);
    expect(report.take, 1320);
  });

  testWidgets('till shows the nest take and each guest on top', (tester) async {
    tester.view.physicalSize = const Size(390, 2000);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          theme: AppTheme.light(),
          home: Scaffold(
            body: RevenueTill(orders: orders, now: now),
          ),
        ),
      ),
    );
    await tester.pump();

    expect(find.text('Till'), findsOneWidget);
    expect(find.text('NEST TAKE'), findsOneWidget);
    expect(find.textContaining('₱1,020'), findsOneWidget);
    expect(find.text('Mika Santos'), findsOneWidget);
    expect(find.text('gift wrap'), findsOneWidget);
    expect(find.text('Lia Park'), findsOneWidget);
    expect(find.text('Gio Reyes'), findsOneWidget);
    expect(find.text('Cancelled · not in the total'), findsOneWidget);
    expect(find.text('Aya Lim'), findsNothing);

    await tester.tap(find.text('Yesterday'));
    await tester.pump();
    expect(find.text('Aya Lim'), findsOneWidget);
    expect(find.textContaining('₱600'), findsWidgets);
    expect(find.text('Mika Santos'), findsNothing);
  });
}
