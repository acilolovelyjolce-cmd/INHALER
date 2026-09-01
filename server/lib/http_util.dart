import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:shelf/shelf.dart';

Response jsonOk(Object body, {int status = 200}) {
  return Response(
    status,
    body: jsonEncode(body),
    headers: {HttpHeaders.contentTypeHeader: 'application/json; charset=utf-8'},
  );
}

Response jsonError(int status, String message) {
  return jsonOk({'error': message}, status: status);
}

Future<Map<String, dynamic>> readJson(Request request) async {
  final raw = await request.readAsString();
  if (raw.trim().isEmpty) return {};
  final decoded = jsonDecode(raw);
  if (decoded is Map<String, dynamic>) return decoded;
  if (decoded is Map) return Map<String, dynamic>.from(decoded);
  throw const FormatException('Expected a JSON object');
}

Map<String, dynamic> apiDoc(Map<String, dynamic> doc) {
  final out = <String, dynamic>{};
  doc.forEach((key, value) {
    if (key == 'password_hash') return;
    out[key == '_id' ? 'id' : key] = _jsonValue(value);
  });
  return out;
}

Object? _jsonValue(Object? value) {
  if (value is DateTime) return value.toUtc().toIso8601String();
  if (value is Map) {
    return value.map((key, item) => MapEntry(key.toString(), _jsonValue(item)));
  }
  if (value is Iterable && value is! String && value is! Uint8List) {
    return value.map(_jsonValue).toList();
  }
  return value;
}

DateTime parseDate(Object? value, {DateTime? fallback}) {
  if (value is DateTime) return value.toUtc();
  if (value is String && value.isNotEmpty) {
    return DateTime.tryParse(value)?.toUtc() ?? fallback ?? DateTime.now().toUtc();
  }
  return fallback ?? DateTime.now().toUtc();
}
