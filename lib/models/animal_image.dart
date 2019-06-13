class AnimalImage {
    int id;
    int animalId;
    String image;
    String thumbnail;
    dynamic createdAt;
    dynamic updatedAt;
    dynamic deletedAt;

    AnimalImage({
        this.id,
        this.animalId,
        this.image,
        this.thumbnail,
        this.createdAt,
        this.updatedAt,
        this.deletedAt,
    });

    factory AnimalImage.fromJson(Map<String, dynamic> json) => new AnimalImage(
        id: json["id"] == null ? null : json["id"],
        animalId: json["animal_id"] == null ? null : json["animal_id"],
        image: json["image"] == null ? null : json["image"],
        thumbnail: json["thumbnail"] == null ? null : json["thumbnail"],
        createdAt: json["created_at"],
        updatedAt: json["updated_at"],
        deletedAt: json["deleted_at"],
    );

    Map<String, dynamic> toJson() => {
        "id": id == null ? null : id,
        "animal_id": animalId == null ? null : animalId,
        "image": image == null ? null : image,
        "thumbnail": thumbnail == null ? null : thumbnail,
        "created_at": createdAt,
        "updated_at": updatedAt,
        "deleted_at": deletedAt,
    };
}