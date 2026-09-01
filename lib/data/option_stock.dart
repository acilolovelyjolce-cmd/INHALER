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
      add(item.paracord?['id'], item.quantity);
      for (final trinket in item.trinkets ?? const <Map<String, dynamic>>[]) {
        add(trinket['id'], item.quantity);
      }
    }
    return need;
  }

  static int of(Iterable<Product> products, String optionId) {
    for (final product in products) {
      for (final option in [...product.paracords, ...product.trinkets]) {
        if (option.id == optionId) return option.stock;
      }
    }
    return 0;
  }

  static String? nameOf(Iterable<Product> products, String optionId) {
    for (final product in products) {
      for (final option in [...product.paracords, ...product.trinkets]) {
        if (option.id == optionId) return option.name;
      }
    }
    return null;
  }

  static String? shortage(Iterable<Product> products, Map<String, int> need) {
    for (final entry in need.entries) {
      if (of(products, entry.key) < entry.value) {
        final name = nameOf(products, entry.key) ?? 'that option';
        return 'Sorry, $name does not have enough left.';
      }
    }
    return null;
  }

  static List<Product> apply(
    Iterable<Product> products,
    Map<String, int> need, {
    required int sign,
  }) {
    if (need.isEmpty) return products.toList();
    final nextStocks = <String, int>{
      for (final entry in need.entries)
        entry.key: (of(products, entry.key) + sign * entry.value).clamp(0, 999999),
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
          updatedAt: now,
        ),
    ];
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
