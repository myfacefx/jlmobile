// To parse this JSON data, do
//
//     final promoCategory = promoCategoryFromJson(jsonString);

import 'dart:convert';

List<PromoCategory> promoCategoryFromJson(String str) => List<PromoCategory>.from(json.decode(str).map((x) => PromoCategory.fromJson(x)));

String promoCategoryToJson(List<PromoCategory> data) => json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class PromoCategory {
    int id;
    String link;
    String name;
    String description;
    int animalCategoryId;
    String startDate;
    String endDate;
    int order;
    int adminUserId;
    String createdAt;
    String updatedAt;
    dynamic deletedAt;

    PromoCategory({
        this.id,
        this.link,
        this.name,
        this.description,
        this.animalCategoryId,
        this.startDate,
        this.endDate,
        this.order,
        this.adminUserId,
        this.createdAt,
        this.updatedAt,
        this.deletedAt,
    });

    factory PromoCategory.fromJson(Map<String, dynamic> json) => PromoCategory(
        id: json["id"] == null ? null : json["id"],
        link: json["link"] == null ? null : json["link"],
        name: json["name"] == null ? null : json["name"],
        description: json["description"] == null ? null : json["description"],
        animalCategoryId: json["animal_category_id"] == null ? null : json["animal_category_id"],
        startDate: json["start_date"] == null ? null : json["start_date"],
        endDate: json["end_date"] == null ? null : json["end_date"],
        order: json["order"] == null ? null : json["order"],
        adminUserId: json["admin_user_id"] == null ? null : json["admin_user_id"],
        createdAt: json["created_at"] == null ? null : json["created_at"],
        updatedAt: json["updated_at"] == null ? null : json["updated_at"],
        deletedAt: json["deleted_at"],
    );

    Map<String, dynamic> toJson() => {
        "id": id == null ? null : id,
        "link": link == null ? null : link,
        "name": name == null ? null : name,
        "description": description == null ? null : description,
        "animal_category_id": animalCategoryId == null ? null : animalCategoryId,
        "start_date": startDate == null ? null : startDate,
        "end_date": endDate == null ? null : endDate,
        "order": order == null ? null : order,
        "admin_user_id": adminUserId == null ? null : adminUserId,
        "created_at": createdAt == null ? null : createdAt,
        "updated_at": updatedAt == null ? null : updatedAt,
        "deleted_at": deletedAt,
    };
}
