// To parse this JSON data, do
//
//     final paginate = paginateFromJson(jsonString);

import 'dart:convert';

import 'package:jlf_mobile/models/animal.dart';

Paginate paginateFromJson(String str) => Paginate.fromJson(json.decode(str));

String paginateToJson(Paginate data) => json.encode(data.toJson());

class Paginate {
    int currentPage;
    List<Animal> data;
    String firstPageUrl;
    int from;
    int lastPage;
    String lastPageUrl;
    String nextPageUrl;
    String path;
    int perPage;
    String prevPageUrl;
    int to;
    int total;

    Paginate({
        this.currentPage,
        this.data,
        this.firstPageUrl,
        this.from,
        this.lastPage,
        this.lastPageUrl,
        this.nextPageUrl,
        this.path,
        this.perPage,
        this.prevPageUrl,
        this.to,
        this.total,
    });

    factory Paginate.fromJson(Map<String, dynamic> json) => new Paginate(
        currentPage: json["current_page"] == null ? null : int.parse(json["current_page"].toString()) ,
        data: json["data"] == null ? null : new List<Animal>.from(json["data"].map((x) => Animal.fromJson(x))),
        firstPageUrl: json["first_page_url"] == null ? null : json["first_page_url"],
        from: json["from"] == null ? null : int.parse(json["from"].toString()),
        lastPage: json["last_page"] == null ? null : int.parse(json["last_page"].toString()),
        lastPageUrl: json["last_page_url"] == null ? null : json["last_page_url"],
        nextPageUrl: json["next_page_url"] == null ? null : json["next_page_url"],
        path: json["path"] == null ? null : json["path"],
        perPage: json["per_page"] == null ? null : int.parse(json["per_page"].toString()),
        prevPageUrl: json["prev_page_url"] == null ? null : json["prev_page_url"],
        to: json["to"] == null ? null : int.parse(json["to"].toString()),
        total: json["total"] == null ? null : int.parse(json["total"].toString()),
    );

  

    Map<String, dynamic> toJson() => {
        "current_page": currentPage == null ? null : currentPage,
        "first_page_url": firstPageUrl == null ? null : firstPageUrl,
        "from": from == null ? null : from,
        "last_page": lastPage == null ? null : lastPage,
        "last_page_url": lastPageUrl == null ? null : lastPageUrl,
        "next_page_url": nextPageUrl == null ? null : nextPageUrl,
        "path": path == null ? null : path,
        "per_page": perPage == null ? null : perPage,
        "prev_page_url": prevPageUrl == null ? null : prevPageUrl,
        "to": to == null ? null : to,
        "total": total == null ? null : total,
    };
}
