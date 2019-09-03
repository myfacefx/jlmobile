// To parse this JSON data, do
//
//     final promo = promoFromJson(jsonString);

import 'dart:convert';

List<Promo> promoFromJson(String str) => new List<Promo>.from(json.decode(str).map((x) => Promo.fromJson(x)));

String promoToJson(List<Promo> data) => json.encode(new List<dynamic>.from(data.map((x) => x.toJson())));

class Promo {
    int id;
    String link;
    String name;
    String description;
    String fileName;
    String type;
    String startDate;
    String endDate;
    int order;
    int adminUserId;
    dynamic createdAt;
    dynamic updatedAt;
    dynamic deletedAt;

    Promo({
        this.id,
        this.link,
        this.name,
        this.description,
        this.fileName,
        this.type,
        this.startDate,
        this.endDate,
        this.order,
        this.adminUserId,
        this.createdAt,
        this.updatedAt,
        this.deletedAt,
    });

    factory Promo.fromJson(Map<String, dynamic> json) => new Promo(
        id: json["id"] == null ? null : json["id"],
        link: json["link"] == null ? null : json["link"],
        name: json["name"] == null ? null : json["name"],
        description: json["description"] == null ? null : json["description"],
        fileName: json["file_name"] == null ? null : json["file_name"],
        type: json["type"] == null ? null : json["type"],
        startDate: json["start_date"] == null ? null : json["start_date"],
        endDate: json["end_date"] == null ? null : json["end_date"],
        order: json["order"] == null ? null : json["order"],
        adminUserId: json["admin_user_id"] == null ? null : json["admin_user_id"],
        createdAt: json["created_at"],
        updatedAt: json["updated_at"],
        deletedAt: json["deleted_at"],
    );

    Map<String, dynamic> toJson() => {
        "id": id == null ? null : id,
        "link": link == null ? null : link,
        "name": name == null ? null : name,
        "description": description == null ? null : description,
        "file_name": fileName == null ? null : fileName,
        "type": type == null ? null : type,
        "start_date": startDate == null ? null : startDate,
        "end_date": endDate == null ? null : endDate,
        "order": order == null ? null : order,
        "admin_user_id": adminUserId == null ? null : adminUserId,
        "created_at": createdAt,
        "updated_at": updatedAt,
        "deleted_at": deletedAt,
    };
}
