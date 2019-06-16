// To parse this JSON data, do
//
//     final user = userFromJson(jsonString);

import 'dart:convert';

User userFromJson(String str) => User.fromJson(json.decode(str));

List<User> listUserFromJson(String str) => new List<User>.from(json.decode(str).map((x) => User.fromJson(x)));

String userToJson(User data) => json.encode(data.toJson());


class User {
    int id;
    String name;
    String username;
    String email;
    String phoneNumber;
    String address;
    dynamic createdAt;
    dynamic updatedAt;
    dynamic deletedAt;
    int blacklisted;
    int reportsCount;

    User({
        this.id,
        this.name,
        this.username,
        this.email,
        this.phoneNumber,
        this.address,
        this.createdAt,
        this.updatedAt,
        this.deletedAt,
        this.blacklisted,
        this.reportsCount
    });

    factory User.fromJson(Map<String, dynamic> json) => new User(
        id: json["id"] == null ? null : json["id"],
        name: json["name"] == null ? null : json["name"],
        username: json["username"] == null ? null : json["username"], 
        email: json["email"] == null ? null : json["email"],
        phoneNumber: json["phone_number"] == null ? null : json["phone_number"],
        address: json["address"] == null ? null : json["address"],
        createdAt: json["created_at"] == null ? null : json["created_at"],
        updatedAt: json["updated_at"] == null ? null : json["updated_at"],
        deletedAt: json["deleted_at"] == null ? null : json["deleted_at"],
        blacklisted: json["blacklisted"] == null ? null : json['blacklisted'],
        reportsCount: json["reports_count"] == null ? null : json["reports_count"]
    );

    Map<String, dynamic> toJson() => {
        "id": id == null ? null : id,
        "name": name == null ? null : name,
        "username": username == null ? null : username,
        "email": email == null ? null : email,
        "phone_number": phoneNumber == null ? null : phoneNumber,
        "address": address == null ? null : address,
        "created_at": createdAt,
        "updated_at": updatedAt,
        "deleted_at": deletedAt,
        "blacklisted": blacklisted,
        "reports_count": reportsCount
    };
}
