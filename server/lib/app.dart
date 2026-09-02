import 'dart:io';

import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart' as io;
import 'package:shelf_cors_headers/shelf_cors_headers.dart';
import 'package:shelf_static/shelf_static.dart';

import 'env.dart';
import 'fields.dart';
import 'http_util.dart';
import 'migrate.dart';
import 'mongo.dart';
import 'routes.dart';
import 'share_preview.dart';

Future<void> serveWhimsical() async {
  await Mongo.instance.connect();
  await runMigrations();

  final api = const Pipeline()
      .addMiddleware(logRequests())
      .addMiddleware(_jsonErrors())
      .addMiddleware(
        corsHeaders(
          headers: {
            ACCESS_CONTROL_ALLOW_HEADERS: 'Origin, Content-Type, Authorization',
            ACCESS_CONTROL_ALLOW_METHODS: 'GET, POST, PUT, DELETE, OPTIONS',
          },
        ),
      )
      .addHandler(buildRouter().call);

  final webRoot = Env.webRoot;
  final hasWeb = Directory(webRoot).existsSync();
  Handler handler = api;
  if (hasWeb) {
    final staticHandler = createStaticHandler(
      webRoot,
      defaultDocument: 'index.html',
    );
    handler = (Request request) async {
      if (request.url.path.startsWith('api/')) {
        return api(request);
      }
      if (shouldInjectShareMeta(request.url.path)) {
        final index = File('$webRoot/index.html');
        if (index.existsSync()) {
          final template = index.readAsStringSync();
          ShareMeta meta;
          try {
            meta = await shareMetaFor(request);
          } catch (error, stack) {
            stderr.writeln('[whimsical] share meta: $error\n$stack');
            meta = ShareMeta.fallback(originFromRequest(request));
          }
          return Response.ok(
            injectShareMeta(template, meta),
            headers: {
              HttpHeaders.contentTypeHeader: 'text/html; charset=utf-8',
              HttpHeaders.cacheControlHeader: 'public, max-age=60',
            },
          );
        }
      }
      final result = await staticHandler(request);
      if (result.statusCode != 404) return result;
      final index = File('$webRoot/index.html');
      if (!index.existsSync()) return result;
      return Response.ok(
        index.readAsBytesSync(),
        headers: {HttpHeaders.contentTypeHeader: 'text/html; charset=utf-8'},
      );
    };
  }

  final server = await io.serve(handler, InternetAddress.anyIPv4, Env.port);
  stdoutLog('Listening on http://${server.address.host}:${server.port}');
  if (hasWeb) stdoutLog('Serving Flutter web from $webRoot');
}

Middleware _jsonErrors() {
  return (inner) {
    return (Request request) async {
      try {
        return await inner(request);
      } on BadRequest catch (error) {
        return jsonError(400, error.message);
      } catch (error, stack) {
        stderr.writeln('[whimsical] ${request.method} /${request.url}: $error\n$stack');
        final write = request.method == 'POST' ||
            request.method == 'PUT' ||
            request.method == 'DELETE';
        if (isMongoDisconnect(error) && request.method != 'POST') {
          try {
            await Mongo.instance.reconnect();
            return await inner(request);
          } catch (retryError, retryStack) {
            stderr.writeln('[whimsical] retry ${request.method} /${request.url}: $retryError\n$retryStack');
            return jsonError(503, 'The nest is waking up. Tap save once more.');
          }
        }
        if (write) {
          return jsonError(400, 'Could not save that just now. Check the fields and try again.');
        }
        return jsonError(500, 'The nest hiccuped. Try again in a moment.');
      }
    };
  };
}

void stdoutLog(String message) {
  // ignore: avoid_print
  print('[whimsical] $message');
}
