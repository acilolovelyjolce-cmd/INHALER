import 'package:flutter_test/flutter_test.dart';
import 'package:whimsical_hub/models/owner_profile.dart';
import 'package:whimsical_hub/models/product.dart';

void main() {
  test('Product.fromJson fills missing shop fields instead of crashing', () {
    final product = Product.fromJson({
      'id': 12,
      'name': 'Green',
      'price': '200',
      'paracords': [
        {'id': 'cord-1', 'name': 'Orange', 'price': 20},
        {'name': 'nameless'},
      ],
    });
    expect(product.id, '12');
    expect(product.description, isEmpty);
    expect(product.category, 'Inhalers');
    expect(product.isPublished, isFalse);
    expect(product.paracords, hasLength(1));
    expect(product.paracords.first.name, 'Orange');
  });

  test('OwnerProfile.fromJson accepts a public shop payload', () {
    final shop = OwnerProfile.fromJson({
      'id': 'abc',
      'shop_name': 'BDC - PASTEL POCKET',
      'shop_slug': 'whimsical',
    });
    expect(shop.shopName, 'BDC - PASTEL POCKET');
    expect(shop.contactInfo, isEmpty);
  });
}
