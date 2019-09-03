// To parse this JSON data, do
//
//     final animalSubCategory = animalSubCategoryFromJson(jsonString);

import 'dart:convert';

import 'package:jlf_mobile/models/animal_category.dart';

List<AnimalSubCategory> animalSubCategoryFromJson(String str) => new List<AnimalSubCategory>.from(json.decode(str).map((x) => AnimalSubCategory.fromJson(x)));

String animalSubCategoryToJson(List<AnimalSubCategory> data) => json.encode(new List<dynamic>.from(data.map((x) => x.toJson())));

class AnimalSubCategory {
    int id;
    String name;
    String slug;
    int animalCategoryId;
    dynamic image;
    dynamic thumbnail;
    DateTime createdAt;
    DateTime updatedAt;
    dynamic deletedAt;
    int animalsCount;
    AnimalCategory animalCategory;

    AnimalSubCategory({
        this.id,
        this.name,
        this.slug,
        this.animalCategoryId,
        this.image,
        this.thumbnail,
        this.createdAt,
        this.updatedAt,
        this.deletedAt,
        this.animalsCount,
        this.animalCategory,
    });

    factory AnimalSubCategory.fromJson(Map<String, dynamic> json) => new AnimalSubCategory(
        id: json["id"] == null ? null : json["id"],
        name: json["name"] == null ? null : json["name"],
        slug: json["slug"] == null ? null : json["slug"],
        animalCategoryId: json["animal_category_id"] == null ? null : json["animal_category_id"],
        image: json["image"],
        thumbnail: json["thumbnail"],
        createdAt: json["created_at"] == null ? null : DateTime.parse(json["created_at"]),
        updatedAt: json["updated_at"] == null ? null : DateTime.parse(json["updated_at"]),
        deletedAt: json["deleted_at"],
        animalsCount: json["animals_count"] == null ? null : json["animals_count"],
        animalCategory: json["animal_category"] == null ? null : AnimalCategory.fromJson(json["animal_category"]),
    );

    Map<String, dynamic> toJson() => {
        "id": id == null ? null : id,
        "name": name == null ? null : name,
        "slug": slug == null ? null : slug,
        "animal_category_id": animalCategoryId == null ? null : animalCategoryId,
        "image": image,
        "thumbnail": thumbnail,
        "created_at": createdAt == null ? null : createdAt.toIso8601String(),
        "updated_at": updatedAt == null ? null : updatedAt.toIso8601String(),
        "deleted_at": deletedAt,
        "animals_count": animalsCount == null ? null : animalsCount,
        "animal_category": animalCategory == null ? null : animalCategory.toJson(),
    };
}