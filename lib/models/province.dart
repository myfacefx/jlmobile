// To parse this JSON data, do
//
//     final province = provinceFromJson(jsonString);

import 'dart:convert';

List<Province> provinceFromJson(String str) => new List<Province>.from(json.decode(str).map((x) => Province.fromJson(x)));

String provinceToJson(List<Province> data) => json.encode(new List<dynamic>.from(data.map((x) => x.toJson())));

class Province {
    int id;
    String name;
    String slug;
    dynamic createdAt;
    dynamic updatedAt;
    dynamic deletedAt;

    Province({
        this.id,
        this.name,
        this.slug,
        this.createdAt,
        this.updatedAt,
        this.deletedAt,
    });

    factory Province.fromJson(Map<String, dynamic> json) => new Province(
        id: json["id"] == null ? null : json["id"],
        name: json["name"] == null ? null : json["name"],
        slug: json["slug"] == null ? null : json["slug"],
        createdAt: json["created_at"],
        updatedAt: json["updated_at"],
        deletedAt: json["deleted_at"],
    );

    Map<String, dynamic> toJson() => {
        "id": id == null ? null : id,
        "name": name == null ? null : name,
        "slug": slug == null ? null : slug,
        "created_at": createdAt,
        "updated_at": updatedAt,
        "deleted_at": deletedAt,
    };
}
