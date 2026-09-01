import 'product.dart';

class PartsCatalog {
  const PartsCatalog({
    this.paracords = const [],
    this.trinkets = const [],
  });

  factory PartsCatalog.fromJson(Map<String, dynamic> json) {
    const options = ProductOptionListConverter();
    return PartsCatalog(
      paracords: options.fromJson(json['paracords']),
      trinkets: options.fromJson(json['trinkets']),
    );
  }

  final List<ProductOption> paracords;
  final List<ProductOption> trinkets;

  List<ProductOption> of(String kind) => kind == 'trinket' ? trinkets : paracords;
}
