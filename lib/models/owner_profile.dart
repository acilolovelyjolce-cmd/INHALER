import 'package:freezed_annotation/freezed_annotation.dart';

import 'converters.dart';

part 'owner_profile.freezed.dart';
part 'owner_profile.g.dart';

@freezed
abstract class OwnerProfile with _$OwnerProfile {
  @JsonSerializable(fieldRename: FieldRename.snake, explicitToJson: true)
  const factory OwnerProfile({
    required String id,
    @JsonKey(name: 'shop_name') required String shopName,
    @JsonKey(name: 'shop_slug') required String shopSlug,
    String? bio,
    @JsonKey(name: 'headline') String? headline,
    @JsonKey(name: 'logo_url') String? logoUrl,
    @JsonKey(name: 'ewallet_qr_url') String? ewalletQrUrl,
    @StringMapConverter() @JsonKey(name: 'contact_info') required Map<String, String> contactInfo,
  }) = _OwnerProfile;

  factory OwnerProfile.fromJson(Map<String, dynamic> json) =>
      _$OwnerProfileFromJson({
        ...json,
        'id': json['id']?.toString() ?? '',
        'shop_name': json['shop_name']?.toString() ?? 'Whimsical',
        'shop_slug': json['shop_slug']?.toString() ?? 'whimsical',
        'contact_info': json['contact_info'] ?? const <String, String>{},
      });
}
