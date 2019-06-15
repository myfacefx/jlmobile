
import 'package:jlf_mobile/models/user.dart';

class AuctionComment {
    int id;
    int auctionId;
    String comment;
    int userId;
    String createdAt;
    String updatedAt;
    dynamic deletedAt;
    User user;
    int amount;

    AuctionComment({
        this.id,
        this.auctionId,
        this.comment,
        this.userId,
        this.createdAt,
        this.updatedAt,
        this.deletedAt,
        this.user,
        this.amount,
    });

    factory AuctionComment.fromJson(Map<String, dynamic> json) => new AuctionComment(
        id: json["id"] == null ? null : json["id"],
        auctionId: json["auction_id"] == null ? null : json["auction_id"],
        comment: json["comment"] == null ? null : json["comment"],
        userId: json["user_id"] == null ? null : json["user_id"],
        createdAt: json["created_at"] == null ? null : json["created_at"],
        updatedAt: json["updated_at"] == null ? null : json["updated_at"],
        deletedAt: json["deleted_at"],
        user: json["user"] == null ? null : User.fromJson(json["user"]),
        amount: json["amount"] == null ? null : json["amount"],
    );

    Map<String, dynamic> toJson() => {
        "id": id == null ? null : id,
        "auction_id": auctionId == null ? null : auctionId,
        "comment": comment == null ? null : comment,
        "user_id": userId == null ? null : userId,
        "created_at": createdAt == null ? null : createdAt,
        "updated_at": updatedAt == null ? null : updatedAt,
        "deleted_at": deletedAt,
        "user": user == null ? null : user.toJson(),
        "amount": amount == null ? null : amount,
    };
}