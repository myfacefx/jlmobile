// To parse this JSON data, do
//
//     final chatListPagination = chatListPaginationFromJson(jsonString);

import 'dart:convert';

import 'package:jlf_mobile/models/auction.dart';

ChatListPagination chatListPaginationFromJson(String str) => ChatListPagination.fromJson(json.decode(str));

String chatListPaginationToJson(ChatListPagination data) => json.encode(data.toJson());

class ChatListPagination {
    int currentPage;
    List<Auction> data;
    String firstPageUrl;
    int from;
    int lastPage;
    // String lastPageUrl;
    // String nextPageUrl;
    String path;
    int perPage;
    // dynamic prevPageUrl;
    int to;
    int total;

    ChatListPagination({
        this.currentPage,
        this.data,
        this.firstPageUrl,
        this.from,
        this.lastPage,
        // this.lastPageUrl,
        // this.nextPageUrl,
        this.path,
        this.perPage,
        // this.prevPageUrl,
        this.to,
        this.total,
    });

    factory ChatListPagination.fromJson(Map<String, dynamic> json) => new ChatListPagination(
        currentPage: json["current_page"] == null ? null : json["current_page"],
        data: json["data"] == null ? null : new List<Auction>.from(json["data"].map((x) => Auction.fromJson(x))),
        firstPageUrl: json["first_page_url"] == null ? null : json["first_page_url"],
        from: json["from"] == null ? null : json["from"],
        lastPage: json["last_page"] == null ? null : json["last_page"],
        // lastPageUrl: json["last_page_url"] == null ? null : json["last_page_url"],
        // nextPageUrl: json["next_page_url"] == null ? null : json["next_page_url"],
        path: json["path"] == null ? null : json["path"],
        perPage: json["per_page"] == null ? null : json["per_page"],
        // prevPageUrl: json["prev_page_url"],
        to: json["to"] == null ? null : json["to"],
        total: json["total"] == null ? null : json["total"],
    );

    Map<String, dynamic> toJson() => {
        "current_page": currentPage == null ? null : currentPage,
        // "data": data == null ? null : new List<dynamic>.from(data.map((x) => x.toJson())),
        "first_page_url": firstPageUrl == null ? null : firstPageUrl,
        "from": from == null ? null : from,
        "last_page": lastPage == null ? null : lastPage,
        // "last_page_url": lastPageUrl == null ? null : lastPageUrl,
        // "next_page_url": nextPageUrl == null ? null : nextPageUrl,
        "path": path == null ? null : path,
        "per_page": perPage == null ? null : perPage,
        // "prev_page_url": prevPageUrl,
        "to": to == null ? null : to,
        "total": total == null ? null : total,
    };
}