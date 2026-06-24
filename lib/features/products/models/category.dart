class Category {
  final int categoryId;
  final String categoryName;
  final String description;

  Category({
    required this.categoryId,
    required this.categoryName,
    required this.description,
  });

  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      categoryId: json['categoryID'] ?? json['categoryId'] ?? 0,
      categoryName: json['categoryName'] ?? '',
      description: json['description'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'categoryID': categoryId,
      'categoryName': categoryName,
      'description': description,
    };
  }
}
