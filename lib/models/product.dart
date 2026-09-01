import 'package:freezed_annotation/freezed_annotation.dart';

import 'converters.dart';

part 'product.freezed.dart';
part 'product.g.dart';

enum StockStatus {
  @JsonValue('available')
  available,
  @JsonValue('made_to_order')
  madeToOrder,
  @JsonValue('sold_out')
  soldOut,
}

@freezed
abstract class ProductOption with _$ProductOption {
  @JsonSerializable(fieldRename: FieldRename.snake, explicitToJson: true)
  const factory ProductOption({
    required String id,
    required String name,
    @NumDoubleConverter() required double price,
    @JsonKey(name: 'image_url') String? imageUrl,
    @IntConverter() @Default(0) int stock,
  }) = _ProductOption;

  factory ProductOption.fromJson(Map<String, dynamic> json) =>
      _$ProductOptionFromJson(json);
}

class ProductOptionListConverter implements JsonConverter<List<ProductOption>, dynamic> {
  const ProductOptionListConverter();

  @override
  List<ProductOption> fromJson(dynamic json) {
    if (json is! List) return const [];
    return [
      for (final row in json)
        if (row is Map)
          ProductOption.fromJson(Map<String, dynamic>.from(row)),
    ];
  }

  @override
  dynamic toJson(List<ProductOption> object) =>
      object.map((item) => item.toJson()).toList();
}

@freezed
abstract class Product with _$Product {
  @JsonSerializable(fieldRename: FieldRename.snake, explicitToJson: true)
  const factory Product({
    required String id,
    @JsonKey(name: 'owner_id') String? ownerId,
    required String name,
    required String description,
    @NumDoubleConverter() required double price,
    @NullableNumDoubleConverter() @JsonKey(name: 'compare_at_price') double? compareAtPrice,
    @StringListConverter() @JsonKey(name: 'image_urls') required List<String> imageUrls,
    required String category,
    @ProductOptionListConverter() @Default([]) List<ProductOption> paracords,
    @ProductOptionListConverter() @Default([]) List<ProductOption> trinkets,
    @JsonKey(name: 'stock_status') required StockStatus stockStatus,
    @JsonKey(name: 'is_published') required bool isPublished,
    @JsonKey(name: 'sort_order') required int sortOrder,
    @JsonKey(name: 'created_at') required DateTime createdAt,
    @JsonKey(name: 'updated_at') required DateTime updatedAt,
  }) = _Product;

  factory Product.fromJson(Map<String, dynamic> json) => _$ProductFromJson(json);
}

extension StockStatusX on StockStatus {
  String get label => switch (this) {
        StockStatus.available => 'in the nest',
        StockStatus.madeToOrder => 'made to order',
        StockStatus.soldOut => 'all gone for now',
      };
}

extension ProductPricingX on Product {
  double linePrice({ProductOption? paracord, List<ProductOption> pickedTrinkets = const []}) {
    return price +
        (paracord?.price ?? 0) +
        pickedTrinkets.fold<double>(0, (sum, item) => sum + item.price);
  }

  String get optionStockSummary {
    final bits = [
      for (final option in [...paracords, ...trinkets]) '${option.name} ${option.stock}',
    ];
    if (bits.isEmpty) return '';
    return bits.take(4).join(' · ');
  }
}
