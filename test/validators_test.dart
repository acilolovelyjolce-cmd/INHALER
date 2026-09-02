import 'package:flutter_test/flutter_test.dart';
import 'package:whimsical_hub/config/validators.dart';

void main() {
  test('name rejects blanks and overlong copy', () {
    expect(Validators.name(''), 'Name is required');
    expect(Validators.name('Baby Rex'), isNull);
    expect(Validators.name('x' * 81), 'Name is too long');
  });

  test('price accepts pesos and rejects junk', () {
    expect(Validators.price('450'), isNull);
    expect(Validators.price('₱1,200'), isNull);
    expect(Validators.price('-1'), 'Enter a valid price');
    expect(Validators.price('12.3.4'), 'Enter a valid price');
    expect(Validators.optionalPrice(''), isNull);
  });

  test('stock must be a whole number', () {
    expect(Validators.stock('0'), isNull);
    expect(Validators.stock('12'), isNull);
    expect(Validators.stock('1.5'), 'Enter a whole number');
    expect(Validators.stock('-2'), 'Enter a whole number');
  });

  test('slug and contact stay picky in the right ways', () {
    expect(Validators.slug('whimsical'), isNull);
    expect(Validators.slug('Tiny Charms'), 'Use lowercase letters, numbers, and hyphens');
    expect(Validators.contact('ab'), 'Add a number or social we can reach');
    expect(Validators.contact('09XX 555'), isNull);
  });

  test('signed amounts allow discounts', () {
    expect(Validators.signedAmount('-10'), isNull);
    expect(Validators.signedAmount('10'), isNull);
    expect(Validators.signedAmount('nope'), 'Enter a valid amount');
  });
}
