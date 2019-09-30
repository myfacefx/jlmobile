// To parse this JSON data, do
//
//     final transaction = transactionFromJson(jsonString);

import 'dart:convert';

import 'package:jlf_mobile/models/animal.dart';
import 'package:jlf_mobile/models/user.dart';

Transaction transactionFromJson(String str) => Transaction.fromJson(json.decode(str));

String transactionToJson(Transaction data) => json.encode(data.toJson());

class Transaction {
    int id;
    int animalId;
    String type;
    String invoiceNumber;
    dynamic quantity;
    dynamic expeditionName;
    dynamic guarantee;
    int price;
    dynamic deliveryPrice;
    dynamic servicePrice;
    dynamic sellerBankName;
    dynamic sellerBankAccountNumber;
    dynamic sellerBankAccountName;
    dynamic deliveryDate;
    dynamic receivedDateEstimation;
    dynamic buyerAddress;
    dynamic buyerBankName;
    dynamic buyerBankAccountNumber;
    dynamic buyerBankAccountName;
    int sellerUserId;
    int buyerUserId;
    int adminUserId;
    DateTime createdAt;
    DateTime updatedAt;
    dynamic deletedAt;
    Animal animal;
    User seller;
    User buyer;
    User admin;

    Transaction({
        this.id,
        this.animalId,
        this.type,
        this.invoiceNumber,
        this.quantity,
        this.expeditionName,
        this.guarantee,
        this.price,
        this.deliveryPrice,
        this.servicePrice,
        this.sellerBankName,
        this.sellerBankAccountNumber,
        this.sellerBankAccountName,
        this.deliveryDate,
        this.receivedDateEstimation,
        this.buyerAddress,
        this.buyerBankName,
        this.buyerBankAccountNumber,
        this.buyerBankAccountName,
        this.sellerUserId,
        this.buyerUserId,
        this.adminUserId,
        this.createdAt,
        this.updatedAt,
        this.deletedAt,
        this.animal,
        this.seller,
        this.buyer,
        this.admin,
    });

    factory Transaction.fromJson(Map<String, dynamic> json) => Transaction(
        id: json["id"] == null ? null : json["id"],
        animalId: json["animal_id"] == null ? null : json["animal_id"],
        type: json["type"] == null ? null : json["type"],
        invoiceNumber: json["invoice_number"] == null ? null : json["invoice_number"],
        quantity: json["quantity"],
        expeditionName: json["expedition_name"],
        guarantee: json["guarantee"],
        price: json["price"] == null ? null : json["price"],
        deliveryPrice: json["delivery_price"],
        servicePrice: json["service_price"],
        sellerBankName: json["seller_bank_name"],
        sellerBankAccountNumber: json["seller_bank_account_number"],
        sellerBankAccountName: json["seller_bank_account_name"],
        deliveryDate: json["delivery_date"],
        receivedDateEstimation: json["received_date_estimation"],
        buyerAddress: json["buyer_address"],
        buyerBankName: json["buyer_bank_name"],
        buyerBankAccountNumber: json["buyer_bank_account_number"],
        buyerBankAccountName: json["buyer_bank_account_name"],
        sellerUserId: json["seller_user_id"] == null ? null : json["seller_user_id"],
        buyerUserId: json["buyer_user_id"] == null ? null : json["buyer_user_id"],
        adminUserId: json["admin_user_id"] == null ? null : json["admin_user_id"],
        createdAt: json["created_at"] == null ? null : DateTime.parse(json["created_at"]),
        updatedAt: json["updated_at"] == null ? null : DateTime.parse(json["updated_at"]),
        deletedAt: json["deleted_at"],
        animal: json["animal"] == null ? null : Animal.fromJson(json["animal"]),
        seller: json["seller"] == null ? null : User.fromJson(json["seller"]),
        buyer: json["buyer"] == null ? null : User.fromJson(json["buyer"]),
        admin: json["admin"] == null ? null : User.fromJson(json["admin"]),
    );

    Map<String, dynamic> toJson() => {
        "id": id == null ? null : id,
        "animal_id": animalId == null ? null : animalId,
        "type": type == null ? null : type,
        "invoice_number": invoiceNumber == null ? null : invoiceNumber,
        "quantity": quantity,
        "expedition_name": expeditionName,
        "guarantee": guarantee,
        "price": price == null ? null : price,
        "delivery_price": deliveryPrice,
        "service_price": servicePrice,
        "seller_bank_name": sellerBankName,
        "seller_bank_account_number": sellerBankAccountNumber,
        "seller_bank_account_name": sellerBankAccountName,
        "delivery_date": deliveryDate,
        "received_date_estimation": receivedDateEstimation,
        "buyer_address": buyerAddress,
        "buyer_bank_name": buyerBankName,
        "buyer_bank_account_number": buyerBankAccountNumber,
        "buyer_bank_account_name": buyerBankAccountName,
        "seller_user_id": sellerUserId == null ? null : sellerUserId,
        "buyer_user_id": buyerUserId == null ? null : buyerUserId,
        "admin_user_id": adminUserId == null ? null : adminUserId,
        "created_at": createdAt == null ? null : createdAt.toIso8601String(),
        "updated_at": updatedAt == null ? null : updatedAt.toIso8601String(),
        "deleted_at": deletedAt,
        "animal": animal == null ? null : animal.toJson(),
        "seller": seller == null ? null : seller.toJson(),
        "buyer": buyer == null ? null : buyer.toJson(),
        "admin": admin == null ? null : admin.toJson(),
    }..removeWhere((key, val) => val == null);
}