import 'dart:io';

class Env {
  static String get mongoUri =>
      Platform.environment['MONGODB_URI'] ?? '';

  static String get jwtSecret =>
      Platform.environment['JWT_SECRET'] ?? 'dev-only-change-me';

  static String get ownerEmail =>
      Platform.environment['OWNER_EMAIL'] ?? 'owner@whimsical.local';

  static String get ownerPassword =>
      Platform.environment['OWNER_PASSWORD'] ?? 'changeme';

  static String get shopName =>
      Platform.environment['SHOP_NAME'] ?? 'Whimsical';

  static String get shopSlug =>
      Platform.environment['SHOP_SLUG'] ?? 'whimsical';

  static String get ownerBio =>
      Platform.environment['OWNER_BIO'] ??
      'Hand-finished inhaler charms with tiny dinosaur keychains — made in small batches for pockets, bags, and little everyday joys.';

  static int get port {
    final raw = Platform.environment['PORT'] ?? '8080';
    return int.tryParse(raw) ?? 8080;
  }

  static String get webRoot =>
      Platform.environment['WEB_ROOT'] ?? 'build/web';

  static String get publicBaseUrl =>
      Platform.environment['PUBLIC_BASE_URL'] ?? '';
}
