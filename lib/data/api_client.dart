import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../config/env.dart';
import 'session_store.dart';

class ApiException implements Exception {
  ApiException(this.message, {this.status});

  final String message;
  final int? status;

  @override
  String toString() => message;
}

class ApiClient {
  ApiClient({http.Client? httpClient}) : _http = httpClient ?? http.Client();

  static final ApiClient instance = ApiClient();

  final http.Client _http;
  final _inflightGets = <String, Future<dynamic>>{};

  static String get origin {
    if (AppConfig.apiUrl.isNotEmpty && AppConfig.apiUrl != 'demo') {
      return AppConfig.apiUrl.replaceAll(RegExp(r'/$'), '');
    }
    if (kIsWeb) {
      final base = Uri.base.origin;
      if (base.isNotEmpty && base != 'null') return base;
    }
    return AppConfig.publicBaseUrl.replaceAll(RegExp(r'/$'), '');
  }

  static String resolveMedia(String url) {
    if (url.startsWith('asset:') || url.startsWith('http://') || url.startsWith('https://')) {
      return url;
    }
    if (url.startsWith('/')) return '$origin$url';
    return url;
  }

  Uri _uri(String path) => Uri.parse('$origin$path');

  String _encode(Object body) {
    try {
      return jsonEncode(body);
    } catch (_) {
      throw ApiException('That form could not be sent. Check the fields and try again.');
    }
  }

  Map<String, String> _headers({bool json = true, bool auth = true}) {
    return {
      if (json) 'Content-Type': 'application/json',
      if (auth && SessionStore.instance.token != null)
        'Authorization': 'Bearer ${SessionStore.instance.token}',
    };
  }

  static const _timeout = Duration(seconds: 12);

  Future<dynamic> get(String path, {bool auth = true}) async {
    final key = '${auth ? '1' : '0'}:$path';
    return _inflightGets.putIfAbsent(key, () async {
      try {
        return await _withRetry(() async {
          final response = await _http
              .get(
                _uri(path),
                headers: _headers(json: false, auth: auth),
              )
              .timeout(_timeout);
          return _decode(response);
        });
      } finally {
        _inflightGets.remove(key);
      }
    });
  }

  Future<dynamic> post(String path, [Object? body]) async {
    return _withRetry(() async {
      final response = await _http
          .post(
            _uri(path),
            headers: _headers(),
            body: body == null ? null : _encode(body),
          )
          .timeout(_timeout);
      return _decode(response);
    }, attempts: 2);
  }

  Future<dynamic> put(String path, [Object? body]) async {
    return _withRetry(() async {
      final response = await _http
          .put(
            _uri(path),
            headers: _headers(),
            body: body == null ? null : _encode(body),
          )
          .timeout(_timeout);
      return _decode(response);
    }, attempts: 2);
  }

  Future<dynamic> delete(String path) async {
    return _withRetry(() async {
      final response = await _http
          .delete(_uri(path), headers: _headers(json: false))
          .timeout(_timeout);
      return _decode(response);
    }, attempts: 2);
  }

  Future<String> upload(String path, Uint8List bytes, {String contentType = 'image/jpeg'}) async {
    return _withRetry(() async {
      final response = await _http
          .post(
            _uri(path),
            headers: {
              'Content-Type': contentType,
              if (SessionStore.instance.token != null)
                'Authorization': 'Bearer ${SessionStore.instance.token}',
            },
            body: bytes,
          )
          .timeout(_timeout);
      final decoded = _decode(response);
      if (decoded is Map && decoded['url'] is String) {
        return decoded['url'] as String;
      }
      throw ApiException('Upload did not return a url');
    }, attempts: 2);
  }

  Future<T> _withRetry<T>(Future<T> Function() run, {int attempts = 3}) async {
    Object? last;
    for (var attempt = 0; attempt < attempts; attempt++) {
      try {
        return await run();
      } on ApiException catch (error) {
        last = error;
        final status = error.status ?? 0;
        if (status < 500 || attempt == attempts - 1) rethrow;
      } catch (error) {
        last = error;
        if (attempt == attempts - 1) rethrow;
      }
      await Future<void>.delayed(Duration(milliseconds: 160 * (attempt + 1)));
    }
    throw last!;
  }

  dynamic _decode(http.Response response) {
    if (response.statusCode == 401) {
      SessionStore.instance.clear();
    }
    final raw = response.body.trim();
    if (raw.isEmpty) {
      if (response.statusCode >= 400) {
        throw ApiException(_failMessage(response.statusCode), status: response.statusCode);
      }
      return null;
    }
    Object? decoded;
    try {
      decoded = jsonDecode(raw);
    } on FormatException {
      throw ApiException(_failMessage(response.statusCode), status: response.statusCode);
    }
    if (response.statusCode >= 400) {
      final message = decoded is Map ? (decoded['error'] ?? decoded['message']) : null;
      throw ApiException(
        message?.toString() ?? _failMessage(response.statusCode),
        status: response.statusCode,
      );
    }
    return decoded;
  }

  static String _failMessage(int status) {
    if (status >= 500) return 'The nest hiccuped. Try again in a moment.';
    if (status == 401) return 'Please sign in again.';
    return 'Request failed';
  }
}
