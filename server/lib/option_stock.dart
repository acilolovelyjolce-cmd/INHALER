int _asInt(Object? value) {
  if (value is int) return value;
  if (value is num) return value.toInt();
  return int.tryParse(value?.toString() ?? '') ?? 0;
}

String? _mapId(Object? raw) {
  if (raw is! Map) return null;
  final id = raw['id'] ?? raw['_id'];
  final key = id?.toString() ?? '';
  return key.isEmpty ? null : key;
}

String? _productId(Map<String, dynamic> product) {
  final id = product['_id'] ?? product['id'];
  final key = id?.toString() ?? '';
  return key.isEmpty ? null : key;
}

Map<String, int> neededFromItems(Object? items) {
  final need = <String, int>{};
  void add(Object? id, int qty) {
    final key = id?.toString() ?? '';
    if (key.isEmpty) return;
    need[key] = (need[key] ?? 0) + qty;
  }

  if (items is! List) return need;
  for (final raw in items) {
    if (raw is! Map) continue;
    final item = Map<Object?, Object?>.from(raw);
    final qty = _asInt(item['quantity'] ?? 1);
    add(_mapId(item['paracord']), qty);
    final trinkets = item['trinkets'];
    if (trinkets is List) {
      for (final trinket in trinkets) {
        add(_mapId(trinket), qty);
      }
    }
  }
  return need;
}

Map<String, int> neededProductsFromItems(Object? items) {
  final need = <String, int>{};
  if (items is! List) return need;
  for (final raw in items) {
    if (raw is! Map) continue;
    final item = Map<Object?, Object?>.from(raw);
    final id = item['product_id']?.toString() ?? '';
    if (id.isEmpty) continue;
    need[id] = (need[id] ?? 0) + _asInt(item['quantity'] ?? 1);
  }
  return need;
}

int? stockOf(Iterable<Map<String, dynamic>> products, String optionId) {
  for (final product in products) {
    for (final key in const ['paracords', 'trinkets']) {
      final list = product[key];
      if (list is! List) continue;
      for (final raw in list) {
        if (_mapId(raw) == optionId && raw is Map) {
          return _asInt(raw['stock']);
        }
      }
    }
  }
  return null;
}

String? optionNameOf(Iterable<Map<String, dynamic>> products, String optionId) {
  for (final product in products) {
    for (final key in const ['paracords', 'trinkets']) {
      final list = product[key];
      if (list is! List) continue;
      for (final raw in list) {
        if (_mapId(raw) == optionId && raw is Map) {
          return raw['name']?.toString();
        }
      }
    }
  }
  return null;
}

Map<String, dynamic>? productOf(Iterable<Map<String, dynamic>> products, String productId) {
  for (final product in products) {
    if (_productId(product) == productId) return product;
  }
  return null;
}

bool tracksInhalerStock(Map<String, dynamic> product) {
  if (product['stock_status']?.toString() == 'made_to_order') return false;
  return product.containsKey('stock') && product['stock'] != null;
}

int inhalerStockOf(Map<String, dynamic> product) {
  if (!tracksInhalerStock(product)) {
    return product['stock_status']?.toString() == 'sold_out' ? 0 : 999999;
  }
  return _asInt(product['stock']);
}

String? shortageMessage(Iterable<Map<String, dynamic>> products, Object? items) {
  final options = neededFromItems(items);
  for (final entry in options.entries) {
    final have = stockOf(products, entry.key);
    if (have == null) continue;
    if (have < entry.value) {
      final name = optionNameOf(products, entry.key) ?? 'that option';
      return 'Sorry, $name does not have enough left.';
    }
  }

  final inhalers = neededProductsFromItems(items);
  for (final entry in inhalers.entries) {
    final product = productOf(products, entry.key);
    if (product == null || !tracksInhalerStock(product)) continue;
    if (inhalerStockOf(product) < entry.value) {
      final name = product['name']?.toString();
      return 'Sorry, ${name == null || name.isEmpty ? 'that inhaler' : name} does not have enough left.';
    }
  }
  return null;
}

void _writeStocks(List<Map<String, dynamic>> products, Map<String, int> stocks) {
  if (stocks.isEmpty) return;
  for (final product in products) {
    for (final key in const ['paracords', 'trinkets']) {
      final list = product[key];
      if (list is! List) continue;
      product[key] = [
        for (final raw in list)
          if (raw is Map)
            {
              ...Map<String, dynamic>.from(raw),
              if (stocks.containsKey(_mapId(raw))) 'stock': stocks[_mapId(raw)],
            }
          else
            raw,
      ];
    }
  }
}

void applyOptionStock(
  List<Map<String, dynamic>> products,
  Map<String, int> need, {
  required int sign,
}) {
  if (need.isEmpty) return;
  _writeStocks(products, {
    for (final entry in need.entries)
      if (stockOf(products, entry.key) != null)
        entry.key: (stockOf(products, entry.key)! + sign * entry.value).clamp(0, 999999),
  });
}

void applyInhalerStock(
  List<Map<String, dynamic>> products,
  Map<String, int> need, {
  required int sign,
}) {
  if (need.isEmpty) return;
  for (final product in products) {
    final id = _productId(product);
    if (id == null || !need.containsKey(id)) continue;
    if (!tracksInhalerStock(product)) continue;
    final next = (inhalerStockOf(product) + sign * need[id]!).clamp(0, 999999);
    product['stock'] = next;
    final status = product['stock_status']?.toString();
    if (status == 'made_to_order') continue;
    if (next <= 0) {
      product['stock_status'] = 'sold_out';
    } else if (status == 'sold_out') {
      product['stock_status'] = 'available';
    }
  }
}

void applyOrderStock(
  List<Map<String, dynamic>> products,
  Object? items, {
  required int sign,
}) {
  applyOptionStock(products, neededFromItems(items), sign: sign);
  applyInhalerStock(products, neededProductsFromItems(items), sign: sign);
}

void syncOptionStockFrom(List<Map<String, dynamic>> products, Map<String, dynamic> source) {
  final stocks = <String, int>{};
  for (final key in const ['paracords', 'trinkets']) {
    final list = source[key];
    if (list is! List) continue;
    for (final raw in list) {
      final id = _mapId(raw);
      if (id != null && raw is Map) {
        stocks[id] = _asInt(raw['stock']);
      }
    }
  }
  _writeStocks(products, stocks);
}
