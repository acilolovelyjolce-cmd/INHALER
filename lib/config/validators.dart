class Validators {
  static String? requiredField(String? value, {String label = 'This field'}) {
    if (value == null || value.trim().isEmpty) {
      return '$label is required';
    }
    return null;
  }

  static String? email(String? value) {
    final requiredError = requiredField(value, label: 'Email');
    if (requiredError != null) return requiredError;
    final v = value!.trim();
    if (!RegExp(r'^[^@]+@[^@]+\.[^@]+$').hasMatch(v)) {
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
    final parsed = double.tryParse(value!.replaceAll(',', '').trim());
    if (parsed == null || parsed < 0) return 'Enter a valid price';
    return null;
  }

  static String? optionalPrice(String? value) {
    if (value == null || value.trim().isEmpty) return null;
    return price(value);
  }

  static String? contact(String? value) {
    return requiredField(value, label: 'Contact');
  }

  static String? slug(String? value) {
    final requiredError = requiredField(value, label: 'Shop link');
    if (requiredError != null) return requiredError;
    if (!RegExp(r'^[a-z0-9]+(?:-[a-z0-9]+)*$').hasMatch(value!.trim())) {
      return 'Use lowercase letters, numbers, and hyphens';
    }
    return null;
  }
}
