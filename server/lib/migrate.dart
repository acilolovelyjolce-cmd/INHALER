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
    '004_parts_catalog': _partsCatalog,
    '005_product_stock': _productStock,
    '006_letterings_and_special_trinkets': _letteringsAndSpecial,
    '007_ropes': _ropes,
    '008_part_sort_order': _partSortOrder,
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
  await mongo.parts.createIndex(keys: {'owner_id': 1, 'kind': 1}, name: 'parts_owner_kind');
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
    {'id': 'cord-mint', 'name': 'Mint paracord', 'price': 40, 'image_url': 'asset:assets/parts/cord_mint.svg', 'stock': 8},
    {'id': 'cord-blush', 'name': 'Blush paracord', 'price': 40, 'image_url': 'asset:assets/parts/cord_blush.svg', 'stock': 8},
    {'id': 'cord-sky', 'name': 'Sky paracord', 'price': 40, 'image_url': 'asset:assets/parts/cord_sky.svg', 'stock': 6},
  ];
  const trinkets = [
    {'id': 't-rex', 'name': 'Baby Rex', 'price': 80, 'image_url': 'asset:assets/parts/charm_rex.svg', 'stock': 5},
    {'id': 't-stego', 'name': 'Sleepy Stego', 'price': 80, 'image_url': 'asset:assets/parts/charm_stego.svg', 'stock': 5},
    {'id': 't-star', 'name': 'Tiny Star', 'price': 35, 'image_url': 'asset:assets/doodles/doodle_sparkle.svg', 'stock': 12},
    {'id': 't-heart', 'name': 'Heart charm', 'price': 35, 'image_url': 'asset:assets/doodles/doodle_heart.svg', 'stock': 12},
  ];
  const letterings = [
    {'id': 'l-a', 'name': 'Letter A', 'price': 25, 'image_url': 'asset:assets/doodles/doodle_sparkle.svg', 'stock': 20},
    {'id': 'l-m', 'name': 'Letter M', 'price': 25, 'image_url': 'asset:assets/doodles/doodle_cloud.svg', 'stock': 20},
  ];
  const specialTrinkets = [
    {'id': 's-pearl', 'name': 'Pearl Rex', 'price': 120, 'image_url': 'asset:assets/parts/charm_rex.svg', 'stock': 3},
    {'id': 's-gold', 'name': 'Gold Stego', 'price': 120, 'image_url': 'asset:assets/parts/charm_stego.svg', 'stock': 3},
  ];
  const ropes = [
    {'id': 'rope-gold', 'name': 'Gold rope', 'price': 30, 'image_url': 'asset:assets/parts/cord_blush.svg', 'stock': 10},
    {'id': 'rope-silver', 'name': 'Silver rope', 'price': 30, 'image_url': 'asset:assets/parts/cord_sky.svg', 'stock': 10},
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
      'letterings': letterings,
      'ropes': ropes,
      'special_trinkets': specialTrinkets,
      'stock': stockStatus == 'sold_out' ? 0 : 10,
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
    for (final key in const ['paracords', 'trinkets', 'letterings', 'ropes', 'special_trinkets']) {
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

Future<void> _partsCatalog() async {
  final mongo = Mongo.instance;
  await mongo.parts.createIndex(keys: {'owner_id': 1, 'kind': 1}, name: 'parts_owner_kind');
  final products = await mongo.products.find().toList();
  final now = DateTime.now().toUtc();
  final seen = <String>{};
  final docs = <Map<String, dynamic>>[];

  void take(String ownerId, String kind, Object? raw) {
    if (raw is! Map) return;
    final id = raw['id']?.toString() ?? '';
    if (id.isEmpty) return;
    final key = '$ownerId:$id';
    if (!seen.add(key)) return;
    docs.add({
      '_id': id,
      'owner_id': ownerId,
      'kind': kind,
      'name': raw['name'] ?? '',
      'price': raw['price'] ?? 0,
      'image_url': raw['image_url'],
      'stock': (raw['stock'] as num?)?.toInt() ?? 0,
      'created_at': now,
      'updated_at': now,
    });
  }

  for (final row in products) {
    final ownerId = row['owner_id']?.toString() ?? '';
    if (ownerId.isEmpty) continue;
    final cords = row['paracords'];
    if (cords is List) {
      for (final item in cords) {
        take(ownerId, 'paracord', item);
      }
    }
    final charms = row['trinkets'];
    if (charms is List) {
      for (final item in charms) {
        take(ownerId, 'trinket', item);
      }
    }
    final letters = row['letterings'];
    if (letters is List) {
      for (final item in letters) {
        take(ownerId, 'lettering', item);
      }
    }
    final ropeRows = row['ropes'];
    if (ropeRows is List) {
      for (final item in ropeRows) {
        take(ownerId, 'rope', item);
      }
    }
    final specials = row['special_trinkets'];
    if (specials is List) {
      for (final item in specials) {
        take(ownerId, 'special_trinket', item);
      }
    }
  }

  for (final doc in docs) {
    final existing = await mongo.parts.findOne(where.eq('_id', doc['_id']));
    if (existing == null) {
      await mongo.parts.insertOne(doc);
    }
  }
}

Future<void> _productStock() async {
  final rows = await Mongo.instance.products.find().toList();
  final now = DateTime.now().toUtc();
  for (final row in rows) {
    if (row.containsKey('stock') && row['stock'] != null) continue;
    final sold = row['stock_status']?.toString() == 'sold_out';
    row['stock'] = sold ? 0 : 10;
    row['updated_at'] = now;
    await Mongo.instance.products.replaceOne(where.eq('_id', row['_id']), row);
  }
}

Future<void> _letteringsAndSpecial() async {
  final mongo = Mongo.instance;
  final products = await mongo.products.find().toList();
  final now = DateTime.now().toUtc();
  final seen = <String>{};
  for (final part in await mongo.parts.find().toList()) {
    final ownerId = part['owner_id']?.toString() ?? '';
    final id = part['_id']?.toString() ?? '';
    if (ownerId.isNotEmpty && id.isNotEmpty) seen.add('$ownerId:$id');
  }

  final docs = <Map<String, dynamic>>[];
  void take(String ownerId, String kind, Object? raw) {
    if (raw is! Map) return;
    final id = raw['id']?.toString() ?? '';
    if (id.isEmpty) return;
    if (!seen.add('$ownerId:$id')) return;
    docs.add({
      '_id': id,
      'owner_id': ownerId,
      'kind': kind,
      'name': raw['name'] ?? '',
      'price': raw['price'] ?? 0,
      'image_url': raw['image_url'],
      'stock': (raw['stock'] as num?)?.toInt() ?? 0,
      'created_at': now,
      'updated_at': now,
    });
  }

  for (final row in products) {
    var changed = false;
    if (row['letterings'] is! List) {
      row['letterings'] = <Map<String, dynamic>>[];
      changed = true;
    }
    if (row['special_trinkets'] is! List) {
      row['special_trinkets'] = <Map<String, dynamic>>[];
      changed = true;
    }
    if (changed) {
      row['updated_at'] = now;
      await mongo.products.replaceOne(where.eq('_id', row['_id']), row);
    }

    final ownerId = row['owner_id']?.toString() ?? '';
    if (ownerId.isEmpty) continue;
    final letters = row['letterings'];
    if (letters is List) {
      for (final item in letters) {
        take(ownerId, 'lettering', item);
      }
    }
    final ropeRows = row['ropes'];
    if (ropeRows is List) {
      for (final item in ropeRows) {
        take(ownerId, 'rope', item);
      }
    }
    final specials = row['special_trinkets'];
    if (specials is List) {
      for (final item in specials) {
        take(ownerId, 'special_trinket', item);
      }
    }
  }

  for (final doc in docs) {
    final existing = await mongo.parts.findOne(where.eq('_id', doc['_id']));
    if (existing == null) {
      await mongo.parts.insertOne(doc);
    }
  }
}

Future<void> _ropes() async {
  final mongo = Mongo.instance;
  final products = await mongo.products.find().toList();
  final now = DateTime.now().toUtc();
  final seen = <String>{};
  for (final part in await mongo.parts.find().toList()) {
    final ownerId = part['owner_id']?.toString() ?? '';
    final id = part['_id']?.toString() ?? '';
    if (ownerId.isNotEmpty && id.isNotEmpty) seen.add('$ownerId:$id');
  }

  final docs = <Map<String, dynamic>>[];
  void take(String ownerId, Object? raw) {
    if (raw is! Map) return;
    final id = raw['id']?.toString() ?? '';
    if (id.isEmpty) return;
    if (!seen.add('$ownerId:$id')) return;
    docs.add({
      '_id': id,
      'owner_id': ownerId,
      'kind': 'rope',
      'name': raw['name'] ?? '',
      'price': raw['price'] ?? 0,
      'image_url': raw['image_url'],
      'stock': (raw['stock'] as num?)?.toInt() ?? 0,
      'created_at': now,
      'updated_at': now,
    });
  }

  for (final row in products) {
    if (row['ropes'] is! List) {
      row['ropes'] = <Map<String, dynamic>>[];
      row['updated_at'] = now;
      await mongo.products.replaceOne(where.eq('_id', row['_id']), row);
    }
    final ownerId = row['owner_id']?.toString() ?? '';
    if (ownerId.isEmpty) continue;
    final ropes = row['ropes'];
    if (ropes is List) {
      for (final item in ropes) {
        take(ownerId, item);
      }
    }
  }

  for (final doc in docs) {
    final existing = await mongo.parts.findOne(where.eq('_id', doc['_id']));
    if (existing == null) {
      await mongo.parts.insertOne(doc);
    }
  }
}

Future<void> _partSortOrder() async {
  final mongo = Mongo.instance;
  final now = DateTime.now().toUtc();
  final grouped = <String, List<Map<String, dynamic>>>{};
  for (final part in await mongo.parts.find().toList()) {
    final ownerId = part['owner_id']?.toString() ?? '';
    final kind = part['kind']?.toString() ?? 'paracord';
    grouped.putIfAbsent('$ownerId:$kind', () => []).add(part);
  }
  for (final rows in grouped.values) {
    rows.sort((a, b) {
      final aOrder = (a['sort_order'] as num?)?.toInt();
      final bOrder = (b['sort_order'] as num?)?.toInt();
      if (aOrder != null && bOrder != null && aOrder != bOrder) {
        return aOrder.compareTo(bOrder);
      }
      return (a['name']?.toString() ?? '').toLowerCase().compareTo(
            (b['name']?.toString() ?? '').toLowerCase(),
          );
    });
    for (var i = 0; i < rows.length; i++) {
      rows[i]['sort_order'] = i;
      rows[i]['updated_at'] = now;
      await mongo.parts.replaceOne(where.eq('_id', rows[i]['_id']), rows[i]);
    }
  }
}
