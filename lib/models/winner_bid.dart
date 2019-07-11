class WinnerBid {
    int id;
    int auctionId;
    int amount;
    int userId;
    String createdAt;
    String updatedAt;
    dynamic deletedAt;

    WinnerBid({
        this.id,
        this.auctionId,
        this.amount,
        this.userId,
        this.createdAt,
        this.updatedAt,
        this.deletedAt,
    });

    factory WinnerBid.fromJson(Map<String, dynamic> json) => new WinnerBid(
        id: json["id"] == null ? null : json["id"],
        auctionId: json["auction_id"] == null ? null : json["auction_id"],
        amount: json["amount"] == null ? null : json["amount"],
        userId: json["user_id"] == null ? null : json["user_id"],
        createdAt: json["created_at"] == null ? null : json["created_at"],
        updatedAt: json["updated_at"] == null ? null : json["updated_at"],
        deletedAt: json["deleted_at"],
    );

    Map<String, dynamic> toJson() => {
        "id": id == null ? null : id,
        "auction_id": auctionId == null ? null : auctionId,
        "amount": amount == null ? null : amount,
        "user_id": userId == null ? null : userId,
        "created_at": createdAt == null ? null : createdAt,
        "updated_at": updatedAt == null ? null : updatedAt,
        "deleted_at": deletedAt,
    };
}