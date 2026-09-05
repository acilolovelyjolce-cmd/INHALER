import 'dart:async';

import 'package:mongo_dart/mongo_dart.dart';

import 'env.dart';
import 'fields.dart';

/// One process-wide MongoDB client. Request handlers must use [Mongo.instance]
/// and must not call [Db.create] / [Db.open] themselves.
class Mongo {
  Mongo._();
  static final Mongo instance = Mongo._();

  Db? _db;
  Future<void>? _inFlight;
  var _needsReplace = false;

  Db get db {
    final database = _db;
    if (database == null) {
      throw StateError('MongoDB is not connected');
    }
    return database;
  }

  DbCollection get owners => db.collection('owners');
  DbCollection get products => db.collection('products');
  DbCollection get parts => db.collection('parts');
  DbCollection get orders => db.collection('orders');
  DbCollection get migrations => db.collection('schema_migrations');

  bool get isReady {
    final database = _db;
    return database != null && database.isConnected;
  }

  /// Opens the shared client, or returns the one already open.
  Future<void> connect({int attempts = 12}) {
    return _locked(() => _open(attempts: attempts));
  }

  /// Reuses the live client. Only opens again if the socket is gone.
  Future<void> ensureOpen() => connect(attempts: 4);

  /// Closes a dead client and opens one replacement. Concurrent callers
  /// wait on the same lock instead of stacking new Atlas pools.
  Future<void> reconnect() {
    _needsReplace = true;
    return _locked(() async {
      if (isReady && !_needsReplace) return;
      _needsReplace = false;
      await _dispose(_db);
      _db = null;
      await _open(attempts: 4);
    });
  }

  Future<void> close() {
    return _locked(() async {
      await _dispose(_db);
      _db = null;
    });
  }

  Future<void> _locked(Future<void> Function() work) {
    final previous = _inFlight ?? Future<void>.value();
    late final Future<void> started;
    started = previous.catchError((_) {}).then((_) => work());
    _inFlight = started;
    started.whenComplete(() {
      if (identical(_inFlight, started)) _inFlight = null;
    });
    return started;
  }

  Future<void> _open({required int attempts}) async {
    if (isReady) return;

    final uri = Env.mongoUri.trim();
    if (uri.isEmpty) {
      throw StateError(
        'MONGODB_URI is missing. Set it to your Atlas SRV connection string.',
      );
    }

    Object? lastError;
    for (var i = 1; i <= attempts; i++) {
      Db? candidate;
      try {
        candidate = await _openClient(uri);
        final previous = _db;
        _db = candidate;
        if (previous != null && !identical(previous, candidate)) {
          await _dispose(previous);
        }
        stdoutLog('Connected to MongoDB Atlas (${candidate.databaseName})');
        return;
      } catch (error) {
        lastError = error;
        await _dispose(candidate);
        stdoutLog('Mongo connect attempt $i/$attempts failed: $error');
        final wait = isTlsHandshake(error) ? 8 : (i < 4 ? 2 : 5);
        await Future<void>.delayed(Duration(seconds: wait));
      }
    }
    throw StateError(
      'Could not connect to MongoDB Atlas: $lastError\n'
      'A TLS handshake error means Atlas refused the socket. Check Network Access '
      '(allow 0.0.0.0/0 or Render IPs), that the cluster is not paused, and that '
      'you are under the connection limit — kill idle sessions if you just hit 500.',
    );
  }

  Future<Db> _openClient(String uri) async {
    final normalized = normalizeMongoUri(uri);
    final seed = await Db.create(normalized);
    try {
      await seed.open(secure: true);
      return seed;
    } catch (error) {
      final hosts = seed.uriList;
      await _dispose(seed);
      if (hosts.length <= 1) rethrow;
      Object? lastError = error;
      for (final hostUri in hosts) {
        Db? single;
        try {
          single = Db(hostUri);
          await single.open(secure: true);
          stdoutLog('Connected to one Atlas host instead of the full replica set');
          return single;
        } catch (hostError) {
          lastError = hostError;
          await _dispose(single);
        }
      }
      throw lastError ?? error;
    }
  }

  Future<void> _dispose(Db? database) async {
    if (database == null) return;
    try {
      await database.close();
    } catch (_) {}
  }
}

Future<void> mapInBatches<T>(
  Iterable<T> items,
  Future<void> Function(T item) work, {
  int size = 8,
}) async {
  final list = items.toList();
  for (var i = 0; i < list.length; i += size) {
    final end = i + size > list.length ? list.length : i + size;
    await Future.wait([
      for (final item in list.sublist(i, end)) work(item),
    ]);
  }
}

void stdoutLog(String message) {
  // ignore: avoid_print
  print('[whimsical] $message');
}

/// Keeps user/password bytes intact and turns on Atlas TLS flags.
String normalizeMongoUri(String raw) {
  final uri = raw.trim();
  if (uri.isEmpty) return uri;
  final lower = uri.toLowerCase();
  final extra = <String>[];
  if (!lower.contains('tls=true') && !lower.contains('ssl=true')) {
    extra.addAll(['tls=true', 'ssl=true']);
  }
  if (!lower.contains('safeatlas=')) extra.add('safeAtlas=true');
  if (extra.isEmpty) return uri;
  return uri.contains('?') ? '$uri&${extra.join('&')}' : '$uri?${extra.join('&')}';
}

bool isTlsHandshake(Object error) {
  final text = error.toString().toLowerCase();
  return text.contains('handshake') ||
      text.contains('tlsv1') ||
      text.contains('certificate') ||
      text.contains('secure_socket');
}

bool isMongoDisconnect(Object error) {
  final text = error.toString().toLowerCase();
  return text.contains('mongodb is not connected') ||
      text.contains('no master connection') ||
      text.contains('no primary found') ||
      text.contains('socketexception') ||
      text.contains('connection closed') ||
      text.contains('connection reset') ||
      text.contains('broken pipe') ||
      text.contains('db is not open') ||
      text.contains('state.init') ||
      isTlsHandshake(error);
}

Future<void> mongoUpsert(
  DbCollection collection,
  Object id,
  Map<String, dynamic> doc,
) async {
  final safe = bsonMap(doc);
  final name = collection.collectionName;
  Future<void> write() async {
    await Mongo.instance.ensureOpen();
    await Mongo.instance.db.collection(name).replaceOne(
          where.eq('_id', id),
          safe,
          upsert: true,
        );
  }

  try {
    await write();
  } catch (error) {
    if (!isMongoDisconnect(error)) rethrow;
    await Mongo.instance.reconnect();
    await write();
  }
}

Future<void> mongoSet(
  DbCollection collection,
  Object id,
  Map<String, dynamic> fields,
) async {
  final safe = bsonMap(fields);
  if (safe.isEmpty) return;
  final name = collection.collectionName;

  ModifierBuilder modifierFor() {
    var modifier = modify;
    for (final entry in safe.entries) {
      modifier = modifier.set(entry.key, entry.value);
    }
    return modifier;
  }

  Future<void> write() async {
    await Mongo.instance.ensureOpen();
    await Mongo.instance.db.collection(name).update(
          where.eq('_id', id),
          modifierFor(),
        );
  }

  try {
    await write();
  } catch (error) {
    if (!isMongoDisconnect(error)) rethrow;
    await Mongo.instance.reconnect();
    await write();
  }
}
