// To parse this JSON data, do
//
//     final article = articleFromJson(jsonString);

import 'dart:convert';

List<Article> articleFromJson(String str) => new List<Article>.from(json.decode(str).map((x) => Article.fromJson(x)));

String articleToJson(List<Article> data) => json.encode(new List<dynamic>.from(data.map((x) => x.toJson())));

class Article {
    int id;
    String link;
    String description;
    String type;
    String startDate;
    String endDate;
    int order;
    int adminUserId;
    dynamic createdAt;
    dynamic updatedAt;
    dynamic deletedAt;

    Article({
        this.id,
        this.link,
        this.description,
        this.type,
        this.startDate,
        this.endDate,
        this.order,
        this.adminUserId,
        this.createdAt,
        this.updatedAt,
        this.deletedAt,
    });

    factory Article.fromJson(Map<String, dynamic> json) => new Article(
        id: json["id"] == null ? null : json["id"],
        link: json["link"] == null ? null : json["link"],
        description: json["description"] == null ? null : json["description"],
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
        "description": description == null ? null : description,
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
