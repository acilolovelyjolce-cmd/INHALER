import 'package:flutter_test/flutter_test.dart';

import 'package:whimsical_hub/data/demo_catalog.dart';
import 'package:whimsical_hub/models/order_request.dart';
import 'package:whimsical_hub/providers/catalog_providers.dart';
import 'package:whimsical_hub/widgets/storefront/mix_bill.dart';

void main() {
  final inhaler = demoProducts().first;
  final cord = demoCords.first;
  final charm = demoTrinkets.first;

  test('lists a peso amount for the inhaler, paracord, and each trinket', () {
    final bill = MixBillData(
      productName: inhaler.name,
      inhalerPrice: inhaler.price,
      paracord: cord,
      trinkets: [charm, demoTrinkets[1]],
      quantity: 2,
    );

    expect(bill.parts.map((part) => part.label).toList(), [
      'Inhaler',
      'Mint paracord',
      'Baby Rex',
      'Sleepy Stego',
    ]);
    expect(bill.parts.map((part) => part.price).toList(), [450, 40, 80, 80]);
    expect(bill.unitTotal, 650);
    expect(bill.lineTotal, 1300);
  });

  test('cart lines split the mix price back into named parts', () {
    final line = CartLine(
      productId: inhaler.id,
      productName: inhaler.name,
      price: inhaler.price + cord.price + charm.price,
      quantity: 1,
      paracord: cord,
      trinkets: [charm],
    );
    final bill = MixBillData.fromCartLine(line);
    expect(bill.inhalerPrice, 450);
    expect(bill.parts.last.price, 80);
    expect(bill.lineTotal, 570);
  });

  test('order items keep add-on prices from the saved maps', () {
    const item = OrderItem(
      productId: 'p-baby-rex',
      productName: 'Baby Rex Inhaler Keychain',
      quantity: 1,
      priceAtOrder: 570,
      paracord: {'id': 'cord-mint', 'name': 'Mint paracord', 'price': 40},
      trinkets: [
        {'id': 't-rex', 'name': 'Baby Rex', 'price': 80},
      ],
    );
    final bill = MixBillData.fromOrderItem(item);
    expect(bill.parts.map((part) => '${part.label} ${part.price}').toList(), [
      'Inhaler 450.0',
      'Mint paracord 40.0',
      'Baby Rex 80.0',
    ]);
  });
}
