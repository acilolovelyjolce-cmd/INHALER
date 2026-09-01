// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'product.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_ProductOption _$ProductOptionFromJson(Map<String, dynamic> json) =>
    _ProductOption(
      id: json['id'] as String,
      name: json['name'] as String,
      price: const NumDoubleConverter().fromJson(json['price']),
      imageUrl: json['image_url'] as String?,
      stock: json['stock'] == null
          ? 0
          : const IntConverter().fromJson(json['stock']),
    );

Map<String, dynamic> _$ProductOptionToJson(_ProductOption instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'price': const NumDoubleConverter().toJson(instance.price),
      'image_url': instance.imageUrl,
      'stock': const IntConverter().toJson(instance.stock),
    };

_Product _$ProductFromJson(Map<String, dynamic> json) => _Product(
  id: json['id'] as String,
  ownerId: json['owner_id'] as String?,
  name: json['name'] as String,
  description: json['description'] as String,
  price: const NumDoubleConverter().fromJson(json['price']),
  compareAtPrice: const NullableNumDoubleConverter().fromJson(
    json['compare_at_price'],
  ),
  imageUrls: const StringListConverter().fromJson(json['image_urls']),
  category: json['category'] as String,
  paracords: json['paracords'] == null
      ? const []
      : const ProductOptionListConverter().fromJson(json['paracords']),
  trinkets: json['trinkets'] == null
      ? const []
      : const ProductOptionListConverter().fromJson(json['trinkets']),
  stockStatus: $enumDecode(_$StockStatusEnumMap, json['stock_status']),
  isPublished: json['is_published'] as bool,
  sortOrder: (json['sort_order'] as num).toInt(),
  createdAt: DateTime.parse(json['created_at'] as String),
  updatedAt: DateTime.parse(json['updated_at'] as String),
);

Map<String, dynamic> _$ProductToJson(_Product instance) => <String, dynamic>{
  'id': instance.id,
  'owner_id': instance.ownerId,
  'name': instance.name,
  'description': instance.description,
  'price': const NumDoubleConverter().toJson(instance.price),
  'compare_at_price': const NullableNumDoubleConverter().toJson(
    instance.compareAtPrice,
  ),
  'image_urls': const StringListConverter().toJson(instance.imageUrls),
  'category': instance.category,
  'paracords': const ProductOptionListConverter().toJson(instance.paracords),
  'trinkets': const ProductOptionListConverter().toJson(instance.trinkets),
  'stock_status': _$StockStatusEnumMap[instance.stockStatus]!,
  'is_published': instance.isPublished,
  'sort_order': instance.sortOrder,
  'created_at': instance.createdAt.toIso8601String(),
  'updated_at': instance.updatedAt.toIso8601String(),
};

const _$StockStatusEnumMap = {
  StockStatus.available: 'available',
  StockStatus.madeToOrder: 'made_to_order',
  StockStatus.soldOut: 'sold_out',
};
