// To parse this JSON data, do
//
//     final animal = animalFromJson(jsonString);

import 'dart:convert';

import 'package:jlf_mobile/models/auction.dart';

List<Animal> animalFromJson(String str) => new List<Animal>.from(json.decode(str).map((x) => Animal.fromJson(x)));

String animalToJson(List<Animal> data) => json.encode(new List<dynamic>.from(data.map((x) => x.toJson())));

class Animal {
    int id;
    int animalSubCategoryId;
    String name;
    String gender;
    String description;
    String dateOfBirth;
    int regencyId;
    int ownerUserId;
    String slug;
    String createdAt;
    String updatedAt;
    dynamic deletedAt;
    Auction auction;

    Animal({
        this.id,
        this.animalSubCategoryId,
        this.name,
        this.gender,
        this.description,
        this.dateOfBirth,
        this.regencyId,
        this.ownerUserId,
        this.slug,
        this.createdAt,
        this.updatedAt,
        this.deletedAt,
        this.auction,
    });

    factory Animal.fromJson(Map<String, dynamic> json) => new Animal(
        id: json["id"] == null ? null : json["id"],
        animalSubCategoryId: json["animal_sub_category_id"] == null ? null : json["animal_sub_category_id"],
        name: json["name"] == null ? null : json["name"],
        gender: json["gender"] == null ? null : json["gender"],
        description: json["description"] == null ? null : json["description"],
        dateOfBirth: json["date_of_birth"] == null ? null : json["date_of_birth"],
        regencyId: json["regency_id"] == null ? null : json["regency_id"],
        ownerUserId: json["owner_user_id"] == null ? null : json["owner_user_id"],
        slug: json["slug"] == null ? null : json["slug"],
        createdAt: json["created_at"] == null ? null : json["created_at"],
        updatedAt: json["updated_at"] == null ? null : json["updated_at"],
        deletedAt: json["deleted_at"],
        auction: json["auction"] == null ? null : Auction.fromJson(json["auction"]),
    );

    Map<String, dynamic> toJson() => {
        "id": id == null ? null : id,
        "animal_sub_category_id": animalSubCategoryId == null ? null : animalSubCategoryId,
        "name": name == null ? null : name,
        "gender": gender == null ? null : gender,
        "description": description == null ? null : description,
        "date_of_birth": dateOfBirth == null ? null : dateOfBirth,
        "regency_id": regencyId == null ? null : regencyId,
        "owner_user_id": ownerUserId == null ? null : ownerUserId,
        "slug": slug == null ? null : slug,
        "created_at": createdAt == null ? null : createdAt,
        "updated_at": updatedAt == null ? null : updatedAt,
        "deleted_at": deletedAt,
        "auction": auction == null ? null : auction.toJson(),
    };
}

