import 'package:jlf_mobile/models/user.dart';

class ProductComment {
    int id;
    int productId;
    String comment;
    int userId;
    dynamic createdAt;
    dynamic updatedAt;
    dynamic deletedAt;
    User user;

    ProductComment({
        this.id,
        this.productId,
        this.comment,
        this.userId,
        this.createdAt,
        this.updatedAt,
        this.deletedAt,
        this.user,
    });

    factory ProductComment.fromJson(Map<String, dynamic> json) => new ProductComment(
        id: json["id"] == null ? null : json["id"],
        productId: json["product_id"] == null ? null : json["product_id"],
        comment: json["comment"] == null ? null : json["comment"],
        userId: json["user_id"] == null ? null : json["user_id"],
        createdAt: json["created_at"],
        updatedAt: json["updated_at"],
        deletedAt: json["deleted_at"],
        user: json["user"] == null ? null : User.fromJson(json["user"]),
    );

    Map<String, dynamic> toJson() => {
        "id": id == null ? null : id,
        "product_id": productId == null ? null : productId,
        "comment": comment == null ? null : comment,
        "user_id": userId == null ? null : userId,
        "created_at": createdAt,
        "updated_at": updatedAt,
        "deleted_at": deletedAt,
        "user": user == null ? null : user.toJson(),
    };
}