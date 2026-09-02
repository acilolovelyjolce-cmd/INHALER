import 'dart:io';
import 'dart:typed_data';

import 'package:mongo_dart/mongo_dart.dart';
import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';
import 'package:uuid/uuid.dart';

import 'auth.dart';
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
    ..get('/api/parts', _myParts)
    ..put('/api/parts/<id>', _upsertPart)
    ..delete('/api/parts/<id>', _deletePart)
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
  final email = (body['email'] as String? ?? '').trim().toLowerCase();
  final password = body['password'] as String? ?? '';
  if (email.isEmpty || password.isEmpty) {
    return jsonError(400, 'Email and password are required');
  }
  final owner = await Mongo.instance.owners.findOne(where.eq('email', email));
  if (owner == null || !passwordMatches(password, owner['password_hash'] as String)) {
    return jsonError(401, 'Could not sign in. Check your email and password.');
  }
  return jsonOk({
    'token': signOwner(owner),
    'user': apiDoc(owner),
  });
}

Future<Response> _shop(Request request) async {
  final slug = request.params['slug']!;
  final owner = await Mongo.instance.owners.findOne(where.eq('shop_slug', slug));
  if (owner == null) return jsonError(404, 'Shop not found');
  final doc = apiDoc(owner);
  return jsonOk({
    'id': doc['id']?.toString() ?? '',
    'shop_name': doc['shop_name'] ?? 'Whimsical',
    'shop_slug': doc['shop_slug'] ?? slug,
    'bio': doc['bio'],
    'logo_url': doc['logo_url'],
    'ewallet_qr_url': doc['ewallet_qr_url'],
    'contact_info': doc['contact_info'] is Map ? doc['contact_info'] : <String, String>{},
  });
}

Future<Response> _publishedProducts(Request request) async {
  final slug = request.params['slug']!;
  final rows = await Mongo.instance.products
      .find(where.eq('shop_slug', slug).eq('is_published', true))
      .toList();
  rows.sort((a, b) {
    final aOrder = (a['sort_order'] as num?)?.toInt() ?? 0;
    final bOrder = (b['sort_order'] as num?)?.toInt() ?? 0;
    return aOrder.compareTo(bOrder);
  });
  final encoded = <Map<String, dynamic>>[];
  for (final row in rows) {
    try {
      encoded.add(apiDoc(Map<String, dynamic>.from(row)));
    } catch (error, stack) {
      stderr.writeln('[whimsical] skip product ${row['_id']}: $error\n$stack');
    }
  }
  return jsonOk(encoded);
}

Future<Response> _submitOrder(Request request) async {
  final slug = request.params['slug']!;
  final shop = await Mongo.instance.owners.findOne(where.eq('shop_slug', slug));
  if (shop == null) return jsonError(404, 'Shop not found');

  final body = await readJson(request);
  if ((body['honeypot'] as String? ?? '').trim().isNotEmpty) {
    return jsonOk({'id': 'honeypot', 'ok': true});
  }

  final now = DateTime.now().toUtc();
  final doc = {
    '_id': _uuid.v4(),
    'shop_slug': slug,
    'customer_name': (body['customer_name'] as String? ?? '').trim(),
    'customer_contact': (body['customer_contact'] as String? ?? '').trim(),
    'items': body['items'] ?? [],
    'total_amount': body['total_amount'] ?? 0,
    'customer_note': body['customer_note'],
    'status': 'new_request',
    'payment_status': 'unpaid',
    'payment_method': body['payment_method'],
    'internal_notes': null,
    'created_at': now,
    'updated_at': now,
  };
  if ((doc['customer_name'] as String).isEmpty ||
      (doc['customer_contact'] as String).isEmpty) {
    return jsonError(400, 'Name and contact are required');
  }

  final products = await Mongo.instance.products.find(where.eq('shop_slug', slug)).toList();
  final need = neededFromItems(doc['items']);
  final shortage = shortageMessage(products, need);
  if (shortage != null) return jsonError(409, shortage);
  applyOptionStock(products, need, sign: -1);
  await _persistProducts(products);
  await _writePartStocks(shop['_id'].toString(), products);

  await Mongo.instance.orders.insertOne(doc);
  return jsonOk(apiDoc(doc), status: 201);
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
  final next = {
    ...owner,
    'shop_name': body['shop_name'] ?? owner['shop_name'],
    'shop_slug': body['shop_slug'] ?? owner['shop_slug'],
    'bio': body['bio'] ?? owner['bio'],
    'logo_url': body['logo_url'] ?? owner['logo_url'],
    'ewallet_qr_url': body['ewallet_qr_url'] ?? owner['ewallet_qr_url'],
    'contact_info': body['contact_info'] ?? owner['contact_info'],
    'updated_at': now,
  };
  await Mongo.instance.owners.replaceOne(where.eq('_id', owner['_id']), next);
  return jsonOk(apiDoc(next));
}

Future<Response> _uploadLogo(Request request) async {
  final owner = await ownerFromRequest(request);
  if (owner == null) return jsonError(401, 'Sign in required');
  final bytes = await _readBytes(request);
  final url = await _storeFile(bytes, contentType: request.mimeType ?? 'image/jpeg');
  final next = {...owner, 'logo_url': url, 'updated_at': DateTime.now().toUtc()};
  await Mongo.instance.owners.replaceOne(where.eq('_id', owner['_id']), next);
  return jsonOk({'url': url, 'user': apiDoc(next)});
}

Future<Response> _uploadWalletQr(Request request) async {
  final owner = await ownerFromRequest(request);
  if (owner == null) return jsonError(401, 'Sign in required');
  final bytes = await _readBytes(request);
  final url = await _storeFile(bytes, contentType: request.mimeType ?? 'image/jpeg');
  final next = {...owner, 'ewallet_qr_url': url, 'updated_at': DateTime.now().toUtc()};
  await Mongo.instance.owners.replaceOne(where.eq('_id', owner['_id']), next);
  return jsonOk({'url': url, 'user': apiDoc(next)});
}

Future<Response> _myProducts(Request request) async {
  final owner = await ownerFromRequest(request);
  if (owner == null) return jsonError(401, 'Sign in required');
  final rows = await Mongo.instance.products.find(where.eq('owner_id', owner['_id'])).toList();
  rows.sort((a, b) {
    final aOrder = (a['sort_order'] as num?)?.toInt() ?? 0;
    final bOrder = (b['sort_order'] as num?)?.toInt() ?? 0;
    return aOrder.compareTo(bOrder);
  });
  return jsonOk([
    for (final row in rows) apiDoc(Map<String, dynamic>.from(row)),
  ]);
}

Future<Response> _upsertProduct(Request request) async {
  final owner = await ownerFromRequest(request);
  if (owner == null) return jsonError(401, 'Sign in required');
  final body = await readJson(request);
  final now = DateTime.now().toUtc();
  final id = request.params['id'] ?? body['id'] as String? ?? _uuid.v4();
  final existing = await Mongo.instance.products.findOne(where.eq('_id', id));
  if (existing != null && existing['owner_id'] != owner['_id']) {
    return jsonError(403, 'Not your product');
  }
  final doc = {
    '_id': id,
    'owner_id': owner['_id'],
    'shop_slug': owner['shop_slug'],
    'name': body['name'] ?? existing?['name'] ?? '',
    'description': body['description'] ?? existing?['description'] ?? '',
    'price': body['price'] ?? existing?['price'] ?? 0,
    'compare_at_price': body['compare_at_price'] ?? existing?['compare_at_price'],
    'image_urls': body['image_urls'] ?? existing?['image_urls'] ?? [],
    'category': body['category'] ?? existing?['category'] ?? 'Dino Series',
    'paracords': <Map<String, dynamic>>[],
    'trinkets': <Map<String, dynamic>>[],
    'stock_status': body['stock_status'] ?? existing?['stock_status'] ?? 'available',
    'is_published': body['is_published'] ?? existing?['is_published'] ?? false,
    'sort_order': body['sort_order'] ?? existing?['sort_order'] ?? 99,
    'created_at': parseDate(existing?['created_at'] ?? body['created_at'], fallback: now),
    'updated_at': now,
  };
  final options = await _partOptions(owner['_id'].toString());
  if (options.$1.isNotEmpty || options.$2.isNotEmpty) {
    doc['paracords'] = options.$1;
    doc['trinkets'] = options.$2;
  } else {
    doc['paracords'] = body['paracords'] ?? existing?['paracords'] ?? [];
    doc['trinkets'] = body['trinkets'] ?? existing?['trinkets'] ?? [];
  }
  if (existing == null) {
    await Mongo.instance.products.insertOne(doc);
  } else {
    await Mongo.instance.products.replaceOne(where.eq('_id', id), doc);
  }
  return jsonOk(apiDoc(doc));
}

Future<Response> _deleteProduct(Request request) async {
  final owner = await ownerFromRequest(request);
  if (owner == null) return jsonError(401, 'Sign in required');
  final id = request.params['id']!;
  final existing = await Mongo.instance.products.findOne(where.eq('_id', id));
  if (existing == null) return jsonError(404, 'Not found');
  if (existing['owner_id'] != owner['_id']) return jsonError(403, 'Not your product');
  await Mongo.instance.products.deleteOne(where.eq('_id', id));
  return jsonOk({'ok': true});
}

Future<Response> _reorder(Request request) async {
  final owner = await ownerFromRequest(request);
  if (owner == null) return jsonError(401, 'Sign in required');
  final body = await readJson(request);
  final ids = (body['ids'] as List? ?? []).map((e) => e.toString()).toList();
  final now = DateTime.now().toUtc();
  for (var i = 0; i < ids.length; i++) {
    await Mongo.instance.products.update(
      where.eq('_id', ids[i]).eq('owner_id', owner['_id']),
      modify.set('sort_order', i).set('updated_at', now),
    );
  }
  return jsonOk({'ok': true});
}

Future<Response> _bulkPrice(Request request) async {
  final owner = await ownerFromRequest(request);
  if (owner == null) return jsonError(401, 'Sign in required');
  final body = await readJson(request);
  final category = body['category'] as String? ?? '';
  final percent = body['percent'] as bool? ?? true;
  final amount = (body['amount'] as num?)?.toDouble() ?? 0;
  final now = DateTime.now().toUtc();
  final rows = await Mongo.instance.products
      .find(where.eq('owner_id', owner['_id']).eq('category', category))
      .toList();
  for (final row in rows) {
    final price = (row['price'] as num?)?.toDouble() ?? 0;
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
  final category = (body['category'] as String? ?? '').trim();
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
  final nextStatus = (body['status'] ?? existing['status']).toString();
  final next = {
    ...existing,
    'status': body['status'] ?? existing['status'],
    'payment_status': body['payment_status'] ?? existing['payment_status'],
    'internal_notes': body['internal_notes'] ?? existing['internal_notes'],
    'updated_at': DateTime.now().toUtc(),
  };

  if (previousStatus != nextStatus) {
    final products = await Mongo.instance.products
        .find(where.eq('shop_slug', owner['shop_slug']))
        .toList();
    final need = neededFromItems(existing['items']);
    if (previousStatus != 'cancelled' && nextStatus == 'cancelled') {
      applyOptionStock(products, need, sign: 1);
      await _persistProducts(products);
      await _writePartStocks(owner['_id'].toString(), products);
    } else if (previousStatus == 'cancelled' && nextStatus != 'cancelled') {
      final shortage = shortageMessage(products, need);
      if (shortage != null) return jsonError(409, shortage);
      applyOptionStock(products, need, sign: -1);
      await _persistProducts(products);
      await _writePartStocks(owner['_id'].toString(), products);
    }
  }

  await Mongo.instance.orders.replaceOne(where.eq('_id', id), next);
  return jsonOk(apiDoc(next));
}

Future<Response> _myParts(Request request) async {
  final owner = await ownerFromRequest(request);
  if (owner == null) return jsonError(401, 'Sign in required');
  final options = await _partOptions(owner['_id'].toString());
  return jsonOk({'paracords': options.$1, 'trinkets': options.$2});
}

Future<Response> _upsertPart(Request request) async {
  final owner = await ownerFromRequest(request);
  if (owner == null) return jsonError(401, 'Sign in required');
  final body = await readJson(request);
  final now = DateTime.now().toUtc();
  final id = request.params['id'] ?? body['id'] as String? ?? _uuid.v4();
  final kind = (body['kind'] as String? ?? 'paracord') == 'trinket' ? 'trinket' : 'paracord';
  final existing = await Mongo.instance.parts.findOne(where.eq('_id', id));
  if (existing != null && existing['owner_id'] != owner['_id']) {
    return jsonError(403, 'Not your part');
  }
  final doc = {
    '_id': id,
    'owner_id': owner['_id'],
    'kind': kind,
    'name': body['name'] ?? existing?['name'] ?? '',
    'price': body['price'] ?? existing?['price'] ?? 0,
    'image_url': body['image_url'] ?? existing?['image_url'],
    'stock': body['stock'] ?? existing?['stock'] ?? 0,
    'created_at': parseDate(existing?['created_at'], fallback: now),
    'updated_at': now,
  };
  if (existing == null) {
    await Mongo.instance.parts.insertOne(doc);
  } else {
    await Mongo.instance.parts.replaceOne(where.eq('_id', id), doc);
  }
  await _attachParts(owner['_id'].toString());
  return jsonOk(apiDoc(doc));
}

Future<Response> _deletePart(Request request) async {
  final owner = await ownerFromRequest(request);
  if (owner == null) return jsonError(401, 'Sign in required');
  final id = request.params['id']!;
  final existing = await Mongo.instance.parts.findOne(where.eq('_id', id));
  if (existing == null) return jsonError(404, 'Not found');
  if (existing['owner_id'] != owner['_id']) return jsonError(403, 'Not your part');
  await Mongo.instance.parts.deleteOne(where.eq('_id', id));
  await _attachParts(owner['_id'].toString());
  return jsonOk({'ok': true});
}

Future<(List<Map<String, dynamic>>, List<Map<String, dynamic>>)> _partOptions(String ownerId) async {
  final rows = await Mongo.instance.parts.find(where.eq('owner_id', ownerId)).toList();
  final cords = <Map<String, dynamic>>[];
  final charms = <Map<String, dynamic>>[];
  for (final row in rows) {
    final option = {
      'id': row['_id'],
      'name': row['name'] ?? '',
      'price': row['price'] ?? 0,
      'image_url': row['image_url'],
      'stock': row['stock'] ?? 0,
    };
    if (row['kind'] == 'trinket') {
      charms.add(option);
    } else {
      cords.add(option);
    }
  }
  return (cords, charms);
}

Future<void> _attachParts(String ownerId) async {
  final options = await _partOptions(ownerId);
  if (options.$1.isEmpty && options.$2.isEmpty) return;
  final products = await Mongo.instance.products.find(where.eq('owner_id', ownerId)).toList();
  final now = DateTime.now().toUtc();
  for (final product in products) {
    product['paracords'] = options.$1;
    product['trinkets'] = options.$2;
    product['updated_at'] = now;
    await Mongo.instance.products.replaceOne(where.eq('_id', product['_id']), product);
  }
}

Future<void> _writePartStocks(String ownerId, List<Map<String, dynamic>> products) async {
  final stocks = <String, int>{};
  for (final product in products) {
    for (final key in const ['paracords', 'trinkets']) {
      final list = product[key];
      if (list is! List) continue;
      for (final raw in list) {
        if (raw is Map && raw['id'] != null) {
          stocks[raw['id'].toString()] = (raw['stock'] as num?)?.toInt() ?? 0;
        }
      }
    }
  }
  if (stocks.isEmpty) return;
  final now = DateTime.now().toUtc();
  final parts = await Mongo.instance.parts.find(where.eq('owner_id', ownerId)).toList();
  for (final part in parts) {
    final id = part['_id']?.toString() ?? '';
    if (!stocks.containsKey(id)) continue;
    part['stock'] = stocks[id];
    part['updated_at'] = now;
    await Mongo.instance.parts.replaceOne(where.eq('_id', part['_id']), part);
  }
}

Future<void> _persistProducts(List<Map<String, dynamic>> products) async {
  final now = DateTime.now().toUtc();
  for (final product in products) {
    product['updated_at'] = now;
    await Mongo.instance.products.replaceOne(where.eq('_id', product['_id']), product);
  }
}

Future<Response> _uploadFile(Request request) async {
  final owner = await ownerFromRequest(request);
  if (owner == null) return jsonError(401, 'Sign in required');
  final bytes = await _readBytes(request);
  final url = await _storeFile(bytes, contentType: request.mimeType ?? 'image/jpeg');
  return jsonOk({'url': url});
}

Future<Response> _getFile(Request request) async {
  final id = request.params['id']!;
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
