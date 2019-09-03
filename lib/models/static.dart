// To parse this JSON data, do
//
//     final static = staticFromJson(jsonString);

import 'dart:convert';

List<Static> staticFromJson(String str) =>
    new List<Static>.from(json.decode(str).map((x) => Static.fromJson(x)));

String staticToJson(List<Static> data) =>
    json.encode(new List<dynamic>.from(data.map((x) => x.toJson())));

class Static {
  int id;
  String popUpImageUrl;
  String popUpText;
  String version;
  String changeLog;
  String rekBer1;
  String rekBer2;
  String rekBer3;
  String emailCs;
  String noTelpCs;
  String imageUpcoming;
  dynamic deletedAt;
  dynamic createdAt;
  dynamic updatedAt;

  Static(
      {this.id,
      this.popUpImageUrl,
      this.popUpText,
      this.version,
      this.changeLog,
      this.rekBer1,
      this.rekBer2,
      this.rekBer3,
      this.emailCs,
      this.noTelpCs,
      this.deletedAt,
      this.createdAt,
      this.updatedAt,
      this.imageUpcoming});

  factory Static.fromJson(Map<String, dynamic> json) => new Static(
        id: json["id"] == null ? null : json["id"],
        popUpImageUrl:
            json["pop_up_image_url"] == null ? null : json["pop_up_image_url"],
        popUpText: json["pop_up_text"] == null ? null : json["pop_up_text"],
        version: json["version"] == null ? null : json["version"],
        changeLog: json["change_log"] == null ? null : json["change_log"],
        imageUpcoming:
            json["image_upcoming"] == null ? null : json["image_upcoming"],
        rekBer1: json["rek_ber1"] == null ? null : json["rek_ber1"],
        rekBer2: json["rek_ber2"] == null ? null : json["rek_ber2"],
        rekBer3: json["rek_ber3"] == null ? null : json["rek_ber3"],
        emailCs: json["email_cs"] == null ? null : json["email_cs"],
        noTelpCs: json["no_telp_cs"] == null ? null : json["no_telp_cs"],
        deletedAt: json["deleted_at"],
        createdAt: json["created_at"],
        updatedAt: json["updated_at"],
      );

  Map<String, dynamic> toJson() => {
        "id": id == null ? null : id,
        "pop_up_image_url": popUpImageUrl == null ? null : popUpImageUrl,
        "pop_up_text": popUpText == null ? null : popUpText,
        "version": version == null ? null : version,
        "change_log": changeLog == null ? null : changeLog,
        "rek_ber1": rekBer1 == null ? null : rekBer1,
        "rek_ber2": rekBer2 == null ? null : rekBer2,
        "rek_ber3": rekBer3 == null ? null : rekBer3,
        "email_cs": emailCs == null ? null : emailCs,
        "no_telp_cs": noTelpCs == null ? null : noTelpCs,
        "deleted_at": deletedAt,
        "created_at": createdAt,
        "updated_at": updatedAt,
      };
}
