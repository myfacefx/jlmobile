// To parse this JSON data, do
//
//     final user = userFromJson(jsonString);

import 'dart:convert';

User userFromJson(String str) => User.fromJson(json.decode(str));

String userToJson(User data) => json.encode(data.toJson());

List<User> listUserFromJson(String str) => new List<User>.from(json.decode(str).map((x) => User.fromJson(x)));

class User {
    int id;
    String name;
    String email;
    dynamic gender;
    String username;
    String password;
    dynamic phoneNumber;
    dynamic address;
    String photo;
    int roleId;
    dynamic regencyId;
    int blacklisted;
    dynamic deletedAt;
    DateTime createdAt;
    DateTime updatedAt;
    int reportsCount;
    int bidsCount;
    Role role;

  int regency_id;

    User({
        this.id,
        this.name,
        this.email,
        this.gender,
        this.username,
        this.password,
        this.phoneNumber,
        this.address,
        this.photo,
        this.roleId,
        this.regencyId,
        this.blacklisted,
        this.deletedAt,
        this.createdAt,
        this.updatedAt,
        this.reportsCount,
        this.bidsCount,
        this.role,
    });

    factory User.fromJson(Map<String, dynamic> json) => new User(
        id: json["id"] == null ? null : json["id"],
        name: json["name"] == null ? null : json["name"],
        email: json["email"] == null ? null : json["email"],
        gender: json["gender"],
        username: json["username"] == null ? null : json["username"],
        password: json["password"] == null ? null : json["password"],
        phoneNumber: json["phone_number"],
        address: json["address"],
        photo: json["photo"] == null ? null : json["photo"],
        roleId: json["role_id"] == null ? null : json["role_id"],
        regencyId: json["regency_id"],
        blacklisted: json["blacklisted"] == null ? null : json["blacklisted"],
        deletedAt: json["deleted_at"],
        createdAt: json["created_at"] == null ? null : DateTime.parse(json["created_at"]),
        updatedAt: json["updated_at"] == null ? null : DateTime.parse(json["updated_at"]),
        reportsCount: json["reports_count"] == null ? null : json["reports_count"],
        bidsCount: json["bids_count"] == null ? null : json["bids_count"],
        role: json["role"] == null ? null : Role.fromJson(json["role"]),
    );

    Map<String, dynamic> toJson() => {
        "id": id == null ? null : id,
        "name": name == null ? null : name,
        "email": email == null ? null : email,
        "gender": gender,
        "username": username == null ? null : username,
        "password": password == null ? null : password,
        "phone_number": phoneNumber,
        "address": address,
        "photo": photo == null ? null : photo,
        "role_id": roleId == null ? null : roleId,
        "regency_id": regencyId,
        "blacklisted": blacklisted == null ? null : blacklisted,
        "deleted_at": deletedAt,
        "created_at": createdAt == null ? null : createdAt.toIso8601String(),
        "updated_at": updatedAt == null ? null : updatedAt.toIso8601String(),
        "reports_count": reportsCount == null ? null : reportsCount,
        "bids_count": bidsCount == null ? null : bidsCount,
        "role": role == null ? null : role.toJson(),
    }..removeWhere((key, val) => val == null);
}

class Role {
    int id;
    String name;
    DateTime createdAt;
    DateTime updatedAt;
    dynamic deletedAt;

    Role({
        this.id,
        this.name,
        this.createdAt,
        this.updatedAt,
        this.deletedAt,
    });

    factory Role.fromJson(Map<String, dynamic> json) => new Role(
        id: json["id"] == null ? null : json["id"],
        name: json["name"] == null ? null : json["name"],
        createdAt: json["created_at"] == null ? null : DateTime.parse(json["created_at"]),
        updatedAt: json["updated_at"] == null ? null : DateTime.parse(json["updated_at"]),
        deletedAt: json["deleted_at"],
    );

    Map<String, dynamic> toJson() => {
        "id": id == null ? null : id,
        "name": name == null ? null : name,
        "created_at": createdAt == null ? null : createdAt.toIso8601String(),
        "updated_at": updatedAt == null ? null : updatedAt.toIso8601String(),
        "deleted_at": deletedAt,
    };
}
