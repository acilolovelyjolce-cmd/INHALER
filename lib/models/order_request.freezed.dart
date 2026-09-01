// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'order_request.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$OrderItem {

@JsonKey(name: 'product_id') String get productId;@JsonKey(name: 'product_name') String get productName;@JsonKey(name: 'variant_selection') Map<String, dynamic>? get variantSelection; int get quantity;@NumDoubleConverter()@JsonKey(name: 'price_at_order') double get priceAtOrder; Map<String, dynamic>? get paracord; List<Map<String, dynamic>>? get trinkets;
/// Create a copy of OrderItem
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$OrderItemCopyWith<OrderItem> get copyWith => _$OrderItemCopyWithImpl<OrderItem>(this as OrderItem, _$identity);

  /// Serializes this OrderItem to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is OrderItem&&(identical(other.productId, productId) || other.productId == productId)&&(identical(other.productName, productName) || other.productName == productName)&&const DeepCollectionEquality().equals(other.variantSelection, variantSelection)&&(identical(other.quantity, quantity) || other.quantity == quantity)&&(identical(other.priceAtOrder, priceAtOrder) || other.priceAtOrder == priceAtOrder)&&const DeepCollectionEquality().equals(other.paracord, paracord)&&const DeepCollectionEquality().equals(other.trinkets, trinkets));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,productId,productName,const DeepCollectionEquality().hash(variantSelection),quantity,priceAtOrder,const DeepCollectionEquality().hash(paracord),const DeepCollectionEquality().hash(trinkets));

@override
String toString() {
  return 'OrderItem(productId: $productId, productName: $productName, variantSelection: $variantSelection, quantity: $quantity, priceAtOrder: $priceAtOrder, paracord: $paracord, trinkets: $trinkets)';
}


}

/// @nodoc
abstract mixin class $OrderItemCopyWith<$Res>  {
  factory $OrderItemCopyWith(OrderItem value, $Res Function(OrderItem) _then) = _$OrderItemCopyWithImpl;
@useResult
$Res call({
@JsonKey(name: 'product_id') String productId,@JsonKey(name: 'product_name') String productName,@JsonKey(name: 'variant_selection') Map<String, dynamic>? variantSelection, int quantity,@NumDoubleConverter()@JsonKey(name: 'price_at_order') double priceAtOrder, Map<String, dynamic>? paracord, List<Map<String, dynamic>>? trinkets
});




}
/// @nodoc
class _$OrderItemCopyWithImpl<$Res>
    implements $OrderItemCopyWith<$Res> {
  _$OrderItemCopyWithImpl(this._self, this._then);

  final OrderItem _self;
  final $Res Function(OrderItem) _then;

/// Create a copy of OrderItem
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? productId = null,Object? productName = null,Object? variantSelection = freezed,Object? quantity = null,Object? priceAtOrder = null,Object? paracord = freezed,Object? trinkets = freezed,}) {
  return _then(_self.copyWith(
productId: null == productId ? _self.productId : productId // ignore: cast_nullable_to_non_nullable
as String,productName: null == productName ? _self.productName : productName // ignore: cast_nullable_to_non_nullable
as String,variantSelection: freezed == variantSelection ? _self.variantSelection : variantSelection // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>?,quantity: null == quantity ? _self.quantity : quantity // ignore: cast_nullable_to_non_nullable
as int,priceAtOrder: null == priceAtOrder ? _self.priceAtOrder : priceAtOrder // ignore: cast_nullable_to_non_nullable
as double,paracord: freezed == paracord ? _self.paracord : paracord // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>?,trinkets: freezed == trinkets ? _self.trinkets : trinkets // ignore: cast_nullable_to_non_nullable
as List<Map<String, dynamic>>?,
  ));
}

}


/// Adds pattern-matching-related methods to [OrderItem].
extension OrderItemPatterns on OrderItem {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _OrderItem value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _OrderItem() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _OrderItem value)  $default,){
final _that = this;
switch (_that) {
case _OrderItem():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _OrderItem value)?  $default,){
final _that = this;
switch (_that) {
case _OrderItem() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(name: 'product_id')  String productId, @JsonKey(name: 'product_name')  String productName, @JsonKey(name: 'variant_selection')  Map<String, dynamic>? variantSelection,  int quantity, @NumDoubleConverter()@JsonKey(name: 'price_at_order')  double priceAtOrder,  Map<String, dynamic>? paracord,  List<Map<String, dynamic>>? trinkets)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _OrderItem() when $default != null:
return $default(_that.productId,_that.productName,_that.variantSelection,_that.quantity,_that.priceAtOrder,_that.paracord,_that.trinkets);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(name: 'product_id')  String productId, @JsonKey(name: 'product_name')  String productName, @JsonKey(name: 'variant_selection')  Map<String, dynamic>? variantSelection,  int quantity, @NumDoubleConverter()@JsonKey(name: 'price_at_order')  double priceAtOrder,  Map<String, dynamic>? paracord,  List<Map<String, dynamic>>? trinkets)  $default,) {final _that = this;
switch (_that) {
case _OrderItem():
return $default(_that.productId,_that.productName,_that.variantSelection,_that.quantity,_that.priceAtOrder,_that.paracord,_that.trinkets);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(name: 'product_id')  String productId, @JsonKey(name: 'product_name')  String productName, @JsonKey(name: 'variant_selection')  Map<String, dynamic>? variantSelection,  int quantity, @NumDoubleConverter()@JsonKey(name: 'price_at_order')  double priceAtOrder,  Map<String, dynamic>? paracord,  List<Map<String, dynamic>>? trinkets)?  $default,) {final _that = this;
switch (_that) {
case _OrderItem() when $default != null:
return $default(_that.productId,_that.productName,_that.variantSelection,_that.quantity,_that.priceAtOrder,_that.paracord,_that.trinkets);case _:
  return null;

}
}

}

/// @nodoc

@JsonSerializable(fieldRename: FieldRename.snake, explicitToJson: true)
class _OrderItem implements OrderItem {
  const _OrderItem({@JsonKey(name: 'product_id') required this.productId, @JsonKey(name: 'product_name') required this.productName, @JsonKey(name: 'variant_selection') final  Map<String, dynamic>? variantSelection, required this.quantity, @NumDoubleConverter()@JsonKey(name: 'price_at_order') required this.priceAtOrder, final  Map<String, dynamic>? paracord, final  List<Map<String, dynamic>>? trinkets}): _variantSelection = variantSelection,_paracord = paracord,_trinkets = trinkets;
  factory _OrderItem.fromJson(Map<String, dynamic> json) => _$OrderItemFromJson(json);

@override@JsonKey(name: 'product_id') final  String productId;
@override@JsonKey(name: 'product_name') final  String productName;
 final  Map<String, dynamic>? _variantSelection;
@override@JsonKey(name: 'variant_selection') Map<String, dynamic>? get variantSelection {
  final value = _variantSelection;
  if (value == null) return null;
  if (_variantSelection is EqualUnmodifiableMapView) return _variantSelection;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(value);
}

@override final  int quantity;
@override@NumDoubleConverter()@JsonKey(name: 'price_at_order') final  double priceAtOrder;
 final  Map<String, dynamic>? _paracord;
@override Map<String, dynamic>? get paracord {
  final value = _paracord;
  if (value == null) return null;
  if (_paracord is EqualUnmodifiableMapView) return _paracord;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(value);
}

 final  List<Map<String, dynamic>>? _trinkets;
@override List<Map<String, dynamic>>? get trinkets {
  final value = _trinkets;
  if (value == null) return null;
  if (_trinkets is EqualUnmodifiableListView) return _trinkets;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(value);
}


/// Create a copy of OrderItem
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$OrderItemCopyWith<_OrderItem> get copyWith => __$OrderItemCopyWithImpl<_OrderItem>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$OrderItemToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _OrderItem&&(identical(other.productId, productId) || other.productId == productId)&&(identical(other.productName, productName) || other.productName == productName)&&const DeepCollectionEquality().equals(other._variantSelection, _variantSelection)&&(identical(other.quantity, quantity) || other.quantity == quantity)&&(identical(other.priceAtOrder, priceAtOrder) || other.priceAtOrder == priceAtOrder)&&const DeepCollectionEquality().equals(other._paracord, _paracord)&&const DeepCollectionEquality().equals(other._trinkets, _trinkets));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,productId,productName,const DeepCollectionEquality().hash(_variantSelection),quantity,priceAtOrder,const DeepCollectionEquality().hash(_paracord),const DeepCollectionEquality().hash(_trinkets));

@override
String toString() {
  return 'OrderItem(productId: $productId, productName: $productName, variantSelection: $variantSelection, quantity: $quantity, priceAtOrder: $priceAtOrder, paracord: $paracord, trinkets: $trinkets)';
}


}

/// @nodoc
abstract mixin class _$OrderItemCopyWith<$Res> implements $OrderItemCopyWith<$Res> {
  factory _$OrderItemCopyWith(_OrderItem value, $Res Function(_OrderItem) _then) = __$OrderItemCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(name: 'product_id') String productId,@JsonKey(name: 'product_name') String productName,@JsonKey(name: 'variant_selection') Map<String, dynamic>? variantSelection, int quantity,@NumDoubleConverter()@JsonKey(name: 'price_at_order') double priceAtOrder, Map<String, dynamic>? paracord, List<Map<String, dynamic>>? trinkets
});




}
/// @nodoc
class __$OrderItemCopyWithImpl<$Res>
    implements _$OrderItemCopyWith<$Res> {
  __$OrderItemCopyWithImpl(this._self, this._then);

  final _OrderItem _self;
  final $Res Function(_OrderItem) _then;

/// Create a copy of OrderItem
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? productId = null,Object? productName = null,Object? variantSelection = freezed,Object? quantity = null,Object? priceAtOrder = null,Object? paracord = freezed,Object? trinkets = freezed,}) {
  return _then(_OrderItem(
productId: null == productId ? _self.productId : productId // ignore: cast_nullable_to_non_nullable
as String,productName: null == productName ? _self.productName : productName // ignore: cast_nullable_to_non_nullable
as String,variantSelection: freezed == variantSelection ? _self._variantSelection : variantSelection // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>?,quantity: null == quantity ? _self.quantity : quantity // ignore: cast_nullable_to_non_nullable
as int,priceAtOrder: null == priceAtOrder ? _self.priceAtOrder : priceAtOrder // ignore: cast_nullable_to_non_nullable
as double,paracord: freezed == paracord ? _self._paracord : paracord // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>?,trinkets: freezed == trinkets ? _self._trinkets : trinkets // ignore: cast_nullable_to_non_nullable
as List<Map<String, dynamic>>?,
  ));
}


}


/// @nodoc
mixin _$OrderRequest {

 String get id;@JsonKey(name: 'shop_slug') String get shopSlug;@JsonKey(name: 'customer_name') String get customerName;@JsonKey(name: 'customer_contact') String get customerContact; List<OrderItem> get items;@NumDoubleConverter()@JsonKey(name: 'total_amount') double get totalAmount;@JsonKey(name: 'customer_note') String? get customerNote; OrderStatus get status;@JsonKey(name: 'payment_status') PaymentStatus get paymentStatus;@JsonKey(name: 'payment_method') PaymentMethod? get paymentMethod;@JsonKey(name: 'internal_notes') String? get internalNotes;@JsonKey(name: 'created_at') DateTime get createdAt;@JsonKey(name: 'updated_at') DateTime get updatedAt;
/// Create a copy of OrderRequest
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$OrderRequestCopyWith<OrderRequest> get copyWith => _$OrderRequestCopyWithImpl<OrderRequest>(this as OrderRequest, _$identity);

  /// Serializes this OrderRequest to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is OrderRequest&&(identical(other.id, id) || other.id == id)&&(identical(other.shopSlug, shopSlug) || other.shopSlug == shopSlug)&&(identical(other.customerName, customerName) || other.customerName == customerName)&&(identical(other.customerContact, customerContact) || other.customerContact == customerContact)&&const DeepCollectionEquality().equals(other.items, items)&&(identical(other.totalAmount, totalAmount) || other.totalAmount == totalAmount)&&(identical(other.customerNote, customerNote) || other.customerNote == customerNote)&&(identical(other.status, status) || other.status == status)&&(identical(other.paymentStatus, paymentStatus) || other.paymentStatus == paymentStatus)&&(identical(other.paymentMethod, paymentMethod) || other.paymentMethod == paymentMethod)&&(identical(other.internalNotes, internalNotes) || other.internalNotes == internalNotes)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,shopSlug,customerName,customerContact,const DeepCollectionEquality().hash(items),totalAmount,customerNote,status,paymentStatus,paymentMethod,internalNotes,createdAt,updatedAt);

@override
String toString() {
  return 'OrderRequest(id: $id, shopSlug: $shopSlug, customerName: $customerName, customerContact: $customerContact, items: $items, totalAmount: $totalAmount, customerNote: $customerNote, status: $status, paymentStatus: $paymentStatus, paymentMethod: $paymentMethod, internalNotes: $internalNotes, createdAt: $createdAt, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class $OrderRequestCopyWith<$Res>  {
  factory $OrderRequestCopyWith(OrderRequest value, $Res Function(OrderRequest) _then) = _$OrderRequestCopyWithImpl;
@useResult
$Res call({
 String id,@JsonKey(name: 'shop_slug') String shopSlug,@JsonKey(name: 'customer_name') String customerName,@JsonKey(name: 'customer_contact') String customerContact, List<OrderItem> items,@NumDoubleConverter()@JsonKey(name: 'total_amount') double totalAmount,@JsonKey(name: 'customer_note') String? customerNote, OrderStatus status,@JsonKey(name: 'payment_status') PaymentStatus paymentStatus,@JsonKey(name: 'payment_method') PaymentMethod? paymentMethod,@JsonKey(name: 'internal_notes') String? internalNotes,@JsonKey(name: 'created_at') DateTime createdAt,@JsonKey(name: 'updated_at') DateTime updatedAt
});




}
/// @nodoc
class _$OrderRequestCopyWithImpl<$Res>
    implements $OrderRequestCopyWith<$Res> {
  _$OrderRequestCopyWithImpl(this._self, this._then);

  final OrderRequest _self;
  final $Res Function(OrderRequest) _then;

/// Create a copy of OrderRequest
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? shopSlug = null,Object? customerName = null,Object? customerContact = null,Object? items = null,Object? totalAmount = null,Object? customerNote = freezed,Object? status = null,Object? paymentStatus = null,Object? paymentMethod = freezed,Object? internalNotes = freezed,Object? createdAt = null,Object? updatedAt = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,shopSlug: null == shopSlug ? _self.shopSlug : shopSlug // ignore: cast_nullable_to_non_nullable
as String,customerName: null == customerName ? _self.customerName : customerName // ignore: cast_nullable_to_non_nullable
as String,customerContact: null == customerContact ? _self.customerContact : customerContact // ignore: cast_nullable_to_non_nullable
as String,items: null == items ? _self.items : items // ignore: cast_nullable_to_non_nullable
as List<OrderItem>,totalAmount: null == totalAmount ? _self.totalAmount : totalAmount // ignore: cast_nullable_to_non_nullable
as double,customerNote: freezed == customerNote ? _self.customerNote : customerNote // ignore: cast_nullable_to_non_nullable
as String?,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as OrderStatus,paymentStatus: null == paymentStatus ? _self.paymentStatus : paymentStatus // ignore: cast_nullable_to_non_nullable
as PaymentStatus,paymentMethod: freezed == paymentMethod ? _self.paymentMethod : paymentMethod // ignore: cast_nullable_to_non_nullable
as PaymentMethod?,internalNotes: freezed == internalNotes ? _self.internalNotes : internalNotes // ignore: cast_nullable_to_non_nullable
as String?,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}

}


/// Adds pattern-matching-related methods to [OrderRequest].
extension OrderRequestPatterns on OrderRequest {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _OrderRequest value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _OrderRequest() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _OrderRequest value)  $default,){
final _that = this;
switch (_that) {
case _OrderRequest():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _OrderRequest value)?  $default,){
final _that = this;
switch (_that) {
case _OrderRequest() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id, @JsonKey(name: 'shop_slug')  String shopSlug, @JsonKey(name: 'customer_name')  String customerName, @JsonKey(name: 'customer_contact')  String customerContact,  List<OrderItem> items, @NumDoubleConverter()@JsonKey(name: 'total_amount')  double totalAmount, @JsonKey(name: 'customer_note')  String? customerNote,  OrderStatus status, @JsonKey(name: 'payment_status')  PaymentStatus paymentStatus, @JsonKey(name: 'payment_method')  PaymentMethod? paymentMethod, @JsonKey(name: 'internal_notes')  String? internalNotes, @JsonKey(name: 'created_at')  DateTime createdAt, @JsonKey(name: 'updated_at')  DateTime updatedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _OrderRequest() when $default != null:
return $default(_that.id,_that.shopSlug,_that.customerName,_that.customerContact,_that.items,_that.totalAmount,_that.customerNote,_that.status,_that.paymentStatus,_that.paymentMethod,_that.internalNotes,_that.createdAt,_that.updatedAt);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id, @JsonKey(name: 'shop_slug')  String shopSlug, @JsonKey(name: 'customer_name')  String customerName, @JsonKey(name: 'customer_contact')  String customerContact,  List<OrderItem> items, @NumDoubleConverter()@JsonKey(name: 'total_amount')  double totalAmount, @JsonKey(name: 'customer_note')  String? customerNote,  OrderStatus status, @JsonKey(name: 'payment_status')  PaymentStatus paymentStatus, @JsonKey(name: 'payment_method')  PaymentMethod? paymentMethod, @JsonKey(name: 'internal_notes')  String? internalNotes, @JsonKey(name: 'created_at')  DateTime createdAt, @JsonKey(name: 'updated_at')  DateTime updatedAt)  $default,) {final _that = this;
switch (_that) {
case _OrderRequest():
return $default(_that.id,_that.shopSlug,_that.customerName,_that.customerContact,_that.items,_that.totalAmount,_that.customerNote,_that.status,_that.paymentStatus,_that.paymentMethod,_that.internalNotes,_that.createdAt,_that.updatedAt);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id, @JsonKey(name: 'shop_slug')  String shopSlug, @JsonKey(name: 'customer_name')  String customerName, @JsonKey(name: 'customer_contact')  String customerContact,  List<OrderItem> items, @NumDoubleConverter()@JsonKey(name: 'total_amount')  double totalAmount, @JsonKey(name: 'customer_note')  String? customerNote,  OrderStatus status, @JsonKey(name: 'payment_status')  PaymentStatus paymentStatus, @JsonKey(name: 'payment_method')  PaymentMethod? paymentMethod, @JsonKey(name: 'internal_notes')  String? internalNotes, @JsonKey(name: 'created_at')  DateTime createdAt, @JsonKey(name: 'updated_at')  DateTime updatedAt)?  $default,) {final _that = this;
switch (_that) {
case _OrderRequest() when $default != null:
return $default(_that.id,_that.shopSlug,_that.customerName,_that.customerContact,_that.items,_that.totalAmount,_that.customerNote,_that.status,_that.paymentStatus,_that.paymentMethod,_that.internalNotes,_that.createdAt,_that.updatedAt);case _:
  return null;

}
}

}

/// @nodoc

@JsonSerializable(fieldRename: FieldRename.snake, explicitToJson: true)
class _OrderRequest implements OrderRequest {
  const _OrderRequest({required this.id, @JsonKey(name: 'shop_slug') required this.shopSlug, @JsonKey(name: 'customer_name') required this.customerName, @JsonKey(name: 'customer_contact') required this.customerContact, required final  List<OrderItem> items, @NumDoubleConverter()@JsonKey(name: 'total_amount') required this.totalAmount, @JsonKey(name: 'customer_note') this.customerNote, required this.status, @JsonKey(name: 'payment_status') required this.paymentStatus, @JsonKey(name: 'payment_method') this.paymentMethod, @JsonKey(name: 'internal_notes') this.internalNotes, @JsonKey(name: 'created_at') required this.createdAt, @JsonKey(name: 'updated_at') required this.updatedAt}): _items = items;
  factory _OrderRequest.fromJson(Map<String, dynamic> json) => _$OrderRequestFromJson(json);

@override final  String id;
@override@JsonKey(name: 'shop_slug') final  String shopSlug;
@override@JsonKey(name: 'customer_name') final  String customerName;
@override@JsonKey(name: 'customer_contact') final  String customerContact;
 final  List<OrderItem> _items;
@override List<OrderItem> get items {
  if (_items is EqualUnmodifiableListView) return _items;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_items);
}

@override@NumDoubleConverter()@JsonKey(name: 'total_amount') final  double totalAmount;
@override@JsonKey(name: 'customer_note') final  String? customerNote;
@override final  OrderStatus status;
@override@JsonKey(name: 'payment_status') final  PaymentStatus paymentStatus;
@override@JsonKey(name: 'payment_method') final  PaymentMethod? paymentMethod;
@override@JsonKey(name: 'internal_notes') final  String? internalNotes;
@override@JsonKey(name: 'created_at') final  DateTime createdAt;
@override@JsonKey(name: 'updated_at') final  DateTime updatedAt;

/// Create a copy of OrderRequest
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$OrderRequestCopyWith<_OrderRequest> get copyWith => __$OrderRequestCopyWithImpl<_OrderRequest>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$OrderRequestToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _OrderRequest&&(identical(other.id, id) || other.id == id)&&(identical(other.shopSlug, shopSlug) || other.shopSlug == shopSlug)&&(identical(other.customerName, customerName) || other.customerName == customerName)&&(identical(other.customerContact, customerContact) || other.customerContact == customerContact)&&const DeepCollectionEquality().equals(other._items, _items)&&(identical(other.totalAmount, totalAmount) || other.totalAmount == totalAmount)&&(identical(other.customerNote, customerNote) || other.customerNote == customerNote)&&(identical(other.status, status) || other.status == status)&&(identical(other.paymentStatus, paymentStatus) || other.paymentStatus == paymentStatus)&&(identical(other.paymentMethod, paymentMethod) || other.paymentMethod == paymentMethod)&&(identical(other.internalNotes, internalNotes) || other.internalNotes == internalNotes)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,shopSlug,customerName,customerContact,const DeepCollectionEquality().hash(_items),totalAmount,customerNote,status,paymentStatus,paymentMethod,internalNotes,createdAt,updatedAt);

@override
String toString() {
  return 'OrderRequest(id: $id, shopSlug: $shopSlug, customerName: $customerName, customerContact: $customerContact, items: $items, totalAmount: $totalAmount, customerNote: $customerNote, status: $status, paymentStatus: $paymentStatus, paymentMethod: $paymentMethod, internalNotes: $internalNotes, createdAt: $createdAt, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class _$OrderRequestCopyWith<$Res> implements $OrderRequestCopyWith<$Res> {
  factory _$OrderRequestCopyWith(_OrderRequest value, $Res Function(_OrderRequest) _then) = __$OrderRequestCopyWithImpl;
@override @useResult
$Res call({
 String id,@JsonKey(name: 'shop_slug') String shopSlug,@JsonKey(name: 'customer_name') String customerName,@JsonKey(name: 'customer_contact') String customerContact, List<OrderItem> items,@NumDoubleConverter()@JsonKey(name: 'total_amount') double totalAmount,@JsonKey(name: 'customer_note') String? customerNote, OrderStatus status,@JsonKey(name: 'payment_status') PaymentStatus paymentStatus,@JsonKey(name: 'payment_method') PaymentMethod? paymentMethod,@JsonKey(name: 'internal_notes') String? internalNotes,@JsonKey(name: 'created_at') DateTime createdAt,@JsonKey(name: 'updated_at') DateTime updatedAt
});




}
/// @nodoc
class __$OrderRequestCopyWithImpl<$Res>
    implements _$OrderRequestCopyWith<$Res> {
  __$OrderRequestCopyWithImpl(this._self, this._then);

  final _OrderRequest _self;
  final $Res Function(_OrderRequest) _then;

/// Create a copy of OrderRequest
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? shopSlug = null,Object? customerName = null,Object? customerContact = null,Object? items = null,Object? totalAmount = null,Object? customerNote = freezed,Object? status = null,Object? paymentStatus = null,Object? paymentMethod = freezed,Object? internalNotes = freezed,Object? createdAt = null,Object? updatedAt = null,}) {
  return _then(_OrderRequest(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,shopSlug: null == shopSlug ? _self.shopSlug : shopSlug // ignore: cast_nullable_to_non_nullable
as String,customerName: null == customerName ? _self.customerName : customerName // ignore: cast_nullable_to_non_nullable
as String,customerContact: null == customerContact ? _self.customerContact : customerContact // ignore: cast_nullable_to_non_nullable
as String,items: null == items ? _self._items : items // ignore: cast_nullable_to_non_nullable
as List<OrderItem>,totalAmount: null == totalAmount ? _self.totalAmount : totalAmount // ignore: cast_nullable_to_non_nullable
as double,customerNote: freezed == customerNote ? _self.customerNote : customerNote // ignore: cast_nullable_to_non_nullable
as String?,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as OrderStatus,paymentStatus: null == paymentStatus ? _self.paymentStatus : paymentStatus // ignore: cast_nullable_to_non_nullable
as PaymentStatus,paymentMethod: freezed == paymentMethod ? _self.paymentMethod : paymentMethod // ignore: cast_nullable_to_non_nullable
as PaymentMethod?,internalNotes: freezed == internalNotes ? _self.internalNotes : internalNotes // ignore: cast_nullable_to_non_nullable
as String?,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}


}

// dart format on
