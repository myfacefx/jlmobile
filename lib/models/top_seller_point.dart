// To parse this JSON data, do
//
//     final topSellerPoint = topSellerPointFromJson(jsonString);

import 'dart:convert';

import 'package:jlf_mobile/models/user.dart';

List<TopSellerPoint> topSellerPointFromJson(String str) => List<TopSellerPoint>.from(json.decode(str).map((x) => TopSellerPoint.fromJson(x)));

String topSellerPointToJson(List<TopSellerPoint> data) => json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class TopSellerPoint {
    int id;
    int userId;
    double point;
    int animalSubCategoryId;
    int animalCategoryId;
    dynamic createdAt;
    dynamic updatedAt;
    dynamic deletedAt;
    User user;

    TopSellerPoint({
        this.id,
        this.userId,
        this.point,
        this.animalSubCategoryId,
        this.animalCategoryId,
        this.createdAt,
        this.updatedAt,
        this.deletedAt,
        this.user,
    });

    factory TopSellerPoint.fromJson(Map<String, dynamic> json) => TopSellerPoint(
        id: json["id"] == null ? null : json["id"],
        userId: json["owner_user_id"] == null ? null : json["owner_user_id"],
        point: json["point"] == null ? null : double.parse(json["point"].toString()),
        animalSubCategoryId: json["animal_sub_category_id"] == null ? null : json["animal_sub_category_id"],
        animalCategoryId: json["animal_category_id"] == null ? null : json["animal_category_id"],
        createdAt: json["created_at"],
        updatedAt: json["updated_at"],
        deletedAt: json["deleted_at"],
        user: json["user"] == null ? null : User.fromJson(json["user"]),
    );

    Map<String, dynamic> toJson() => {
        "id": id == null ? null : id,
        "user_id": userId == null ? null : userId,
        "point": point == null ? null : point,
        "animal_sub_category_id": animalSubCategoryId == null ? null : animalSubCategoryId,
        "animal_category_id": animalCategoryId == null ? null : animalCategoryId,
        "created_at": createdAt,
        "updated_at": updatedAt,
        "deleted_at": deletedAt,
        "user": user == null ? null : user.toJson(),
    };
}
