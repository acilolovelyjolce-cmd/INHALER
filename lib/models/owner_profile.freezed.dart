// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'owner_profile.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$OwnerProfile {

 String get id;@JsonKey(name: 'shop_name') String get shopName;@JsonKey(name: 'shop_slug') String get shopSlug; String? get bio;@JsonKey(name: 'logo_url') String? get logoUrl;@StringMapConverter()@JsonKey(name: 'contact_info') Map<String, String> get contactInfo;
/// Create a copy of OwnerProfile
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$OwnerProfileCopyWith<OwnerProfile> get copyWith => _$OwnerProfileCopyWithImpl<OwnerProfile>(this as OwnerProfile, _$identity);

  /// Serializes this OwnerProfile to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is OwnerProfile&&(identical(other.id, id) || other.id == id)&&(identical(other.shopName, shopName) || other.shopName == shopName)&&(identical(other.shopSlug, shopSlug) || other.shopSlug == shopSlug)&&(identical(other.bio, bio) || other.bio == bio)&&(identical(other.logoUrl, logoUrl) || other.logoUrl == logoUrl)&&const DeepCollectionEquality().equals(other.contactInfo, contactInfo));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,shopName,shopSlug,bio,logoUrl,const DeepCollectionEquality().hash(contactInfo));

@override
String toString() {
  return 'OwnerProfile(id: $id, shopName: $shopName, shopSlug: $shopSlug, bio: $bio, logoUrl: $logoUrl, contactInfo: $contactInfo)';
}


}

/// @nodoc
abstract mixin class $OwnerProfileCopyWith<$Res>  {
  factory $OwnerProfileCopyWith(OwnerProfile value, $Res Function(OwnerProfile) _then) = _$OwnerProfileCopyWithImpl;
@useResult
$Res call({
 String id,@JsonKey(name: 'shop_name') String shopName,@JsonKey(name: 'shop_slug') String shopSlug, String? bio,@JsonKey(name: 'logo_url') String? logoUrl,@StringMapConverter()@JsonKey(name: 'contact_info') Map<String, String> contactInfo
});




}
/// @nodoc
class _$OwnerProfileCopyWithImpl<$Res>
    implements $OwnerProfileCopyWith<$Res> {
  _$OwnerProfileCopyWithImpl(this._self, this._then);

  final OwnerProfile _self;
  final $Res Function(OwnerProfile) _then;

/// Create a copy of OwnerProfile
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? shopName = null,Object? shopSlug = null,Object? bio = freezed,Object? logoUrl = freezed,Object? contactInfo = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,shopName: null == shopName ? _self.shopName : shopName // ignore: cast_nullable_to_non_nullable
as String,shopSlug: null == shopSlug ? _self.shopSlug : shopSlug // ignore: cast_nullable_to_non_nullable
as String,bio: freezed == bio ? _self.bio : bio // ignore: cast_nullable_to_non_nullable
as String?,logoUrl: freezed == logoUrl ? _self.logoUrl : logoUrl // ignore: cast_nullable_to_non_nullable
as String?,contactInfo: null == contactInfo ? _self.contactInfo : contactInfo // ignore: cast_nullable_to_non_nullable
as Map<String, String>,
  ));
}

}


/// Adds pattern-matching-related methods to [OwnerProfile].
extension OwnerProfilePatterns on OwnerProfile {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _OwnerProfile value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _OwnerProfile() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _OwnerProfile value)  $default,){
final _that = this;
switch (_that) {
case _OwnerProfile():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _OwnerProfile value)?  $default,){
final _that = this;
switch (_that) {
case _OwnerProfile() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id, @JsonKey(name: 'shop_name')  String shopName, @JsonKey(name: 'shop_slug')  String shopSlug,  String? bio, @JsonKey(name: 'logo_url')  String? logoUrl, @StringMapConverter()@JsonKey(name: 'contact_info')  Map<String, String> contactInfo)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _OwnerProfile() when $default != null:
return $default(_that.id,_that.shopName,_that.shopSlug,_that.bio,_that.logoUrl,_that.contactInfo);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id, @JsonKey(name: 'shop_name')  String shopName, @JsonKey(name: 'shop_slug')  String shopSlug,  String? bio, @JsonKey(name: 'logo_url')  String? logoUrl, @StringMapConverter()@JsonKey(name: 'contact_info')  Map<String, String> contactInfo)  $default,) {final _that = this;
switch (_that) {
case _OwnerProfile():
return $default(_that.id,_that.shopName,_that.shopSlug,_that.bio,_that.logoUrl,_that.contactInfo);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id, @JsonKey(name: 'shop_name')  String shopName, @JsonKey(name: 'shop_slug')  String shopSlug,  String? bio, @JsonKey(name: 'logo_url')  String? logoUrl, @StringMapConverter()@JsonKey(name: 'contact_info')  Map<String, String> contactInfo)?  $default,) {final _that = this;
switch (_that) {
case _OwnerProfile() when $default != null:
return $default(_that.id,_that.shopName,_that.shopSlug,_that.bio,_that.logoUrl,_that.contactInfo);case _:
  return null;

}
}

}

/// @nodoc

@JsonSerializable(fieldRename: FieldRename.snake, explicitToJson: true)
class _OwnerProfile implements OwnerProfile {
  const _OwnerProfile({required this.id, @JsonKey(name: 'shop_name') required this.shopName, @JsonKey(name: 'shop_slug') required this.shopSlug, this.bio, @JsonKey(name: 'logo_url') this.logoUrl, @StringMapConverter()@JsonKey(name: 'contact_info') required final  Map<String, String> contactInfo}): _contactInfo = contactInfo;
  factory _OwnerProfile.fromJson(Map<String, dynamic> json) => _$OwnerProfileFromJson(json);

@override final  String id;
@override@JsonKey(name: 'shop_name') final  String shopName;
@override@JsonKey(name: 'shop_slug') final  String shopSlug;
@override final  String? bio;
@override@JsonKey(name: 'logo_url') final  String? logoUrl;
 final  Map<String, String> _contactInfo;
@override@StringMapConverter()@JsonKey(name: 'contact_info') Map<String, String> get contactInfo {
  if (_contactInfo is EqualUnmodifiableMapView) return _contactInfo;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_contactInfo);
}


/// Create a copy of OwnerProfile
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$OwnerProfileCopyWith<_OwnerProfile> get copyWith => __$OwnerProfileCopyWithImpl<_OwnerProfile>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$OwnerProfileToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _OwnerProfile&&(identical(other.id, id) || other.id == id)&&(identical(other.shopName, shopName) || other.shopName == shopName)&&(identical(other.shopSlug, shopSlug) || other.shopSlug == shopSlug)&&(identical(other.bio, bio) || other.bio == bio)&&(identical(other.logoUrl, logoUrl) || other.logoUrl == logoUrl)&&const DeepCollectionEquality().equals(other._contactInfo, _contactInfo));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,shopName,shopSlug,bio,logoUrl,const DeepCollectionEquality().hash(_contactInfo));

@override
String toString() {
  return 'OwnerProfile(id: $id, shopName: $shopName, shopSlug: $shopSlug, bio: $bio, logoUrl: $logoUrl, contactInfo: $contactInfo)';
}


}

/// @nodoc
abstract mixin class _$OwnerProfileCopyWith<$Res> implements $OwnerProfileCopyWith<$Res> {
  factory _$OwnerProfileCopyWith(_OwnerProfile value, $Res Function(_OwnerProfile) _then) = __$OwnerProfileCopyWithImpl;
@override @useResult
$Res call({
 String id,@JsonKey(name: 'shop_name') String shopName,@JsonKey(name: 'shop_slug') String shopSlug, String? bio,@JsonKey(name: 'logo_url') String? logoUrl,@StringMapConverter()@JsonKey(name: 'contact_info') Map<String, String> contactInfo
});




}
/// @nodoc
class __$OwnerProfileCopyWithImpl<$Res>
    implements _$OwnerProfileCopyWith<$Res> {
  __$OwnerProfileCopyWithImpl(this._self, this._then);

  final _OwnerProfile _self;
  final $Res Function(_OwnerProfile) _then;

/// Create a copy of OwnerProfile
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? shopName = null,Object? shopSlug = null,Object? bio = freezed,Object? logoUrl = freezed,Object? contactInfo = null,}) {
  return _then(_OwnerProfile(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,shopName: null == shopName ? _self.shopName : shopName // ignore: cast_nullable_to_non_nullable
as String,shopSlug: null == shopSlug ? _self.shopSlug : shopSlug // ignore: cast_nullable_to_non_nullable
as String,bio: freezed == bio ? _self.bio : bio // ignore: cast_nullable_to_non_nullable
as String?,logoUrl: freezed == logoUrl ? _self.logoUrl : logoUrl // ignore: cast_nullable_to_non_nullable
as String?,contactInfo: null == contactInfo ? _self._contactInfo : contactInfo // ignore: cast_nullable_to_non_nullable
as Map<String, String>,
  ));
}


}

// dart format on
