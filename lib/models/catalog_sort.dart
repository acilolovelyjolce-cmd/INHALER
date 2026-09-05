import 'product.dart';

enum CatalogSort {
  manual,
  priceAsc,
  priceDesc,
  nameAsc;

  String get apiValue => switch (this) {
        manual => 'manual',
        priceAsc => 'price_asc',
        priceDesc => 'price_desc',
        nameAsc => 'name_asc',
      };

  String get label => switch (this) {
        manual => 'Your order',
        priceAsc => 'Cheapest first',
        priceDesc => 'Most expensive first',
        nameAsc => 'Name A–Z',
      };

  String get help => switch (this) {
        manual => 'Customers see inhalers, cords, trinkets, letterings, ropes, and specials in the order you drag them.',
        priceAsc => 'Customers see the lowest price at the top, including add-ons.',
        priceDesc => 'Customers see the highest price at the top, including add-ons.',
        nameAsc => 'Customers see inhalers and add-ons in alphabetical order.',
      };

  static CatalogSort parse(String? raw) {
    final key = (raw ?? '').trim().toLowerCase().replaceAll('-', '_').replaceAll(' ', '_');
    return switch (key) {
      'price_asc' || 'cheapest' || 'price' => priceAsc,
      'price_desc' || 'expensive' => priceDesc,
      'name_asc' || 'name' || 'az' => nameAsc,
      _ => manual,
    };
  }

  List<Product> apply(Iterable<Product> products) {
    final next = [...products];
    next.sort((a, b) {
      final ranked = switch (this) {
        CatalogSort.manual => a.sortOrder.compareTo(b.sortOrder),
        CatalogSort.priceAsc => a.price.compareTo(b.price),
        CatalogSort.priceDesc => b.price.compareTo(a.price),
        CatalogSort.nameAsc => a.name.toLowerCase().compareTo(b.name.toLowerCase()),
      };
      if (ranked != 0) return ranked;
      final byOrder = a.sortOrder.compareTo(b.sortOrder);
      if (byOrder != 0) return byOrder;
      return a.name.toLowerCase().compareTo(b.name.toLowerCase());
    });
    return next;
  }

  List<ProductOption> applyOptions(Iterable<ProductOption> options) {
    final next = [...options];
    if (this == CatalogSort.manual) return next;
    next.sort((a, b) {
      final ranked = switch (this) {
        CatalogSort.manual => 0,
        CatalogSort.priceAsc => a.price.compareTo(b.price),
        CatalogSort.priceDesc => b.price.compareTo(a.price),
        CatalogSort.nameAsc => a.name.toLowerCase().compareTo(b.name.toLowerCase()),
      };
      if (ranked != 0) return ranked;
      return a.name.toLowerCase().compareTo(b.name.toLowerCase());
    });
    return next;
  }
}
