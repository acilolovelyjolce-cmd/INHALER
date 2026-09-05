import 'dart:async';

import 'package:test/test.dart';
import 'package:whimsical_server/mongo.dart';

void main() {
  test('only real socket drops count as a disconnect', () {
    expect(isMongoDisconnect(StateError('MongoDB is not connected')), isTrue);
    expect(isMongoDisconnect('SocketException: Connection reset by peer'), isTrue);
    expect(isMongoDisconnect('No master connection'), isTrue);
    expect(isMongoDisconnect('DB is not open. State.INIT'), isTrue);
  });

  test('ordinary request errors do not open a new Mongo client', () {
    expect(isMongoDisconnect('Could not save that just now'), isFalse);
    expect(isMongoDisconnect(TimeoutException('Request timed out')), isFalse);
    expect(isMongoDisconnect(StateError('Name and contact are required')), isFalse);
    expect(isMongoDisconnect('connection pool warning'), isFalse);
  });

  test('Atlas URI keeps the password and turns TLS on', () {
    const raw =
        'mongodb+srv://user:p%40ss@cluster0.xxxx.mongodb.net/whimsical_hub?retryWrites=true&w=majority';
    final normalized = normalizeMongoUri(raw);
    expect(normalized.contains('user:p%40ss@'), isTrue);
    expect(normalized.contains('tls=true'), isTrue);
    expect(normalized.contains('ssl=true'), isTrue);
    expect(normalized.contains('safeAtlas=true'), isTrue);
    expect(normalizeMongoUri('$raw&tls=true'), isNot(contains('tls=true&tls=true')));
  });

  test('TLS handshake errors count as a dropped socket', () {
    expect(
      isTlsHandshake(
        'HandshakeException: Handshake error in client (OS Error: TLSV1_ALERT_INTERNAL_ERROR)',
      ),
      isTrue,
    );
  });
}
