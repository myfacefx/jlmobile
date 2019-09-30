class AuctionChat {
    String firebaseChatId;
    int sellerUnreadCount;
    int sellerUserId;
    int buyerUnreadCount;
    int buyerUserId;
    int adminUnreadCount;
    int adminUserId;
    DateTime createdAt;
    DateTime updatedAt;
    DateTime deletedAt;
    int auctionId;

    AuctionChat({
        this.firebaseChatId,
        this.sellerUnreadCount,
        this.sellerUserId,
        this.buyerUnreadCount,
        this.buyerUserId,
        this.adminUnreadCount,
        this.adminUserId,
        this.createdAt,
        this.updatedAt,
        this.deletedAt,
        this.auctionId,
    });

    factory AuctionChat.fromJson(Map<String, dynamic> json) => AuctionChat(
        firebaseChatId: json["firebase_chat_id"] == null ? null : json["firebase_chat_id"],
        sellerUnreadCount: json["seller_unread_count"] == null ? null : json["seller_unread_count"],
        sellerUserId: json["seller_user_id"] == null ? null : json["seller_user_id"],
        buyerUnreadCount: json["buyer_unread_count"] == null ? null : json["buyer_unread_count"],
        buyerUserId: json["buyer_user_id"] == null ? null : json["buyer_user_id"],
        adminUnreadCount: json["admin_unread_count"] == null ? null : json["admin_unread_count"],
        adminUserId: json["admin_user_id"] == null ? null : json["admin_user_id"],
        createdAt: json["created_at"] == null ? null : DateTime.parse(json["created_at"]),
        updatedAt: json["updated_at"] == null ? null : DateTime.parse(json["updated_at"]),
        deletedAt: json["deleted_at"] == null ? null : DateTime.parse(json["deleted_at"]),
        auctionId: json["auction_id"] == null ? null : json["auction_id"],
    );

    Map<String, dynamic> toJson() => {
        "firebase_chat_id": firebaseChatId == null ? null : firebaseChatId,
        "seller_unread_count": sellerUnreadCount == null ? null : sellerUnreadCount,
        "seller_user_id": sellerUserId == null ? null : sellerUserId,
        "buyer_unread_count": buyerUnreadCount == null ? null : buyerUnreadCount,
        "buyer_user_id": buyerUserId == null ? null : buyerUserId,
        "admin_unread_count": adminUnreadCount == null ? null : adminUnreadCount,
        "admin_user_id": adminUserId == null ? null : adminUserId,
        "created_at": createdAt == null ? null : createdAt.toIso8601String(),
        "updated_at": updatedAt == null ? null : updatedAt.toIso8601String(),
        "deleted_at": deletedAt == null ? null : deletedAt.toIso8601String(),
        "auction_id": auctionId == null ? null : auctionId,
    };
}