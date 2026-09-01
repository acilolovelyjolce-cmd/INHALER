int _asInt(Object? value) {
  if (value is int) return value;
  if (value is num) return value.toInt();
  return int.tryParse(value?.toString() ?? '') ?? 0;
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
    final paracord = item['paracord'];
    if (paracord is Map) add(paracord['id'], qty);
    final trinkets = item['trinkets'];
    if (trinkets is List) {
      for (final trinket in trinkets) {
        if (trinket is Map) add(trinket['id'], qty);
      }
    }
  }
  return need;
}

int stockOf(Iterable<Map<String, dynamic>> products, String optionId) {
  for (final product in products) {
    for (final key in const ['paracords', 'trinkets']) {
      final list = product[key];
      if (list is! List) continue;
      for (final raw in list) {
        if (raw is Map && raw['id']?.toString() == optionId) {
          return _asInt(raw['stock']);
        }
      }
    }
  }
  return 0;
}

String? optionNameOf(Iterable<Map<String, dynamic>> products, String optionId) {
  for (final product in products) {
    for (final key in const ['paracords', 'trinkets']) {
      final list = product[key];
      if (list is! List) continue;
      for (final raw in list) {
        if (raw is Map && raw['id']?.toString() == optionId) {
          return raw['name']?.toString();
        }
      }
    }
  }
  return null;
}

String? shortageMessage(Iterable<Map<String, dynamic>> products, Map<String, int> need) {
  for (final entry in need.entries) {
    if (stockOf(products, entry.key) < entry.value) {
      final name = optionNameOf(products, entry.key) ?? 'that option';
      return 'Sorry, $name does not have enough left.';
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
              if (stocks.containsKey(raw['id']?.toString())) 'stock': stocks[raw['id'].toString()],
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
      entry.key: (stockOf(products, entry.key) + sign * entry.value).clamp(0, 999999),
  });
}

void syncOptionStockFrom(List<Map<String, dynamic>> products, Map<String, dynamic> source) {
  final stocks = <String, int>{};
  for (final key in const ['paracords', 'trinkets']) {
    final list = source[key];
    if (list is! List) continue;
    for (final raw in list) {
      if (raw is Map && raw['id'] != null) {
        stocks[raw['id'].toString()] = _asInt(raw['stock']);
      }
    }
  }
  _writeStocks(products, stocks);
}
