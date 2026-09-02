class Validators {
  static final _zw = RegExp(r'[\u0000\u200b\u200c\u200d\ufeff]');
  static final _lineBreaks = RegExp(r'[\r\n\t\v\f]+');
  static final _multiSpace = RegExp(r' {2,}');
  static final _moneyJunk = RegExp(r'[₱,\s\u00a0\u1680\u2000-\u200a\u202f\u205f\u3000]');
  static final _currencyWord = RegExp(r'php', caseSensitive: false);

  static String cleanLine(String? value) {
    if (value == null) return '';
    return value
        .replaceAll(_zw, '')
        .replaceAll(_lineBreaks, ' ')
        .replaceAll(_multiSpace, ' ')
        .trim();
  }

  static String cleanMultiline(String? value) {
    if (value == null) return '';
    return value
        .replaceAll(_zw, '')
        .replaceAll('\r\n', '\n')
        .replaceAll('\r', '\n')
        .trim();
  }

  static String cleanMoney(String? value) {
    if (value == null) return '';
    var text = value.replaceAll(_zw, '').trim();
    text = text.replaceAll(_currencyWord, '');
    text = text.replaceAll('−', '-').replaceAll('–', '-').replaceAll('—', '-');
    text = text.replaceAll(_moneyJunk, '');
    return text;
  }

  static double? parseMoney(String? value, {bool allowNegative = false}) {
    final cleaned = cleanMoney(value);
    if (cleaned.isEmpty || cleaned == '-' || cleaned == '.' || cleaned == '-.') {
      return null;
    }
    if (cleaned.split('.').length > 2) return null;
    final parsed = double.tryParse(cleaned);
    if (parsed == null || !parsed.isFinite) return null;
    if (!allowNegative && parsed < 0) return null;
    if (parsed.abs() > 9999999) return null;
    return parsed;
  }

  static int? parseStock(String? value) {
    final cleaned = (value ?? '').replaceAll(_zw, '').replaceAll(RegExp(r'[\s,]'), '').trim();
    if (cleaned.isEmpty) return null;
    final parsed = int.tryParse(cleaned);
    if (parsed == null || parsed < 0 || parsed > 999999) return null;
    return parsed;
  }

  static String? requiredField(String? value, {String label = 'This field'}) {
    if (cleanLine(value).isEmpty) {
      return '$label is required';
    }
    return null;
  }

  static String? name(String? value, {String label = 'Name', int max = 80}) {
    final text = cleanLine(value);
    if (text.isEmpty) return '$label is required';
    if (text.length > max) return '$label is too long';
    return null;
  }

  static String? optionalText(String? value, {int max = 240, String label = 'This field'}) {
    final text = cleanMultiline(value);
    if (text.isEmpty) return null;
    if (text.length > max) return '$label is too long';
    return null;
  }

  static String? email(String? value) {
    final requiredError = requiredField(value, label: 'Email');
    if (requiredError != null) return requiredError;
    final v = cleanLine(value).toLowerCase();
    if (!RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(v)) {
      return 'Enter a valid email';
    }
    return null;
  }

  static String? password(String? value) {
    if (value == null || value.isEmpty) return 'Password is required';
    if (value.length < 6) return 'At least 6 characters';
    return null;
  }

  static String? price(String? value) {
    if (cleanLine(value).isEmpty) return 'Price is required';
    if (parseMoney(value) == null) return 'Enter a valid price';
    return null;
  }

  static String? optionalPrice(String? value) {
    if (cleanLine(value).isEmpty) return null;
    if (parseMoney(value) == null) return 'Enter a valid price';
    return null;
  }

  static String? signedAmount(String? value) {
    if (cleanLine(value).isEmpty) return 'Amount is required';
    if (parseMoney(value, allowNegative: true) == null) return 'Enter a valid amount';
    return null;
  }

  static String? stock(String? value) {
    if (cleanLine(value).isEmpty) return 'Left is required';
    if (parseStock(value) == null) return 'Enter a whole number';
    return null;
  }

  static String? contact(String? value) {
    final text = cleanLine(value);
    if (text.isEmpty) return 'Contact is required';
    if (text.length < 3) return 'Add a number or social we can reach';
    return null;
  }

  static String? contactKey(String? value) {
    final text = cleanLine(value);
    if (text.isEmpty) return null;
    if (text.startsWith(r'$') || text.contains('.')) {
      return 'Use letters without dots';
    }
    if (text.length > 40) return 'Too long';
    return null;
  }

  static String? slug(String? value) {
    final requiredError = requiredField(value, label: 'Shop link');
    if (requiredError != null) return requiredError;
    final v = cleanLine(value);
    if (v.length > 40) return 'Shop link is too long';
    if (!RegExp(r'^[a-z0-9]+(?:-[a-z0-9]+)*$').hasMatch(v)) {
      return 'Use lowercase letters, numbers, and hyphens';
    }
    return null;
  }
}
