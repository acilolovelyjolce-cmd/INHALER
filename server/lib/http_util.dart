import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:mongo_dart/mongo_dart.dart';
import 'package:shelf/shelf.dart';

import 'fields.dart';

const _jsonHeaders = {HttpHeaders.contentTypeHeader: 'application/json; charset=utf-8'};

Response jsonOk(Object body, {int status = 200}) {
  try {
    return Response(status, body: jsonEncode(body), headers: _jsonHeaders);
  } catch (error, stack) {
    stderr.writeln('[whimsical] jsonOk failed: $error\n$stack');
    return Response(
      500,
      body: jsonEncode({'error': 'Could not read that just now.'}),
      headers: _jsonHeaders,
    );
  }
}

Response jsonError(int status, String message) {
  return jsonOk({'error': message}, status: status);
}

Future<Map<String, dynamic>> readJson(Request request) async {
  try {
    final raw = await request.readAsString();
    if (raw.trim().isEmpty) return {};
    final decoded = jsonDecode(raw);
    if (decoded is Map<String, dynamic>) return decoded;
    if (decoded is Map) return Map<String, dynamic>.from(decoded);
    throw BadRequest('That form could not be read.');
  } on BadRequest {
    rethrow;
  } on FormatException {
    throw BadRequest('That form could not be read.');
  }
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
  if (value == null) return null;
  if (value is DateTime) return value.toUtc().toIso8601String();
  if (value is ObjectId) return value.oid;
  if (value is Map) {
    return {
      for (final entry in value.entries) entry.key.toString(): _jsonValue(entry.value),
    };
  }
  if (value is Iterable && value is! String && value is! TypedData) {
    return [for (final item in value) _jsonValue(item)];
  }
  if (value is num || value is bool || value is String) return value;
  return value.toString();
}

DateTime parseDate(Object? value, {DateTime? fallback}) {
  if (value is DateTime) return value.toUtc();
  if (value is String && value.isNotEmpty) {
    return DateTime.tryParse(value)?.toUtc() ?? fallback ?? DateTime.now().toUtc();
  }
  return fallback ?? DateTime.now().toUtc();
}
