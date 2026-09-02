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
    expect(product.category, isEmpty);
    expect(product.isPublished, isFalse);
    expect(product.paracords, hasLength(1));
    expect(product.paracords.first.name, 'Orange');
    expect(product.stock, 99);
    expect(product.isSoldOut, isFalse);
  });

  test('Product.fromJson treats a missing stock on a sold-out inhaler as zero', () {
    final product = Product.fromJson({
      'id': 'gone',
      'name': 'Gone',
      'price': 10,
      'stock_status': 'sold_out',
    });
    expect(product.stock, 0);
    expect(product.isSoldOut, isTrue);
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
