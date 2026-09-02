import '../models/order_request.dart';
import '../models/product.dart';

class OptionStock {
  static Map<String, int> needed(Iterable<OrderItem> items) {
    final need = <String, int>{};
    void add(Object? id, int qty) {
      final key = id?.toString() ?? '';
      if (key.isEmpty) return;
      need[key] = (need[key] ?? 0) + qty;
    }

    for (final item in items) {
      add(item.paracord?['id'] ?? item.paracord?['_id'], item.quantity);
      for (final trinket in item.trinkets ?? const <Map<String, dynamic>>[]) {
        add(trinket['id'] ?? trinket['_id'], item.quantity);
      }
    }
    return need;
  }

  static Map<String, int> neededProducts(Iterable<OrderItem> items) {
    final need = <String, int>{};
    for (final item in items) {
      if (item.productId.isEmpty) continue;
      need[item.productId] = (need[item.productId] ?? 0) + item.quantity;
    }
    return need;
  }

  static int? of(Iterable<Product> products, String optionId) {
    for (final product in products) {
      for (final option in [...product.paracords, ...product.trinkets]) {
        if (option.id == optionId) return option.stock;
      }
    }
    return null;
  }

  static String? nameOf(Iterable<Product> products, String optionId) {
    for (final product in products) {
      for (final option in [...product.paracords, ...product.trinkets]) {
        if (option.id == optionId) return option.name;
      }
    }
    return null;
  }

  static Product? productOf(Iterable<Product> products, String productId) {
    for (final product in products) {
      if (product.id == productId) return product;
    }
    return null;
  }

  static String? shortage(Iterable<Product> products, Iterable<OrderItem> items) {
    for (final entry in needed(items).entries) {
      final have = of(products, entry.key);
      if (have == null) continue;
      if (have < entry.value) {
        final name = nameOf(products, entry.key) ?? 'that option';
        return 'Sorry, $name does not have enough left.';
      }
    }
    for (final entry in neededProducts(items).entries) {
      final product = productOf(products, entry.key);
      if (product == null || !product.tracksInhalerStock) continue;
      if (product.stock < entry.value) {
        return 'Sorry, ${product.name} does not have enough left.';
      }
    }
    return null;
  }

  static List<Product> apply(
    Iterable<Product> products,
    Iterable<OrderItem> items, {
    required int sign,
  }) {
    final optionNeed = needed(items);
    final productNeed = neededProducts(items);
    final nextStocks = <String, int>{
      for (final entry in optionNeed.entries)
        if (of(products, entry.key) != null)
          entry.key: (of(products, entry.key)! + sign * entry.value).clamp(0, 999999),
    };
    final now = DateTime.now();
    return [
      for (final product in products)
        product.copyWith(
          paracords: [
            for (final option in product.paracords)
              nextStocks.containsKey(option.id)
                  ? option.copyWith(stock: nextStocks[option.id]!)
                  : option,
          ],
          trinkets: [
            for (final option in product.trinkets)
              nextStocks.containsKey(option.id)
                  ? option.copyWith(stock: nextStocks[option.id]!)
                  : option,
          ],
          stock: _nextInhalerStock(product, productNeed, sign),
          stockStatus: _nextStatus(product, productNeed, sign),
          updatedAt: now,
        ),
    ];
  }

  static int _nextInhalerStock(Product product, Map<String, int> need, int sign) {
    final qty = need[product.id];
    if (qty == null || !product.tracksInhalerStock) return product.stock;
    return (product.stock + sign * qty).clamp(0, 999999);
  }

  static StockStatus _nextStatus(Product product, Map<String, int> need, int sign) {
    if (product.stockStatus == StockStatus.madeToOrder) return product.stockStatus;
    final next = _nextInhalerStock(product, need, sign);
    if (next <= 0) return StockStatus.soldOut;
    if (product.stockStatus == StockStatus.soldOut) return StockStatus.available;
    return product.stockStatus;
  }

  static List<Product> syncFrom(Iterable<Product> products, Product source) {
    final stocks = <String, int>{
      for (final option in [...source.paracords, ...source.trinkets]) option.id: option.stock,
    };
    if (stocks.isEmpty) return products.toList();
    return [
      for (final product in products)
        product.copyWith(
          paracords: [
            for (final option in product.paracords)
              stocks.containsKey(option.id) ? option.copyWith(stock: stocks[option.id]!) : option,
          ],
          trinkets: [
            for (final option in product.trinkets)
              stocks.containsKey(option.id) ? option.copyWith(stock: stocks[option.id]!) : option,
          ],
        ),
    ];
  }
}
