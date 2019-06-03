// To parse this JSON data, do
//
//     final animalCategory = animalCategoryFromJson(jsonString);

import 'dart:convert';

List<AnimalCategory> animalCategoryFromJson(String str) => new List<AnimalCategory>.from(json.decode(str).map((x) => AnimalCategory.fromJson(x)));

String animalCategoryToJson(List<AnimalCategory> data) => json.encode(new List<dynamic>.from(data.map((x) => x.toJson())));

class AnimalCategory {
    int id;
    String name;
    String slug;
    int count;
    String createdAt;
    String updatedAt;
    String deletedAt;

    AnimalCategory({
        this.id,
        this.name,
        this.slug,
        this.count,
        this.createdAt,
        this.updatedAt,
        this.deletedAt,
    });

    factory AnimalCategory.fromJson(Map<String, dynamic> json) => new AnimalCategory(
        id: json["id"] == null ? null : json["id"],
        name: json["name"] == null ? null : json["name"],
        slug: json["slug"] == null ? null : json["slug"],
        count: json["count"] == null ? null : json["count"],
        createdAt: json["created_at"] == null ? null : json["created_at"],
        updatedAt: json["updated_at"] == null ? null : json["updated_at"],
        deletedAt: json["deleted_at"] == null ? null : json["deleted_at"],
    );

    Map<String, dynamic> toJson() => {
        "id": id == null ? null : id,
        "name": name == null ? null : name,
        "slug": slug == null ? null : slug,
        "count": count == null ? null : count,
        "created_at": createdAt == null ? null : createdAt,
        "updated_at": updatedAt == null ? null : updatedAt,
        "deleted_at": deletedAt == null ? null : deletedAt,
    };
}
