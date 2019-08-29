// To parse this JSON data, do
//
//     final user = userFromJson(jsonString);

import 'dart:convert';

import 'package:jlf_mobile/models/province.dart';
import 'package:jlf_mobile/models/regency.dart';

User userFromJson(String str) => User.fromJson(json.decode(str));

String userToJson(User data) => json.encode(data.toJson());

List<User> listUserFromJson(String str) =>
    new List<User>.from(json.decode(str).map((x) => User.fromJson(x)));

class User {
  int id;
  String name;
  String email;
  dynamic gender;
  String description;
  String username;
  String password;
  String phoneNumber;
  dynamic address;
  String photo;
  int roleId;
  int regencyId;
  int blacklisted;
  dynamic deletedAt;
  DateTime createdAt;
  DateTime updatedAt;
  int reportsCount;
  int bidsCount;
  int historiesCount;
  Role role;
  Regency regency;
  Province province;
  String firebaseToken;
  int statusCode;
  String facebookUserId;
  String identityNumber;
  String verificationStatus;

  User(
      {this.id,
      this.name,
      this.email,
      this.gender,
      this.description,
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
      this.historiesCount,
      this.role,
      this.regency,
      this.province,
      this.firebaseToken,
      this.facebookUserId,
      this.identityNumber,
      this.verificationStatus
      });

  factory User.fromJson(Map<String, dynamic> json) => new User(
        id: json["id"] == null ? null : json["id"],
        name: json["name"] == null ? null : json["name"],
        email: json["email"] == null ? null : json["email"],
        gender: json["gender"],
        description: json["description"] == null ? null : json["description"],
        username: json["username"] == null ? null : json["username"],
        password: json["password"] == null ? null : json["password"],
        phoneNumber: json["phone_number"],
        address: json["address"],
        photo: json["photo"] == null ? null : json['photo'],
        roleId: json["role_id"] == null ? null : json["role_id"],
        regencyId: json["regency_id"] == null ? null : json["regency_id"],
        blacklisted: json["blacklisted"] == null ? null : json["blacklisted"],
        deletedAt: json["deleted_at"],
        createdAt: json["created_at"] == null
            ? null
            : DateTime.parse(json["created_at"]),
        updatedAt: json["updated_at"] == null
            ? null
            : DateTime.parse(json["updated_at"]),
        reportsCount:
            json["reports_count"] == null ? null : json["reports_count"],
        bidsCount: json["bids_count"] == null ? null : json["bids_count"],
        historiesCount:
            json["histories_count"] == null ? null : json["histories_count"],
        role: json["role"] == null ? null : Role.fromJson(json["role"]),
        regency:
            json["regency"] == null ? null : Regency.fromJson(json["regency"]),
        province: json["province"] == null
            ? null
            : Province.fromJson(json["province"]),
        firebaseToken:
            json["firebase_token"] == null ? null : json["firebase_token"],
        facebookUserId:
            json["facebook_user_id"] == null ? null : json["facebook_user_id"],
        identityNumber:
            json["identity_number"] == null ? null : json["identity_number"],
        verificationStatus:
            json["verification_status"] == null ? null : json["verification_status"],
      );

  Map<String, dynamic> toJson() => {
        "id": id == null ? null : id,
        "name": name == null ? null : name,
        "email": email == null ? null : email,
        "gender": gender,
        "description": description == null ? null : description,
        "username": username == null ? null : username,
        "password": password == null ? null : password,
        "phone_number": phoneNumber,
        "address": address,
        "photo": photo == null ? null : photo,
        "role_id": roleId == null ? null : roleId,
        "regency_id": regencyId == null ? null : regencyId,
        "blacklisted": blacklisted == null ? null : blacklisted,
        "deleted_at": deletedAt,
        "created_at": createdAt == null ? null : createdAt.toIso8601String(),
        "updated_at": updatedAt == null ? null : updatedAt.toIso8601String(),
        "reports_count": reportsCount == null ? null : reportsCount,
        "bids_count": bidsCount == null ? null : bidsCount,
        "histories_count": historiesCount == null ? null : historiesCount,
        "role": role == null ? null : role.toJson(),
        "regency": regency == null ? null : regency.toJson(),
        "province": province == null ? null : province.toJson(),
        "firebase_token": firebaseToken == null ? null : firebaseToken,
        "facebook_user_id": facebookUserId == null ? null : facebookUserId,
        "verification_status": verificationStatus == null ? null : verificationStatus,
        "identity_number": identityNumber == null ? null : identityNumber
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
        createdAt: json["created_at"] == null
            ? null
            : DateTime.parse(json["created_at"]),
        updatedAt: json["updated_at"] == null
            ? null
            : DateTime.parse(json["updated_at"]),
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
