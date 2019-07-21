// To parse this JSON data, do
//
//     final product = productFromJson(jsonString);

import 'dart:convert';

Product productFromJson(String str) => Product.fromJson(json.decode(str));

String productToJson(Product data) => json.encode(data.toJson());

class Product {
    int id;
    int animalId;
    int price;
    String status;
    int quantity;
    int innerIslandShipping;
    int ownerUserId;
    dynamic createdAt;
    dynamic updatedAt;
    dynamic deletedAt;
    String slug;

    Product({
        this.id,
        this.animalId,
        this.price,
        this.status,
        this.quantity,
        this.innerIslandShipping,
        this.ownerUserId,
        this.createdAt,
        this.updatedAt,
        this.deletedAt,
        this.slug
    });

    factory Product.fromJson(Map<String, dynamic> json) => new Product(
        id: json["id"] == null ? null : json["id"],
        animalId: json["animal_id"] == null ? null : json["animal_id"],
        price: json["price"] == null ? null : json["price"],
        status: json["status"] == null ? null : json["status"],
        quantity: json["quantity"] == null ? null : json["quantity"],
        innerIslandShipping: json["inner_island_shipping"] == null ? null : json["inner_island_shipping"],
        ownerUserId: json["owner_user_id"] == null ? null : json["owner_user_id"],
        createdAt: json["created_at"],
        updatedAt: json["updated_at"],
        deletedAt: json["deleted_at"],
        slug: json["slug"] == null ? null : json["slug"],
    );

    Map<String, dynamic> toJson() => {
        "id": id == null ? null : id,
        "animal_id": animalId == null ? null : animalId,
        "price": price == null ? null : price,
        "status": status == null ? null : status,
        "quantity": quantity == null ? null : quantity,
        "inner_island_shipping": innerIslandShipping == null ? null : innerIslandShipping,
        "owner_user_id": ownerUserId == null ? null : ownerUserId,
        "created_at": createdAt,
        "updated_at": updatedAt,
        "deleted_at": deletedAt,
        "slug": slug == null ? null : slug,
    }..removeWhere( (key, val) => val == null);
}
