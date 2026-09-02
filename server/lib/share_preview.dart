import 'package:mongo_dart/mongo_dart.dart';
import 'package:shelf/shelf.dart';

import 'env.dart';
import 'fields.dart';
import 'http_util.dart';
import 'mongo.dart';

class ShareMeta {
  const ShareMeta({
    required this.title,
    required this.description,
    required this.url,
    required this.image,
    required this.siteName,
  });

  final String title;
  final String description;
  final String url;
  final String image;
  final String siteName;

  factory ShareMeta.fallback(String origin, {String? slug}) {
    final shop = slug ?? Env.shopSlug;
    return ShareMeta(
      title: Env.shopName,
      description: Env.ownerBio,
      url: '$origin/shop/$shop',
      image: '$origin/icons/Icon-512.png',
      siteName: Env.shopName,
    );
  }
}

String originFromRequest(Request request) {
  final configured = Env.publicBaseUrl.replaceAll(RegExp(r'/$'), '');
  if (configured.isNotEmpty) return configured;
  final proto = request.headers['x-forwarded-proto'] ??
      (request.requestedUri.scheme.isEmpty ? 'https' : request.requestedUri.scheme);
  final host = request.headers['x-forwarded-host'] ??
      request.headers['host'] ??
      request.requestedUri.host;
  if (host.isEmpty) return 'https://inhaler.onrender.com';
  return '$proto://$host';
}

String? slugFromPath(String path) {
  final match = RegExp(r'(?:^|/)shop/([^/]+)').firstMatch(path);
  return match?.group(1);
}

String? productIdFromPath(String path) {
  final match = RegExp(r'(?:^|/)shop/[^/]+/product/([^/]+)').firstMatch(path);
  return match?.group(1);
}

bool shouldInjectShareMeta(String path) {
  if (path.startsWith('api/')) return false;
  final last = path.split('/').last;
  if (last.contains('.') && !last.endsWith('.html')) return false;
  return true;
}

String absoluteUrl(String origin, String url) {
  final trimmed = url.trim();
  if (trimmed.startsWith('https://') || trimmed.startsWith('http://')) return trimmed;
  if (trimmed.startsWith('/')) return '$origin$trimmed';
  return '$origin/$trimmed';
}

Future<ShareMeta> shareMetaFor(Request request) async {
  final origin = originFromRequest(request);
  final slug = slugFromPath(request.url.path) ?? Env.shopSlug;
  final fallback = ShareMeta.fallback(origin, slug: slug);
  try {
    final owner = await Mongo.instance.owners.findOne(where.eq('shop_slug', slug));
    if (owner == null) return fallback;

    final name = cleanLine(owner['shop_name'] ?? Env.shopName, max: 80);
    final headline = cleanLine(owner['headline'], max: 80);
    final bio = cleanMultiline(owner['bio'] ?? Env.ownerBio, max: 240);
    final description = headline.isNotEmpty ? headline : (bio.isNotEmpty ? bio : fallback.description);
    final stamp = parseDate(owner['updated_at']).millisecondsSinceEpoch;
    var image = '$origin/api/shops/$slug/share-image?v=$stamp';

    final productId = productIdFromPath(request.url.path);
    var title = name.isEmpty ? fallback.title : name;
    var pageUrl = '$origin/shop/$slug';
    if (productId != null && productId.isNotEmpty) {
      final product = await Mongo.instance.products.findOne(
        where.eq('_id', productId).eq('shop_slug', slug),
      );
      if (product != null && product['is_published'] != false) {
        final productName = cleanLine(product['name'], max: 80);
        if (productName.isNotEmpty) title = productName;
        pageUrl = '$origin/shop/$slug/product/$productId';
        final urls = product['image_urls'];
        if (urls is List) {
          for (final raw in urls) {
            final url = asString(raw).trim();
            if (url.isEmpty || url.startsWith('asset:')) continue;
            image = absoluteUrl(origin, url);
            break;
          }
        }
      }
    }

    return ShareMeta(
      title: title,
      description: description,
      url: pageUrl,
      image: image,
      siteName: name.isEmpty ? fallback.siteName : name,
    );
  } catch (_) {
    return fallback;
  }
}

String injectShareMeta(String html, ShareMeta meta) {
  final title = _escape(meta.title);
  final description = _escape(meta.description);
  final url = _escape(meta.url);
  final image = _escape(meta.image);
  final site = _escape(meta.siteName);
  final tags = '''
  <meta name="description" content="$description">
  <meta property="og:type" content="website">
  <meta property="og:site_name" content="$site">
  <meta property="og:title" content="$title">
  <meta property="og:description" content="$description">
  <meta property="og:url" content="$url">
  <meta property="og:image" content="$image">
  <meta property="og:image:secure_url" content="$image">
  <meta property="og:image:alt" content="$title">
  <meta property="og:image:width" content="512">
  <meta property="og:image:height" content="512">
  <meta name="twitter:card" content="summary_large_image">
  <meta name="twitter:title" content="$title">
  <meta name="twitter:description" content="$description">
  <meta name="twitter:image" content="$image">
  <link rel="canonical" href="$url">
''';
  var next = html.replaceFirst(
    RegExp(r'<title>[^<]*</title>'),
    '<title>$title</title>',
  );
  next = next.replaceAll(
    RegExp(
      r'[ \t]*<meta[^>]*(?:name="(?:description|twitter:[^"]*)"|property="og:[^"]*")[^>]*>\s*',
      caseSensitive: false,
    ),
    '',
  );
  next = next.replaceAll(
    RegExp(r'[ \t]*<link rel="canonical"[^>]*>\s*', caseSensitive: false),
    '',
  );
  if (next.contains('</head>')) {
    next = next.replaceFirst('</head>', '$tags</head>');
  }
  return next;
}

String _escape(String value) {
  return value
      .replaceAll('&', '&amp;')
      .replaceAll('<', '&lt;')
      .replaceAll('>', '&gt;')
      .replaceAll('"', '&quot;');
}
