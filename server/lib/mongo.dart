import 'dart:async';

import 'package:mongo_dart/mongo_dart.dart';

import 'env.dart';

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

  Future<void> close() async {
    await _db?.close();
    _db = null;
  }
}

void stdoutLog(String message) {
  // ignore: avoid_print
  print('[whimsical] $message');
}
