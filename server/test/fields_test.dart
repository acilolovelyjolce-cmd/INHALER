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

  test('parsePartKind accepts lettering and special trinket names', () {
    expect(parsePartKind('trinket'), 'trinket');
    expect(parsePartKind('lettering'), 'lettering');
    expect(parsePartKind('letter'), 'lettering');
    expect(parsePartKind('special_trinket'), 'special_trinket');
    expect(parsePartKind('special trinket'), 'special_trinket');
    expect(parsePartKind('rope'), 'rope');
    expect(parsePartKind('ropes'), 'rope');
    expect(parsePartKind(null), 'paracord');
  });

  test('parseCatalogSort maps shop display names', () {
    expect(parseCatalogSort(null), 'manual');
    expect(parseCatalogSort('cheapest'), 'price_asc');
    expect(parseCatalogSort('price_desc'), 'price_desc');
    expect(parseCatalogSort('name_asc'), 'name_asc');
    expect(parseCatalogSort('az'), 'name_asc');
  });

  test('reorderMapsByIds writes the owner arrange order onto product options', () {
    final next = reorderMapsByIds(
      [
        {'id': 'c', 'name': 'Coral', 'price': 80, 'sort_order': 0},
        {'id': 'a', 'name': 'Aqua', 'price': 20, 'sort_order': 1},
        {'id': 'b', 'name': 'Berry', 'price': 40, 'sort_order': 2},
      ],
      ['a', 'b', 'c'],
    );
    expect([for (final row in next) row['id']], ['a', 'b', 'c']);
    expect([for (final row in next) row['sort_order']], [0, 1, 2]);
  });

  test('reorderMapsByIds keeps options that were not in the arrange list', () {
    final next = reorderMapsByIds(
      [
        {'id': 'keep', 'name': 'Keep'},
        {'id': 'move', 'name': 'Move'},
      ],
      ['move'],
    );
    expect([for (final row in next) row['id']], ['move', 'keep']);
  });

  test('applyCatalogSortToProductRow sorts customer add-ons the same way', () {
    final row = applyCatalogSortToProductRow(
      {
        'name': 'Baby Rex',
        'price': 350,
        'sort_order': 0,
        'trinkets': [
          {'id': 'rex', 'name': 'Baby Rex', 'price': 80, 'sort_order': 0},
          {'id': 'star', 'name': 'Tiny Star', 'price': 20, 'sort_order': 1},
        ],
      },
      'price_asc',
    );
    final trinkets = row['trinkets'] as List;
    expect(trinkets.first['id'], 'star');
    expect(trinkets.last['id'], 'rex');
  });
}
