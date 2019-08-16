import 'dart:convert';

import 'package:jlf_mobile/models/user.dart';

List<TopSeller> topSellerFromJson(String str) => new List<TopSeller>.from(json.decode(str).map((x) => TopSeller.fromJson(x)));

String topSellerToJson(List<TopSeller> data) => json.encode(new List<dynamic>.from(data.map((x) => x.toJson())));

class TopSeller {
    int id;
    int userId;
    dynamic deletedAt;
    dynamic createdAt;
    dynamic updatedAt;
    dynamic image;
    dynamic thumbnail;
    int animalSubCategoryId;
    User user;

    TopSeller({
        this.id,
        this.userId,
        this.deletedAt,
        this.createdAt,
        this.updatedAt,
        this.image,
        this.thumbnail,
        this.animalSubCategoryId,
        this.user,
    });

    factory TopSeller.fromJson(Map<String, dynamic> json) => new TopSeller(
        id: json["id"] == null ? null : json["id"],
        userId: json["user_id"] == null ? null : json["user_id"],
        deletedAt: json["deleted_at"],
        createdAt: json["created_at"],
        updatedAt: json["updated_at"],
        image: json["image"],
        thumbnail: json["thumbnail"],
        animalSubCategoryId: json["animal_sub_category_id"] == null ? null : json["animal_sub_category_id"],
        user: json["user"] == null ? null : User.fromJson(json["user"]),
    );

    Map<String, dynamic> toJson() => {
        "id": id == null ? null : id,
        "user_id": userId == null ? null : userId,
        "deleted_at": deletedAt,
        "created_at": createdAt,
        "updated_at": updatedAt,
        "image": image,
        "thumbnail": thumbnail,
        "animal_sub_category_id": animalSubCategoryId == null ? null : animalSubCategoryId,
        "user": user == null ? null : user.toJson(),
    }..removeWhere( (key, val) => val == null);
}
