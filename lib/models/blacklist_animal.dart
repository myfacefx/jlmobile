// To parse this JSON data, do
//
//     final blacklistAnimal = blacklistAnimalFromJson(jsonString);

import 'dart:convert';

List<BlacklistAnimal> blacklistAnimalFromJson(String str) => new List<BlacklistAnimal>.from(json.decode(str).map((x) => BlacklistAnimal.fromJson(x)));

String blacklistAnimalToJson(List<BlacklistAnimal> data) => json.encode(new List<dynamic>.from(data.map((x) => x.toJson())));

class BlacklistAnimal {
    int id;
    String title;
    String slug;
    String image;
    String thumbnail;
    dynamic createdAt;
    dynamic updatedAt;
    dynamic deletedAt;

    BlacklistAnimal({
        this.id,
        this.title,
        this.slug,
        this.image,
        this.thumbnail,
        this.createdAt,
        this.updatedAt,
        this.deletedAt,
    });

    factory BlacklistAnimal.fromJson(Map<String, dynamic> json) => new BlacklistAnimal(
        id: json["id"] == null ? null : json["id"],
        title: json["title"] == null ? null : json["title"],
        slug: json["slug"] == null ? null : json["slug"],
        image: json["image"] == null ? null : json["image"],
        thumbnail: json["thumbnail"] == null ? null : json["thumbnail"],
        createdAt: json["created_at"],
        updatedAt: json["updated_at"],
        deletedAt: json["deleted_at"],
    );

    Map<String, dynamic> toJson() => {
        "id": id == null ? null : id,
        "title": title == null ? null : title,
        "slug": slug == null ? null : slug,
        "image": image == null ? null : image,
        "thumbnail": thumbnail == null ? null : thumbnail,
        "created_at": createdAt,
        "updated_at": updatedAt,
        "deleted_at": deletedAt,
    };
}
