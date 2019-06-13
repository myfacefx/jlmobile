class AnimalSubCategory {
    int id;
    String name;
    String image;
    String thumbnail;
    String slug;
    int animalCategoryId;
    String createdAt;
    String updatedAt;
    dynamic deletedAt;
    int animalsCount;

    AnimalSubCategory({
        this.id,
        this.name,
        this.image,
        this.thumbnail,
        this.slug,
        this.animalCategoryId,
        this.createdAt,
        this.updatedAt,
        this.deletedAt,
        this.animalsCount,
    });

    factory AnimalSubCategory.fromJson(Map<String, dynamic> json) => new AnimalSubCategory(
        id: json["id"] == null ? null : json["id"],
        name: json["name"] == null ? null : json["name"],
        image: json["image"] == null ? null : json["image"],
        thumbnail: json["thumbnail"] == null ? null : json["thumbnail"],
        slug: json["slug"] == null ? null : json["slug"],
        animalCategoryId: json["animal_category_id"] == null ? null : json["animal_category_id"],
        createdAt: json["created_at"] == null ? null : json["created_at"],
        updatedAt: json["updated_at"] == null ? null : json["updated_at"],
        deletedAt: json["deleted_at"],
        animalsCount: json["animals_count"] == null ? null : json["animals_count"],
    );

    Map<String, dynamic> toJson() => {
        "id": id == null ? null : id,
        "name": name == null ? null : name,
        "image": image == null ? null : image,
        "thumbnail": thumbnail == null ? null : thumbnail,
        "slug": slug == null ? null : slug,
        "animal_category_id": animalCategoryId == null ? null : animalCategoryId,
        "created_at": createdAt == null ? null : createdAt,
        "updated_at": updatedAt == null ? null : updatedAt,
        "deleted_at": deletedAt,
        "animals_count": animalsCount == null ? null : animalsCount,
    };
}
