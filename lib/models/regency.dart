// To parse this JSON data, do
//
//     final regency = regencyFromJson(jsonString);

import 'dart:convert';

List<Regency> regencyFromJson(String str) => new List<Regency>.from(json.decode(str).map((x) => Regency.fromJson(x)));

String regencyToJson(List<Regency> data) => json.encode(new List<dynamic>.from(data.map((x) => x.toJson())));

class Regency {
    int id;
    String name;
    String slug;
    int provinceId;
    dynamic createdAt;
    dynamic updatedAt;
    dynamic deletedAt;

    Regency({
        this.id,
        this.name,
        this.slug,
        this.provinceId,
        this.createdAt,
        this.updatedAt,
        this.deletedAt,
    });

    factory Regency.fromJson(Map<String, dynamic> json) => new Regency(
        id: json["id"] == null ? null : json["id"],
        name: json["name"] == null ? null : json["name"],
        slug: json["slug"] == null ? null : json["slug"],
        provinceId: json["province_id"] == null ? null : json["province_id"],
        createdAt: json["created_at"],
        updatedAt: json["updated_at"],
        deletedAt: json["deleted_at"],
    );

    Map<String, dynamic> toJson() => {
        "id": id == null ? null : id,
        "name": name == null ? null : name,
        "slug": slug == null ? null : slug,
        "province_id": provinceId == null ? null : provinceId,
        "created_at": createdAt,
        "updated_at": updatedAt,
        "deleted_at": deletedAt,
    };
}
