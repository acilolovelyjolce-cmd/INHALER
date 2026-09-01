// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'owner_profile.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_OwnerProfile _$OwnerProfileFromJson(Map<String, dynamic> json) =>
    _OwnerProfile(
      id: json['id'] as String,
      shopName: json['shop_name'] as String,
      shopSlug: json['shop_slug'] as String,
      bio: json['bio'] as String?,
      logoUrl: json['logo_url'] as String?,
      ewalletQrUrl: json['ewallet_qr_url'] as String?,
      contactInfo: const StringMapConverter().fromJson(json['contact_info']),
    );

Map<String, dynamic> _$OwnerProfileToJson(_OwnerProfile instance) =>
    <String, dynamic>{
      'id': instance.id,
      'shop_name': instance.shopName,
      'shop_slug': instance.shopSlug,
      'bio': instance.bio,
      'logo_url': instance.logoUrl,
      'ewallet_qr_url': instance.ewalletQrUrl,
      'contact_info': const StringMapConverter().toJson(instance.contactInfo),
    };
