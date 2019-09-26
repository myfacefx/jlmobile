import 'package:jlf_mobile/models/auction_comment.dart';
import 'package:jlf_mobile/models/bid.dart';
import 'package:jlf_mobile/models/winner_bid.dart';
import 'package:jlf_mobile/models/user.dart';
import 'package:jlf_mobile/models/animal.dart';
import 'dart:convert';

List<Auction> auctionFromJson(String str) => new List<Auction>.from(json.decode(str).map((x) => Auction.fromJson(x)));

class Auction {
    int id;
    int animalId;
    int openBid;
    int multiply;
    int buyItNow;
    String expiryDate;
    String cancellationImage;
    String cancellationReason;
    String cancellationDate;
    String paymentImage;
    int ownerConfirmation;
    int winnerConfirmation;
    dynamic winnerBidId;
    String winnerAcceptedDate;
    int active;
    String slug;
    String createdAt;
    String updatedAt;
    dynamic deletedAt;
    int countComments;
    int currentBid;
    String lastBid;
    List<AuctionComment> auctionComments;
    List<Bid> bids;
    int ownerUserId;
    int innerIslandShipping;
    int duration;
    WinnerBid winnerBid;
    String verificationCode;
    String firebaseChatId;
    Animal animal;
    User owner;
    User winner;
    dynamic sellerUnreadCount; 
    dynamic sellerUserId;
    dynamic buyerUnreadCount;
    dynamic buyerUserId;
    dynamic adminUnreadCount;
    dynamic adminUserId;
    dynamic adminId;
    AuctionEventParticipant auctionEventParticipant;

    Auction({
        this.id,
        this.animalId,
        this.openBid,
        this.multiply,
        this.buyItNow,
        this.expiryDate,
        this.cancellationImage,
        this.cancellationReason,
        this.cancellationDate,
        this.paymentImage,
        this.ownerConfirmation,
        this.winnerConfirmation,
        this.winnerBidId,
        this.winnerAcceptedDate,
        this.active,
        this.slug,
        this.createdAt,
        this.updatedAt,
        this.deletedAt,
        this.countComments,
        this.currentBid,
        this.auctionComments,
        this.bids,
        this.lastBid,
        this.ownerUserId,
        this.innerIslandShipping,
        this.duration,
        this.winnerBid,
        this.verificationCode,
        this.firebaseChatId,
        this.animal,
        this.owner,
        this.winner,
        this.sellerUnreadCount,
        this.sellerUserId,
        this.buyerUnreadCount,
        this.buyerUserId,
        this.adminUnreadCount,
        this.adminUserId,
        this.adminId,
        this.auctionEventParticipant
    });

    factory Auction.fromJson(Map<String, dynamic> json) => new Auction(
        id: json["id"] == null ? null : json["id"],
        animalId: json["animal_id"] == null ? null : json["animal_id"],
        openBid: json["open_bid"] == null ? null : json["open_bid"],
        multiply: json["multiply"] == null ? null : json["multiply"],
        buyItNow: json["buy_it_now"] == null ? null : json["buy_it_now"],
        expiryDate: json["expiry_date"] == null ? null : json["expiry_date"],
        cancellationImage: json["cancellation_image"] == null ? null : json["cancellation_image"],
        cancellationReason: json["cancellation_reason"] == null ? null : json["cancellation_reason"],
        cancellationDate: json["cancellation_date"] == null ? null : json["cancellation_date"],
        paymentImage: json["payment_image"] == null ? null : json["payment_image"],
        ownerUserId: json["owner_user_id"] == null ? null : json["owner_user_id"],
        ownerConfirmation: json["owner_confirmation"] == null ? null : json["owner_confirmation"],
        winnerConfirmation: json["winner_confirmation"] == null ? null : json["winner_confirmation"],
        winnerBidId: json["winner_bid_id"],
        winnerAcceptedDate: json["winner_accepted_date"] == null ? null : json["winner_accepted_date"],
        active: json["active"] == null ? null : json["active"],
        slug: json["slug"] == null ? null : json["slug"],
        createdAt: json["created_at"] == null ? null : json["created_at"],
        updatedAt: json["updated_at"] == null ? null : json["updated_at"],
        deletedAt: json["deleted_at"],
        countComments: json["count_comments"] == null ? null : json["count_comments"],
        lastBid: json["last_bid"] == null ? null : json["last_bid"],
        currentBid: json["current_bid"] == null ? null : json["current_bid"],
        auctionComments: json["auction_comments"] == null ? null : new List<AuctionComment>.from(json["auction_comments"].map((x) => AuctionComment.fromJson(x))),
        bids: json["bids"] == null ? null : new List<Bid>.from(json["bids"].map((x) => Bid.fromJson(x))),
        innerIslandShipping: json["inner_island_shipping"] == null ? null : json["inner_island_shipping"],
        duration: json["duration"] == null ? null : json["duration"],
        winnerBid: json["winner_bid"] == null ? null : WinnerBid.fromJson(json["winner_bid"]),
        verificationCode: json["verification_code"] == null ? null : json["verification_code"],
        firebaseChatId: json["firebase_chat_id"] == null ? null : json["firebase_chat_id"],
        animal: json["animal"] == null ? null : Animal.fromJson(json["animal"]),
        owner: json["owner"] == null ? null : User.fromJson(json["owner"]),
        winner: json["winner"] == null ? null : User.fromJson(json["winner"]),
        sellerUnreadCount: json["seller_unread_count"] == null ? null : int.parse(json['seller_unread_count'].toString()),  
        sellerUserId: json["seller_user_id"] == null ? null : json['seller_user_id'] is int ? json['seller_user_id'] : int.parse(json['seller_user_id']),
        buyerUnreadCount: json["buyer_unread_count"] == null ? null : json['buyer_unread_count'] is int ? json['buyer_unread_count'] : int.parse(json['buyer_unread_count']),
        buyerUserId: json["buyer_user_id"] == null ? null : json['buyer_user_id'] is int ? json['buyer_user_id'] : int.parse(json['buyer_user_id']), 
        adminUnreadCount: json["admin_unread_count"] == null ? null : json['admin_unread_count'] is int ? json['admin_unread_count'] : int.parse(json['admin_unread_count']), 
        adminUserId: json["admin_user_id"] == null ? null : json['admin_user_id'] is int ? json['admin_user_id'] : int.parse(json['admin_user_id']), 
        adminId: json["admin_id"] == null ? null : json['admin_id'] is int ? json['admin_id'] : int.parse(json['admin_id']), 
        auctionEventParticipant: json["auction_event_participant"] == null ? null : AuctionEventParticipant.fromJson(json["auction_event_participant"]),
    );

    Map<String, dynamic> toJson() => {
        "id": id == null ? null : id,
        "animal_id": animalId == null ? null : animalId,
        "open_bid": openBid == null ? null : openBid,
        "multiply": multiply == null ? null : multiply,
        "buy_it_now": buyItNow == null ? null : buyItNow,
        "expiry_date": expiryDate == null ? null : expiryDate,
        "cancellation_image": cancellationImage == null ? null : cancellationImage,
        "cancellation_reason": cancellationReason == null ? null : cancellationReason,
        "cancellation_date": cancellationDate == null ? null : cancellationDate,
        "payment_image": paymentImage == null ? null : paymentImage,
        "owner_user_id": ownerUserId == null ? null : ownerUserId,
        "owner_confirmation": ownerConfirmation == null ? null : ownerConfirmation,
        "winner_confirmation": winnerConfirmation == null ? null : winnerConfirmation,
        "winner_bid_id": winnerBidId,
        "winner_accepted_date": winnerAcceptedDate == null ? null : winnerAcceptedDate,
        "active": active == null ? null : active,
        "slug": slug == null ? null : slug,
        "created_at": createdAt == null ? null : createdAt,
        "updated_at": updatedAt == null ? null : updatedAt,
        "deleted_at": deletedAt,
        "count_comments": countComments == null ? null : countComments,
        "last_bid": lastBid == null ? null : lastBid,
        "current_bid": currentBid == null ? null : currentBid,
        "auction_comments": auctionComments == null ? null : new List<dynamic>.from(auctionComments.map((x) => x.toJson())),
        "bids": bids == null ? null : new List<dynamic>.from(bids.map((x) => x.toJson())),
        "inner_island_shipping": innerIslandShipping == null ? null : innerIslandShipping,
        "duration": duration == null ? null : duration,
        "winner_bid": winnerBid == null ? null : winnerBid.toJson(),
        "verification_code": verificationCode == null ? null : verificationCode,
        "firebase_chat_id": firebaseChatId == null ? null : firebaseChatId,
        "animal": animal == null ? null : animal.toJson(),
        "owner": owner == null ? null : owner.toJson(),
        "winner": winner == null ? null : winner.toJson(),
        "auction_event_participant": auctionEventParticipant == null ? null : auctionEventParticipant.toJson(),
    }..removeWhere( (key, val) => val == null);
}

class AuctionEventParticipant {
    int id;
    int auctionId;
    int auctionEventId;
    dynamic createdAt;
    dynamic updatedAt;
    dynamic deletedAt;
    AuctionEvent auctionEvent;

    AuctionEventParticipant({
        this.id,
        this.auctionId,
        this.auctionEventId,
        this.createdAt,
        this.updatedAt,
        this.deletedAt,
        this.auctionEvent,
    });

    factory AuctionEventParticipant.fromJson(Map<String, dynamic> json) => AuctionEventParticipant(
        id: json["id"] == null ? null : json["id"],
        auctionId: json["auction_id"] == null ? null : json["auction_id"],
        auctionEventId: json["auction_event_id"] == null ? null : json["auction_event_id"],
        createdAt: json["created_at"],
        updatedAt: json["updated_at"],
        deletedAt: json["deleted_at"],
        auctionEvent: json["auction_event"] == null ? null : AuctionEvent.fromJson(json["auction_event"]),
    );

    Map<String, dynamic> toJson() => {
        "id": id == null ? null : id,
        "auction_id": auctionId == null ? null : auctionId,
        "auction_event_id": auctionEventId == null ? null : auctionEventId,
        "created_at": createdAt,
        "updated_at": updatedAt,
        "deleted_at": deletedAt,
        "auction_event": auctionEvent == null ? null : auctionEvent.toJson(),
    };
}

class AuctionEvent {
    int id;
    String name;
    dynamic startDate;
    dynamic endDate;
    int extraPoint;
    int active;
    dynamic createdAt;
    dynamic updatedAt;
    dynamic deletedAt;

    AuctionEvent({
        this.id,
        this.name,
        this.startDate,
        this.endDate,
        this.extraPoint,
        this.active,
        this.createdAt,
        this.updatedAt,
        this.deletedAt,
    });

    factory AuctionEvent.fromJson(Map<String, dynamic> json) => AuctionEvent(
        id: json["id"] == null ? null : json["id"],
        name: json["name"] == null ? null : json["name"],
        startDate: json["start_date"],
        endDate: json["end_date"],
        extraPoint: json["extra_point"] == null ? null : json["extra_point"],
        active: json["active"] == null ? null : json["active"],
        createdAt: json["created_at"],
        updatedAt: json["updated_at"],
        deletedAt: json["deleted_at"],
    );

    Map<String, dynamic> toJson() => {
        "id": id == null ? null : id,
        "name": name == null ? null : name,
        "start_date": startDate,
        "end_date": endDate,
        "extra_point": extraPoint == null ? null : extraPoint,
        "active": active == null ? null : active,
        "created_at": createdAt,
        "updated_at": updatedAt,
        "deleted_at": deletedAt,
    };
}