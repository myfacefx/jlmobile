// To parse this JSON data, do
//
//     final pointHistory = pointHistoryFromJson(jsonString);

import 'dart:convert';

List<PointHistory> pointHistoryFromJson(String str) => List<PointHistory>.from(json.decode(str).map((x) => PointHistory.fromJson(x)));

String pointHistoryToJson(List<PointHistory> data) => json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class PointHistory {
    int id;
    String information;
    double point;
    int userId;
    dynamic animalId;
    dynamic type;
    dynamic createdAt;
    dynamic updatedAt;
    dynamic deletedAt;

    PointHistory({
        this.id,
        this.information,
        this.point,
        this.userId,
        this.animalId,
        this.type,
        this.createdAt,
        this.updatedAt,
        this.deletedAt,
    });

    factory PointHistory.fromJson(Map<String, dynamic> json) => PointHistory(
        id: json["id"] == null ? null : json["id"],
        information: json["information"] == null ? null : json["information"],
        point: json["point"] == null ? null : json["point"],
        userId: json["user_id"] == null ? null : json["user_id"],
        animalId: json["animal_id"],
        type: json["type"],
        createdAt: json["created_at"],
        updatedAt: json["updated_at"],
        deletedAt: json["deleted_at"],
    );

    Map<String, dynamic> toJson() => {
        "id": id == null ? null : id,
        "information": information == null ? null : information,
        "point": point == null ? null : point,
        "user_id": userId == null ? null : userId,
        "animal_id": animalId,
        "type": type,
        "created_at": createdAt,
        "updated_at": updatedAt,
        "deleted_at": deletedAt,
    }..removeWhere( (key, val) => val == null);
}