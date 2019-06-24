import 'package:jlf_mobile/models/auction_comment.dart';
import 'package:jlf_mobile/models/bid.dart';

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
        this.ownerUserId
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
    };
}