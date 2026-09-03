import 'package:freezed_annotation/freezed_annotation.dart';

import 'converters.dart';

part 'order_request.freezed.dart';
part 'order_request.g.dart';

enum OrderStatus {
  @JsonValue('new_request')
  newRequest,
  @JsonValue('confirmed')
  confirmed,
  @JsonValue('preparing')
  preparing,
  @JsonValue('ready')
  ready,
  @JsonValue('completed')
  completed,
  @JsonValue('cancelled')
  cancelled,
}

enum PaymentMethod {
  @JsonValue('e_wallet')
  eWallet,
  @JsonValue('cash')
  cash,
}

enum PaymentStatus {
  @JsonValue('unpaid')
  unpaid,
  @JsonValue('paid')
  paid,
  @JsonValue('partial')
  partial,
}

@freezed
abstract class OrderItem with _$OrderItem {
  @JsonSerializable(fieldRename: FieldRename.snake, explicitToJson: true)
  const factory OrderItem({
    @JsonKey(name: 'product_id') required String productId,
    @JsonKey(name: 'product_name') required String productName,
    @JsonKey(name: 'variant_selection') Map<String, dynamic>? variantSelection,
    required int quantity,
    @NumDoubleConverter() @JsonKey(name: 'price_at_order') required double priceAtOrder,
    Map<String, dynamic>? paracord,
    List<Map<String, dynamic>>? trinkets,
    List<Map<String, dynamic>>? letterings,
    Map<String, dynamic>? rope,
    @JsonKey(name: 'special_trinkets') List<Map<String, dynamic>>? specialTrinkets,
  }) = _OrderItem;

  factory OrderItem.fromJson(Map<String, dynamic> json) => _$OrderItemFromJson(json);
}

@freezed
abstract class OrderRequest with _$OrderRequest {
  @JsonSerializable(fieldRename: FieldRename.snake, explicitToJson: true)
  const factory OrderRequest({
    required String id,
    @JsonKey(name: 'shop_slug') required String shopSlug,
    @JsonKey(name: 'customer_name') required String customerName,
    @JsonKey(name: 'customer_contact') required String customerContact,
    required List<OrderItem> items,
    @NumDoubleConverter() @JsonKey(name: 'total_amount') required double totalAmount,
    @JsonKey(name: 'customer_note') String? customerNote,
    required OrderStatus status,
    @JsonKey(name: 'payment_status') required PaymentStatus paymentStatus,
    @JsonKey(name: 'payment_method') PaymentMethod? paymentMethod,
    @JsonKey(name: 'internal_notes') String? internalNotes,
    @JsonKey(name: 'created_at') required DateTime createdAt,
    @JsonKey(name: 'updated_at') required DateTime updatedAt,
  }) = _OrderRequest;

  factory OrderRequest.fromJson(Map<String, dynamic> json) =>
      _$OrderRequestFromJson(json);
}

extension OrderStatusX on OrderStatus {
  String get label => switch (this) {
        OrderStatus.newRequest => 'New',
        OrderStatus.confirmed => 'Confirmed',
        OrderStatus.preparing => 'Preparing',
        OrderStatus.ready => 'Ready',
        OrderStatus.completed => 'Completed',
        OrderStatus.cancelled => 'Cancelled',
      };

  OrderStatus? get next => switch (this) {
        OrderStatus.newRequest => OrderStatus.confirmed,
        OrderStatus.confirmed => OrderStatus.preparing,
        OrderStatus.preparing => OrderStatus.ready,
        OrderStatus.ready => OrderStatus.completed,
        OrderStatus.completed => null,
        OrderStatus.cancelled => null,
      };
}

extension PaymentMethodX on PaymentMethod {
  String get label => switch (this) {
        PaymentMethod.eWallet => 'E-wallet',
        PaymentMethod.cash => 'Cash',
      };
}

extension PaymentStatusX on PaymentStatus {
  String get label => switch (this) {
        PaymentStatus.unpaid => 'Unpaid',
        PaymentStatus.paid => 'Paid',
        PaymentStatus.partial => 'Partial',
      };
}
