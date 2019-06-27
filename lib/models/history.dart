// To parse this JSON data, do
//
//     final history = historyFromJson(jsonString);

import 'dart:convert';

List<History> historyFromJson(String str) => new List<History>.from(json.decode(str).map((x) => History.fromJson(x)));

String historyToJson(List<History> data) => json.encode(new List<dynamic>.from(data.map((x) => x.toJson())));

class History {
    int id;
    int userId;
    String information;
    int read;
    DateTime createdAt;
    DateTime updatedAt;
    dynamic deletedAt;

    History({
        this.id,
        this.userId,
        this.information,
        this.read,
        this.createdAt,
        this.updatedAt,
        this.deletedAt,
    });

    factory History.fromJson(Map<String, dynamic> json) => new History(
        id: json["id"] == null ? null : json["id"],
        userId: json["user_id"] == null ? null : json["user_id"],
        information: json["information"] == null ? null : json["information"],
        read: json["read"] == null ? null : json["read"],
        createdAt: json["created_at"] == null ? null : DateTime.parse(json["created_at"]),
        updatedAt: json["updated_at"] == null ? null : DateTime.parse(json["updated_at"]),
        deletedAt: json["deleted_at"],
    );

    Map<String, dynamic> toJson() => {
        "id": id == null ? null : id,
        "user_id": userId == null ? null : userId,
        "information": information == null ? null : information,
        "read": read == null ? null : read,
        "created_at": createdAt == null ? null : createdAt.toIso8601String(),
        "updated_at": updatedAt == null ? null : updatedAt.toIso8601String(),
        "deleted_at": deletedAt,
    };
}
