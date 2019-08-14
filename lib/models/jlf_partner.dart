// To parse this JSON data, do
//
//     final jlfPartner = jlfPartnerFromJson(jsonString);

import 'dart:convert';

List<JlfPartner> jlfPartnerFromJson(String str) => new List<JlfPartner>.from(json.decode(str).map((x) => JlfPartner.fromJson(x)));

String jlfPartnerToJson(List<JlfPartner> data) => json.encode(new List<dynamic>.from(data.map((x) => x.toJson())));

class JlfPartner {
    int id;
    String name;
    String description;
    String image;
    String thumbnail;
    String link;
    int order;
    dynamic deletedAt;
    dynamic createdAt;
    dynamic updatedAt;

    JlfPartner({
        this.id,
        this.name,
        this.description,
        this.image,
        this.thumbnail,
        this.link,
        this.order,
        this.deletedAt,
        this.createdAt,
        this.updatedAt,
    });

    factory JlfPartner.fromJson(Map<String, dynamic> json) => new JlfPartner(
        id: json["id"] == null ? null : json["id"],
        name: json["name"] == null ? null : json["name"],
        description: json["description"] == null ? null : json["description"],
        image: json["image"] == null ? null : json["image"],
        thumbnail: json["thumbnail"] == null ? null : json["thumbnail"],
        link: json["link"] == null ? null : json["link"],
        order: json["order"] == null ? null : json["order"],
        deletedAt: json["deleted_at"],
        createdAt: json["created_at"],
        updatedAt: json["updated_at"],
    );

    Map<String, dynamic> toJson() => {
        "id": id == null ? null : id,
        "name": name == null ? null : name,
        "description": description == null ? null : description,
        "image": image == null ? null : image,
        "thumbnail": thumbnail == null ? null : thumbnail,
        "link": link == null ? null : link,
        "order": order == null ? null : order,
        "deleted_at": deletedAt,
        "created_at": createdAt,
        "updated_at": updatedAt,
    };
}
