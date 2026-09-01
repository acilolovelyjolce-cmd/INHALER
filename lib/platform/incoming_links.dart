String? locationFromIncomingUri(Uri uri) {
  if (uri.scheme == 'whimsical') {
    final parts = [if (uri.host.isNotEmpty) uri.host, ...uri.pathSegments]
        .where((part) => part.isNotEmpty)
        .toList();
    if (parts.isEmpty) return '/dashboard';
    return '/${parts.join('/')}';
  }

  final path = uri.path;
  if (path.startsWith('/shop/') || path.startsWith('/dashboard')) {
    return path;
  }
  return null;
}
