class BadRequest implements Exception {
  BadRequest(this.message);
  final String message;

  @override
  String toString() => message;
}

final _zw = RegExp(r'[\u0000\u200b\u200c\u200d\ufeff]');
final _lineBreaks = RegExp(r'[\r\n\t\v\f]+');
final _multiSpace = RegExp(r' {2,}');
final _moneyJunk = RegExp(r'[₱,\s\u00a0\u1680\u2000-\u200a\u202f\u205f\u3000]');
final _currencyWord = RegExp(r'php', caseSensitive: false);

String asString(Object? value) {
  if (value == null) return '';
  if (value is String) return value;
  if (value is num || value is bool) return value.toString();
  return '';
}

String cleanLine(Object? value, {int max = 200}) {
  var text = asString(value)
      .replaceAll(_zw, '')
      .replaceAll(_lineBreaks, ' ')
      .replaceAll(_multiSpace, ' ')
      .trim();
  if (text.length > max) text = text.substring(0, max);
  return text;
}

String cleanMultiline(Object? value, {int max = 4000}) {
  var text = asString(value)
      .replaceAll(_zw, '')
      .replaceAll('\r\n', '\n')
      .replaceAll('\r', '\n')
      .trim();
  if (text.length > max) text = text.substring(0, max);
  return text;
}

String? cleanOptional(Object? value, {int max = 600, bool multiline = false}) {
  final text = multiline ? cleanMultiline(value, max: max) : cleanLine(value, max: max);
  return text.isEmpty ? null : text;
}

double? parseMoney(Object? value, {bool allowNegative = false}) {
  if (value is num) {
    final parsed = value.toDouble();
    if (!parsed.isFinite) return null;
    if (!allowNegative && parsed < 0) return null;
    if (parsed.abs() > 9999999) return null;
    return parsed;
  }
  var text = asString(value).replaceAll(_zw, '').trim();
  if (text.isEmpty) return null;
  text = text.replaceAll(_currencyWord, '');
  text = text.replaceAll('−', '-').replaceAll('–', '-').replaceAll('—', '-');
  text = text.replaceAll(_moneyJunk, '');
  if (text.isEmpty || text == '-' || text == '.' || text == '-.') return null;
  if (text.split('.').length > 2) return null;
  final parsed = double.tryParse(text);
  if (parsed == null || !parsed.isFinite) return null;
  if (!allowNegative && parsed < 0) return null;
  if (parsed.abs() > 9999999) return null;
  return parsed;
}

int parseInt(Object? value, {int fallback = 0, int min = 0, int max = 999999}) {
  int? parsed;
  if (value is int) {
    parsed = value;
  } else if (value is num) {
    parsed = value.toInt();
  } else {
    final text = asString(value).replaceAll(_zw, '').replaceAll(RegExp(r'[\s,]'), '').trim();
    parsed = int.tryParse(text);
  }
  if (parsed == null) return fallback;
  if (parsed < min) return min;
  if (parsed > max) return max;
  return parsed;
}

bool parseBool(Object? value, {bool fallback = false}) {
  if (value is bool) return value;
  if (value is num) return value != 0;
  final text = asString(value).trim().toLowerCase();
  if (text == 'true' || text == '1' || text == 'yes') return true;
  if (text == 'false' || text == '0' || text == 'no') return false;
  return fallback;
}

String parseId(Object? value, {required String Function() orElse}) {
  final text = asString(value).trim();
  return text.isEmpty ? orElse() : text;
}

List<String> parseStringList(Object? value) {
  if (value is! List) return const [];
  return [
    for (final item in value)
      if (asString(item).trim().isNotEmpty) asString(item).trim(),
  ];
}

List<Map<String, dynamic>> parseOptions(Object? value) {
  if (value is! List) return const [];
  final out = <Map<String, dynamic>>[];
  for (final raw in value) {
    if (raw is! Map) continue;
    final id = cleanLine(raw['id'], max: 80);
    final name = cleanLine(raw['name'], max: 80);
    if (id.isEmpty || name.isEmpty) continue;
    final image = cleanLine(raw['image_url'] ?? raw['imageUrl'], max: 500);
    out.add({
      'id': id,
      'name': name,
      'price': parseMoney(raw['price']) ?? 0,
      'image_url': image.isEmpty ? null : image,
      'stock': parseInt(raw['stock']),
    });
  }
  return out;
}

Map<String, String> parseContact(Object? value) {
  if (value is! Map) return {};
  final out = <String, String>{};
  value.forEach((key, val) {
    final k = cleanLine(key, max: 40);
    if (k.isEmpty || k.startsWith(r'$') || k.contains('.')) return;
    out[k] = cleanLine(val, max: 120);
  });
  return out;
}

String parseStockStatus(Object? value, {String fallback = 'available'}) {
  return switch (asString(value).trim()) {
    'made_to_order' || 'sold_out' || 'available' => asString(value).trim(),
    _ => fallback,
  };
}
