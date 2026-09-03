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
    expect(product.letterings, isEmpty);
    expect(product.ropes, isEmpty);
    expect(product.specialTrinkets, isEmpty);
    expect(product.stock, 99);
    expect(product.isSoldOut, isFalse);
  });

  test('Product.fromJson keeps letterings and special trinkets', () {
    final product = Product.fromJson({
      'id': 'p1',
      'name': 'Pink',
      'price': 100,
      'letterings': [
        {'id': 'l-a', 'name': 'Letter A', 'price': 25, 'stock': 4},
      ],
      'ropes': [
        {'id': 'rope-gold', 'name': 'Gold rope', 'price': 30, 'stock': 6},
      ],
      'special_trinkets': [
        {'id': 's-pearl', 'name': 'Pearl Rex', 'price': 120, 'stock': 2},
      ],
    });
    expect(product.letterings.single.name, 'Letter A');
    expect(product.ropes.single.name, 'Gold rope');
    expect(product.specialTrinkets.single.name, 'Pearl Rex');
    expect(product.linePrice(pickedLetterings: product.letterings, rope: product.ropes.first), 155);
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
