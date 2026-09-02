import 'dart:typed_data';

import '../config/env.dart';
import '../models/owner_profile.dart';
import 'api_client.dart';
import 'app_store.dart';
import 'demo_catalog.dart';
import 'image_compress.dart';
import 'session_store.dart';

class OwnerRepository {
  OwnerRepository();

  final _api = ApiClient.instance;

  Stream<OwnerProfile?> watchBySlug(String slug) async* {
    if (AppConfig.useDemo) {
      final store = DemoMemoryStore.instance;
      if (store.owner.shopSlug == slug) {
        yield store.owner;
        yield* store.ownerCtrl.stream.map((o) => o.shopSlug == slug ? o : null);
      } else {
        yield null;
      }
      return;
    }
    OwnerProfile? last;
    Future<OwnerProfile?> once() async {
      try {
        last = await fetchBySlug(slug);
        return last;
      } catch (_) {
        if (last != null) return last;
        rethrow;
      }
    }
    yield await once();
    yield* Stream.periodic(const Duration(seconds: 8)).asyncMap((_) => once());
  }

  Stream<OwnerProfile?> watchMine() async* {
    if (AppConfig.useDemo) {
      final store = DemoMemoryStore.instance;
      yield store.owner;
      yield* store.ownerCtrl.stream;
      return;
    }
    yield await _fetchMe();
    yield* Stream.periodic(const Duration(seconds: 8)).asyncMap((_) => _fetchMe());
  }

  Future<OwnerProfile?> fetchBySlug(String slug) async {
    if (AppConfig.useDemo) {
      final owner = DemoMemoryStore.instance.owner;
      return owner.shopSlug == slug ? owner : null;
    }
    try {
      final row = await _api.get('/api/shops/$slug', auth: false) as Map<String, dynamic>;
      return OwnerProfile.fromJson(Map<String, dynamic>.from(row));
    } on ApiException catch (error) {
      if (error.status == 404) return null;
      rethrow;
    }
  }

  Future<OwnerProfile?> _fetchMe() async {
    if (!SessionStore.instance.signedIn) return null;
    final row = await _api.get('/api/me') as Map<String, dynamic>;
    return OwnerProfile.fromJson(row);
  }

  Future<void> upsert(OwnerProfile profile) async {
    if (AppConfig.useDemo) {
      DemoMemoryStore.instance.owner = profile;
      DemoMemoryStore.instance.emitOwner();
      return;
    }
    await _api.put('/api/me', profile.toJson());
  }

  Future<String> uploadLogo(Uint8List bytes) async {
    final compressed = await compressForUpload(bytes, maxWidth: 800);
    if (AppConfig.useDemo) {
      const url = 'asset:assets/doodles/dino_mascot.svg';
      DemoMemoryStore.instance.owner =
          DemoMemoryStore.instance.owner.copyWith(logoUrl: url);
      DemoMemoryStore.instance.emitOwner();
      return url;
    }
    return _api.upload('/api/me/logo', compressed);
  }

  Future<String> uploadWalletQr(Uint8List bytes) async {
    final compressed = await compressForUpload(bytes, maxWidth: 1200);
    if (AppConfig.useDemo) {
      const url = 'asset:assets/doodles/doodle_sparkle.svg';
      DemoMemoryStore.instance.owner =
          DemoMemoryStore.instance.owner.copyWith(ewalletQrUrl: url);
      DemoMemoryStore.instance.emitOwner();
      return url;
    }
    return _api.upload('/api/me/ewallet-qr', compressed);
  }

  Future<AuthSnapshot> signIn(String email, String password) async {
    if (AppConfig.useDemo) {
      DemoMemoryStore.instance.signedIn = true;
      DemoMemoryStore.instance.authCtrl.add(true);
      await SessionStore.instance.save(newToken: 'demo', newUserId: demoOwnerId);
      return const AuthSnapshot(signedIn: true, userId: demoOwnerId);
    }
    final row = await _api.post('/api/auth/login', {
      'email': email,
      'password': password,
    }) as Map<String, dynamic>;
    final user = Map<String, dynamic>.from(row['user'] as Map);
    await SessionStore.instance.save(
      newToken: row['token'] as String,
      newUserId: user['id'] as String,
    );
    return AuthSnapshot(signedIn: true, userId: user['id'] as String);
  }

  Future<void> signOut() async {
    if (AppConfig.useDemo) {
      DemoMemoryStore.instance.signedIn = false;
      DemoMemoryStore.instance.authCtrl.add(false);
    }
    await SessionStore.instance.clear();
  }
}
