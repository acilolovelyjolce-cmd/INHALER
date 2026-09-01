import 'package:json_annotation/json_annotation.dart';

class NumDoubleConverter implements JsonConverter<double, dynamic> {
  const NumDoubleConverter();

  @override
  double fromJson(dynamic json) {
    if (json == null) return 0;
    if (json is num) return json.toDouble();
    return double.tryParse(json.toString()) ?? 0;
  }

  @override
  dynamic toJson(double object) => object;
}

class NullableNumDoubleConverter implements JsonConverter<double?, dynamic> {
  const NullableNumDoubleConverter();

  @override
  double? fromJson(dynamic json) {
    if (json == null) return null;
    if (json is num) return json.toDouble();
    return double.tryParse(json.toString());
  }

  @override
  dynamic toJson(double? object) => object;
}

class StringListConverter implements JsonConverter<List<String>, dynamic> {
  const StringListConverter();

  @override
  List<String> fromJson(dynamic json) {
    if (json == null) return const [];
    if (json is List) return json.map((e) => e.toString()).toList();
    return const [];
  }

  @override
  dynamic toJson(List<String> object) => object;
}

class StringMapConverter implements JsonConverter<Map<String, String>, dynamic> {
  const StringMapConverter();

  @override
  Map<String, String> fromJson(dynamic json) {
    if (json is Map) {
      return json.map((key, value) => MapEntry(key.toString(), value?.toString() ?? ''));
    }
    return {};
  }

  @override
  dynamic toJson(Map<String, String> object) => object;
}
