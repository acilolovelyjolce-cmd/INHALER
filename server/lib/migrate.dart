import 'package:bcrypt/bcrypt.dart';
import 'package:mongo_dart/mongo_dart.dart';
import 'package:uuid/uuid.dart';

import 'env.dart';
import 'mongo.dart';

const _uuid = Uuid();

Future<void> runMigrations() async {
  final mongo = Mongo.instance;
  final applied = await mongo.migrations.find().toList();
  final done = applied.map((row) => row['_id'] as String).toSet();

  final steps = <String, Future<void> Function()>{
    '001_indexes': _indexes,
    '002_seed_owner_and_catalog': _seedOwnerAndCatalog,
    '003_option_stock': _optionStock,
  };

  for (final entry in steps.entries) {
    if (done.contains(entry.key)) {
      stdoutLog('Migration ${entry.key} already applied');
      continue;
    }
    stdoutLog('Applying migration ${entry.key}');
    await entry.value();
    await mongo.migrations.insertOne({
      '_id': entry.key,
      'applied_at': DateTime.now().toUtc(),
    });
    stdoutLog('Applied migration ${entry.key}');
  }
}

Future<void> _indexes() async {
  final mongo = Mongo.instance;
  await mongo.owners.createIndex(keys: {'email': 1}, unique: true, name: 'owners_email_uq');
  await mongo.owners.createIndex(keys: {'shop_slug': 1}, unique: true, name: 'owners_slug_uq');
  await mongo.products.createIndex(keys: {'owner_id': 1, 'sort_order': 1}, name: 'products_owner_sort');
  await mongo.products.createIndex(keys: {'shop_slug': 1, 'is_published': 1}, name: 'products_slug_pub');
  await mongo.orders.createIndex(keys: {'shop_slug': 1, 'created_at': -1}, name: 'orders_slug_created');
}

Future<void> _seedOwnerAndCatalog() async {
  final mongo = Mongo.instance;
  final existing = await mongo.owners.findOne(where.eq('email', Env.ownerEmail.toLowerCase()));
  if (existing != null) {
    stdoutLog('Owner ${Env.ownerEmail} already exists — skipping catalog seed');
    return;
  }

  final ownerId = _uuid.v4();
  final now = DateTime.now().toUtc();
  await mongo.owners.insertOne({
    '_id': ownerId,
    'email': Env.ownerEmail.toLowerCase(),
    'password_hash': BCrypt.hashpw(Env.ownerPassword, BCrypt.gensalt()),
    'shop_name': Env.shopName,
    'shop_slug': Env.shopSlug,
    'bio': Env.ownerBio,
    'logo_url': null,
    'contact_info': {
      'instagram': '@whimsical.charms',
      'facebook': 'Whimsical Charms',
      'gcash': '09XX XXX XXXX',
    },
    'created_at': now,
    'updated_at': now,
  });

  final productCount = await mongo.products.count(where.eq('owner_id', ownerId));
  if (productCount > 0) return;

  await mongo.products.insertMany(_catalog(ownerId, Env.shopSlug, now));
  stdoutLog('Seeded owner ${Env.ownerEmail} and 4 catalog products');
}

List<Map<String, dynamic>> _catalog(String ownerId, String slug, DateTime now) {
  const paracords = [
    {'id': 'cord-mint', 'name': 'Mint paracord', 'price': 40, 'image_url': 'asset:assets/products/baby_rex.svg', 'stock': 8},
    {'id': 'cord-blush', 'name': 'Blush paracord', 'price': 40, 'image_url': 'asset:assets/products/pastel_ptero.svg', 'stock': 8},
    {'id': 'cord-sky', 'name': 'Sky paracord', 'price': 40, 'image_url': 'asset:assets/products/cloud_trice.svg', 'stock': 6},
  ];
  const trinkets = [
    {'id': 't-rex', 'name': 'Baby Rex', 'price': 80, 'image_url': 'asset:assets/products/baby_rex.svg', 'stock': 5},
    {'id': 't-stego', 'name': 'Sleepy Stego', 'price': 80, 'image_url': 'asset:assets/products/sleepy_stego.svg', 'stock': 5},
    {'id': 't-star', 'name': 'Tiny Star', 'price': 35, 'image_url': 'asset:assets/doodles/doodle_sparkle.svg', 'stock': 12},
    {'id': 't-heart', 'name': 'Heart charm', 'price': 35, 'image_url': 'asset:assets/doodles/doodle_heart.svg', 'stock': 12},
  ];

  Map<String, dynamic> product({
    required String id,
    required String name,
    required String description,
    required double price,
    double? compareAtPrice,
    required String asset,
    required String category,
    required String stockStatus,
    required int sortOrder,
  }) {
    return {
      '_id': id,
      'owner_id': ownerId,
      'shop_slug': slug,
      'name': name,
      'description': description,
      'price': price,
      'compare_at_price': compareAtPrice,
      'image_urls': ['asset:assets/products/$asset'],
      'category': category,
      'paracords': paracords,
      'trinkets': trinkets,
      'stock_status': stockStatus,
      'is_published': true,
      'sort_order': sortOrder,
      'created_at': now,
      'updated_at': now,
    };
  }

  return [
    product(
      id: 'p-baby-rex',
      name: 'Baby Rex Inhaler Keychain',
      description:
          'A mint-speckled rescue inhaler sleeve with a chubby baby T-rex charm. Clip it to a bag or keep it on the original case — the dino stays put.',
      price: 450,
      compareAtPrice: 520,
      asset: 'baby_rex.svg',
      category: 'Dino Series',
      stockStatus: 'available',
      sortOrder: 0,
    ),
    product(
      id: 'p-sleepy-stego',
      name: 'Sleepy Stego Puff',
      description:
          'Soft yolk enamel and a drowsy stegosaurus who would like you to take your puff, then nap. Slightly oversized charm, very huggable.',
      price: 480,
      asset: 'sleepy_stego.svg',
      category: 'Dino Series',
      stockStatus: 'made_to_order',
      sortOrder: 1,
    ),
    product(
      id: 'p-pastel-ptero',
      name: 'Pastel Ptero Set',
      description:
          'A matching pair: inhaler jacket plus a pterodactyl that actually flies (off your zipper). Lilac and petal, because of course.',
      price: 620,
      compareAtPrice: 690,
      asset: 'pastel_ptero.svg',
      category: 'Pastel Series',
      stockStatus: 'available',
      sortOrder: 2,
    ),
    product(
      id: 'p-cloud-trice',
      name: 'Cloud Trice Charm',
      description:
          'Sky-blue jacket, a triceratops with a cloud ruff, and a yolk star on the clip. Restocking soon — still worth a look.',
      price: 430,
      asset: 'cloud_trice.svg',
      category: 'Pastel Series',
      stockStatus: 'sold_out',
      sortOrder: 3,
    ),
  ];
}

Future<void> _optionStock() async {
  final rows = await Mongo.instance.products.find().toList();
  final now = DateTime.now().toUtc();
  for (final row in rows) {
    row.remove('variants');
    for (final key in const ['paracords', 'trinkets']) {
      final list = row[key];
      if (list is! List) continue;
      row[key] = [
        for (final raw in list)
          if (raw is Map)
            {
              ...Map<String, dynamic>.from(raw),
              'stock': (raw['stock'] as num?)?.toInt() ?? 0,
            }
          else
            raw,
      ];
    }
    row['updated_at'] = now;
    await Mongo.instance.products.replaceOne(where.eq('_id', row['_id']), row);
  }
}
