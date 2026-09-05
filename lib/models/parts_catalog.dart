import 'part_kind.dart';
import 'product.dart';

class PartsCatalog {
  const PartsCatalog({
    this.paracords = const [],
    this.trinkets = const [],
    this.letterings = const [],
    this.ropes = const [],
    this.specialTrinkets = const [],
  });

  factory PartsCatalog.fromJson(Map<String, dynamic> json) {
    const options = ProductOptionListConverter();
    return PartsCatalog(
      paracords: options.fromJson(json['paracords']),
      trinkets: options.fromJson(json['trinkets']),
      letterings: options.fromJson(json['letterings']),
      ropes: options.fromJson(json['ropes']),
      specialTrinkets: options.fromJson(json['special_trinkets']),
    );
  }

  final List<ProductOption> paracords;
  final List<ProductOption> trinkets;
  final List<ProductOption> letterings;
  final List<ProductOption> ropes;
  final List<ProductOption> specialTrinkets;

  List<ProductOption> of(PartKind kind) => switch (kind) {
        PartKind.paracord => paracords,
        PartKind.trinket => trinkets,
        PartKind.lettering => letterings,
        PartKind.rope => ropes,
        PartKind.specialTrinket => specialTrinkets,
      };

  PartsCatalog withKind(PartKind kind, List<ProductOption> options) => switch (kind) {
        PartKind.paracord => PartsCatalog(
            paracords: options,
            trinkets: trinkets,
            letterings: letterings,
            ropes: ropes,
            specialTrinkets: specialTrinkets,
          ),
        PartKind.trinket => PartsCatalog(
            paracords: paracords,
            trinkets: options,
            letterings: letterings,
            ropes: ropes,
            specialTrinkets: specialTrinkets,
          ),
        PartKind.lettering => PartsCatalog(
            paracords: paracords,
            trinkets: trinkets,
            letterings: options,
            ropes: ropes,
            specialTrinkets: specialTrinkets,
          ),
        PartKind.rope => PartsCatalog(
            paracords: paracords,
            trinkets: trinkets,
            letterings: letterings,
            ropes: options,
            specialTrinkets: specialTrinkets,
          ),
        PartKind.specialTrinket => PartsCatalog(
            paracords: paracords,
            trinkets: trinkets,
            letterings: letterings,
            ropes: ropes,
            specialTrinkets: options,
          ),
      };

  int get totalCount =>
      paracords.length +
      trinkets.length +
      letterings.length +
      ropes.length +
      specialTrinkets.length;
}
