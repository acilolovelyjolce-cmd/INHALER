import 'dart:async';

import 'package:mongo_dart/mongo_dart.dart';

import 'env.dart';
import 'fields.dart';

/// One process-wide MongoDB client. Request handlers must use [Mongo.instance]
/// and must not call [Db.create] / [Db.open] themselves.
class Mongo {
  Mongo._();
  static final Mongo instance = Mongo._();

  static const _replaceCooldown = Duration(seconds: 30);

  Db? _db;
  Future<void>? _inFlight;
  DateTime? _openedAt;

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

  /// Opens the shared client once. Later calls reuse it.
  Future<void> connect({int attempts = 12}) {
    return _locked(() => _open(attempts: attempts, replace: false));
  }

  /// Reuses the live client. Opens only when there is no socket.
  Future<void> ensureOpen() {
    if (isReady) return Future.value();
    return connect(attempts: 1);
  }

  /// Replaces the client at most once per [_replaceCooldown].
  /// Request handlers must not call this — it is a last-resort recovery.
  Future<void> reconnect() {
    return _locked(() => _open(attempts: 1, replace: true));
  }

  Future<void> close() {
    return _locked(() async {
      await _dispose(_db);
      _db = null;
      _openedAt = null;
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

  Future<void> _open({required int attempts, required bool replace}) async {
    if (isReady && !replace) return;
    if (replace &&
        _openedAt != null &&
        DateTime.now().difference(_openedAt!) < _replaceCooldown) {
      if (_db != null) return;
    }

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
        _openedAt = DateTime.now();
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

  /// DNS-resolve the SRV URI, then open exactly one host.
  /// [Db.create] + [Db.open] on Atlas would connect to every replica member
  /// and is what stacked hundreds of sockets after each reconnect.
  Future<Db> _openClient(String uri) async {
    final normalized = normalizeMongoUri(uri);
    final hosts = normalized.startsWith('mongodb+srv://')
        ? (await Db.create(normalized)).uriList
        : [normalized];
    Object? lastError;
    for (final hostUri in hosts) {
      Db? single;
      try {
        single = Db(hostUri);
        await single.open(secure: true);
        return single;
      } catch (error) {
        lastError = error;
        await _dispose(single);
      }
    }
    throw lastError ?? StateError('Could not open a MongoDB host');
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
    await write();
  }
}
