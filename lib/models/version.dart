// To parse this JSON data, do
//
//     final version = versionFromJson(jsonString);

import 'dart:convert';

Version versionFromJson(String str) => Version.fromJson(json.decode(str));

String versionToJson(Version data) => json.encode(data.toJson());

class Version {
    bool isUpToDate;
    bool isForceUpdate;
    String url;
    String message;

    Version({
        this.isUpToDate,
        this.isForceUpdate,
        this.url,
        this.message,
    });

    factory Version.fromJson(Map<String, dynamic> json) => new Version(
        isUpToDate: json["is_up_to_date"] == null ? null : json["is_up_to_date"],
        isForceUpdate: json["is_force_update"] == null ? null : json["is_force_update"],
        url: json["url"] == null ? null : json["url"],
        message: json["message"] == null ? null : json["message"],
    );

    Map<String, dynamic> toJson() => {
        "is_up_to_date": isUpToDate == null ? null : isUpToDate,
        "is_force_update": isForceUpdate == null ? null : isForceUpdate,
        "url": url == null ? null : url,
        "message": message == null ? null : message,
    };
}
