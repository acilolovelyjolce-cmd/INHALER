// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'order_request.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_OrderItem _$OrderItemFromJson(Map<String, dynamic> json) => _OrderItem(
  productId: json['product_id'] as String,
  productName: json['product_name'] as String,
  variantSelection: json['variant_selection'] as Map<String, dynamic>?,
  quantity: (json['quantity'] as num).toInt(),
  priceAtOrder: const NumDoubleConverter().fromJson(json['price_at_order']),
);

Map<String, dynamic> _$OrderItemToJson(
  _OrderItem instance,
) => <String, dynamic>{
  'product_id': instance.productId,
  'product_name': instance.productName,
  'variant_selection': instance.variantSelection,
  'quantity': instance.quantity,
  'price_at_order': const NumDoubleConverter().toJson(instance.priceAtOrder),
};

_OrderRequest _$OrderRequestFromJson(Map<String, dynamic> json) =>
    _OrderRequest(
      id: json['id'] as String,
      shopSlug: json['shop_slug'] as String,
      customerName: json['customer_name'] as String,
      customerContact: json['customer_contact'] as String,
      items: (json['items'] as List<dynamic>)
          .map((e) => OrderItem.fromJson(e as Map<String, dynamic>))
          .toList(),
      totalAmount: const NumDoubleConverter().fromJson(json['total_amount']),
      customerNote: json['customer_note'] as String?,
      status: $enumDecode(_$OrderStatusEnumMap, json['status']),
      paymentStatus: $enumDecode(
        _$PaymentStatusEnumMap,
        json['payment_status'],
      ),
      internalNotes: json['internal_notes'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );

Map<String, dynamic> _$OrderRequestToJson(_OrderRequest instance) =>
    <String, dynamic>{
      'id': instance.id,
      'shop_slug': instance.shopSlug,
      'customer_name': instance.customerName,
      'customer_contact': instance.customerContact,
      'items': instance.items.map((e) => e.toJson()).toList(),
      'total_amount': const NumDoubleConverter().toJson(instance.totalAmount),
      'customer_note': instance.customerNote,
      'status': _$OrderStatusEnumMap[instance.status]!,
      'payment_status': _$PaymentStatusEnumMap[instance.paymentStatus]!,
      'internal_notes': instance.internalNotes,
      'created_at': instance.createdAt.toIso8601String(),
      'updated_at': instance.updatedAt.toIso8601String(),
    };

const _$OrderStatusEnumMap = {
  OrderStatus.newRequest: 'new_request',
  OrderStatus.confirmed: 'confirmed',
  OrderStatus.preparing: 'preparing',
  OrderStatus.ready: 'ready',
  OrderStatus.completed: 'completed',
  OrderStatus.cancelled: 'cancelled',
};

const _$PaymentStatusEnumMap = {
  PaymentStatus.unpaid: 'unpaid',
  PaymentStatus.paid: 'paid',
  PaymentStatus.partial: 'partial',
};
