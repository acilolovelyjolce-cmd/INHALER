import 'dart:typed_data';

import 'package:uuid/uuid.dart';

import '../config/env.dart';
import '../models/catalog_sort.dart';
import '../models/part_kind.dart';
import '../models/parts_catalog.dart';
import '../models/product.dart';
import 'api_client.dart';
import 'app_store.dart';
import 'image_compress.dart';
import 'poll.dart';

class ProductsRepository {
  ProductsRepository();

  final _uuid = const Uuid();
  final _api = ApiClient.instance;

  Stream<List<Product>> watchPublished(String slug) async* {
    if (AppConfig.useDemo) {
      final store = DemoMemoryStore.instance;
      List<Product> published() => CatalogSort.parse(store.owner.catalogSort).apply(
            store.products.where((p) => p.isPublished),
          );
      yield published();
      yield* store.productsCtrl.stream.map((_) => published());
      return;
    }
    var last = <Product>[];
    Future<List<Product>> once({required bool staleOk}) async {
      try {
        last = await _fetchPublished(slug);
        return last;
      } catch (_) {
        if (staleOk && last.isNotEmpty) return last;
        if (!staleOk) {
          try {
            last = await _fetchPublished(slug);
            return last;
          } catch (retryError) {
            if (last.isNotEmpty) return last;
            rethrow;
          }
        }
        rethrow;
      }
    }
    yield await once(staleOk: false);
    yield* Stream.periodic(const Duration(seconds: 4)).asyncMap((_) => once(staleOk: true));
  }

  Stream<List<Product>> watchAll() async* {
    if (AppConfig.useDemo) {
      final store = DemoMemoryStore.instance;
      List<Product> sorted() => [...store.products]..sort((a, b) => a.sortOrder.compareTo(b.sortOrder));
      yield sorted();
      yield* store.productsCtrl.stream.map((_) => sorted());
      return;
    }
    yield* pollKeepingLast(_fetchMine);
  }

  Future<List<Product>> _fetchPublished(String slug) async {
    final rows = await _api.get('/api/shops/$slug/products', auth: false) as List<dynamic>;
    return _mapRows(rows, sortByOrder: false);
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
      DemoMemoryStore.instance.upsertProduct(product);
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

  Stream<PartsCatalog> watchParts() async* {
    if (AppConfig.useDemo) {
      final store = DemoMemoryStore.instance;
      yield store.partsCatalog;
      yield* store.partsCtrl.stream;
      return;
    }
    yield* pollKeepingLast(fetchParts);
  }

  Future<PartsCatalog> fetchParts() async {
    if (AppConfig.useDemo) return DemoMemoryStore.instance.partsCatalog;
    try {
      final row = await _api.get('/api/parts');
      if (row is Map) {
        return PartsCatalog.fromJson(Map<String, dynamic>.from(row));
      }
    } catch (_) {}
    try {
      return _partsFromProducts(await _fetchMine());
    } on ApiException {
      return const PartsCatalog();
    }
  }

  Future<void> upsertPart(ProductOption option, {required PartKind kind}) async {
    if (AppConfig.useDemo) {
      DemoMemoryStore.instance.upsertPart(option, kind: kind);
      return;
    }
    try {
      await _api.put('/api/parts/${option.id}', {
        'id': option.id,
        'name': option.name,
        'price': option.price,
        'stock': option.stock,
        'kind': kind.apiValue,
        if (option.imageUrl != null && option.imageUrl!.trim().isNotEmpty) 'image_url': option.imageUrl,
      });
    } on ApiException catch (error) {
      if (error.status != 404) rethrow;
      await _fanOutPart(option, kind: kind);
    }
  }

  Future<void> deletePart(String id) async {
    if (AppConfig.useDemo) {
      DemoMemoryStore.instance.deletePart(id);
      return;
    }
    try {
      await _api.delete('/api/parts/$id');
    } on ApiException catch (error) {
      if (error.status != 404) rethrow;
      final products = await _fetchMine();
      for (final product in products) {
        await upsert(
          product.copyWith(
            paracords: [for (final option in product.paracords) if (option.id != id) option],
            trinkets: [for (final option in product.trinkets) if (option.id != id) option],
            letterings: [for (final option in product.letterings) if (option.id != id) option],
            ropes: [for (final option in product.ropes) if (option.id != id) option],
            specialTrinkets: [
              for (final option in product.specialTrinkets)
                if (option.id != id) option,
            ],
            updatedAt: DateTime.now(),
          ),
        );
      }
    }
  }

  Future<void> _fanOutPart(ProductOption option, {required PartKind kind}) async {
    final products = await _fetchMine();
    for (final product in products) {
      List<ProductOption> next(List<ProductOption> current) {
        final list = [...current];
        final idx = list.indexWhere((item) => item.id == option.id);
        if (idx >= 0) {
          list[idx] = option;
        } else {
          list.add(option);
        }
        return list;
      }

      await upsert(
        product.copyWith(
          paracords: kind == PartKind.paracord ? next(product.paracords) : product.paracords,
          trinkets: kind == PartKind.trinket ? next(product.trinkets) : product.trinkets,
          letterings: kind == PartKind.lettering ? next(product.letterings) : product.letterings,
          ropes: kind == PartKind.rope ? next(product.ropes) : product.ropes,
          specialTrinkets:
              kind == PartKind.specialTrinket ? next(product.specialTrinkets) : product.specialTrinkets,
          updatedAt: DateTime.now(),
        ),
      );
    }
  }

  PartsCatalog _partsFromProducts(List<Product> products) {
    final cords = <String, ProductOption>{};
    final charms = <String, ProductOption>{};
    final letters = <String, ProductOption>{};
    final ropeBag = <String, ProductOption>{};
    final specials = <String, ProductOption>{};
    for (final product in products) {
      for (final option in product.paracords) {
        cords[option.id] = option;
      }
      for (final option in product.trinkets) {
        charms[option.id] = option;
      }
      for (final option in product.letterings) {
        letters[option.id] = option;
      }
      for (final option in product.ropes) {
        ropeBag[option.id] = option;
      }
      for (final option in product.specialTrinkets) {
        specials[option.id] = option;
      }
    }
    return PartsCatalog(
      paracords: cords.values.toList(),
      trinkets: charms.values.toList(),
      letterings: letters.values.toList(),
      ropes: ropeBag.values.toList(),
      specialTrinkets: specials.values.toList(),
    );
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
    required bool percent,
    required double amount,
  }) async {
    if (AppConfig.useDemo) {
      final now = DateTime.now();
      final store = DemoMemoryStore.instance;
      for (var i = 0; i < store.products.length; i++) {
        final p = store.products[i];
        final next = percent ? p.price * (1 + amount / 100) : p.price + amount;
        store.products[i] = p.copyWith(price: next < 0 ? 0 : next, updatedAt: now);
      }
      store.emitProducts();
      return;
    }
    await _api.post('/api/products/bulk-price', {
      'percent': percent,
      'amount': amount,
    });
  }

  Future<String> uploadImage(Uint8List bytes, {String? ownerId}) async {
    final compressed = await compressForUpload(bytes, maxWidth: 720);
    if (AppConfig.useDemo) {
      return 'asset:assets/products/baby_rex.svg';
    }
    return _api.upload('/api/files', compressed);
  }

  List<Product> _mapRows(List<dynamic> rows, {bool sortByOrder = true}) {
    final products = <Product>[];
    for (final row in rows) {
      if (row is! Map) continue;
      try {
        final product = Product.fromJson(Map<String, dynamic>.from(row));
        if (product.id.isEmpty || product.name.isEmpty) continue;
        products.add(product);
      } catch (_) {}
    }
    if (sortByOrder) {
      products.sort((a, b) => a.sortOrder.compareTo(b.sortOrder));
    }
    return products;
  }
}
