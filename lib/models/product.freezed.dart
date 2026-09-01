// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'product.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$ProductOption {

 String get id; String get name;@NumDoubleConverter() double get price;@JsonKey(name: 'image_url') String? get imageUrl;@IntConverter() int get stock;
/// Create a copy of ProductOption
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ProductOptionCopyWith<ProductOption> get copyWith => _$ProductOptionCopyWithImpl<ProductOption>(this as ProductOption, _$identity);

  /// Serializes this ProductOption to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ProductOption&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.price, price) || other.price == price)&&(identical(other.imageUrl, imageUrl) || other.imageUrl == imageUrl)&&(identical(other.stock, stock) || other.stock == stock));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name,price,imageUrl,stock);

@override
String toString() {
  return 'ProductOption(id: $id, name: $name, price: $price, imageUrl: $imageUrl, stock: $stock)';
}


}

/// @nodoc
abstract mixin class $ProductOptionCopyWith<$Res>  {
  factory $ProductOptionCopyWith(ProductOption value, $Res Function(ProductOption) _then) = _$ProductOptionCopyWithImpl;
@useResult
$Res call({
 String id, String name,@NumDoubleConverter() double price,@JsonKey(name: 'image_url') String? imageUrl,@IntConverter() int stock
});




}
/// @nodoc
class _$ProductOptionCopyWithImpl<$Res>
    implements $ProductOptionCopyWith<$Res> {
  _$ProductOptionCopyWithImpl(this._self, this._then);

  final ProductOption _self;
  final $Res Function(ProductOption) _then;

/// Create a copy of ProductOption
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? name = null,Object? price = null,Object? imageUrl = freezed,Object? stock = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,price: null == price ? _self.price : price // ignore: cast_nullable_to_non_nullable
as double,imageUrl: freezed == imageUrl ? _self.imageUrl : imageUrl // ignore: cast_nullable_to_non_nullable
as String?,stock: null == stock ? _self.stock : stock // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [ProductOption].
extension ProductOptionPatterns on ProductOption {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ProductOption value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ProductOption() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ProductOption value)  $default,){
final _that = this;
switch (_that) {
case _ProductOption():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ProductOption value)?  $default,){
final _that = this;
switch (_that) {
case _ProductOption() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String name, @NumDoubleConverter()  double price, @JsonKey(name: 'image_url')  String? imageUrl, @IntConverter()  int stock)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ProductOption() when $default != null:
return $default(_that.id,_that.name,_that.price,_that.imageUrl,_that.stock);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String name, @NumDoubleConverter()  double price, @JsonKey(name: 'image_url')  String? imageUrl, @IntConverter()  int stock)  $default,) {final _that = this;
switch (_that) {
case _ProductOption():
return $default(_that.id,_that.name,_that.price,_that.imageUrl,_that.stock);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String name, @NumDoubleConverter()  double price, @JsonKey(name: 'image_url')  String? imageUrl, @IntConverter()  int stock)?  $default,) {final _that = this;
switch (_that) {
case _ProductOption() when $default != null:
return $default(_that.id,_that.name,_that.price,_that.imageUrl,_that.stock);case _:
  return null;

}
}

}

/// @nodoc

@JsonSerializable(fieldRename: FieldRename.snake, explicitToJson: true)
class _ProductOption implements ProductOption {
  const _ProductOption({required this.id, required this.name, @NumDoubleConverter() required this.price, @JsonKey(name: 'image_url') this.imageUrl, @IntConverter() this.stock = 0});
  factory _ProductOption.fromJson(Map<String, dynamic> json) => _$ProductOptionFromJson(json);

@override final  String id;
@override final  String name;
@override@NumDoubleConverter() final  double price;
@override@JsonKey(name: 'image_url') final  String? imageUrl;
@override@JsonKey()@IntConverter() final  int stock;

/// Create a copy of ProductOption
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ProductOptionCopyWith<_ProductOption> get copyWith => __$ProductOptionCopyWithImpl<_ProductOption>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ProductOptionToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ProductOption&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.price, price) || other.price == price)&&(identical(other.imageUrl, imageUrl) || other.imageUrl == imageUrl)&&(identical(other.stock, stock) || other.stock == stock));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name,price,imageUrl,stock);

@override
String toString() {
  return 'ProductOption(id: $id, name: $name, price: $price, imageUrl: $imageUrl, stock: $stock)';
}


}

/// @nodoc
abstract mixin class _$ProductOptionCopyWith<$Res> implements $ProductOptionCopyWith<$Res> {
  factory _$ProductOptionCopyWith(_ProductOption value, $Res Function(_ProductOption) _then) = __$ProductOptionCopyWithImpl;
@override @useResult
$Res call({
 String id, String name,@NumDoubleConverter() double price,@JsonKey(name: 'image_url') String? imageUrl,@IntConverter() int stock
});




}
/// @nodoc
class __$ProductOptionCopyWithImpl<$Res>
    implements _$ProductOptionCopyWith<$Res> {
  __$ProductOptionCopyWithImpl(this._self, this._then);

  final _ProductOption _self;
  final $Res Function(_ProductOption) _then;

/// Create a copy of ProductOption
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? name = null,Object? price = null,Object? imageUrl = freezed,Object? stock = null,}) {
  return _then(_ProductOption(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,price: null == price ? _self.price : price // ignore: cast_nullable_to_non_nullable
as double,imageUrl: freezed == imageUrl ? _self.imageUrl : imageUrl // ignore: cast_nullable_to_non_nullable
as String?,stock: null == stock ? _self.stock : stock // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}


/// @nodoc
mixin _$Product {

 String get id;@JsonKey(name: 'owner_id') String? get ownerId; String get name; String get description;@NumDoubleConverter() double get price;@NullableNumDoubleConverter()@JsonKey(name: 'compare_at_price') double? get compareAtPrice;@StringListConverter()@JsonKey(name: 'image_urls') List<String> get imageUrls; String get category;@ProductOptionListConverter() List<ProductOption> get paracords;@ProductOptionListConverter() List<ProductOption> get trinkets;@JsonKey(name: 'stock_status') StockStatus get stockStatus;@JsonKey(name: 'is_published') bool get isPublished;@JsonKey(name: 'sort_order') int get sortOrder;@JsonKey(name: 'created_at') DateTime get createdAt;@JsonKey(name: 'updated_at') DateTime get updatedAt;
/// Create a copy of Product
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ProductCopyWith<Product> get copyWith => _$ProductCopyWithImpl<Product>(this as Product, _$identity);

  /// Serializes this Product to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Product&&(identical(other.id, id) || other.id == id)&&(identical(other.ownerId, ownerId) || other.ownerId == ownerId)&&(identical(other.name, name) || other.name == name)&&(identical(other.description, description) || other.description == description)&&(identical(other.price, price) || other.price == price)&&(identical(other.compareAtPrice, compareAtPrice) || other.compareAtPrice == compareAtPrice)&&const DeepCollectionEquality().equals(other.imageUrls, imageUrls)&&(identical(other.category, category) || other.category == category)&&const DeepCollectionEquality().equals(other.paracords, paracords)&&const DeepCollectionEquality().equals(other.trinkets, trinkets)&&(identical(other.stockStatus, stockStatus) || other.stockStatus == stockStatus)&&(identical(other.isPublished, isPublished) || other.isPublished == isPublished)&&(identical(other.sortOrder, sortOrder) || other.sortOrder == sortOrder)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,ownerId,name,description,price,compareAtPrice,const DeepCollectionEquality().hash(imageUrls),category,const DeepCollectionEquality().hash(paracords),const DeepCollectionEquality().hash(trinkets),stockStatus,isPublished,sortOrder,createdAt,updatedAt);

@override
String toString() {
  return 'Product(id: $id, ownerId: $ownerId, name: $name, description: $description, price: $price, compareAtPrice: $compareAtPrice, imageUrls: $imageUrls, category: $category, paracords: $paracords, trinkets: $trinkets, stockStatus: $stockStatus, isPublished: $isPublished, sortOrder: $sortOrder, createdAt: $createdAt, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class $ProductCopyWith<$Res>  {
  factory $ProductCopyWith(Product value, $Res Function(Product) _then) = _$ProductCopyWithImpl;
@useResult
$Res call({
 String id,@JsonKey(name: 'owner_id') String? ownerId, String name, String description,@NumDoubleConverter() double price,@NullableNumDoubleConverter()@JsonKey(name: 'compare_at_price') double? compareAtPrice,@StringListConverter()@JsonKey(name: 'image_urls') List<String> imageUrls, String category,@ProductOptionListConverter() List<ProductOption> paracords,@ProductOptionListConverter() List<ProductOption> trinkets,@JsonKey(name: 'stock_status') StockStatus stockStatus,@JsonKey(name: 'is_published') bool isPublished,@JsonKey(name: 'sort_order') int sortOrder,@JsonKey(name: 'created_at') DateTime createdAt,@JsonKey(name: 'updated_at') DateTime updatedAt
});




}
/// @nodoc
class _$ProductCopyWithImpl<$Res>
    implements $ProductCopyWith<$Res> {
  _$ProductCopyWithImpl(this._self, this._then);

  final Product _self;
  final $Res Function(Product) _then;

/// Create a copy of Product
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? ownerId = freezed,Object? name = null,Object? description = null,Object? price = null,Object? compareAtPrice = freezed,Object? imageUrls = null,Object? category = null,Object? paracords = null,Object? trinkets = null,Object? stockStatus = null,Object? isPublished = null,Object? sortOrder = null,Object? createdAt = null,Object? updatedAt = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,ownerId: freezed == ownerId ? _self.ownerId : ownerId // ignore: cast_nullable_to_non_nullable
as String?,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,description: null == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String,price: null == price ? _self.price : price // ignore: cast_nullable_to_non_nullable
as double,compareAtPrice: freezed == compareAtPrice ? _self.compareAtPrice : compareAtPrice // ignore: cast_nullable_to_non_nullable
as double?,imageUrls: null == imageUrls ? _self.imageUrls : imageUrls // ignore: cast_nullable_to_non_nullable
as List<String>,category: null == category ? _self.category : category // ignore: cast_nullable_to_non_nullable
as String,paracords: null == paracords ? _self.paracords : paracords // ignore: cast_nullable_to_non_nullable
as List<ProductOption>,trinkets: null == trinkets ? _self.trinkets : trinkets // ignore: cast_nullable_to_non_nullable
as List<ProductOption>,stockStatus: null == stockStatus ? _self.stockStatus : stockStatus // ignore: cast_nullable_to_non_nullable
as StockStatus,isPublished: null == isPublished ? _self.isPublished : isPublished // ignore: cast_nullable_to_non_nullable
as bool,sortOrder: null == sortOrder ? _self.sortOrder : sortOrder // ignore: cast_nullable_to_non_nullable
as int,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}

}


/// Adds pattern-matching-related methods to [Product].
extension ProductPatterns on Product {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Product value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Product() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Product value)  $default,){
final _that = this;
switch (_that) {
case _Product():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Product value)?  $default,){
final _that = this;
switch (_that) {
case _Product() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id, @JsonKey(name: 'owner_id')  String? ownerId,  String name,  String description, @NumDoubleConverter()  double price, @NullableNumDoubleConverter()@JsonKey(name: 'compare_at_price')  double? compareAtPrice, @StringListConverter()@JsonKey(name: 'image_urls')  List<String> imageUrls,  String category, @ProductOptionListConverter()  List<ProductOption> paracords, @ProductOptionListConverter()  List<ProductOption> trinkets, @JsonKey(name: 'stock_status')  StockStatus stockStatus, @JsonKey(name: 'is_published')  bool isPublished, @JsonKey(name: 'sort_order')  int sortOrder, @JsonKey(name: 'created_at')  DateTime createdAt, @JsonKey(name: 'updated_at')  DateTime updatedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Product() when $default != null:
return $default(_that.id,_that.ownerId,_that.name,_that.description,_that.price,_that.compareAtPrice,_that.imageUrls,_that.category,_that.paracords,_that.trinkets,_that.stockStatus,_that.isPublished,_that.sortOrder,_that.createdAt,_that.updatedAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id, @JsonKey(name: 'owner_id')  String? ownerId,  String name,  String description, @NumDoubleConverter()  double price, @NullableNumDoubleConverter()@JsonKey(name: 'compare_at_price')  double? compareAtPrice, @StringListConverter()@JsonKey(name: 'image_urls')  List<String> imageUrls,  String category, @ProductOptionListConverter()  List<ProductOption> paracords, @ProductOptionListConverter()  List<ProductOption> trinkets, @JsonKey(name: 'stock_status')  StockStatus stockStatus, @JsonKey(name: 'is_published')  bool isPublished, @JsonKey(name: 'sort_order')  int sortOrder, @JsonKey(name: 'created_at')  DateTime createdAt, @JsonKey(name: 'updated_at')  DateTime updatedAt)  $default,) {final _that = this;
switch (_that) {
case _Product():
return $default(_that.id,_that.ownerId,_that.name,_that.description,_that.price,_that.compareAtPrice,_that.imageUrls,_that.category,_that.paracords,_that.trinkets,_that.stockStatus,_that.isPublished,_that.sortOrder,_that.createdAt,_that.updatedAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id, @JsonKey(name: 'owner_id')  String? ownerId,  String name,  String description, @NumDoubleConverter()  double price, @NullableNumDoubleConverter()@JsonKey(name: 'compare_at_price')  double? compareAtPrice, @StringListConverter()@JsonKey(name: 'image_urls')  List<String> imageUrls,  String category, @ProductOptionListConverter()  List<ProductOption> paracords, @ProductOptionListConverter()  List<ProductOption> trinkets, @JsonKey(name: 'stock_status')  StockStatus stockStatus, @JsonKey(name: 'is_published')  bool isPublished, @JsonKey(name: 'sort_order')  int sortOrder, @JsonKey(name: 'created_at')  DateTime createdAt, @JsonKey(name: 'updated_at')  DateTime updatedAt)?  $default,) {final _that = this;
switch (_that) {
case _Product() when $default != null:
return $default(_that.id,_that.ownerId,_that.name,_that.description,_that.price,_that.compareAtPrice,_that.imageUrls,_that.category,_that.paracords,_that.trinkets,_that.stockStatus,_that.isPublished,_that.sortOrder,_that.createdAt,_that.updatedAt);case _:
  return null;

}
}

}

/// @nodoc

@JsonSerializable(fieldRename: FieldRename.snake, explicitToJson: true)
class _Product implements Product {
  const _Product({required this.id, @JsonKey(name: 'owner_id') this.ownerId, required this.name, required this.description, @NumDoubleConverter() required this.price, @NullableNumDoubleConverter()@JsonKey(name: 'compare_at_price') this.compareAtPrice, @StringListConverter()@JsonKey(name: 'image_urls') required final  List<String> imageUrls, required this.category, @ProductOptionListConverter() final  List<ProductOption> paracords = const [], @ProductOptionListConverter() final  List<ProductOption> trinkets = const [], @JsonKey(name: 'stock_status') required this.stockStatus, @JsonKey(name: 'is_published') required this.isPublished, @JsonKey(name: 'sort_order') required this.sortOrder, @JsonKey(name: 'created_at') required this.createdAt, @JsonKey(name: 'updated_at') required this.updatedAt}): _imageUrls = imageUrls,_paracords = paracords,_trinkets = trinkets;
  factory _Product.fromJson(Map<String, dynamic> json) => _$ProductFromJson(json);

@override final  String id;
@override@JsonKey(name: 'owner_id') final  String? ownerId;
@override final  String name;
@override final  String description;
@override@NumDoubleConverter() final  double price;
@override@NullableNumDoubleConverter()@JsonKey(name: 'compare_at_price') final  double? compareAtPrice;
 final  List<String> _imageUrls;
@override@StringListConverter()@JsonKey(name: 'image_urls') List<String> get imageUrls {
  if (_imageUrls is EqualUnmodifiableListView) return _imageUrls;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_imageUrls);
}

@override final  String category;
 final  List<ProductOption> _paracords;
@override@JsonKey()@ProductOptionListConverter() List<ProductOption> get paracords {
  if (_paracords is EqualUnmodifiableListView) return _paracords;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_paracords);
}

 final  List<ProductOption> _trinkets;
@override@JsonKey()@ProductOptionListConverter() List<ProductOption> get trinkets {
  if (_trinkets is EqualUnmodifiableListView) return _trinkets;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_trinkets);
}

@override@JsonKey(name: 'stock_status') final  StockStatus stockStatus;
@override@JsonKey(name: 'is_published') final  bool isPublished;
@override@JsonKey(name: 'sort_order') final  int sortOrder;
@override@JsonKey(name: 'created_at') final  DateTime createdAt;
@override@JsonKey(name: 'updated_at') final  DateTime updatedAt;

/// Create a copy of Product
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ProductCopyWith<_Product> get copyWith => __$ProductCopyWithImpl<_Product>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ProductToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Product&&(identical(other.id, id) || other.id == id)&&(identical(other.ownerId, ownerId) || other.ownerId == ownerId)&&(identical(other.name, name) || other.name == name)&&(identical(other.description, description) || other.description == description)&&(identical(other.price, price) || other.price == price)&&(identical(other.compareAtPrice, compareAtPrice) || other.compareAtPrice == compareAtPrice)&&const DeepCollectionEquality().equals(other._imageUrls, _imageUrls)&&(identical(other.category, category) || other.category == category)&&const DeepCollectionEquality().equals(other._paracords, _paracords)&&const DeepCollectionEquality().equals(other._trinkets, _trinkets)&&(identical(other.stockStatus, stockStatus) || other.stockStatus == stockStatus)&&(identical(other.isPublished, isPublished) || other.isPublished == isPublished)&&(identical(other.sortOrder, sortOrder) || other.sortOrder == sortOrder)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,ownerId,name,description,price,compareAtPrice,const DeepCollectionEquality().hash(_imageUrls),category,const DeepCollectionEquality().hash(_paracords),const DeepCollectionEquality().hash(_trinkets),stockStatus,isPublished,sortOrder,createdAt,updatedAt);

@override
String toString() {
  return 'Product(id: $id, ownerId: $ownerId, name: $name, description: $description, price: $price, compareAtPrice: $compareAtPrice, imageUrls: $imageUrls, category: $category, paracords: $paracords, trinkets: $trinkets, stockStatus: $stockStatus, isPublished: $isPublished, sortOrder: $sortOrder, createdAt: $createdAt, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class _$ProductCopyWith<$Res> implements $ProductCopyWith<$Res> {
  factory _$ProductCopyWith(_Product value, $Res Function(_Product) _then) = __$ProductCopyWithImpl;
@override @useResult
$Res call({
 String id,@JsonKey(name: 'owner_id') String? ownerId, String name, String description,@NumDoubleConverter() double price,@NullableNumDoubleConverter()@JsonKey(name: 'compare_at_price') double? compareAtPrice,@StringListConverter()@JsonKey(name: 'image_urls') List<String> imageUrls, String category,@ProductOptionListConverter() List<ProductOption> paracords,@ProductOptionListConverter() List<ProductOption> trinkets,@JsonKey(name: 'stock_status') StockStatus stockStatus,@JsonKey(name: 'is_published') bool isPublished,@JsonKey(name: 'sort_order') int sortOrder,@JsonKey(name: 'created_at') DateTime createdAt,@JsonKey(name: 'updated_at') DateTime updatedAt
});




}
/// @nodoc
class __$ProductCopyWithImpl<$Res>
    implements _$ProductCopyWith<$Res> {
  __$ProductCopyWithImpl(this._self, this._then);

  final _Product _self;
  final $Res Function(_Product) _then;

/// Create a copy of Product
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? ownerId = freezed,Object? name = null,Object? description = null,Object? price = null,Object? compareAtPrice = freezed,Object? imageUrls = null,Object? category = null,Object? paracords = null,Object? trinkets = null,Object? stockStatus = null,Object? isPublished = null,Object? sortOrder = null,Object? createdAt = null,Object? updatedAt = null,}) {
  return _then(_Product(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,ownerId: freezed == ownerId ? _self.ownerId : ownerId // ignore: cast_nullable_to_non_nullable
as String?,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,description: null == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String,price: null == price ? _self.price : price // ignore: cast_nullable_to_non_nullable
as double,compareAtPrice: freezed == compareAtPrice ? _self.compareAtPrice : compareAtPrice // ignore: cast_nullable_to_non_nullable
as double?,imageUrls: null == imageUrls ? _self._imageUrls : imageUrls // ignore: cast_nullable_to_non_nullable
as List<String>,category: null == category ? _self.category : category // ignore: cast_nullable_to_non_nullable
as String,paracords: null == paracords ? _self._paracords : paracords // ignore: cast_nullable_to_non_nullable
as List<ProductOption>,trinkets: null == trinkets ? _self._trinkets : trinkets // ignore: cast_nullable_to_non_nullable
as List<ProductOption>,stockStatus: null == stockStatus ? _self.stockStatus : stockStatus // ignore: cast_nullable_to_non_nullable
as StockStatus,isPublished: null == isPublished ? _self.isPublished : isPublished // ignore: cast_nullable_to_non_nullable
as bool,sortOrder: null == sortOrder ? _self.sortOrder : sortOrder // ignore: cast_nullable_to_non_nullable
as int,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}


}

// dart format on
