// To parse this JSON data, do
//
//     final animalCategory = animalCategoryFromJson(jsonString);

import 'dart:convert';

import 'package:jlf_mobile/models/animal_sub_category.dart';

List<AnimalCategory> animalCategoryFromJson(String str) => new List<AnimalCategory>.from(json.decode(str).map((x) => AnimalCategory.fromJson(x)));

String animalCategoryToJson(List<AnimalCategory> data) => json.encode(new List<dynamic>.from(data.map((x) => x.toJson())));

AnimalCategory animalObjectCategoryFromJson(String str) {
    final jsonData = json.decode(str);
    return AnimalCategory.fromJson(jsonData);
}

String animalObjectToJson(AnimalCategory data) {
    final dyn = data.toJson();
    return json.encode(dyn);
}

class AnimalCategory {
    int id;
    String name;
    String image;
    dynamic thumbnail;
    String slug;
    String createdAt;
    String updatedAt;
    dynamic deletedAt;
    int animalsCount;
    int isVideoAllowed;
    List<AnimalSubCategory> animalSubCategories;

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
        this.isVideoAllowed,
        this.animalSubCategories,
    });

    factory AnimalCategory.fromJson(Map<String, dynamic> json) => new AnimalCategory(
        id: json["id"] == null ? null : json["id"],
        name: json["name"] == null ? null : json["name"],
        image: json["image"] == null ? null : json["image"],
        thumbnail: json["thumbnail"],
        slug: json["slug"] == null ? null : json["slug"],
        createdAt: json["created_at"] == null ? null : json["created_at"],
        updatedAt: json["updated_at"] == null ? null : json["updated_at"],
        deletedAt: json["deleted_at"],
        animalsCount: json["animals_count"] == null ? null : json["animals_count"],
        isVideoAllowed: json["is_video_allowed"] == null ? null : json["is_video_allowed"],
        animalSubCategories: json["animal_sub_categories"] == null ? null : new List<AnimalSubCategory>.from(json["animal_sub_categories"].map((x) => AnimalSubCategory.fromJson(x))),
    );

    Map<String, dynamic> toJson() => {
        "id": id == null ? null : id,
        "name": name == null ? null : name,
        "image": image == null ? null : image,
        "thumbnail": thumbnail,
        "slug": slug == null ? null : slug,
        "created_at": createdAt == null ? null : createdAt,
        "updated_at": updatedAt == null ? null : updatedAt,
        "deleted_at": deletedAt,
        "animals_count": animalsCount == null ? null : animalsCount,
        "is_video_allowed": isVideoAllowed == null ? null : isVideoAllowed,
        "animal_sub_categories": animalSubCategories == null ? null : new List<dynamic>.from(animalSubCategories.map((x) => x.toJson())),
    }..removeWhere( (key, val) => val == null);
}

