// To parse this JSON data, do
//
//     final animalCategory = animalCategoryFromJson(jsonString);

import 'dart:convert';

List<AnimalCategory> animalCategoryFromJson(String str) => new List<AnimalCategory>.from(json.decode(str).map((x) => AnimalCategory.fromJson(x)));

String animalCategoryToJson(List<AnimalCategory> data) => json.encode(new List<dynamic>.from(data.map((x) => x.toJson())));

class AnimalCategory {
    int id;
    String name;
    String image;
    String thumbnail;
    String slug;
    String createdAt;
    String updatedAt;
    String deletedAt;
    int animalsCount;

    AnimalCategory({
        this.id,
        this.name,
        this.image,
        this.thumbnail,
        this.slug,
        this.createdAt,
        this.updatedAt,
        this.deletedAt,
        this.animalsCount,
    });

    factory AnimalCategory.fromJson(Map<String, dynamic> json) => new AnimalCategory(
        id: json["id"] == null ? null : json["id"],
        name: json["name"] == null ? null : json["name"],
        image: json["image"] == null ? null : json["image"],
        thumbnail: json["thumbnail"] == null ? null : json["thumbnail"],
        slug: json["slug"] == null ? null : json["slug"],
        createdAt: json["created_at"] == null ? null : json["created_at"],
        updatedAt: json["updated_at"] == null ? null : json["updated_at"],
        deletedAt: json["deleted_at"] == null ? null : json["deleted_at"],
        animalsCount: json["animals_count"] == null ? null : json["animals_count"],
    );

    Map<String, dynamic> toJson() => {
        "id": id == null ? null : id,
        "name": name == null ? null : name,
        "image": image == null ? null : image,
        "thumbnail": thumbnail == null ? null : thumbnail,
        "slug": slug == null ? null : slug,
        "created_at": createdAt == null ? null : createdAt,
        "updated_at": updatedAt == null ? null : updatedAt,
        "deleted_at": deletedAt == null ? null : deletedAt,
        "animals_count": animalsCount == null ? null : animalsCount,
    };
}
