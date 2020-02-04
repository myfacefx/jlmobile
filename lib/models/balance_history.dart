// To parse this JSON data, do
//
//     final pointHistory = pointHistoryFromJson(jsonString);

import 'dart:convert';

List<PointHistory> balanceHistoryFromJson(String str) => List<PointHistory>.from(json.decode(str).map((x) => PointHistory.fromJson(x)));

String balanceHistoryToJson(List<PointHistory> data) => json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class PointHistory {
    int id;
    String information;
    double point;
    int userId;
    String vacc;
    dynamic animalId;
    dynamic type;
    dynamic createdAt;
    dynamic updatedAt;
    dynamic deletedAt;

    PointHistory({
        this.id,
        this.vacc,
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
        vacc: json["virtualacc"] == null ? null : json["virtualacc"],
      
      
        information: json["status"] == null ? null : json["status"]
      ,
       
        point: json["balances"] == null ? null : double.parse(json["balances"].toString()),
        userId: json["user_id"] == null ? null : json["user_id"],
        animalId: json["animal_id"],
       type: json["type"],
        createdAt: json["transDt"],
       updatedAt: json["updated_at"],
       deletedAt: json["deleted_at"],
    );

    Map<String, dynamic> toJson() => {
        "payMethod": id == null ? null : id,
         "virtualacc": vacc == null ? null : vacc,
        "status": information == null ? null : information,
        "balances": point == null ? null : point,
       "user_id": userId == null ? null : userId,
        "animal_id": animalId,
       "type": type,
        "transDt": createdAt,
       "updated_at": updatedAt,
        "deleted_at": deletedAt,
    }..removeWhere( (key, val) => val == null);
}