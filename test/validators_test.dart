import 'package:flutter_test/flutter_test.dart';
import 'package:whimsical_hub/config/validators.dart';

void main() {
  test('name rejects blanks and overlong copy', () {
    expect(Validators.name(''), 'Name is required');
    expect(Validators.name('   \n\t  '), 'Name is required');
    expect(Validators.name('Baby Rex'), isNull);
    expect(Validators.name('x' * 81), 'Name is too long');
  });

  test('name keeps special characters and trims indent', () {
    expect(Validators.name('  Baby "Rex" & Co.  '), isNull);
    expect(Validators.cleanLine('\tBaby Rex\n'), 'Baby Rex');
    expect(Validators.cleanLine("Rex's #1 charm (mint)!"), "Rex's #1 charm (mint)!");
    expect(Validators.name('🦖 mint-speckled'), isNull);
    expect(Validators.cleanLine('Baby\u200bRex'), 'BabyRex');
  });

  test('description keeps indented lines', () {
    const copy = 'Line one\n  indented two\n\tthree';
    expect(Validators.optionalText(copy, max: 600, label: 'Description'), isNull);
    expect(Validators.cleanMultiline(copy), 'Line one\n  indented two\n\tthree');
    expect(Validators.optionalText('  \n  '), isNull);
  });

  test('price accepts pesos and rejects junk', () {
    expect(Validators.price('450'), isNull);
    expect(Validators.price('₱1,200'), isNull);
    expect(Validators.price('  PHP 1,200.50  '), isNull);
    expect(Validators.parseMoney('₱1,200'), 1200);
    expect(Validators.parseMoney('1\u00a0200'), 1200);
    expect(Validators.price('-1'), 'Enter a valid price');
    expect(Validators.price('12.3.4'), 'Enter a valid price');
    expect(Validators.optionalPrice(''), isNull);
    expect(Validators.optionalPrice('   '), isNull);
  });

  test('stock must be a whole number', () {
    expect(Validators.stock('0'), isNull);
    expect(Validators.stock('12'), isNull);
    expect(Validators.stock(' 12 '), isNull);
    expect(Validators.parseStock('1,200'), 1200);
    expect(Validators.stock('1.5'), 'Enter a whole number');
    expect(Validators.stock('-2'), 'Enter a whole number');
  });

  test('slug and contact stay picky in the right ways', () {
    expect(Validators.slug('whimsical'), isNull);
    expect(Validators.slug('Tiny Charms'), 'Use lowercase letters, numbers, and hyphens');
    expect(Validators.contact('ab'), 'Add a number or social we can reach');
    expect(Validators.contact('09XX 555'), isNull);
    expect(Validators.contactKey('gcash'), isNull);
    expect(Validators.contactKey('ig.handle'), 'Use letters without dots');
    expect(Validators.contactKey(r'$gt'), 'Use letters without dots');
  });

  test('signed amounts allow discounts', () {
    expect(Validators.signedAmount('-10'), isNull);
    expect(Validators.signedAmount('10'), isNull);
    expect(Validators.signedAmount('−10'), isNull);
    expect(Validators.parseMoney('−10', allowNegative: true), -10);
    expect(Validators.signedAmount('nope'), 'Enter a valid amount');
  });
}
