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
    Map<String, dynamic>? variants,
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
