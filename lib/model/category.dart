class Category {
  final String? id;
  final String category;

  const Category({this.id, required this.category});

  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      id: json['id']?.toString(),
      category: (json['category'] ?? '').toString(),
    );
  }
}
