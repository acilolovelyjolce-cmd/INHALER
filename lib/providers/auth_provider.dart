import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../config/env.dart';
import '../data/app_store.dart';
import '../data/owner_repository.dart';
import '../data/session_store.dart';

part 'auth_provider.g.dart';

@Riverpod(keepAlive: true)
OwnerRepository ownerRepository(OwnerRepositoryRef ref) => OwnerRepository();

@Riverpod(keepAlive: true)
class Auth extends _$Auth {
  @override
  Stream<AuthSnapshot> build() async* {
    yield SessionStore.instance.snapshot;
    if (AppConfig.useDemo) {
      yield* DemoMemoryStore.instance.authCtrl.stream.map(
        (signedIn) => signedIn
            ? const AuthSnapshot(signedIn: true, userId: 'demo-owner')
            : AuthSnapshot.signedOut,
      );
      return;
    }
    yield* SessionStore.instance.changes;
  }

  Future<void> signIn(String email, String password) {
    return ref.read(ownerRepositoryProvider).signIn(email, password);
  }

  Future<void> signOut() => ref.read(ownerRepositoryProvider).signOut();
}

bool get isSignedInNow {
  if (AppConfig.useDemo) return DemoMemoryStore.instance.signedIn;
  return SessionStore.instance.signedIn;
}
