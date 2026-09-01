import 'package:bcrypt/bcrypt.dart';
import 'package:dart_jsonwebtoken/dart_jsonwebtoken.dart';
import 'package:mongo_dart/mongo_dart.dart';
import 'package:shelf/shelf.dart';

import 'env.dart';
import 'mongo.dart';

Map<String, dynamic>? ownerFromToken(String? token) {
  if (token == null || token.isEmpty) return null;
  try {
    final jwt = JWT.verify(token, SecretKey(Env.jwtSecret));
    final payload = jwt.payload;
    if (payload is Map) return Map<String, dynamic>.from(payload);
  } catch (_) {
    return null;
  }
  return null;
}

String? bearer(Request request) {
  final header = request.headers['authorization'];
  if (header != null && header.toLowerCase().startsWith('bearer ')) {
    return header.substring(7).trim();
  }
  return request.url.queryParameters['token'];
}

Future<Map<String, dynamic>?> ownerFromRequest(Request request) async {
  final claims = ownerFromToken(bearer(request));
  final id = claims?['sub'] as String?;
  if (id == null) return null;
  return Mongo.instance.owners.findOne(where.eq('_id', id));
}

String signOwner(Map<String, dynamic> owner) {
  final jwt = JWT({
    'sub': owner['_id'],
    'slug': owner['shop_slug'],
    'email': owner['email'],
  });
  return jwt.sign(SecretKey(Env.jwtSecret), expiresIn: const Duration(days: 14));
}

bool passwordMatches(String password, String hash) {
  try {
    return BCrypt.checkpw(password, hash);
  } catch (_) {
    return false;
  }
}
