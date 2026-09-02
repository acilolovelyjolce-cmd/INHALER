import 'package:mongo_dart/mongo_dart.dart';
import 'package:test/test.dart';
import 'package:whimsical_server/fields.dart';

void main() {
  test('asString keeps uuids and object ids', () {
    expect(asString('cord-mint'), 'cord-mint');
    expect(asString(ObjectId.fromHexString('64b64b64b64b64b64b64b64b')), '64b64b64b64b64b64b64b64b');
    expect(asString(12), '12');
    expect(asString(null), isEmpty);
  });

  test('sameId compares mongo ids as text', () {
    final id = ObjectId.fromHexString('64b64b64b64b64b64b64b64b');
    expect(sameId(id, '64b64b64b64b64b64b64b64b'), isTrue);
    expect(sameId('abc', 'abc'), isTrue);
    expect(sameId('abc', 'xyz'), isFalse);
    expect(sameId(null, 'abc'), isFalse);
  });

  test('bsonMap drops operator keys and non-finite numbers', () {
    final safe = bsonMap({
      '_id': 'part-1',
      'name': 'Mint paracord',
      'price': double.nan,
      r'$where': 'drop',
      'nested.bad': 1,
      'stock': '8',
      'options': [
        {'id': 'x', 'name': 'X', 'price': 40, 'image_url': null},
      ],
    });
    expect(safe['_id'], 'part-1');
    expect(safe['price'], 0);
    expect(safe.containsKey(r'$where'), isFalse);
    expect(safe.containsKey('nested.bad'), isFalse);
    expect(safe['options'], isA<List>());
    expect((safe['options'] as List).first['image_url'], isNull);
  });

  test('parseMoney and parseInt accept messy typed values', () {
    expect(parseMoney('₱40'), 40);
    expect(parseMoney(40), 40);
    expect(parseMoney('  12.5 '), 12.5);
    expect(parseInt(' 12 '), 12);
    expect(parseInt(null), 0);
    expect(parseInt(8.9), 8);
  });
}
