import 'dart:typed_data';

import 'package:uuid/uuid.dart';

import '../config/env.dart';
import '../models/product.dart';
import 'api_client.dart';
import 'app_store.dart';
import 'image_compress.dart';

class ProductsRepository {
  ProductsRepository();

  final _uuid = const Uuid();
  final _api = ApiClient.instance;

  Stream<List<Product>> watchPublished(String slug) async* {
    if (AppConfig.useDemo) {
      final store = DemoMemoryStore.instance;
      List<Product> published() => store.products.where((p) => p.isPublished).toList()
        ..sort((a, b) => a.sortOrder.compareTo(b.sortOrder));
      yield published();
      yield* store.productsCtrl.stream.map((_) => published());
      return;
    }
    yield await _fetchPublished(slug);
    yield* Stream.periodic(const Duration(seconds: 4)).asyncMap((_) => _fetchPublished(slug));
  }

  Stream<List<Product>> watchAll() async* {
    if (AppConfig.useDemo) {
      final store = DemoMemoryStore.instance;
      List<Product> sorted() => [...store.products]..sort((a, b) => a.sortOrder.compareTo(b.sortOrder));
      yield sorted();
      yield* store.productsCtrl.stream.map((_) => sorted());
      return;
    }
    yield await _fetchMine();
    yield* Stream.periodic(const Duration(seconds: 4)).asyncMap((_) => _fetchMine());
  }

  Future<List<Product>> _fetchPublished(String slug) async {
    final rows = await _api.get('/api/shops/$slug/products') as List<dynamic>;
    return _mapRows(rows);
  }

  Future<List<Product>> _fetchMine() async {
    final rows = await _api.get('/api/products') as List<dynamic>;
    return _mapRows(rows);
  }

  Future<Product?> getById(String id) async {
    if (AppConfig.useDemo) {
      for (final product in DemoMemoryStore.instance.products) {
        if (product.id == id) return product;
      }
      return null;
    }
    final all = await _fetchMine();
    for (final product in all) {
      if (product.id == id) return product;
    }
    return null;
  }

  Future<void> upsert(Product product) async {
    if (AppConfig.useDemo) {
      final store = DemoMemoryStore.instance;
      final idx = store.products.indexWhere((p) => p.id == product.id);
      if (idx >= 0) {
        store.products[idx] = product;
      } else {
        store.products.add(product);
      }
      store.emitProducts();
      return;
    }
    await _api.put('/api/products/${product.id}', product.toJson());
  }

  Future<void> delete(String id) async {
    if (AppConfig.useDemo) {
      DemoMemoryStore.instance.products.removeWhere((p) => p.id == id);
      DemoMemoryStore.instance.emitProducts();
      return;
    }
    await _api.delete('/api/products/$id');
  }

  Future<void> reorder(List<Product> ordered) async {
    if (AppConfig.useDemo) {
      for (var i = 0; i < ordered.length; i++) {
        await upsert(ordered[i].copyWith(sortOrder: i, updatedAt: DateTime.now()));
      }
      return;
    }
    await _api.post('/api/products/reorder', {
      'ids': ordered.map((p) => p.id).toList(),
    });
  }

  Future<Product> duplicate(Product product) async {
    final copy = product.copyWith(
      id: _uuid.v4(),
      name: '${product.name} (copy)',
      isPublished: false,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
    await upsert(copy);
    return copy;
  }

  Future<void> bulkAdjustPrice({
    required String category,
    required bool percent,
    required double amount,
  }) async {
    if (AppConfig.useDemo) {
      final now = DateTime.now();
      final store = DemoMemoryStore.instance;
      for (var i = 0; i < store.products.length; i++) {
        final p = store.products[i];
        if (p.category != category) continue;
        final next = percent ? p.price * (1 + amount / 100) : p.price + amount;
        store.products[i] = p.copyWith(price: next < 0 ? 0 : next, updatedAt: now);
      }
      store.emitProducts();
      return;
    }
    await _api.post('/api/products/bulk-price', {
      'category': category,
      'percent': percent,
      'amount': amount,
    });
  }

  Future<String> uploadImage(Uint8List bytes, {String? ownerId}) async {
    final compressed = await compressForUpload(bytes);
    if (AppConfig.useDemo) {
      return 'asset:assets/products/baby_rex.svg';
    }
    return _api.upload('/api/files', compressed);
  }

  List<Product> _mapRows(List<dynamic> rows) {
    return rows
        .map((row) => Product.fromJson(Map<String, dynamic>.from(row as Map)))
        .toList()
      ..sort((a, b) => a.sortOrder.compareTo(b.sortOrder));
  }
}
