import 'package:flutter_test/flutter_test.dart';
import 'package:whimsical_hub/data/demo_catalog.dart';
import 'package:whimsical_hub/data/option_stock.dart';
import 'package:whimsical_hub/models/order_request.dart';
import 'package:whimsical_hub/models/product.dart';

OrderItem _line({
  required Product product,
  required int quantity,
  ProductOption? paracord,
  List<ProductOption> trinkets = const [],
}) {
  return OrderItem(
    productId: product.id,
    productName: product.name,
    quantity: quantity,
    priceAtOrder: product.price,
    paracord: paracord?.toJson(),
    trinkets: [for (final item in trinkets) item.toJson()],
  );
}

void main() {
  test('checkout is not blocked when the cart option is missing from the catalog', () {
    final products = demoProducts();
    final items = [
      _line(
        product: products.first,
        quantity: 1,
        paracord: const ProductOption(id: 'ghost-cord', name: 'Ghost', price: 0, stock: 1),
      ),
    ];
    expect(OptionStock.shortage(products, items), isNull);
  });

  test('checkout is blocked when a paracord really does not have enough left', () {
    final products = demoProducts();
    final cord = demoCords.first.copyWith(stock: 1);
    final catalog = [
      products.first.copyWith(paracords: [cord], stock: 10),
    ];
    final items = [
      _line(product: catalog.first, quantity: 2, paracord: cord),
    ];
    expect(OptionStock.shortage(catalog, items), contains('Mint paracord'));
  });

  test('checkout is blocked when the inhaler itself is out', () {
    final product = demoProducts().first.copyWith(stock: 1);
    final items = [_line(product: product, quantity: 2, paracord: demoCords.first)];
    expect(OptionStock.shortage([product], items), contains(product.name));
  });

  test('placing an order decrements inhaler and option stock', () {
    final product = demoProducts().first.copyWith(stock: 5);
    final items = [
      _line(
        product: product,
        quantity: 2,
        paracord: product.paracords.first,
        trinkets: [product.trinkets.first],
      ),
    ];
    final next = OptionStock.apply([product], items, sign: -1).first;
    expect(next.stock, 3);
    expect(next.paracords.first.stock, product.paracords.first.stock - 2);
    expect(next.trinkets.first.stock, product.trinkets.first.stock - 2);
  });

  test('made-to-order inhalers skip quantity tracking', () {
    final product = demoProducts()[1];
    expect(product.stockStatus, StockStatus.madeToOrder);
    final items = [_line(product: product, quantity: 4, paracord: demoCords.first)];
    expect(OptionStock.shortage([product], items), isNull);
    final next = OptionStock.apply([product], items, sign: -1).first;
    expect(next.stock, product.stock);
    expect(next.stockStatus, StockStatus.madeToOrder);
  });
}
