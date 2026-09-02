Stream<T> pollKeepingLast<T>(
  Future<T> Function() fetch, {
  Duration period = const Duration(seconds: 12),
}) async* {
  T? last;
  var hasLast = false;

  Future<T> once({required bool staleOk}) async {
    try {
      final next = await fetch();
      last = next;
      hasLast = true;
      return next;
    } catch (error) {
      if (staleOk && hasLast) return last as T;
      rethrow;
    }
  }

  yield await once(staleOk: false);
  yield* Stream.periodic(period).asyncMap((_) => once(staleOk: true));
}
