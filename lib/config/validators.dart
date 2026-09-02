class Validators {
  static String? requiredField(String? value, {String label = 'This field'}) {
    if (value == null || value.trim().isEmpty) {
      return '$label is required';
    }
    return null;
  }

  static String? name(String? value, {String label = 'Name', int max = 80}) {
    final requiredError = requiredField(value, label: label);
    if (requiredError != null) return requiredError;
    if (value!.trim().length > max) return '$label is too long';
    return null;
  }

  static String? optionalText(String? value, {int max = 240, String label = 'This field'}) {
    if (value == null || value.trim().isEmpty) return null;
    if (value.trim().length > max) return '$label is too long';
    return null;
  }

  static String? email(String? value) {
    final requiredError = requiredField(value, label: 'Email');
    if (requiredError != null) return requiredError;
    final v = value!.trim();
    if (!RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(v)) {
      return 'Enter a valid email';
    }
    return null;
  }

  static String? password(String? value) {
    final requiredError = requiredField(value, label: 'Password');
    if (requiredError != null) return requiredError;
    if (value!.length < 6) return 'At least 6 characters';
    return null;
  }

  static String? price(String? value) {
    final requiredError = requiredField(value, label: 'Price');
    if (requiredError != null) return requiredError;
    return _money(value!, allowNegative: false, label: 'price');
  }

  static String? optionalPrice(String? value) {
    if (value == null || value.trim().isEmpty) return null;
    return _money(value, allowNegative: false, label: 'price');
  }

  static String? signedAmount(String? value) {
    final requiredError = requiredField(value, label: 'Amount');
    if (requiredError != null) return requiredError;
    return _money(value!, allowNegative: true, label: 'amount');
  }

  static String? stock(String? value) {
    final requiredError = requiredField(value, label: 'Left');
    if (requiredError != null) return requiredError;
    final parsed = int.tryParse(value!.trim());
    if (parsed == null || parsed < 0) return 'Enter a whole number';
    if (parsed > 999999) return 'That is too many';
    return null;
  }

  static String? contact(String? value) {
    final requiredError = requiredField(value, label: 'Contact');
    if (requiredError != null) return requiredError;
    if (value!.trim().length < 3) return 'Add a number or social we can reach';
    return null;
  }

  static String? slug(String? value) {
    final requiredError = requiredField(value, label: 'Shop link');
    if (requiredError != null) return requiredError;
    final v = value!.trim();
    if (v.length > 40) return 'Shop link is too long';
    if (!RegExp(r'^[a-z0-9]+(?:-[a-z0-9]+)*$').hasMatch(v)) {
      return 'Use lowercase letters, numbers, and hyphens';
    }
    return null;
  }

  static String? _money(String value, {required bool allowNegative, required String label}) {
    final cleaned = value.replaceAll(RegExp(r'[₱,\s]'), '').trim();
    if (cleaned.isEmpty) return 'Enter a valid $label';
    if (cleaned.split('.').length > 2) return 'Enter a valid $label';
    final parsed = double.tryParse(cleaned);
    if (parsed == null) return 'Enter a valid $label';
    if (!allowNegative && parsed < 0) return 'Enter a valid $label';
    if (parsed.abs() > 9999999) return 'That $label is too high';
    return null;
  }
}
