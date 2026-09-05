import 'package:flutter_test/flutter_test.dart';
import 'package:whimsical_hub/data/demo_catalog.dart';
import 'package:whimsical_hub/models/catalog_sort.dart';
import 'package:whimsical_hub/models/owner_profile.dart';

void main() {
  test('cheapest first lists the lowest inhaler price at the top', () {
    final ranked = CatalogSort.priceAsc.apply(demoProducts());
    expect(ranked.first.price, lessThanOrEqualTo(ranked.last.price));
    for (var i = 1; i < ranked.length; i++) {
      expect(ranked[i - 1].price, lessThanOrEqualTo(ranked[i].price));
    }
  });

  test('most expensive first lists the highest inhaler price at the top', () {
    final ranked = CatalogSort.priceDesc.apply(demoProducts());
    expect(ranked.first.price, greaterThanOrEqualTo(ranked.last.price));
  });

  test('manual keeps the owner drag order', () {
    final ranked = CatalogSort.manual.apply(demoProducts());
    expect(ranked.map((item) => item.sortOrder).toList(), [0, 1, 2, 3]);
  });

  test('option lists follow cheapest and name order', () {
    final cheapest = CatalogSort.priceAsc.applyOptions(demoCords);
    for (var i = 1; i < cheapest.length; i++) {
      expect(cheapest[i - 1].price, lessThanOrEqualTo(cheapest[i].price));
    }
    final named = CatalogSort.nameAsc.applyOptions(demoCords);
    final names = [for (final item in named) item.name.toLowerCase()];
    expect(names, List<String>.from(names)..sort());
  });

  test('OwnerProfile defaults catalog sort to manual', () {
    final shop = OwnerProfile.fromJson({
      'id': 'abc',
      'shop_name': 'BDC',
      'shop_slug': 'whimsical',
    });
    expect(shop.catalogSort, 'manual');
    expect(CatalogSort.parse(shop.catalogSort), CatalogSort.manual);
  });

  test('arrange cheapest is the same list in the owner catalog and customer shop', () {
    final arranged = CatalogSort.priceAsc.applyOptions(demoTrinkets);
    expect(arranged.first.price, lessThanOrEqualTo(arranged.last.price));
    expect(
      CatalogSort.priceAsc.applyOptions(arranged).map((item) => item.id),
      arranged.map((item) => item.id),
    );
    expect(
      CatalogSort.orderedByIds(demoTrinkets, [for (final item in arranged) item.id])
          .map((item) => item.id),
      arranged.map((item) => item.id),
    );
  });

  test('orderedByIds keeps leftover options after the arranged ones', () {
    final first = demoCords.first;
    final ranked = CatalogSort.orderedByIds(demoCords, [first.id]);
    expect(ranked.first.id, first.id);
    expect(ranked.length, demoCords.length);
    expect({for (final item in ranked) item.id}, {for (final item in demoCords) item.id});
  });
}
