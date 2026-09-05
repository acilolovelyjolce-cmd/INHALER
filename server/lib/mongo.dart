import 'dart:async';

import 'package:mongo_dart/mongo_dart.dart';

import 'env.dart';
import 'fields.dart';

class Mongo {
  Mongo._();
  static final Mongo instance = Mongo._();

  Db? _db;

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

  Future<void> connect({int attempts = 12}) async {
    final uri = Env.mongoUri.trim();
    if (uri.isEmpty) {
      throw StateError(
        'MONGODB_URI is missing. Set it to your Atlas SRV connection string.',
      );
    }

    Object? lastError;
    for (var i = 1; i <= attempts; i++) {
      try {
        final database = await Db.create(uri);
        await database.open();
        _db = database;
        stdoutLog('Connected to MongoDB Atlas (${database.databaseName})');
        return;
      } catch (error) {
        lastError = error;
        stdoutLog('Mongo connect attempt $i/$attempts failed: $error');
        await Future<void>.delayed(Duration(seconds: i < 4 ? 2 : 5));
      }
    }
    throw StateError('Could not connect to MongoDB Atlas: $lastError');
  }

  bool get isReady {
    final database = _db;
    return database != null && database.isConnected;
  }

  Future<void> reconnect() async {
    try {
      await _db?.close();
    } catch (_) {}
    _db = null;
    await connect(attempts: 4);
  }

  Future<void> ensureOpen() async {
    if (isReady) return;
    await reconnect();
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

bool isMongoDisconnect(Object error) {
  final text = error.toString().toLowerCase();
  return text.contains('socket') ||
      text.contains('not connected') ||
      text.contains('connection') ||
      text.contains('closed') ||
      text.contains('timed out') ||
      text.contains('timeout') ||
      text.contains('network') ||
      text.contains('mongodb is not connected') ||
      text.contains('stateerror');
}

Future<void> mongoUpsert(
  DbCollection collection,
  Object id,
  Map<String, dynamic> doc,
) async {
  final safe = bsonMap(doc);
  Future<void> write() async {
    await Mongo.instance.ensureOpen();
    await collection.replaceOne(where.eq('_id', id), safe, upsert: true);
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

  ModifierBuilder modifierFor() {
    var modifier = modify;
    for (final entry in safe.entries) {
      modifier = modifier.set(entry.key, entry.value);
    }
    return modifier;
  }

  Future<void> write() async {
    await Mongo.instance.ensureOpen();
    await collection.update(where.eq('_id', id), modifierFor());
  }

  try {
    await write();
  } catch (error) {
    if (!isMongoDisconnect(error)) rethrow;
    await Mongo.instance.reconnect();
    await write();
  }
}
