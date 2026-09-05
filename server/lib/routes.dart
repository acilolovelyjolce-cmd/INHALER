import 'dart:io';
import 'dart:typed_data';

import 'package:mongo_dart/mongo_dart.dart';
import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';
import 'package:uuid/uuid.dart';

import 'auth.dart';
import 'env.dart';
import 'fields.dart';
import 'http_util.dart';
import 'mongo.dart';
import 'option_stock.dart';

const _uuid = Uuid();

Router buildRouter() {
  final router = Router()
    ..get('/api/health', _health)
    ..post('/api/auth/login', _login)
    ..get('/api/shops/<slug>', _shop)
    ..get('/api/shops/<slug>/products', _publishedProducts)
    ..get('/api/shops/<slug>/share-image', _shareImage)
    ..get('/api/shop', _defaultShop)
    ..post('/api/shops/<slug>/orders', _submitOrder)
    ..get('/api/me', _me)
    ..put('/api/me', _updateMe)
    ..post('/api/me/logo', _uploadLogo)
    ..post('/api/me/ewallet-qr', _uploadWalletQr)
    ..get('/api/products', _myProducts)
    ..post('/api/products', _upsertProduct)
    ..put('/api/products/<id>', _upsertProduct)
    ..delete('/api/products/<id>', _deleteProduct)
    ..post('/api/products/reorder', _reorder)
    ..post('/api/products/bulk-price', _bulkPrice)
    ..post('/api/products/delete-category', _deleteCategory)
    ..get('/api/orders', _myOrders)
    ..put('/api/orders/<id>', _updateOrder)
    ..delete('/api/orders/<id>', _deleteOrder)
    ..get('/api/parts', _myParts)
    ..put('/api/parts/<id>', _upsertPart)
    ..delete('/api/parts/<id>', _deletePart)
    ..post('/api/parts/reorder', _reorderParts)
    ..post('/api/files', _uploadFile)
    ..get('/api/files/<id>', _getFile);
  return router;
}

Future<Response> _health(Request request) async {
  return jsonOk({
    'ok': true,
    'db': Mongo.instance.db.databaseName,
    'time': DateTime.now().toUtc().toIso8601String(),
  });
}

Future<Response> _login(Request request) async {
  final body = await readJson(request);
  final email = cleanLine(body['email']).toLowerCase();
  final password = asString(body['password']);
  if (email.isEmpty || password.isEmpty) {
    return jsonError(400, 'Email and password are required');
  }
  final owner = await Mongo.instance.owners.findOne(where.eq('email', email));
  if (owner == null || !passwordMatches(password, asString(owner['password_hash']))) {
    return jsonError(401, 'Could not sign in. Check your email and password.');
  }
  return jsonOk({
    'token': signOwner(owner),
    'user': apiDoc(owner),
  });
}

Future<Response> _shop(Request request) async {
  final slug = request.params['slug']!;
  final owner = await findPublicOwner(slug);
  if (owner == null) return jsonError(404, 'Shop not found');
  return jsonOk(_shopPayload(owner, slug));
}

Future<Response> _defaultShop(Request request) async {
  final owner = await findPublicOwner(Env.shopSlug);
  if (owner == null) return jsonError(404, 'Shop not found');
  return jsonOk(_shopPayload(owner, owner['shop_slug']?.toString() ?? Env.shopSlug));
}

Map<String, dynamic> _shopPayload(Map<String, dynamic> owner, String slug) {
  final doc = apiDoc(owner);
  return {
    'id': doc['id']?.toString() ?? '',
    'shop_name': doc['shop_name'] ?? 'Whimsical',
    'shop_slug': doc['shop_slug'] ?? slug,
    'bio': doc['bio'],
    'headline': doc['headline'],
    'logo_url': doc['logo_url'],
    'ewallet_qr_url': doc['ewallet_qr_url'],
    'contact_info': doc['contact_info'] is Map ? doc['contact_info'] : <String, String>{},
    'catalog_sort': parseCatalogSort(doc['catalog_sort']),
  };
}

Future<Map<String, dynamic>?> findPublicOwner(String? slug) async {
  final wanted = (slug ?? '').trim();
  if (wanted.isNotEmpty) {
    final exact = await Mongo.instance.owners.findOne(where.eq('shop_slug', wanted));
    if (exact != null) return exact;
  }
  if (Env.shopSlug.isNotEmpty && Env.shopSlug != wanted) {
    final seeded = await Mongo.instance.owners.findOne(where.eq('shop_slug', Env.shopSlug));
    if (seeded != null) return seeded;
  }
  final all = await Mongo.instance.owners.find().toList();
  if (all.isEmpty) return null;
  return all.first;
}

bool _publishedFlag(Object? value) {
  if (value == false || value == 'false' || value == 0 || value == '0') return false;
  return true;
}

Future<List<Map<String, dynamic>>> _productsForOwner(Object ownerId) async {
  var rows = await Mongo.instance.products.find(where.eq('owner_id', ownerId)).toList();
  if (rows.isEmpty) {
    final asText = asString(ownerId);
    if (asText.isNotEmpty && asText != ownerId) {
      rows = await Mongo.instance.products.find(where.eq('owner_id', asText)).toList();
    }
  }
  return rows;
}

Future<List<Map<String, dynamic>>> _catalogForOwner(Object ownerId, {String? slug}) async {
  var rows = await _productsForOwner(ownerId);
  if (rows.isEmpty && slug != null && slug.isNotEmpty) {
    rows = await Mongo.instance.products.find(where.eq('shop_slug', slug)).toList();
  }
  return rows;
}

Future<Response> _publishedProducts(Request request) async {
  final slug = request.params['slug']!;
  final owner = await findPublicOwner(slug);
  if (owner == null) return jsonOk(<Map<String, dynamic>>[]);
  var rows = await _productsForOwner(owner['_id'] as Object);
  if (rows.isEmpty) {
    rows = await Mongo.instance.products.find(where.eq('shop_slug', slug)).toList();
  }
  final published = [
    for (final row in rows)
      if (_publishedFlag(row['is_published'])) row,
  ];
  final sort = parseCatalogSort(owner['catalog_sort']);
  published.sort((a, b) => compareCatalogRows(
        Map<String, dynamic>.from(a),
        Map<String, dynamic>.from(b),
        sort,
      ));
  final encoded = <Map<String, dynamic>>[];
  for (final row in published) {
    try {
      encoded.add(apiDoc(applyCatalogSortToProductRow(Map<String, dynamic>.from(row), sort)));
    } catch (error, stack) {
      stderr.writeln('[whimsical] skip product ${row['_id']}: $error\n$stack');
    }
  }
  return jsonOk(encoded);
}

Future<Response> _submitOrder(Request request) async {
  final slug = request.params['slug']!;
  final shop = await findPublicOwner(slug);
  if (shop == null) return jsonError(404, 'Shop not found');

  final body = await readJson(request);
  if (cleanLine(body['honeypot']).isNotEmpty) {
    return jsonOk({'id': 'honeypot', 'ok': true});
  }

  final now = DateTime.now().toUtc();
  final shopSlug = shop['shop_slug']?.toString() ?? slug;
  final doc = {
    '_id': _uuid.v4(),
    'shop_slug': shopSlug,
    'customer_name': cleanLine(body['customer_name'], max: 80),
    'customer_contact': cleanLine(body['customer_contact'], max: 80),
    'items': body['items'] is List ? body['items'] : [],
    'total_amount': parseMoney(body['total_amount']) ?? 0,
    'customer_note': cleanOptional(body['customer_note'], max: 600, multiline: true),
    'status': 'new_request',
    'payment_status': 'unpaid',
    'payment_method': cleanOptional(body['payment_method'], max: 40),
    'internal_notes': null,
    'created_at': now,
    'updated_at': now,
  };
  if ((doc['customer_name'] as String).isEmpty ||
      (doc['customer_contact'] as String).isEmpty) {
    return jsonError(400, 'Name and contact are required');
  }

  final products = await _catalogForOwner(shop['_id'] as Object, slug: shopSlug);
  final shortage = shortageMessage(products, doc['items']);
  if (shortage != null) return jsonError(409, shortage);
  applyOrderStock(products, doc['items'], sign: -1);
  await _persistProducts(products);
  await _writePartStocks(shop['_id'], products);

  await Mongo.instance.orders.insertOne(doc);
  return jsonOk(apiDoc(doc), status: 201);
}

Future<Response> _shareImage(Request request) async {
  final slug = request.params['slug']!;
  final owner = await findPublicOwner(slug);
  final logo = owner?['logo_url']?.toString() ?? '';
  final fileId = RegExp(r'/api/files/([a-fA-F0-9]+)').firstMatch(logo)?.group(1);
  if (fileId != null) return _fileById(fileId);
  if (logo.startsWith('https://') || logo.startsWith('http://')) {
    return Response.seeOther(logo);
  }
  return _fallbackShareIcon();
}

Future<Response> _me(Request request) async {
  final owner = await ownerFromRequest(request);
  if (owner == null) return jsonError(401, 'Sign in required');
  return jsonOk(apiDoc(owner));
}

Future<Response> _updateMe(Request request) async {
  final owner = await ownerFromRequest(request);
  if (owner == null) return jsonError(401, 'Sign in required');
  final body = await readJson(request);
  final now = DateTime.now().toUtc();
  final slug = cleanLine(body['shop_slug'] ?? owner['shop_slug'], max: 40).toLowerCase();
  if (slug.isEmpty || !RegExp(r'^[a-z0-9]+(?:-[a-z0-9]+)*$').hasMatch(slug)) {
    return jsonError(400, 'Use lowercase letters, numbers, and hyphens for the shop link');
  }
  final shopName = cleanLine(body['shop_name'] ?? owner['shop_name'], max: 80);
  if (shopName.isEmpty) return jsonError(400, 'Name is required');
  final fields = {
    'shop_name': shopName,
    'shop_slug': slug,
    'bio': cleanOptional(body.containsKey('bio') ? body['bio'] : owner['bio'], max: 600, multiline: true),
    'headline': cleanOptional(
      body.containsKey('headline') ? body['headline'] : owner['headline'],
      max: 80,
    ),
    'logo_url': body.containsKey('logo_url') ? body['logo_url'] : owner['logo_url'],
    'ewallet_qr_url': body.containsKey('ewallet_qr_url') ? body['ewallet_qr_url'] : owner['ewallet_qr_url'],
    'contact_info': body.containsKey('contact_info')
        ? parseContact(body['contact_info'])
        : parseContact(owner['contact_info']),
    'catalog_sort': parseCatalogSort(
      body.containsKey('catalog_sort') ? body['catalog_sort'] : owner['catalog_sort'],
    ),
    'updated_at': now,
  };
  try {
    await mongoSet(Mongo.instance.owners, owner['_id'], fields);
  } catch (error, stack) {
    stderr.writeln('[whimsical] update me: $error\n$stack');
    await mongoUpsert(Mongo.instance.owners, owner['_id'], {
      ...bsonMap(Map<String, dynamic>.from(owner)),
      ...fields,
      '_id': owner['_id'],
    });
  }
  if (slug != owner['shop_slug']) {
    final products = await _productsForOwner(owner['_id'] as Object);
    for (final product in products) {
      final id = product['_id'];
      if (id == null) continue;
      try {
        await mongoSet(Mongo.instance.products, id, {
          'shop_slug': slug,
          'updated_at': now,
        });
      } catch (error, stack) {
        stderr.writeln('[whimsical] update shop slug on $id: $error\n$stack');
      }
    }
  }
  final saved = await Mongo.instance.owners.findOne(where.eq('_id', owner['_id']));
  return jsonOk(apiDoc(Map<String, dynamic>.from(saved ?? {...owner, ...fields})));
}

Future<Response> _uploadLogo(Request request) async {
  final owner = await ownerFromRequest(request);
  if (owner == null) return jsonError(401, 'Sign in required');
  final bytes = await _readBytes(request);
  if (bytes.isEmpty) return jsonError(400, 'That photo was empty.');
  final url = await _storeFile(bytes, contentType: request.mimeType ?? 'image/jpeg');
  final next = {...owner, 'logo_url': url, 'updated_at': DateTime.now().toUtc()};
  await Mongo.instance.owners.replaceOne(where.eq('_id', owner['_id']), next);
  return jsonOk({'url': url, 'user': apiDoc(next)});
}

Future<Response> _uploadWalletQr(Request request) async {
  final owner = await ownerFromRequest(request);
  if (owner == null) return jsonError(401, 'Sign in required');
  final bytes = await _readBytes(request);
  if (bytes.isEmpty) return jsonError(400, 'That photo was empty.');
  final url = await _storeFile(bytes, contentType: request.mimeType ?? 'image/jpeg');
  final next = {...owner, 'ewallet_qr_url': url, 'updated_at': DateTime.now().toUtc()};
  await Mongo.instance.owners.replaceOne(where.eq('_id', owner['_id']), next);
  return jsonOk({'url': url, 'user': apiDoc(next)});
}

Future<Response> _myProducts(Request request) async {
  final owner = await ownerFromRequest(request);
  if (owner == null) return jsonError(401, 'Sign in required');
  final rows = await _productsForOwner(owner['_id'] as Object);
  final sort = parseCatalogSort(owner['catalog_sort']);
  rows.sort((a, b) => compareCatalogRows(
        Map<String, dynamic>.from(a),
        Map<String, dynamic>.from(b),
        sort,
      ));
  return jsonOk([
    for (final row in rows) apiDoc(applyCatalogSortToProductRow(Map<String, dynamic>.from(row), sort)),
  ]);
}

Future<Response> _upsertProduct(Request request) async {
  final owner = await ownerFromRequest(request);
  if (owner == null) return jsonError(401, 'Sign in required');
  final body = await readJson(request);
  final now = DateTime.now().toUtc();
  final id = parseId(request.params['id'] ?? body['id'], orElse: _uuid.v4);
  final existing = await Mongo.instance.products.findOne(where.eq('_id', id));
  if (existing != null && !sameId(existing['owner_id'], owner['_id'])) {
    return jsonError(403, 'Not your product');
  }
  final name = cleanLine(body['name'] ?? existing?['name'], max: 80);
  if (name.isEmpty) return jsonError(400, 'Name is required');
  final doc = {
    '_id': id,
    'owner_id': owner['_id'],
    'shop_slug': owner['shop_slug'],
    'name': name,
    'description': cleanMultiline(body['description'] ?? existing?['description'], max: 600),
    'price': parseMoney(body['price'] ?? existing?['price']) ?? 0,
    'compare_at_price': parseMoney(body['compare_at_price'] ?? existing?['compare_at_price']),
    'image_urls': parseStringList(body['image_urls'] ?? existing?['image_urls']),
    'category': '',
    'paracords': <Map<String, dynamic>>[],
    'trinkets': <Map<String, dynamic>>[],
    'letterings': <Map<String, dynamic>>[],
    'ropes': <Map<String, dynamic>>[],
    'special_trinkets': <Map<String, dynamic>>[],
    'stock': parseInt(body['stock'] ?? existing?['stock']),
    'stock_status': parseStockStatus(
      body['stock_status'] ?? existing?['stock_status'],
    ),
    'is_published': parseBool(body['is_published'] ?? existing?['is_published'], fallback: false),
    'sort_order': parseInt(body['sort_order'] ?? existing?['sort_order'], fallback: 99, max: 99999),
    'created_at': parseDate(existing?['created_at'] ?? body['created_at'], fallback: now),
    'updated_at': now,
  };
  final options = await _partOptions(owner['_id']);
  if (options.hasAny) {
    doc.addAll(options.productFields);
  } else {
    doc['paracords'] = parseOptions(body['paracords'] ?? existing?['paracords']);
    doc['trinkets'] = parseOptions(body['trinkets'] ?? existing?['trinkets']);
    doc['letterings'] = parseOptions(body['letterings'] ?? existing?['letterings']);
    doc['ropes'] = parseOptions(body['ropes'] ?? existing?['ropes']);
    doc['special_trinkets'] =
        parseOptions(body['special_trinkets'] ?? existing?['special_trinkets']);
  }
  final stock = parseInt(doc['stock']);
  var status = doc['stock_status']?.toString() ?? 'available';
  if (status != 'made_to_order') {
    if (stock <= 0) {
      status = 'sold_out';
    } else if (status == 'sold_out') {
      status = 'available';
    }
  }
  doc['stock'] = stock;
  doc['stock_status'] = status;
  try {
    await mongoUpsert(Mongo.instance.products, id, doc);
  } catch (error, stack) {
    stderr.writeln('[whimsical] upsert product $id: $error\n$stack');
    throw BadRequest('Could not save that inhaler. Check the fields and try again.');
  }
  return jsonOk(apiDoc(doc));
}

Future<Response> _deleteProduct(Request request) async {
  final owner = await ownerFromRequest(request);
  if (owner == null) return jsonError(401, 'Sign in required');
  final id = request.params['id']!;
  final existing = await Mongo.instance.products.findOne(where.eq('_id', id));
  if (existing == null) return jsonError(404, 'Not found');
  if (!sameId(existing['owner_id'], owner['_id'])) return jsonError(403, 'Not your product');
  await Mongo.instance.products.deleteOne(where.eq('_id', id));
  return jsonOk({'ok': true});
}

Future<Response> _reorder(Request request) async {
  final owner = await ownerFromRequest(request);
  if (owner == null) return jsonError(401, 'Sign in required');
  final body = await readJson(request);
  final ids = (body['ids'] as List? ?? []).map((e) => e.toString()).toList();
  final now = DateTime.now().toUtc();
  if (body.containsKey('catalog_sort')) {
    try {
      await mongoSet(Mongo.instance.owners, owner['_id'], {
        'catalog_sort': parseCatalogSort(body['catalog_sort']),
        'updated_at': now,
      });
    } catch (error, stack) {
      stderr.writeln('[whimsical] reorder catalog sort: $error\n$stack');
    }
  }
  await mapInBatches(List<int>.generate(ids.length, (i) => i), (i) async {
    await Mongo.instance.products.update(
      where.eq('_id', ids[i]).eq('owner_id', owner['_id']),
      modify.set('sort_order', i).set('updated_at', now),
    );
  });
  return jsonOk({'ok': true});
}

Future<Response> _bulkPrice(Request request) async {
  final owner = await ownerFromRequest(request);
  if (owner == null) return jsonError(401, 'Sign in required');
  final body = await readJson(request);
  final percent = parseBool(body['percent'], fallback: true);
  final amount = parseMoney(body['amount'], allowNegative: true) ?? 0;
  final now = DateTime.now().toUtc();
  final query = where.eq('owner_id', owner['_id']);
  final rows = await Mongo.instance.products.find(query).toList();
  for (final row in rows) {
    final price = parseMoney(row['price']) ?? 0;
    final next = percent ? price * (1 + amount / 100) : price + amount;
    row['price'] = next < 0 ? 0 : next;
    row['updated_at'] = now;
    await Mongo.instance.products.replaceOne(where.eq('_id', row['_id']), row);
  }
  return jsonOk({'ok': true});
}

Future<Response> _deleteCategory(Request request) async {
  final owner = await ownerFromRequest(request);
  if (owner == null) return jsonError(401, 'Sign in required');
  final body = await readJson(request);
  final category = cleanLine(body['category'], max: 80);
  if (category.isEmpty) return jsonError(400, 'Category is required');
  final rows = await Mongo.instance.products
      .find(where.eq('owner_id', owner['_id']).eq('category', category))
      .toList();
  for (final row in rows) {
    await Mongo.instance.products.deleteOne(where.eq('_id', row['_id']));
  }
  return jsonOk({'ok': true, 'deleted': rows.length});
}

Future<Response> _myOrders(Request request) async {
  final owner = await ownerFromRequest(request);
  if (owner == null) return jsonError(401, 'Sign in required');
  final rows = await Mongo.instance.orders.find(where.eq('shop_slug', owner['shop_slug'])).toList();
  rows.sort((a, b) => parseDate(b['created_at']).compareTo(parseDate(a['created_at'])));
  return jsonOk([
    for (final row in rows) apiDoc(Map<String, dynamic>.from(row)),
  ]);
}

Future<Response> _updateOrder(Request request) async {
  final owner = await ownerFromRequest(request);
  if (owner == null) return jsonError(401, 'Sign in required');
  final id = request.params['id']!;
  final existing = await Mongo.instance.orders.findOne(where.eq('_id', id));
  if (existing == null) return jsonError(404, 'Not found');
  if (existing['shop_slug'] != owner['shop_slug']) {
    return jsonError(403, 'Not your order');
  }
  final body = await readJson(request);
  final previousStatus = existing['status']?.toString() ?? '';
  final nextStatus = body.containsKey('status')
      ? cleanLine(body['status'], max: 40)
      : previousStatus;
  final nextItems = body.containsKey('items') && body['items'] is List
      ? body['items']
      : existing['items'];
  final customerName = body.containsKey('customer_name')
      ? cleanLine(body['customer_name'], max: 80)
      : asString(existing['customer_name']);
  final customerContact = body.containsKey('customer_contact')
      ? cleanLine(body['customer_contact'], max: 80)
      : asString(existing['customer_contact']);
  if (customerName.isEmpty || customerContact.isEmpty) {
    return jsonError(400, 'Name and contact are required');
  }
  final next = {
    ...existing,
    'customer_name': customerName,
    'customer_contact': customerContact,
    'customer_note': body.containsKey('customer_note')
        ? cleanOptional(body['customer_note'], max: 600, multiline: true)
        : existing['customer_note'],
    'items': nextItems,
    'total_amount': body.containsKey('total_amount')
        ? parseMoney(body['total_amount']) ?? existing['total_amount']
        : existing['total_amount'],
    'status': body.containsKey('status') ? cleanLine(body['status'], max: 40) : existing['status'],
    'payment_status': body.containsKey('payment_status')
        ? cleanLine(body['payment_status'], max: 40)
        : existing['payment_status'],
    'payment_method': body.containsKey('payment_method')
        ? cleanOptional(body['payment_method'], max: 40)
        : existing['payment_method'],
    'internal_notes': body.containsKey('internal_notes')
        ? cleanOptional(body['internal_notes'], max: 2000, multiline: true)
        : existing['internal_notes'],
    'updated_at': DateTime.now().toUtc(),
  };

  final itemsChanged = body.containsKey('items');
  final wasCancelled = previousStatus == 'cancelled';
  final nowCancelled = nextStatus == 'cancelled';
  if ((!wasCancelled && nowCancelled) ||
      (wasCancelled && !nowCancelled) ||
      (!wasCancelled && !nowCancelled && itemsChanged)) {
    final products = await _catalogForOwner(
      owner['_id'] as Object,
      slug: owner['shop_slug']?.toString(),
    );
    if (!wasCancelled && nowCancelled) {
      applyOrderStock(products, existing['items'], sign: 1);
    } else if (wasCancelled && !nowCancelled) {
      final shortage = shortageMessage(products, nextItems);
      if (shortage != null) return jsonError(409, shortage);
      applyOrderStock(products, nextItems, sign: -1);
    } else {
      applyOrderStock(products, existing['items'], sign: 1);
      final shortage = shortageMessage(products, nextItems);
      if (shortage != null) {
        applyOrderStock(products, existing['items'], sign: -1);
        return jsonError(409, shortage);
      }
      applyOrderStock(products, nextItems, sign: -1);
    }
    await _persistProducts(products);
    await _writePartStocks(owner['_id'], products);
  }

  await Mongo.instance.orders.replaceOne(where.eq('_id', id), next);
  return jsonOk(apiDoc(next));
}

Future<Response> _deleteOrder(Request request) async {
  final owner = await ownerFromRequest(request);
  if (owner == null) return jsonError(401, 'Sign in required');
  final id = request.params['id']!;
  final existing = await Mongo.instance.orders.findOne(where.eq('_id', id));
  if (existing == null) return jsonError(404, 'Not found');
  if (existing['shop_slug'] != owner['shop_slug']) {
    return jsonError(403, 'Not your order');
  }
  if (existing['status']?.toString() != 'cancelled') {
    final products = await _catalogForOwner(
      owner['_id'] as Object,
      slug: owner['shop_slug']?.toString(),
    );
    applyOrderStock(products, existing['items'], sign: 1);
    await _persistProducts(products);
    await _writePartStocks(owner['_id'], products);
  }
  await Mongo.instance.orders.deleteOne(where.eq('_id', id));
  return jsonOk({'ok': true});
}

Future<Response> _myParts(Request request) async {
  final owner = await ownerFromRequest(request);
  if (owner == null) return jsonError(401, 'Sign in required');
  final options = await _partOptions(owner['_id']);
  final sort = parseCatalogSort(owner['catalog_sort']);
  if (sort != 'manual') {
    options.paracords.sort((a, b) => compareCatalogRows(a, b, sort));
    options.trinkets.sort((a, b) => compareCatalogRows(a, b, sort));
    options.letterings.sort((a, b) => compareCatalogRows(a, b, sort));
    options.ropes.sort((a, b) => compareCatalogRows(a, b, sort));
    options.specialTrinkets.sort((a, b) => compareCatalogRows(a, b, sort));
  }
  return jsonOk(options.json);
}

Future<Response> _upsertPart(Request request) async {
  final owner = await ownerFromRequest(request);
  if (owner == null) return jsonError(401, 'Sign in required');
  final body = await readJson(request);
  final now = DateTime.now().toUtc();
  final id = parseId(request.params['id'] ?? body['id'], orElse: _uuid.v4);
  final kind = parsePartKind(body['kind']);
  final existing = await Mongo.instance.parts.findOne(where.eq('_id', id));
  if (existing != null && !sameId(existing['owner_id'], owner['_id'])) {
    return jsonError(403, 'Not your part');
  }
  final name = cleanLine(body['name'] ?? existing?['name'], max: 80);
  if (name.isEmpty) return jsonError(400, 'Name is required');
  final doc = {
    '_id': id,
    'owner_id': owner['_id'],
    'kind': kind,
    'name': name,
    'price': parseMoney(body['price'] ?? existing?['price']) ?? 0,
    'image_url': cleanOptional(body['image_url'] ?? existing?['image_url'], max: 500),
    'stock': parseInt(body['stock'] ?? existing?['stock']),
    'sort_order': parseInt(
      body['sort_order'] ?? existing?['sort_order'],
      fallback: existing == null ? 999 : parseInt(existing['sort_order'], fallback: 999),
      max: 99999,
    ),
    'created_at': parseDate(existing?['created_at'], fallback: now),
    'updated_at': now,
  };
  try {
    await mongoUpsert(Mongo.instance.parts, id, doc);
  } catch (error, stack) {
    stderr.writeln('[whimsical] upsert part $id: $error\n$stack');
    throw BadRequest('Could not save that $kind. Check the name, price, and photo, then try again.');
  }
  await _attachParts(owner['_id']);
  return jsonOk(apiDoc(doc));
}

Future<Response> _deletePart(Request request) async {
  final owner = await ownerFromRequest(request);
  if (owner == null) return jsonError(401, 'Sign in required');
  final id = request.params['id']!;
  final existing = await Mongo.instance.parts.findOne(where.eq('_id', id));
  if (existing == null) return jsonError(404, 'Not found');
  if (!sameId(existing['owner_id'], owner['_id'])) return jsonError(403, 'Not your part');
  await Mongo.instance.parts.deleteOne(where.eq('_id', id));
  await _attachParts(owner['_id']);
  return jsonOk({'ok': true});
}

class _ShopParts {
  const _ShopParts({
    required this.paracords,
    required this.trinkets,
    required this.letterings,
    required this.ropes,
    required this.specialTrinkets,
  });

  final List<Map<String, dynamic>> paracords;
  final List<Map<String, dynamic>> trinkets;
  final List<Map<String, dynamic>> letterings;
  final List<Map<String, dynamic>> ropes;
  final List<Map<String, dynamic>> specialTrinkets;

  bool get hasAny =>
      paracords.isNotEmpty ||
      trinkets.isNotEmpty ||
      letterings.isNotEmpty ||
      ropes.isNotEmpty ||
      specialTrinkets.isNotEmpty;

  Map<String, List<Map<String, dynamic>>> get productFields => {
        'paracords': paracords,
        'trinkets': trinkets,
        'letterings': letterings,
        'ropes': ropes,
        'special_trinkets': specialTrinkets,
      };

  Map<String, List<Map<String, dynamic>>> get json => productFields;
}

Future<_ShopParts> _partOptions(Object ownerId) async {
  var rows = await Mongo.instance.parts.find(where.eq('owner_id', ownerId)).toList();
  if (rows.isEmpty) {
    final asText = asString(ownerId);
    if (asText.isNotEmpty && asText != ownerId) {
      rows = await Mongo.instance.parts.find(where.eq('owner_id', asText)).toList();
    }
  }
  final cords = <Map<String, dynamic>>[];
  final charms = <Map<String, dynamic>>[];
  final letters = <Map<String, dynamic>>[];
  final ropeBag = <Map<String, dynamic>>[];
  final specials = <Map<String, dynamic>>[];
  for (final row in rows) {
    final option = {
      'id': asString(row['_id']),
      'name': cleanLine(row['name'], max: 80),
      'price': parseMoney(row['price']) ?? 0,
      'image_url': cleanOptional(row['image_url'], max: 500),
      'stock': parseInt(row['stock']),
      'sort_order': parseInt(row['sort_order'], fallback: 999, max: 99999),
    };
    if (asString(option['id']).isEmpty || asString(option['name']).isEmpty) continue;
    switch (asString(row['kind'])) {
      case 'trinket':
        charms.add(option);
      case 'lettering':
        letters.add(option);
      case 'rope':
        ropeBag.add(option);
      case 'special_trinket':
        specials.add(option);
      default:
        cords.add(option);
    }
  }
  int byOrder(Map<String, dynamic> a, Map<String, dynamic> b) {
    final ranked = parseInt(a['sort_order'], fallback: 999, max: 99999)
        .compareTo(parseInt(b['sort_order'], fallback: 999, max: 99999));
    if (ranked != 0) return ranked;
    return asString(a['name']).toLowerCase().compareTo(asString(b['name']).toLowerCase());
  }

  cords.sort(byOrder);
  charms.sort(byOrder);
  letters.sort(byOrder);
  ropeBag.sort(byOrder);
  specials.sort(byOrder);
  return _ShopParts(
    paracords: cords,
    trinkets: charms,
    letterings: letters,
    ropes: ropeBag,
    specialTrinkets: specials,
  );
}

Future<Response> _reorderParts(Request request) async {
  final owner = await ownerFromRequest(request);
  if (owner == null) return jsonError(401, 'Sign in required');
  final body = await readJson(request);
  final kind = parsePartKind(body['kind']);
  final ids = [
    for (final raw in body['ids'] is List ? body['ids'] as List : const [])
      asString(raw),
  ].where((id) => id.isNotEmpty).toList();
  if (ids.isEmpty) return jsonOk({'ok': true});
  final now = DateTime.now().toUtc();
  final ownerId = owner['_id'] as Object;
  if (body.containsKey('catalog_sort')) {
    try {
      await mongoSet(Mongo.instance.owners, ownerId, {
        'catalog_sort': parseCatalogSort(body['catalog_sort']),
        'updated_at': now,
      });
    } catch (error, stack) {
      stderr.writeln('[whimsical] reorder parts catalog sort: $error\n$stack');
    }
  }
  try {
    final owned = await _partsForOwner(ownerId);
    final byId = <String, Map<String, dynamic>>{
      for (final row in owned)
        if (parsePartKind(row['kind']) == kind) asString(row['_id']): Map<String, dynamic>.from(row),
    };
    await mapInBatches(List<int>.generate(ids.length, (i) => i), (i) async {
      final existing = byId[ids[i]];
      if (existing == null) return;
      final id = existing['_id'];
      if (id == null) return;
      try {
        await Mongo.instance.parts.update(
          where.eq('_id', id),
          modify.set('sort_order', i).set('updated_at', now),
        );
      } catch (error, stack) {
        stderr.writeln('[whimsical] reorder part $id: $error\n$stack');
      }
    });
    await _applyPartOrderToProducts(ownerId, kind, ids);
  } catch (error, stack) {
    stderr.writeln('[whimsical] reorder parts: $error\n$stack');
    try {
      await _applyPartOrderToProducts(ownerId, kind, ids);
    } catch (retryError, retryStack) {
      stderr.writeln('[whimsical] reorder parts on products: $retryError\n$retryStack');
    }
  }
  return jsonOk({'ok': true, 'kind': kind, 'ids': ids});
}

Future<List<Map<String, dynamic>>> _partsForOwner(Object ownerId) async {
  var rows = await Mongo.instance.parts.find(where.eq('owner_id', ownerId)).toList();
  if (rows.isEmpty) {
    final asText = asString(ownerId);
    if (asText.isNotEmpty && asText != ownerId) {
      rows = await Mongo.instance.parts.find(where.eq('owner_id', asText)).toList();
    }
  }
  return rows;
}

Future<void> _applyPartOrderToProducts(Object ownerId, String kind, List<String> ids) async {
  final key = optionListKeyForKind(kind);
  final products = await _productsForOwner(ownerId);
  final now = DateTime.now().toUtc();
  await mapInBatches(products, (product) async {
    final id = product['_id'];
    if (id == null) return;
    final next = reorderMapsByIds(product[key], ids);
    if (next.isEmpty) return;
    try {
      await Mongo.instance.products.update(
        where.eq('_id', id),
        modify.set(key, next).set('updated_at', now),
      );
    } catch (error, stack) {
      stderr.writeln('[whimsical] reorder $key on $id: $error\n$stack');
      try {
        await mongoSet(Mongo.instance.products, id, {key: next, 'updated_at': now});
      } catch (retryError, retryStack) {
        stderr.writeln('[whimsical] reorder $key fallback $id: $retryError\n$retryStack');
      }
    }
  });
}

Future<void> _attachParts(Object ownerId) async {
  try {
    final options = await _partOptions(ownerId);
    if (!options.hasAny) return;
    var products = await _productsForOwner(ownerId);
    if (products.isEmpty) return;
    final fields = {
      ...options.productFields,
      'updated_at': DateTime.now().toUtc(),
    };
    await mapInBatches(products, (product) async {
      final id = product['_id'];
      if (id == null) return;
      try {
        await mongoSet(Mongo.instance.products, id, fields);
      } catch (error, stack) {
        stderr.writeln('[whimsical] attach parts to $id: $error\n$stack');
      }
    });
  } catch (error, stack) {
    stderr.writeln('[whimsical] attach parts: $error\n$stack');
  }
}

Future<void> _writePartStocks(Object ownerId, List<Map<String, dynamic>> products) async {
  final stocks = <String, int>{};
  for (final product in products) {
    for (final key in optionListKeys) {
      final list = product[key];
      if (list is! List) continue;
      for (final raw in list) {
        if (raw is Map && raw['id'] != null) {
          stocks[raw['id'].toString()] = parseInt(raw['stock']);
        }
      }
    }
  }
  if (stocks.isEmpty) return;
  final now = DateTime.now().toUtc();
  var parts = await Mongo.instance.parts.find(where.eq('owner_id', ownerId)).toList();
  if (parts.isEmpty) {
    final asText = ownerId.toString();
    if (asText != ownerId) {
      parts = await Mongo.instance.parts.find(where.eq('owner_id', asText)).toList();
    }
  }
  await mapInBatches(parts, (part) async {
    final id = part['_id'];
    if (id == null) return;
    final key = asString(id);
    if (!stocks.containsKey(key)) return;
    try {
      await mongoSet(Mongo.instance.parts, id, {
        'stock': stocks[key],
        'updated_at': now,
      });
    } catch (error, stack) {
      stderr.writeln('[whimsical] write part stock $key: $error\n$stack');
    }
  });
}

Future<void> _persistProducts(List<Map<String, dynamic>> products) async {
  final now = DateTime.now().toUtc();
  await mapInBatches(products, (product) async {
    final id = product['_id'];
    if (id == null) return;
    try {
      await mongoSet(Mongo.instance.products, id, {
        'paracords': product['paracords'],
        'trinkets': product['trinkets'],
        'letterings': product['letterings'],
        'ropes': product['ropes'],
        'special_trinkets': product['special_trinkets'],
        'stock': product['stock'],
        'stock_status': product['stock_status'],
        'updated_at': now,
      });
    } catch (error, stack) {
      stderr.writeln('[whimsical] persist product $id: $error\n$stack');
    }
  });
}

Future<Response> _uploadFile(Request request) async {
  final owner = await ownerFromRequest(request);
  if (owner == null) return jsonError(401, 'Sign in required');
  final bytes = await _readBytes(request);
  if (bytes.isEmpty) return jsonError(400, 'That photo was empty.');
  if (bytes.lengthInBytes > 8 * 1024 * 1024) {
    return jsonError(400, 'That photo is too large.');
  }
  final url = await _storeFile(bytes, contentType: request.mimeType ?? 'image/jpeg');
  return jsonOk({'url': url});
}

Future<Response> _getFile(Request request) async {
  return _fileById(request.params['id']!);
}

Future<Response> _fileById(String id) async {
  ObjectId objectId;
  try {
    objectId = ObjectId.fromHexString(id);
  } catch (_) {
    return jsonError(400, 'Invalid file id');
  }
  final grid = GridFS(Mongo.instance.db);
  final file = await grid.findOne(where.id(objectId));
  if (file == null) return jsonError(404, 'File not found');
  final builder = BytesBuilder(copy: false);
  final chunks = await grid.chunks
      .find(where.eq('files_id', file.id).sortBy('n'))
      .toList();
  for (final chunk in chunks) {
    final data = chunk['data'];
    if (data is BsonBinary) {
      builder.add(data.byteList);
    } else if (data is List<int>) {
      builder.add(data);
    }
  }
  return Response.ok(
    builder.takeBytes(),
    headers: {
      HttpHeaders.contentTypeHeader: file.contentType ?? 'image/jpeg',
      HttpHeaders.cacheControlHeader: 'public, max-age=86400',
    },
  );
}

Future<Response> _fallbackShareIcon() async {
  for (final name in const ['icons/Icon-512.png', 'apple-touch-icon.png', 'favicon.png']) {
    final file = File('${Env.webRoot}/$name');
    if (file.existsSync()) {
      return Response.ok(
        file.readAsBytesSync(),
        headers: {
          HttpHeaders.contentTypeHeader: 'image/png',
          HttpHeaders.cacheControlHeader: 'public, max-age=300',
        },
      );
    }
  }
  return jsonError(404, 'No share image');
}

Future<Uint8List> _readBytes(Request request) async {
  final builder = BytesBuilder(copy: false);
  await for (final chunk in request.read()) {
    builder.add(chunk);
  }
  return builder.takeBytes();
}

Future<String> _storeFile(Uint8List bytes, {required String contentType}) async {
  final grid = GridFS(Mongo.instance.db);
  final file = grid.createFile(Stream<List<int>>.fromIterable([bytes]), '${_uuid.v4()}.jpg');
  file.contentType = contentType;
  await file.save();
  final id = (file.id as ObjectId).oid;
  return '/api/files/$id';
}
