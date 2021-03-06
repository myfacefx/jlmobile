// To parse this JSON data, do
//
//     final animal = animalFromJson(jsonString);

import 'dart:convert';

import 'package:jlf_mobile/models/animal_sub_category.dart';
import 'package:jlf_mobile/models/animal_image.dart';
import 'package:jlf_mobile/models/auction.dart';
import 'package:jlf_mobile/models/product.dart';
import 'package:jlf_mobile/models/user.dart';

List<Animal> animalFromJson(String str) => new List<Animal>.from(json.decode(str).map((x) => Animal.fromJson(x)));

// Animal animalFromJson(String str) => Animal.fromJson(json.decode(str));

String animalToJson(Animal data) => json.encode(data.toJson());
String animalListToJson(List<Animal> data) => json.encode(new List<dynamic>.from(data.map((x) => x.toJson())));

class Animal {
    int id;
    int animalSubCategoryId;
    String name;
    String gender;
    String descriptionAnimal;
    String descriptionDelivery;
    String descriptionWarranty;
    String description;
    DateTime dateOfBirth;
    int regencyId;
    int ownerUserId;
    String slug;
    String videoPath;
    DateTime createdAt;
    DateTime updatedAt;
    dynamic deletedAt;
    Auction auction;
    List<AnimalImage> animalImages;
    User owner;
    AnimalSubCategory animalSubCategory;
    Product product;

    Animal({
        this.id,
        this.animalSubCategoryId,
        this.name,
        this.gender,
        this.descriptionAnimal,
        this.descriptionDelivery,
        this.descriptionWarranty,
        this.description,
        this.dateOfBirth,
        this.regencyId,
        this.ownerUserId,
        this.slug,
        this.videoPath,
        this.createdAt,
        this.updatedAt,
        this.deletedAt,
        this.auction,
        this.animalImages,
        this.owner,
        this.animalSubCategory,
        this.product
    });

    factory Animal.fromJson(Map<String, dynamic> json) => new Animal(
        id: json["id"] == null ? null : json["id"],
        animalSubCategoryId: json["animal_sub_category_id"] == null ? null : json["animal_sub_category_id"],
        name: json["name"] == null ? null : json["name"],
        gender: json["gender"] == null ? null : json["gender"],
        descriptionAnimal: json["description_animal"] == null ? null : json["description_animal"],
        descriptionDelivery: json["description_delivery"] == null ? null : json["description_delivery"],
        descriptionWarranty: json["description_warranty"] == null ? null : json["description_warranty"],
        description: json["description"] == null ? null : json["description"],
        dateOfBirth: json["date_of_birth"] == null ? null : DateTime.parse(json["date_of_birth"]),
        regencyId: json["regency_id"] == null ? null : json["regency_id"],
        ownerUserId: json["owner_user_id"] == null ? null : json["owner_user_id"],
        slug: json["slug"] == null ? null : json["slug"],
        videoPath: json["video_path"] == null ? null : json["video_path"],
        createdAt: json["created_at"] == null ? null : DateTime.parse(json["created_at"]),
        updatedAt: json["updated_at"] == null ? null : DateTime.parse(json["updated_at"]),
        deletedAt: json["deleted_at"],
        auction: json["auction"] == null ? null : Auction.fromJson(json["auction"]),
        animalImages: json["animal_images"] == null ? null : new List<AnimalImage>.from(json["animal_images"].map((x) => AnimalImage.fromJson(x))),
        owner: json["owner"] == null ? null : User.fromJson(json["owner"]),
        animalSubCategory: json["animal_sub_category"] == null ? null : AnimalSubCategory.fromJson(json["animal_sub_category"]),
        product: json["product"] == null ? null : Product.fromJson(json["product"]),
    );

    Map<String, dynamic> toJson() => {
        "id": id == null ? null : id,
        "animal_sub_category_id": animalSubCategoryId == null ? null : animalSubCategoryId,
        "name": name == null ? null : name,
        "gender": gender == null ? null : gender,
        "description_animal": descriptionAnimal == null ? null : descriptionAnimal,
        "description_delivery": descriptionDelivery == null ? null : descriptionDelivery,
        "description_warranty": descriptionWarranty == null ? null : descriptionWarranty,
        "description": description == null ? null : description,
        "date_of_birth": dateOfBirth == null ? null : "${dateOfBirth.year.toString().padLeft(4, '0')}-${dateOfBirth.month.toString().padLeft(2, '0')}-${dateOfBirth.day.toString().padLeft(2, '0')}",
        "regency_id": regencyId == null ? null : regencyId,
        "owner_user_id": ownerUserId == null ? null : ownerUserId,
        "slug": slug == null ? null : slug,
        "video_path": videoPath == null ? null : videoPath,
        "created_at": createdAt == null ? null : createdAt.toIso8601String(),
        "updated_at": updatedAt == null ? null : updatedAt.toIso8601String(),
        "deleted_at": deletedAt,
        "auction": auction == null ? null : auction.toJson(),
        "animal_images": animalImages == null ? null : new List<dynamic>.from(animalImages.map((x) => x.toJson())),
        "owner": owner == null ? null : owner.toJson(),
        "animal_sub_category": animalSubCategory == null ? null : animalSubCategory.toJson(),
        "product": product == null ? null : product.toJson(),
    }..removeWhere( (key, val) => val == null);
}